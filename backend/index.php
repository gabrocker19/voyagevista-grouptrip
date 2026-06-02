<?php
$allowedOrigins = ["http://localhost:5173", "http://localhost"];
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
if (in_array($origin, $allowedOrigins)) {
    header("Access-Control-Allow-Origin: $origin");
} else {
    header("Access-Control-Allow-Origin: http://localhost");
}
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

session_set_cookie_params(['path' => '/', 'samesite' => 'Lax']);
session_start();
// Libère immédiatement le verrou de session. Sinon PHP le garde jusqu'à la fin
// de la requête et toutes les requêtes du même utilisateur se sérialisent
// (ex. la page Itinéraire charge 5 requêtes en parallèle). $_SESSION reste
// lisible ; les rares endpoints qui écrivent la session la rouvrent eux-mêmes.
session_write_close();
require_once 'routes/router.php';
