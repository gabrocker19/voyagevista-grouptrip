<?php
require_once 'config/database.php';

class CatalogueController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    public function destinations() {
        $search    = $_GET['search']    ?? '';
        $categorie = $_GET['categorie'] ?? '';

        $sql = "SELECT * FROM destinations WHERE 1=1";
        $params = [];

        if ($search) {
            $sql .= " AND (nom LIKE ? OR pays LIKE ?)";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }
        if ($categorie) {
            $sql .= " AND categorie = ?";
            $params[] = $categorie;
        }

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }

    public function transports() {
        $origine     = $_GET['origine']     ?? '';
        $destination = $_GET['destination'] ?? '';
        $type        = $_GET['type']        ?? '';

        $sql = "SELECT * FROM transports WHERE places_dispo > 0";
        $params = [];

        if ($origine) {
            $sql .= " AND origine LIKE ?";
            $params[] = "%$origine%";
        }
        if ($destination) {
            $sql .= " AND destination LIKE ?";
            $params[] = "%$destination%";
        }
        if ($type) {
            $sql .= " AND type = ?";
            $params[] = $type;
        }

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }

    public function getTransport($id) {
        $stmt = $this->db->prepare("SELECT * FROM transports WHERE id = ?");
        $stmt->execute([$id]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$result) {
            http_response_code(404);
            echo json_encode(["error" => "Transport non trouvé."]);
            return;
        }
        echo json_encode($result);
    }

    public function hebergements() {
        $destination_id = $_GET['destination_id'] ?? '';

        $sql = "SELECT * FROM hebergements WHERE 1=1";
        $params = [];

        if ($destination_id) {
            $sql .= " AND destination_id = ?";
            $params[] = $destination_id;
        }

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }

    public function activites() {
        $destination_id = $_GET['destination_id'] ?? '';

        $sql = "SELECT * FROM activites WHERE 1=1";
        $params = [];

        if ($destination_id) {
            $sql .= " AND destination_id = ?";
            $params[] = $destination_id;
        }

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }

public function getHebergement($id) {
    $stmt = $this->db->prepare("SELECT * FROM hebergements WHERE id = ?");
    $stmt->execute([$id]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$result) { http_response_code(404); echo json_encode(["error" => "Hébergement non trouvé."]); return; }
    echo json_encode($result);
}

public function activitesByIds() {
    $ids = $_GET['ids'] ?? '';
    if (!$ids) { echo json_encode([]); return; }
    $idArray = explode(',', $ids);
    $placeholders = implode(',', array_fill(0, count($idArray), '?'));
    $stmt = $this->db->prepare("SELECT * FROM activites WHERE id IN ($placeholders)");
    $stmt->execute($idArray);
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}
public function getDestination($id) {
    $stmt = $this->db->prepare("SELECT * FROM destinations WHERE id = ?");
    $stmt->execute([$id]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$result) { http_response_code(404); echo json_encode(["error" => "Destination non trouvée."]); return; }
    echo json_encode($result);
}

// ── ADMIN CRUD ────────────────────────────────────────────────────────────────

private function requireAdmin() {
    require_once 'middleware/auth.php';
    requireAuth();
    if ($_SESSION['user_role'] !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "Accès réservé aux administrateurs."]);
        exit;
    }
}

