<?php
require_once 'config/database.php';
require_once 'middleware/auth.php';

class ReservationController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    public function create() {
        requireAuth();
        $data = json_decode(file_get_contents("php://input"), true);
        $groupe_id = $data['groupe_id'] ?? null;

        if (!$groupe_id) {
            http_response_code(400);
            echo json_encode(["error" => "groupe_id requis."]);
            return;
        }

        // Vérifier que l'utilisateur est membre accepté
        $stmt = $this->db->prepare("
            SELECT id FROM membres_groupe
            WHERE utilisateur_id = ? AND groupe_id = ? AND statut = 'accepte'
        ");
        $stmt->execute([$_SESSION['user_id'], $groupe_id]);
        if (!$stmt->fetch()) {
            http_response_code(403);
            echo json_encode(["error" => "Accès refusé."]);
            return;
        }

        // Récupérer l'itinéraire
        $stmt = $this->db->prepare("SELECT * FROM itineraires WHERE groupe_id = ?");
        $stmt->execute([$groupe_id]);
        $itineraire = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$itineraire) {
            http_response_code(404);
            echo json_encode(["error" => "Aucun itinéraire trouvé. Composez d'abord votre voyage."]);
            return;
        }

        // Récupérer tous les membres acceptés
        $stmt = $this->db->prepare("
            SELECT utilisateur_id FROM membres_groupe
            WHERE groupe_id = ? AND statut = 'accepte'
        ");
        $stmt->execute([$groupe_id]);
        $membres = $stmt->fetchAll(PDO::FETCH_COLUMN);

        $montant      = $itineraire['cout_total'];
        $last_res_id  = null;

        foreach ($membres as $uid) {
            // Supprimer l'ancienne réservation si elle existe
            $stmt = $this->db->prepare("
                DELETE FROM reservations WHERE itineraire_id = ? AND utilisateur_id = ?
            ");
            $stmt->execute([$itineraire['id'], $uid]);

            $stmt = $this->db->prepare("
                INSERT INTO reservations (itineraire_id, utilisateur_id, montant, statut_paiement)
                VALUES (?, ?, ?, 'paye')
            ");
            $stmt->execute([$itineraire['id'], $uid, $montant]);
            $last_res_id = $this->db->lastInsertId();
        }

        // Mettre à jour les statuts
        $this->db->prepare("UPDATE groupes SET statut = 'reservation_confirmee' WHERE id = ?")->execute([$groupe_id]);
        $this->db->prepare("UPDATE itineraires SET statut = 'valide' WHERE groupe_id = ?")->execute([$groupe_id]);

        // Générer la référence de réservation
        $reference = 'VV-' . date('Y') . '-' . str_pad($last_res_id, 4, '0', STR_PAD_LEFT);

        // Notifier tous les membres
        foreach ($membres as $uid) {
            $stmt = $this->db->prepare("
                INSERT INTO notifications (utilisateur_id, type, message, lien)
                VALUES (?, 'reservation', ?, ?)
            ");
            $stmt->execute([
                $uid,
                "Réservation confirmée — Réf. {$reference}. Montant : {$montant}€/pers.",
                "/groupes/{$groupe_id}"
            ]);
        }

        http_response_code(201);
        echo json_encode([
            "message"   => "Réservation confirmée.",
            "reference" => $reference,
            "montant"   => $montant,
            "nb_membres"=> count($membres),
        ]);
    }

    public function getByGroupe($groupe_id) {
        requireAuth();

        $stmt = $this->db->prepare("
            SELECT r.*, u.nom AS membre_nom, u.email AS membre_email
            FROM reservations r
            JOIN utilisateurs u ON u.id = r.utilisateur_id
            JOIN itineraires  i ON i.id = r.itineraire_id
            WHERE i.groupe_id = ?
            ORDER BY r.created_at DESC
        ");
        $stmt->execute([$groupe_id]);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }
}
