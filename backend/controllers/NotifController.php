<?php
require_once 'config/database.php';
require_once 'middleware/auth.php';

class NotifController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    public function index() {
        requireAuth();
        $userId = $_SESSION['user_id'];

        $stmt = $this->db->prepare(
            "SELECT * FROM notifications WHERE utilisateur_id = ? ORDER BY created_at DESC LIMIT 50"
        );
        $stmt->execute([$userId]);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }

    public function marquerLue($id) {
        requireAuth();
        $userId = $_SESSION['user_id'];

        $stmt = $this->db->prepare(
            "UPDATE notifications SET lu = 1 WHERE id = ? AND utilisateur_id = ?"
        );
        $stmt->execute([$id, $userId]);

        if ($stmt->rowCount() === 0) {
            http_response_code(404);
            echo json_encode(["error" => "Notification non trouvée."]);
            return;
        }
        echo json_encode(["message" => "Notification lue."]);
    }

    public function marquerToutesLues() {
        requireAuth();
        $userId = $_SESSION['user_id'];

        $stmt = $this->db->prepare(
            "UPDATE notifications SET lu = 1 WHERE utilisateur_id = ? AND lu = 0"
        );
        $stmt->execute([$userId]);
        echo json_encode(["message" => "Toutes les notifications marquées comme lues."]);
    }

    public static function envoyer($db, $utilisateurId, $type, $message) {
        $stmt = $db->prepare(
            "INSERT INTO notifications (utilisateur_id, type, message) VALUES (?, ?, ?)"
        );
        $stmt->execute([$utilisateurId, $type, $message]);
    }
}
