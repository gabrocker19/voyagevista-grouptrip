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
            WHERE mg.utilisateur_id = ? AND mg.statut != 'refuse'
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

        // Valider les dates si fournies
        $date_depart = !empty($data['date_depart']) ? $data['date_depart'] : null;
        $date_retour = !empty($data['date_retour']) ? $data['date_retour'] : null;
        if ($date_depart && $date_retour && $date_retour <= $date_depart) {
            http_response_code(400);
            echo json_encode(["error" => "La date de retour doit être après la date de départ."]);
            return;
        }

        // Créer le groupe
        $stmt = $this->db->prepare("
            INSERT INTO groupes (nom, budget_max, date_depart, date_retour, organisateur_id, statut)
            VALUES (?, ?, ?, ?, ?, 'en_formation')
        ");
        $stmt->execute([
            $data['nom'],
            $data['budget_max'] ?? null,
            $date_depart,
            $date_retour,
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

        // Vérifier que l'utilisateur est membre (accepté ou en attente pour voir l'invitation)
        $stmt = $this->db->prepare("
            SELECT mg.role, mg.statut FROM membres_groupe mg
            WHERE mg.groupe_id = ? AND mg.utilisateur_id = ?
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

    // PUT /api/groupes/:id — modifier un groupe
    public function update($id) {
        requireAuth();
        $data = json_decode(file_get_contents("php://input"), true);

        $stmt = $this->db->prepare("SELECT id FROM groupes WHERE id = ? AND organisateur_id = ?");
        $stmt->execute([$id, $_SESSION['user_id']]);
        if (!$stmt->fetch()) {
            http_response_code(403);
            echo json_encode(["error" => "Seul l'organisateur peut modifier le groupe."]);
            return;
        }

        $nom = trim($data['nom'] ?? '');
        if (!$nom) {
            http_response_code(400);
            echo json_encode(["error" => "Le nom est requis."]);
            return;
        }

        $date_depart = !empty($data['date_depart']) ? $data['date_depart'] : null;
        $date_retour = !empty($data['date_retour']) ? $data['date_retour'] : null;

        $stmt = $this->db->prepare("UPDATE groupes SET nom = ?, budget_max = ?, date_depart = ?, date_retour = ? WHERE id = ?");
        $stmt->execute([$nom, $data['budget_max'] ?? null, $date_depart, $date_retour, $id]);
        echo json_encode(["message" => "Groupe mis à jour."]);
    }

    // DELETE /api/groupes/:id — supprimer un groupe
    public function delete($id) {
        requireAuth();

        $stmt = $this->db->prepare("SELECT id FROM groupes WHERE id = ? AND organisateur_id = ?");
        $stmt->execute([$id, $_SESSION['user_id']]);
        if (!$stmt->fetch()) {
            http_response_code(403);
            echo json_encode(["error" => "Seul l'organisateur peut supprimer le groupe."]);
            return;
        }

        // Supprimer les données liées
        $this->db->prepare("DELETE FROM votes WHERE groupe_id = ?")->execute([$id]);
        $this->db->prepare("DELETE FROM notifications WHERE message LIKE ? AND utilisateur_id IN (SELECT utilisateur_id FROM membres_groupe WHERE groupe_id = ?)")->execute(["%groupe%", $id]);
        $this->db->prepare("DELETE FROM membres_groupe WHERE groupe_id = ?")->execute([$id]);
        $this->db->prepare("DELETE FROM groupes WHERE id = ?")->execute([$id]);

        echo json_encode(["message" => "Groupe supprimé."]);
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
            INSERT INTO notifications (utilisateur_id, type, message, lien)
            VALUES (?, 'invitation', ?, ?)
        ");
        $msg = "Vous avez été invité à rejoindre le groupe : " . ($data['groupe_nom'] ?? '');
        $stmt->execute([$user['id'], $msg, "/groupes/{$id}"]);

        echo json_encode(["message" => "Invitation envoyée à " . $user['nom']]);
    }

    // DELETE /api/groupes/:id/membres/:userId — retirer un membre
    public function retirerMembre($id, $userId) {
        requireAuth();

        $stmt = $this->db->prepare("SELECT id FROM groupes WHERE id = ? AND organisateur_id = ?");
        $stmt->execute([$id, $_SESSION['user_id']]);
        if (!$stmt->fetch()) {
            http_response_code(403);
            echo json_encode(["error" => "Seul l'organisateur peut retirer un membre."]);
            return;
        }
        if ((int)$userId === (int)$_SESSION['user_id']) {
            http_response_code(400);
            echo json_encode(["error" => "Vous ne pouvez pas vous retirer vous-même."]);
            return;
        }
        $this->db->prepare("DELETE FROM membres_groupe WHERE groupe_id = ? AND utilisateur_id = ?")->execute([$id, $userId]);
        $this->db->prepare("DELETE FROM votes WHERE groupe_id = ? AND utilisateur_id = ?")->execute([$id, $userId]);
        echo json_encode(["message" => "Membre retiré."]);
    }

    // POST /api/groupes/:id/rejoindre
    public function rejoindre($id) {
        requireAuth();
        $data = json_decode(file_get_contents("php://input"), true);

        if ($data['statut'] === 'refuse') {
            $stmt = $this->db->prepare("
                DELETE FROM membres_groupe WHERE groupe_id = ? AND utilisateur_id = ?
            ");
            $stmt->execute([$id, $_SESSION['user_id']]);
            echo json_encode(["message" => "Invitation refusée."]);
        } else {
            $stmt = $this->db->prepare("
                UPDATE membres_groupe SET statut = ?
                WHERE groupe_id = ? AND utilisateur_id = ?
            ");
            $stmt->execute([$data['statut'], $id, $_SESSION['user_id']]);
            echo json_encode(["message" => "Statut mis à jour."]);
        }
    }
}