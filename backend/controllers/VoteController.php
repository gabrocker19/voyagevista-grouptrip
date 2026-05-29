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

        // R1 : un seul vote par membre par type — insérer ou remplacer
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

        // Mettre à jour le groupe selon le type
        if ($data['type'] === 'destination') {
            $stmt = $this->db->prepare("UPDATE groupes SET destination_id = ? WHERE id = ?");
            $stmt->execute([$data['valeur'], $data['groupe_id']]);
        } elseif ($data['type'] === 'dates') {
            $dates = explode('|', $data['valeur']); // format: "2026-06-14|2026-06-28"
            $stmt  = $this->db->prepare("UPDATE groupes SET date_depart = ?, date_retour = ? WHERE id = ?");
            $stmt->execute([$dates[0], $dates[1], $data['groupe_id']]);
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
                INSERT INTO notifications (utilisateur_id, type, message)
                VALUES (?, 'vote_valide', ?)
            ");
            $stmt->execute([$uid, "Le vote {$data['type']} a été validé par l'organisateur."]);
        }

        echo json_encode(["message" => "Choix validé."]);
    }
}