public function createDestination() {
    $this->requireAdmin();
    $data = json_decode(file_get_contents("php://input"), true);
    if (empty($data['nom']) || empty($data['pays']) || empty($data['categorie'])) {
        http_response_code(400); echo json_encode(["error" => "Nom, pays et catégorie requis."]); return;
    }
    $stmt = $this->db->prepare("INSERT INTO destinations (nom, pays, categorie, description, prix_min, image_url) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$data['nom'], $data['pays'], $data['categorie'], $data['description'] ?? null, $data['prix_min'] ?? 0, $data['image_url'] ?? null]);
    http_response_code(201);
    echo json_encode(["message" => "Destination créée.", "id" => $this->db->lastInsertId()]);
}

public function updateDestination($id) {
    $this->requireAdmin();
    $data = json_decode(file_get_contents("php://input"), true);
    $stmt = $this->db->prepare("UPDATE destinations SET nom=?, pays=?, categorie=?, description=?, prix_min=?, image_url=? WHERE id=?");
    $stmt->execute([$data['nom'], $data['pays'], $data['categorie'], $data['description'] ?? null, $data['prix_min'] ?? 0, $data['image_url'] ?? null, $id]);
    echo json_encode(["message" => "Destination mise à jour."]);
}

public function deleteDestination($id) {
    $this->requireAdmin();
    $stmt = $this->db->prepare("DELETE FROM destinations WHERE id = ?");
    $stmt->execute([$id]);
    echo json_encode(["message" => "Destination supprimée."]);
}

public function createHebergement() {
    $this->requireAdmin();
    $data = json_decode(file_get_contents("php://input"), true);
    if (empty($data['nom']) || empty($data['destination_id']) || empty($data['type']) || !isset($data['prix_nuit'])) {
        http_response_code(400); echo json_encode(["error" => "Champs requis manquants."]); return;
    }
    $stmt = $this->db->prepare("INSERT INTO hebergements (destination_id, nom, type, prix_nuit, capacite, description) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$data['destination_id'], $data['nom'], $data['type'], $data['prix_nuit'], $data['capacite'] ?? 10, $data['description'] ?? null]);
    http_response_code(201);
    echo json_encode(["message" => "Hébergement créé.", "id" => $this->db->lastInsertId()]);
}

public function deleteHebergement($id) {
    $this->requireAdmin();
    $stmt = $this->db->prepare("DELETE FROM hebergements WHERE id = ?");
    $stmt->execute([$id]);
    echo json_encode(["message" => "Hébergement supprimé."]);
}

public function createActivite() {
    $this->requireAdmin();
    $data = json_decode(file_get_contents("php://input"), true);
    if (empty($data['nom']) || empty($data['destination_id']) || !isset($data['prix'])) {
        http_response_code(400); echo json_encode(["error" => "Champs requis manquants."]); return;
    }
    $capacite = $data['capacite_max'] ?? 20;
    $stmt = $this->db->prepare("INSERT INTO activites (destination_id, nom, description, prix, capacite_max, places_restantes, duree_heures) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$data['destination_id'], $data['nom'], $data['description'] ?? null, $data['prix'], $capacite, $capacite, $data['duree_heures'] ?? null]);
    http_response_code(201);
    echo json_encode(["message" => "Activité créée.", "id" => $this->db->lastInsertId()]);
}

public function deleteActivite($id) {
    $this->requireAdmin();
    $stmt = $this->db->prepare("DELETE FROM activites WHERE id = ?");
    $stmt->execute([$id]);
    echo json_encode(["message" => "Activité supprimée."]);
}

public function getAllTransports() {
    $this->requireAdmin();
    $search = $_GET['search'] ?? '';
    $sql = "SELECT * FROM transports WHERE 1=1";
    $params = [];
    if ($search) {
        $sql .= " AND (compagnie LIKE ? OR origine LIKE ? OR destination LIKE ?)";
        $params[] = "%$search%"; $params[] = "%$search%"; $params[] = "%$search%";
    }
    $sql .= " ORDER BY date_depart DESC";
    $stmt = $this->db->prepare($sql);
    $stmt->execute($params);
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}

public function createTransport() {
    $this->requireAdmin();
    $data = json_decode(file_get_contents("php://input"), true);
    if (empty($data['compagnie']) || empty($data['type']) || empty($data['origine']) || empty($data['destination']) || empty($data['date_depart']) || empty($data['date_arrivee']) || !isset($data['prix'])) {
        http_response_code(400); echo json_encode(["error" => "Champs requis manquants."]); return;
    }
    $stmt = $this->db->prepare("INSERT INTO transports (compagnie, type, origine, destination, date_depart, date_arrivee, prix, places_dispo) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$data['compagnie'], $data['type'], $data['origine'], $data['destination'], $data['date_depart'], $data['date_arrivee'], $data['prix'], $data['places_dispo'] ?? 100]);
    http_response_code(201);
    echo json_encode(["message" => "Transport créé.", "id" => $this->db->lastInsertId()]);
}

public function deleteTransport($id) {
    $this->requireAdmin();
    $stmt = $this->db->prepare("DELETE FROM transports WHERE id = ?");
    $stmt->execute([$id]);
    echo json_encode(["message" => "Transport supprimé."]);
}
}