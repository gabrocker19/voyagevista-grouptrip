<?php
$uri    = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$base   = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/');
if ($base !== '' && strpos($uri, $base) === 0) {
    $uri = substr($uri, strlen($base));
}
if (empty($uri)) $uri = '/';
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

} elseif ($uri === '/api/profil' && $method === 'PUT') {
    require_once 'controllers/AuthController.php';
    (new AuthController())->updateProfil();

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

} elseif (preg_match('/^\/api\/groupes\/(\d+)$/', $uri, $m) && $method === 'PUT') {
    require_once 'controllers/GroupController.php';
    (new GroupController())->update($m[1]);

} elseif (preg_match('/^\/api\/groupes\/(\d+)$/', $uri, $m) && $method === 'DELETE') {
    require_once 'controllers/GroupController.php';
    (new GroupController())->delete($m[1]);

} elseif (preg_match('/^\/api\/groupes\/(\d+)\/membres\/(\d+)$/', $uri, $m) && $method === 'DELETE') {
    require_once 'controllers/GroupController.php';
    (new GroupController())->retirerMembre($m[1], $m[2]);

} elseif (preg_match('/^\/api\/groupes\/(\d+)\/inviter$/', $uri, $m) && $method === 'POST') {
    require_once 'controllers/GroupController.php';
    (new GroupController())->invite($m[1]);

} elseif (preg_match('/^\/api\/groupes\/(\d+)\/rejoindre$/', $uri, $m) && $method === 'POST') {
    require_once 'controllers/GroupController.php';
    (new GroupController())->rejoindre($m[1]);

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
    $ids = $_GET['ids'] ?? null;
    if ($ids) {
        (new CatalogueController())->activitesByIds();
    } else {
        (new CatalogueController())->activites();
    }

// ── VOTES ─────────────────────────────────────────────────────────────────────
} elseif ($uri === '/api/votes' && $method === 'POST') {
    require_once 'controllers/VoteController.php';
    (new VoteController())->voter();

} elseif ($uri === '/api/votes' && $method === 'GET') {
    require_once 'controllers/VoteController.php';
    (new VoteController())->resultats();

} elseif ($uri === '/api/votes/valider' && $method === 'POST') {
    require_once 'controllers/VoteController.php';
    (new VoteController())->valider();

// ── ITINERAIRE ────────────────────────────────────────────────────────────────
} elseif ($uri === '/api/itineraires' && $method === 'POST') {
    require_once 'controllers/ItineraireController.php';
    (new ItineraireController())->create();
    
} elseif (preg_match('/^\/api\/itineraires\/groupe\/(\d+)$/', $uri, $m) && $method === 'GET') {
    require_once 'controllers/ItineraireController.php';
    (new ItineraireController())->getByGroupe($m[1]);

} elseif (preg_match('/^\/api\/itineraires\/groupe\/(\d+)$/', $uri, $m) && $method === 'DELETE') {
    require_once 'controllers/ItineraireController.php';
    (new ItineraireController())->supprimer($m[1]);

} elseif (preg_match('/^\/api\/itineraires\/groupe\/(\d+)\/transport$/', $uri, $m) && $method === 'DELETE') {
    require_once 'controllers/ItineraireController.php';
    (new ItineraireController())->annulerTransport($m[1]);

} elseif (preg_match('/^\/api\/itineraires\/groupe\/(\d+)\/hebergement$/', $uri, $m) && $method === 'DELETE') {
    require_once 'controllers/ItineraireController.php';
    (new ItineraireController())->annulerHebergement($m[1]);

} elseif (preg_match('/^\/api\/itineraires\/groupe\/(\d+)\/activites\/(\d+)$/', $uri, $m) && $method === 'DELETE') {
    require_once 'controllers/ItineraireController.php';
    (new ItineraireController())->annulerActivite($m[1], $m[2]);

// ── RESERVATIONS ──────────────────────────────────────────────────────────────
} elseif ($uri === '/api/reservations' && $method === 'POST') {
    require_once 'controllers/ReservationController.php';
    (new ReservationController())->create();

} elseif (preg_match('/^\/api\/reservations\/groupe\/(\d+)$/', $uri, $m) && $method === 'GET') {
    require_once 'controllers/ReservationController.php';
    (new ReservationController())->getByGroupe($m[1]);

// ── NOTIFICATIONS ─────────────────────────────────────────────────────────────
// ── ADMIN CATALOGUE ──────────────────────────────────────────────────────────
} elseif ($uri === '/api/admin/destinations' && $method === 'POST') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->createDestination();

} elseif (preg_match('/^\/api\/admin\/destinations\/(\d+)$/', $uri, $m) && $method === 'PUT') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->updateDestination($m[1]);

} elseif (preg_match('/^\/api\/admin\/destinations\/(\d+)$/', $uri, $m) && $method === 'DELETE') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->deleteDestination($m[1]);

} elseif ($uri === '/api/admin/hebergements' && $method === 'POST') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->createHebergement();

} elseif (preg_match('/^\/api\/admin\/hebergements\/(\d+)$/', $uri, $m) && $method === 'DELETE') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->deleteHebergement($m[1]);

} elseif ($uri === '/api/admin/activites' && $method === 'POST') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->createActivite();

} elseif (preg_match('/^\/api\/admin\/activites\/(\d+)$/', $uri, $m) && $method === 'DELETE') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->deleteActivite($m[1]);

} elseif ($uri === '/api/admin/transports' && $method === 'GET') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->getAllTransports();

} elseif ($uri === '/api/admin/transports' && $method === 'POST') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->createTransport();

} elseif (preg_match('/^\/api\/admin\/transports\/(\d+)$/', $uri, $m) && $method === 'DELETE') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->deleteTransport($m[1]);

// ── ADMIN UTILISATEURS ────────────────────────────────────────────────────────
} elseif ($uri === '/api/admin/utilisateurs' && $method === 'GET') {
    require_once 'controllers/AuthController.php';
    (new AuthController())->listUsers();

} elseif (preg_match('/^\/api\/admin\/utilisateurs\/(\d+)\/role$/', $uri, $m) && $method === 'PUT') {
    require_once 'controllers/AuthController.php';
    (new AuthController())->updateRole($m[1]);

} elseif ($uri === '/api/notifications' && $method === 'GET') {
    require_once 'controllers/NotifController.php';
    (new NotifController())->index();

} elseif ($uri === '/api/notifications/lire-tout' && $method === 'PUT') {
    require_once 'controllers/NotifController.php';
    (new NotifController())->marquerToutesLues();

} elseif (preg_match('/^\/api\/notifications\/(\d+)\/lire$/', $uri, $m) && $method === 'PUT') {
    require_once 'controllers/NotifController.php';
    (new NotifController())->marquerLue($m[1]);

} elseif (preg_match('/^\/api\/transports\/(\d+)$/', $uri, $m) && $method === 'GET') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->getTransport($m[1]);

} elseif (preg_match('/^\/api\/hebergements\/(\d+)$/', $uri, $m) && $method === 'GET') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->getHebergement($m[1]);

} elseif (preg_match('/^\/api\/destinations\/(\d+)$/', $uri, $m) && $method === 'GET') {
    require_once 'controllers/CatalogueController.php';
    (new CatalogueController())->getDestination($m[1]);
} 
else {
    http_response_code(404);
    echo json_encode(["error" => "Endpoint non trouvé : $method $uri"]);
}

