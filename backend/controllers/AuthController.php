<?php
require_once 'config/database.php';

class AuthController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    public function register() {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!$data['email'] || !$data['password'] || !$data['nom']) {
            http_response_code(400);
            echo json_encode(["error" => "Champs requis manquants."]);
            return;
        }

        // Vérifier si email déjà utilisé
        $stmt = $this->db->prepare("SELECT id FROM utilisateurs WHERE email = ?");
        $stmt->execute([$data['email']]);
        if ($stmt->fetch()) {
            http_response_code(409);
            echo json_encode(["error" => "Email déjà utilisé."]);
            return;
        }

        $hash = password_hash($data['password'], PASSWORD_BCRYPT);
        $stmt = $this->db->prepare(
            "INSERT INTO utilisateurs (nom, email, mot_de_passe, role) VALUES (?, ?, ?, 'membre')"
        );
        $stmt->execute([$data['nom'], $data['email'], $hash]);

        http_response_code(201);
        echo json_encode(["message" => "Compte créé avec succès."]);
    }

    public function login() {
        $data = json_decode(file_get_contents("php://input"), true);

        $stmt = $this->db->prepare("SELECT * FROM utilisateurs WHERE email = ?");
        $stmt->execute([$data['email']]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user || !password_verify($data['password'], $user['mot_de_passe'])) {
            http_response_code(401);
            echo json_encode(["error" => "Email ou mot de passe incorrect."]);
            return;
        }

        $_SESSION['user_id']   = $user['id'];
        $_SESSION['user_role'] = $user['role'];

        echo json_encode([
            "message" => "Connexion réussie.",
            "user"    => ["id" => $user['id'], "nom" => $user['nom'], "email" => $user['email'], "role" => $user['role']]
        ]);
    }

    public function logout() {
        session_destroy();
        echo json_encode(["message" => "Déconnexion réussie."]);
    }

    public function me() {
        require_once 'middleware/auth.php';
        requireAuth();

        $stmt = $this->db->prepare("SELECT id, nom, email, role FROM utilisateurs WHERE id = ?");
        $stmt->execute([$_SESSION['user_id']]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode($user);
    }
}
