<?php
require_once 'config/database.php';
require_once 'middleware/auth.php';

class VoteController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    // POST /api/votes — voter
    public function voter() {
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
            echo json_encode(["error" => "Vous n'êtes pas membre de ce groupe."]);
            return;
        }

        try {
            $stmt = $this->db->prepare("
                INSERT INTO votes (utilisateur_id, groupe_id, type, valeur)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE valeur = VALUES(valeur)
            ");
            $stmt->execute([
                $_SESSION['user_id'],
                $data['groupe_id'],
                $data['type'],
                $data['valeur']
            ]);
            echo json_encode(["message" => "Vote enregistré."]);
        } catch (\PDOException $e) {
            http_response_code(500);
            echo json_encode(["error" => "Erreur vote : " . $e->getMessage()]);
        }
    }

    // GET /api/votes?groupe_id=X&type=Y — résultats d'un vote
    public function resultats() {
        requireAuth();
        $groupe_id = $_GET['groupe_id'] ?? null;
        $type      = $_GET['type']      ?? null;

        if (!$groupe_id || !$type) {
            http_response_code(400);
            echo json_encode(["error" => "groupe_id et type requis."]);
            return;
        }

        $stmt = $this->db->prepare("
            SELECT v.valeur, COUNT(*) as nb_votes,
                   GROUP_CONCAT(u.nom SEPARATOR ', ') as votants
            FROM votes v
            JOIN utilisateurs u ON u.id = v.utilisateur_id
            WHERE v.groupe_id = ? AND v.type = ?
            GROUP BY v.valeur
            ORDER BY nb_votes DESC
        ");
        $stmt->execute([$groupe_id, $type]);
        $resultats = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Vote de l'utilisateur connecté
        $stmt = $this->db->prepare("
            SELECT valeur FROM votes 
            WHERE utilisateur_id = ? AND groupe_id = ? AND type = ?
        ");
        $stmt->execute([$_SESSION['user_id'], $groupe_id, $type]);
        $mon_vote = $stmt->fetchColumn();

        // Total membres du groupe
        $stmt = $this->db->prepare("
            SELECT COUNT(*) FROM membres_groupe 
            WHERE groupe_id = ? AND statut = 'accepte'
        ");
        $stmt->execute([$groupe_id]);
        $total_membres = $stmt->fetchColumn();

        echo json_encode([
            "resultats"      => $resultats,
            "mon_vote"       => $mon_vote,
            "total_membres"  => (int)$total_membres
        ]);
    }

    // POST /api/votes/valider — organisateur valide un choix
    public function valider() {
        requireAuth();
        $data = json_decode(file_get_contents("php://input"), true);

        // Vérifier que c'est l'organisateur
        $stmt = $this->db->prepare("
            SELECT id FROM groupes WHERE id = ? AND organisateur_id = ?
        ");
        $stmt->execute([$data['groupe_id'], $_SESSION['user_id']]);
        if (!$stmt->fetch()) {
            http_response_code(403);
            echo json_encode(["error" => "Seul l'organisateur peut valider."]);
            return;
        }

        // Nombre de membres acceptés dans le groupe
        $stmtMb = $this->db->prepare("SELECT COUNT(*) FROM membres_groupe WHERE groupe_id = ? AND statut = 'accepte'");
        $stmtMb->execute([$data['groupe_id']]);
        $nb_membres = (int)$stmtMb->fetchColumn();

        // Mettre à jour le groupe selon le type
        if ($data['type'] === 'destination') {
            $stmt = $this->db->prepare("UPDATE groupes SET destination_id = ? WHERE id = ?");
            $stmt->execute([$data['valeur'], $data['groupe_id']]);

        } elseif ($data['type'] === 'dates') {
            $dates = explode('|', $data['valeur']);
            $stmt  = $this->db->prepare("UPDATE groupes SET date_depart = ?, date_retour = ? WHERE id = ?");
            $stmt->execute([$dates[0], $dates[1], $data['groupe_id']]);

        } elseif ($data['type'] === 'transport') {
            $stmt = $this->db->prepare("SELECT places_dispo FROM transports WHERE id = ?");
            $stmt->execute([$data['valeur']]);
            $t = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!$t || (int)$t['places_dispo'] < $nb_membres) {
                http_response_code(400);
                echo json_encode(["error" => "Ce transport n'a pas assez de places ({$t['places_dispo']} disponibles, {$nb_membres} membres dans le groupe)."]);
                return;
            }
            $itin_id = $this->getOrCreateItineraire($data['groupe_id']);
            $this->db->prepare("UPDATE itineraires SET transport_id = ? WHERE id = ?")->execute([$data['valeur'], $itin_id]);
            $this->recalculerCout($itin_id);

        } elseif ($data['type'] === 'hebergement') {
            $stmt = $this->db->prepare("SELECT capacite FROM hebergements WHERE id = ?");
            $stmt->execute([$data['valeur']]);
            $h = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!$h || (int)$h['capacite'] < $nb_membres) {
                http_response_code(400);
                echo json_encode(["error" => "Cet hébergement n'a pas assez de capacité ({$h['capacite']} places, {$nb_membres} membres dans le groupe)."]);
                return;
            }
            $itin_id = $this->getOrCreateItineraire($data['groupe_id']);
            $this->db->prepare("UPDATE itineraires SET hebergement_id = ? WHERE id = ?")->execute([$data['valeur'], $itin_id]);
            $this->recalculerCout($itin_id);

        } elseif ($data['type'] === 'activite') {
            $activite_ids = array_filter(array_map('intval', explode(',', $data['valeur'])));
            foreach ($activite_ids as $act_id) {
                $stmt = $this->db->prepare("SELECT nom, places_restantes FROM activites WHERE id = ?");
                $stmt->execute([$act_id]);
                $a = $stmt->fetch(PDO::FETCH_ASSOC);
                if ($a && (int)$a['places_restantes'] < $nb_membres) {
                    http_response_code(400);
                    echo json_encode(["error" => "L'activité \"{$a['nom']}\" n'a pas assez de places ({$a['places_restantes']} disponibles, {$nb_membres} membres dans le groupe)."]);
                    return;
                }
            }
            $itin_id = $this->getOrCreateItineraire($data['groupe_id']);
            $this->db->prepare("DELETE FROM itineraire_activites WHERE itineraire_id = ?")->execute([$itin_id]);
            foreach ($activite_ids as $act_id) {
                $this->db->prepare("INSERT IGNORE INTO itineraire_activites (itineraire_id, activite_id) VALUES (?, ?)")->execute([$itin_id, $act_id]);
            }
            $this->recalculerCout($itin_id);
        }

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
                VALUES (?, 'vote_valide', ?, ?)
            ");
            $stmt->execute([$uid, "Le vote {$data['type']} a été validé par l'organisateur.", "/groupes/{$data['groupe_id']}/vote"]);
        }

        echo json_encode(["message" => "Choix validé."]);
    }

    private function getOrCreateItineraire($groupe_id) {
        $stmt = $this->db->prepare("SELECT id FROM itineraires WHERE groupe_id = ?");
        $stmt->execute([$groupe_id]);
        $existing = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($existing) return $existing['id'];
        $stmt = $this->db->prepare("INSERT INTO itineraires (groupe_id, cout_total, statut) VALUES (?, 0, 'brouillon')");
        $stmt->execute([$groupe_id]);
        return $this->db->lastInsertId();
    }

    private function recalculerCout($itineraire_id) {
        $stmt = $this->db->prepare("
            SELECT COALESCE(t.prix,0) + COALESCE(h.prix_nuit,0) * COALESCE(DATEDIFF(t.date_arrivee, t.date_depart), 0) +
                   COALESCE((SELECT SUM(a.prix) FROM activites a
                             JOIN itineraire_activites ia ON ia.activite_id = a.id
                             WHERE ia.itineraire_id = ?),0) as total
            FROM itineraires i
            LEFT JOIN transports t ON t.id = i.transport_id
            LEFT JOIN hebergements h ON h.id = i.hebergement_id
            WHERE i.id = ?
        ");
        $stmt->execute([$itineraire_id, $itineraire_id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $this->db->prepare("UPDATE itineraires SET cout_total = ? WHERE id = ?")->execute([$row['total'], $itineraire_id]);
    }
}