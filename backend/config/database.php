<?php
$dbPasswordFile = __DIR__ . '/db_password.php';
$dbPassword = '';
if (file_exists($dbPasswordFile)) {
    require_once $dbPasswordFile;
    $dbPassword = defined('DB_PASSWORD') ? DB_PASSWORD : '';
}

class Database {
    private $host     = "localhost";
    private $db_name  = "voyagevista";
    private $username = "root";
    private $password;
    public  $conn;

    public function __construct() {
        global $dbPassword;
        $this->password = $dbPassword ?? '';
    }

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8",
                $this->username,
                $this->password
            );
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (PDOException $e) {
            echo json_encode(["error" => "Connexion échouée : " . $e->getMessage()]);
        }
        return $this->conn;
    }
}
