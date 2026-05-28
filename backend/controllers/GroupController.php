<?php
require_once 'config/database.php';
require_once 'middleware/auth.php';

class GroupController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    // GET /api/groupes — mes groupes
    public function index() {
        requireAuth();
        $stmt = $this->db->prepare("
            SELECT g.*, u.nom as organisateur_nom,
                   mg.role as mon_role, mg.statut as mon_statut
            FROM groupes g
            JOIN membres_groupe mg ON mg.groupe_id = g.id
            JOIN utilisateurs u ON u.id = g.organisateur_id
            WHERE mg.utilisateur_id = ?
            ORDER BY g.created_at DESC
        ");
        $stmt->execute([$_SESSION['user_id']]);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }

    // POST /api/groupes — créer un groupe
    public function create() {
        requireAuth();
        $data = json_decode(file_get_contents("php://input"), true);

        if (!$data['nom']) {
            http_response_code(400);
            echo json_encode(["error" => "Le nom du groupe est requis."]);
            return;
        }

        // Créer le groupe
        $stmt = $this->db->prepare("
            INSERT INTO groupes (nom, budget_max, organisateur_id, statut)
            VALUES (?, ?, ?, 'en_formation')
        ");
        $stmt->execute([
            $data['nom'],
            $data['budget_max'] ?? null,
            $_SESSION['user_id']
        ]);
        $groupe_id = $this->db->lastInsertId();

        // Ajouter l'organisateur comme membre
        $stmt = $this->db->prepare("
            INSERT INTO membres_groupe (utilisateur_id, groupe_id, role, statut)
            VALUES (?, ?, 'organisateur', 'accepte')
        ");
        $stmt->execute([$_SESSION['user_id'], $groupe_id]);

        http_response_code(201);
        echo json_encode(["message" => "Groupe créé.", "groupe_id" => $groupe_id]);
    }

    // GET /api/groupes/:id — détail d'un groupe
    public function show($id) {
        requireAuth();

        // Vérifier que l'utilisateur est membre
        $stmt = $this->db->prepare("
            SELECT mg.role FROM membres_groupe mg
            WHERE mg.groupe_id = ? AND mg.utilisateur_id = ? AND mg.statut = 'accepte'
        ");
        $stmt->execute([$id, $_SESSION['user_id']]);
        if (!$stmt->fetch()) {
            http_response_code(403);
            echo json_encode(["error" => "Accès refusé."]);
            return;
        }

        // Récupérer le groupe
        $stmt = $this->db->prepare("
            SELECT g.*, u.nom as organisateur_nom
            FROM groupes g
            JOIN utilisateurs u ON u.id = g.organisateur_id
            WHERE g.id = ?
        ");
        $stmt->execute([$id]);
        $groupe = $stmt->fetch(PDO::FETCH_ASSOC);

        // Récupérer les membres
        $stmt = $this->db->prepare("
            SELECT mg.role, mg.statut, u.id, u.nom, u.email
            FROM membres_groupe mg
            JOIN utilisateurs u ON u.id = mg.utilisateur_id
            WHERE mg.groupe_id = ?
        ");
        $stmt->execute([$id]);
        $groupe['membres'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode($groupe);
    }

    // POST /api/groupes/:id/inviter
    public function invite($id) {
        requireAuth();
        $data = json_decode(file_get_contents("php://input"), true);

        // Vérifier que c'est l'organisateur
        $stmt = $this->db->prepare("
            SELECT id FROM groupes WHERE id = ? AND organisateur_id = ?
        ");
        $stmt->execute([$id, $_SESSION['user_id']]);
        if (!$stmt->fetch()) {
            http_response_code(403);
            echo json_encode(["error" => "Seul l'organisateur peut inviter."]);
            return;
        }

        // Trouver l'utilisateur par email
        $stmt = $this->db->prepare("SELECT id, nom FROM utilisateurs WHERE email = ?");
        $stmt->execute([$data['email']]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            http_response_code(404);
            echo json_encode(["error" => "Aucun utilisateur trouvé avec cet email."]);
            return;
        }

        // Vérifier s'il est déjà membre
        $stmt = $this->db->prepare("
            SELECT id FROM membres_groupe WHERE utilisateur_id = ? AND groupe_id = ?
        ");
        $stmt->execute([$user['id'], $id]);
        if ($stmt->fetch()) {
            http_response_code(409);
            echo json_encode(["error" => "Cet utilisateur est déjà dans le groupe."]);
            return;
        }

        // Ajouter comme membre en attente
        $stmt = $this->db->prepare("
            INSERT INTO membres_groupe (utilisateur_id, groupe_id, role, statut)
            VALUES (?, ?, 'membre', 'en_attente')
        ");
        $stmt->execute([$user['id'], $id]);

        // Notification
        $stmt = $this->db->prepare("
            INSERT INTO notifications (utilisateur_id, type, message)
            VALUES (?, 'invitation', ?)
        ");
        $msg = "Vous avez été invité à rejoindre le groupe : " . $data['groupe_nom'] ?? '';
        $stmt->execute([$user['id'], $msg]);

        echo json_encode(["message" => "Invitation envoyée à " . $user['nom']]);
    }

    // POST /api/groupes/:id/rejoindre
    public function rejoindre($id) {
        requireAuth();
        $data = json_decode(file_get_contents("php://input"), true);

        $stmt = $this->db->prepare("
            UPDATE membres_groupe SET statut = ?
            WHERE groupe_id = ? AND utilisateur_id = ?
        ");
        $stmt->execute([$data['statut'], $id, $_SESSION['user_id']]);

        echo json_encode(["message" => "Statut mis à jour."]);
    }
}