<?php
require_once 'config/database.php';
require_once 'middleware/auth.php';

class ItineraireController {
    private $db;
    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }
    // TODO : implémenter les méthodes
}
