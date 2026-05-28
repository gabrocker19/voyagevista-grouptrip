<?php
$uri    = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri    = str_replace('/backend', '', $uri);
$method = $_SERVER['REQUEST_METHOD'];

// ── AUTH ──────────────────────────────────────────────────────────────────────
if ($uri === '/api/auth/register' && $method === 'POST') {
    require_once 'controllers/AuthController.php';
    (new AuthController())->register();

} elseif ($uri === '/api/auth/login' && $method === 'POST') {
    require_once 'controllers/AuthController.php';
    (new AuthController())->login();

} elseif ($uri === '/api/auth/logout' && $method === 'POST') {
    require_once 'controllers/AuthController.php';
    (new AuthController())->logout();

} elseif ($uri === '/api/auth/me' && $method === 'GET') {
    require_once 'controllers/AuthController.php';
    (new AuthController())->me();

// ── GROUPES ───────────────────────────────────────────────────────────────────
} elseif ($uri === '/api/groupes' && $method === 'GET') {
    require_once 'controllers/GroupController.php';
    (new GroupController())->index();

} elseif ($uri === '/api/groupes' && $method === 'POST') {
    require_once 'controllers/GroupController.php';
    (new GroupController())->create();

} elseif (preg_match('/^\/api\/groupes\/(\d+)$/', $uri, $m) && $method === 'GET') {
    require_once 'controllers/GroupController.php';
    (new GroupController())->show($m[1]);

} elseif (preg_match('/^\/api\/groupes\/(\d+)\/inviter$/', $uri, $m) && $method === 'POST') {
    require_once 'controllers/GroupController.php';
    (new GroupController())->invite($m[1]);

// ── CATALOGUE ─────────────────────────────────────────────────────────────────
} elseif ($uri === '/api/destinations' && $method === 'GET') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->destinations();

} elseif ($uri === '/api/transports' && $method === 'GET') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->transports();

} elseif ($uri === '/api/hebergements' && $method === 'GET') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->hebergements();

} elseif ($uri === '/api/activites' && $method === 'GET') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->activites();

// ── VOTES ─────────────────────────────────────────────────────────────────────
} elseif ($uri === '/api/votes' && $method === 'POST') {
    require_once 'controllers/VoteController.php';
    (new VoteController())->voter();

// ── ITINERAIRE ────────────────────────────────────────────────────────────────
} elseif ($uri === '/api/itineraires' && $method === 'POST') {
    require_once 'controllers/ItineraireController.php';
    (new ItineraireController())->create();

// ── NOTIFICATIONS ─────────────────────────────────────────────────────────────
} elseif ($uri === '/api/notifications' && $method === 'GET') {
    require_once 'controllers/NotifController.php';
    (new NotifController())->index();

} else {
    http_response_code(404);
    echo json_encode(["error" => "Endpoint non trouvé : $method $uri"]);
}
