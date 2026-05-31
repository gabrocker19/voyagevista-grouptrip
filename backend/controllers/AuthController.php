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

        $stmt = $this->db->prepare("SELECT id, nom, email, role, created_at FROM utilisateurs WHERE id = ?");
        $stmt->execute([$_SESSION['user_id']]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode($user);
    }

    public function updateProfil() {
        require_once 'middleware/auth.php';
        requireAuth();

        $data = json_decode(file_get_contents("php://input"), true);
        $userId = $_SESSION['user_id'];

        if (empty($data['nom']) || empty($data['email'])) {
            http_response_code(400);
            echo json_encode(["error" => "Nom et email requis."]);
            return;
        }

        // Vérifier que l'email n'est pas pris par quelqu'un d'autre
        $stmt = $this->db->prepare("SELECT id FROM utilisateurs WHERE email = ? AND id != ?");
        $stmt->execute([$data['email'], $userId]);
        if ($stmt->fetch()) {
            http_response_code(409);
            echo json_encode(["error" => "Cet email est déjà utilisé."]);
            return;
        }

        if (!empty($data['nouveau_mot_de_passe'])) {
            // Vérifier l'ancien mot de passe
            $stmt = $this->db->prepare("SELECT mot_de_passe FROM utilisateurs WHERE id = ?");
            $stmt->execute([$userId]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!password_verify($data['ancien_mot_de_passe'] ?? '', $row['mot_de_passe'])) {
                http_response_code(401);
                echo json_encode(["error" => "Mot de passe actuel incorrect."]);
                return;
            }

            $hash = password_hash($data['nouveau_mot_de_passe'], PASSWORD_BCRYPT);
            $stmt = $this->db->prepare(
                "UPDATE utilisateurs SET nom = ?, email = ?, mot_de_passe = ? WHERE id = ?"
            );
            $stmt->execute([$data['nom'], $data['email'], $hash, $userId]);
        } else {
            $stmt = $this->db->prepare(
                "UPDATE utilisateurs SET nom = ?, email = ? WHERE id = ?"
            );
            $stmt->execute([$data['nom'], $data['email'], $userId]);
        }

        $_SESSION['user_email'] = $data['email'];

        $stmt = $this->db->prepare("SELECT id, nom, email, role, created_at FROM utilisateurs WHERE id = ?");
        $stmt->execute([$userId]);
        echo json_encode($stmt->fetch(PDO::FETCH_ASSOC));
    }

    public function listUsers() {
        require_once 'middleware/auth.php';
        requireAuth();
        if ($_SESSION['user_role'] !== 'admin') {
            http_response_code(403);
            echo json_encode(["error" => "Accès refusé."]);
            return;
        }
        $stmt = $this->db->query("SELECT id, nom, email, role, created_at FROM utilisateurs ORDER BY created_at DESC");
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }

    public function updateRole($userId) {
        require_once 'middleware/auth.php';
        requireAuth();
        if ($_SESSION['user_role'] !== 'admin') {
            http_response_code(403);
            echo json_encode(["error" => "Accès refusé."]);
            return;
        }
        if ((int)$userId === (int)$_SESSION['user_id']) {
            http_response_code(400);
            echo json_encode(["error" => "Vous ne pouvez pas modifier votre propre rôle."]);
            return;
        }
        $data = json_decode(file_get_contents("php://input"), true);
        $role = $data['role'] ?? null;
        if (!in_array($role, ['membre', 'admin'])) {
            http_response_code(400);
            echo json_encode(["error" => "Rôle invalide."]);
            return;
        }
        $stmt = $this->db->prepare("UPDATE utilisateurs SET role = ? WHERE id = ?");
        $stmt->execute([$role, $userId]);
        echo json_encode(["message" => "Rôle mis à jour."]);
    }
}
