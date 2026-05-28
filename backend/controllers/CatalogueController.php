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

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
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
}