<?php
require_once 'config/database.php';
require_once 'middleware/auth.php';

class ItineraireController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    public function create() {
        requireAuth();
        $data = json_decode(file_get_contents("php://input"), true);

        // Vérifier que l'utilisateur est membre du groupe
        $stmt = $this->db->prepare("
            SELECT id FROM membres_groupe 
            WHERE utilisateur_id = ? AND groupe_id = ? AND statut = 'accepte'
        ");
        $stmt->execute([$_SESSION['user_id'], $data['groupe_id']]);
        if (!$stmt->fetch()) {
            http_response_code(403);
            echo json_encode(["error" => "Accès refusé."]);
            return;
        }

        // Vérifier si un itinéraire existe déjà
        $stmt = $this->db->prepare("SELECT id FROM itineraires WHERE groupe_id = ?");
        $stmt->execute([$data['groupe_id']]);
        $existing = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($existing) {
            // Mettre à jour
            $stmt = $this->db->prepare("
                UPDATE itineraires 
                SET transport_id = ?, hebergement_id = ?, cout_total = ?, statut = 'brouillon'
                WHERE groupe_id = ?
            ");
            $stmt->execute([
                $data['transport_id']   ?? null,
                $data['hebergement_id'] ?? null,
                $data['cout_total']     ?? 0,
                $data['groupe_id']
            ]);
            $itineraire_id = $existing['id'];
        } else {
            // Créer
            $stmt = $this->db->prepare("
                INSERT INTO itineraires (groupe_id, transport_id, hebergement_id, cout_total, statut)
                VALUES (?, ?, ?, ?, 'brouillon')
            ");
            $stmt->execute([
                $data['groupe_id'],
                $data['transport_id']   ?? null,
                $data['hebergement_id'] ?? null,
                $data['cout_total']     ?? 0,
            ]);
            $itineraire_id = $this->db->lastInsertId();
        }

        // Supprimer les anciennes activités
        $stmt = $this->db->prepare("DELETE FROM itineraire_activites WHERE itineraire_id = ?");
        $stmt->execute([$itineraire_id]);

        // Ajouter les nouvelles activités
        if (!empty($data['activite_ids'])) {
            foreach ($data['activite_ids'] as $activite_id) {
                $stmt = $this->db->prepare("
                    INSERT INTO itineraire_activites (itineraire_id, activite_id)
                    VALUES (?, ?)
                ");
                $stmt->execute([$itineraire_id, $activite_id]);

                // Décrémenter les places restantes
                $stmt = $this->db->prepare("
                    UPDATE activites 
                    SET places_restantes = GREATEST(0, places_restantes - 1)
                    WHERE id = ?
                ");
                $stmt->execute([$activite_id]);
            }
        }

        // Mettre à jour le statut du groupe
        $stmt = $this->db->prepare("
            UPDATE groupes SET statut = 'plan_valide' WHERE id = ?
        ");
        $stmt->execute([$data['groupe_id']]);

        // Notifier tous les membres
        $stmt = $this->db->prepare("
            SELECT utilisateur_id FROM membres_groupe 
            WHERE groupe_id = ? AND statut = 'accepte'
        ");
        $stmt->execute([$data['groupe_id']]);
        $membres = $stmt->fetchAll(PDO::FETCH_COLUMN);

        foreach ($membres as $uid) {
            $stmt = $this->db->prepare("
                INSERT INTO notifications (utilisateur_id, type, message, lien)
                VALUES (?, 'itineraire', ?, ?)
            ");
            $stmt->execute([$uid, "L'itinéraire du groupe a été mis à jour. Total : {$data['cout_total']}€/pers.", "/groupes/{$data['groupe_id']}/itineraire"]);
        }

        http_response_code(201);
        echo json_encode([
            "message"       => "Itinéraire sauvegardé.",
            "itineraire_id" => $itineraire_id
        ]);
    }

    public function annulerTransport($groupe_id) {
        requireAuth();

        $stmt = $this->db->prepare("SELECT id, transport_id FROM itineraires WHERE groupe_id = ?");
        $stmt->execute([$groupe_id]);
        $itin = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$itin) { http_response_code(404); echo json_encode(["error" => "Itinéraire non trouvé."]); return; }

        // Remettre les places du transport
        $stmtMb = $this->db->prepare("SELECT COUNT(*) FROM membres_groupe WHERE groupe_id = ? AND statut = 'accepte'");
        $stmtMb->execute([$groupe_id]);
        $nb_membres = (int)$stmtMb->fetchColumn();
        if ($itin['transport_id']) {
            $this->db->prepare("UPDATE transports SET places_dispo = places_dispo + ? WHERE id = ?")->execute([$nb_membres, $itin['transport_id']]);
        }
        $stmt = $this->db->prepare("
            UPDATE itineraires SET transport_id = NULL, cout_total = GREATEST(0, cout_total - COALESCE(
                (SELECT prix FROM transports WHERE id = ?), 0
            )) WHERE groupe_id = ?
        ");
        $stmt->execute([$itin['transport_id'], $groupe_id]);

        echo json_encode(["message" => "Transport annulé."]);
    }

    public function annulerActivite($groupe_id, $activite_id) {
        requireAuth();

        $stmt = $this->db->prepare("SELECT id FROM itineraires WHERE groupe_id = ?");
        $stmt->execute([$groupe_id]);
        $itin = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$itin) { http_response_code(404); echo json_encode(["error" => "Itinéraire non trouvé."]); return; }

        // Vérifier que l'activité est dans l'itinéraire
        $stmt = $this->db->prepare("SELECT 1 FROM itineraire_activites WHERE itineraire_id = ? AND activite_id = ?");
        $stmt->execute([$itin['id'], $activite_id]);
        if (!$stmt->fetch()) { http_response_code(404); echo json_encode(["error" => "Activité non trouvée dans l'itinéraire."]); return; }

        // Retirer l'activité
        $stmt = $this->db->prepare("DELETE FROM itineraire_activites WHERE itineraire_id = ? AND activite_id = ?");
        $stmt->execute([$itin['id'], $activite_id]);

        // Remettre une place restante
        $stmt = $this->db->prepare("UPDATE activites SET places_restantes = places_restantes + 1 WHERE id = ?");
        $stmt->execute([$activite_id]);

        // Recalculer le coût total
        $stmt = $this->db->prepare("
            SELECT COALESCE(t.prix, 0) + COALESCE(h.prix_nuit, 0) * COALESCE(DATEDIFF(t.date_arrivee, t.date_depart), 0) +
                   COALESCE((SELECT SUM(a.prix) FROM activites a JOIN itineraire_activites ia ON ia.activite_id = a.id WHERE ia.itineraire_id = ?), 0) as total
            FROM itineraires i
            LEFT JOIN transports t ON t.id = i.transport_id
            LEFT JOIN hebergements h ON h.id = i.hebergement_id
            WHERE i.id = ?
        ");
        $stmt->execute([$itin['id'], $itin['id']]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        $stmt = $this->db->prepare("UPDATE itineraires SET cout_total = ? WHERE id = ?");
        $stmt->execute([$row['total'], $itin['id']]);

        echo json_encode(["message" => "Activité retirée de l'itinéraire."]);
    }

    public function supprimer($groupe_id) {
        requireAuth();

        // Vérifier que l'utilisateur est organisateur
        $stmt = $this->db->prepare("SELECT organisateur_id FROM groupes WHERE id = ?");
        $stmt->execute([$groupe_id]);
        $groupe = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$groupe || (int)$groupe['organisateur_id'] !== (int)$_SESSION['user_id']) {
            http_response_code(403);
            echo json_encode(["error" => "Seul l'organisateur peut supprimer l'itinéraire."]);
            return;
        }

        $stmt = $this->db->prepare("SELECT id FROM itineraires WHERE groupe_id = ?");
        $stmt->execute([$groupe_id]);
        $itin = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$itin) { http_response_code(404); echo json_encode(["error" => "Itinéraire non trouvé."]); return; }

        // Remettre les places des activités
        $stmt = $this->db->prepare("SELECT activite_id FROM itineraire_activites WHERE itineraire_id = ?");
        $stmt->execute([$itin['id']]);
        foreach ($stmt->fetchAll(PDO::FETCH_COLUMN) as $aid) {
            $this->db->prepare("UPDATE activites SET places_restantes = places_restantes + 1 WHERE id = ?")->execute([$aid]);
        }

        $this->db->prepare("DELETE FROM itineraire_activites WHERE itineraire_id = ?")->execute([$itin['id']]);
        $this->db->prepare("DELETE FROM itineraires WHERE id = ?")->execute([$itin['id']]);
        $this->db->prepare("UPDATE groupes SET statut = 'vote_en_cours' WHERE id = ?")->execute([$groupe_id]);

        echo json_encode(["message" => "Itinéraire supprimé."]);
    }

    public function annulerHebergement($groupe_id) {
        requireAuth();

        $stmt = $this->db->prepare("SELECT id, hebergement_id FROM itineraires WHERE groupe_id = ?");
        $stmt->execute([$groupe_id]);
        $itin = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$itin) { http_response_code(404); echo json_encode(["error" => "Itinéraire non trouvé."]); return; }

        $stmt = $this->db->prepare("
            UPDATE itineraires SET hebergement_id = NULL,
            cout_total = GREATEST(0, cout_total - COALESCE(
                (SELECT prix_nuit FROM hebergements WHERE id = ?), 0
            )) WHERE groupe_id = ?
        ");
        $stmt->execute([$itin['hebergement_id'], $groupe_id]);

        echo json_encode(["message" => "Hébergement annulé."]);
    }

    public function getByGroupe($groupe_id) {
        requireAuth();

        $stmt = $this->db->prepare("
            SELECT i.*,
                   t.compagnie, t.origine, t.destination as transport_dest, t.prix as transport_prix,
                   t.date_depart as transport_date_depart, t.date_arrivee as transport_date_arrivee,
                   h.nom as heb_nom, h.prix_nuit, h.type as heb_type
            FROM itineraires i
            LEFT JOIN transports   t ON t.id = i.transport_id
            LEFT JOIN hebergements h ON h.id = i.hebergement_id
            WHERE i.groupe_id = ?
        ");
        $stmt->execute([$groupe_id]);
        $itineraire = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$itineraire) {
            http_response_code(404);
            echo json_encode(["error" => "Aucun itinéraire trouvé."]);
            return;
        }

        // Récupérer les activités
        $stmt = $this->db->prepare("
            SELECT a.* FROM activites a
            JOIN itineraire_activites ia ON ia.activite_id = a.id
            WHERE ia.itineraire_id = ?
        ");
        $stmt->execute([$itineraire['id']]);
        $itineraire['activites'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode($itineraire);
    }
}