<?php
function requireAuth() {
    if (!isset($_SESSION['user_id'])) {
        http_response_code(401);
        echo json_encode(["error" => "Non autorisé. Veuillez vous connecter."]);
        exit();
    }
}

function requireAdmin() {
    requireAuth();
    if ($_SESSION['user_role'] !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "Accès refusé."]);
        exit();
    }
}
