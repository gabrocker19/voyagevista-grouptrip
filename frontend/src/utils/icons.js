// Icônes spécifiques par nom de destination
export const DEST_ICONS = {
  // France
  "Paris":               "🗼",
  "Nice":                "🌊",
  "Lyon":                "🏙️",
  "Marseille":           "⚓",
  "Bordeaux":            "🍷",

  // Europe Ouest
  "Londres":             "🎡",
  "Barcelone":           "🏟️",
  "Madrid":              "💃",
  "Lisbonne":            "⚓",
  "Porto":               "🍷",
  "Sintra":              "🏯",
  "Amsterdam":           "🌷",
  "Bruxelles":           "🍫",
  "Dublin":              "🍀",

  // Europe Centre & Nord
  "Berlin":              "🧱",
  "Vienne":              "🎼",
  "Prague":              "🏰",
  "Budapest":            "🌉",
  "Stockholm":           "👑",
  "Copenhague":          "🧜",
  "Oslo":                "🐋",
  "Helsinki":            "🌲",
  "Varsovie":            "🏛️",

  // Europe Sud
  "Rome":                "🏛️",
  "Florence":            "🎨",
  "Venise":              "🚤",
  "Milan":               "👗",
  "Naples":              "🍕",
  "Cinque Terre":        "🎨",
  "Santorin":            "🏺",
  "Mykonos":             "⛵",
  "Athènes":             "🏛️",
  "Dubrovnik":           "🏰",
  "Ibiza":               "🎶",

  // Moyen-Orient & Afrique Nord
  "Dubai":               "🌆",
  "Marrakech":           "🕌",
  "Le Caire":            "🐪",
  "Alger":               "🕌",
  "Tunis":               "🌴",
  "Istanbul":            "🕌",
  "Cappadoce":           "🎈",

  // Afrique subsaharienne
  "Nairobi":             "🦁",
  "Zanzibar":            "🐠",
  "Île Maurice":         "🌺",
  "Cap-Vert":            "🌊",
  "La Réunion":          "🌋",
  "Cape Town":           "🦭",

  // Asie Est
  "Tokyo":               "⛩️",
  "Kyoto":               "🎋",
  "Séoul":               "🎎",
  "Hong Kong":           "🌃",
  "Pékin":               "🐉",
  "Shanghai":            "🌇",

  // Asie Sud-Est
  "Bangkok":             "🛕",
  "Singapour":           "🌇",
  "Bali":                "🌺",
  "Phuket":              "🏖️",
  "Koh Samui":           "🥥",
  "Hanoï":               "🏮",
  "Ho Chi Minh":         "🛵",
  "Kuala Lumpur":        "🏙️",
  "Luang Prabang":       "🏮",
  "Angkor":              "🏯",

  // Asie Sud
  "Maldives":            "🏝️",
  "Mumbai":              "🎬",
  "Delhi":               "🕌",
  "Katmandou":           "⛰️",
  "Goa":                 "🌴",

  // Amériques Nord
  "New York":            "🗽",
  "Los Angeles":         "🌴",
  "Montréal":            "🍁",
  "San Francisco":       "🌉",
  "Miami":               "🌊",
  "Las Vegas":           "🎰",
  "Chicago":             "🏙️",
  "Cancún":              "🌴",

  // Caraïbes & Amérique Centrale
  "La Havane":           "🚗",
  "Punta Cana":          "🌴",
  "Jamaica":             "🌿",

  // Amérique du Sud
  "Rio de Janeiro":      "🎭",
  "Buenos Aires":        "💃",
  "Patagonie":           "🦅",
  "Machu Picchu":        "🏔️",
  "Cartagena":           "🌺",

  // Océanie
  "Sydney":              "🌉",
  "Queenstown":          "🎿",
  "Auckland":            "🥝",
  "Bora Bora":           "🌺",

  // Montagne & Nature
  "Chamonix":            "⛷️",
  "Interlaken":          "🏔️",
  "Fjords de Norvège":   "🛳️",
  "Dolomites":           "🏔️",
};

export const CAT_ICONS = {
  plage:    "🏖️",
  montagne: "🏔️",
  ville:    "🏙️",
  aventure: "🧗",
  culture:  "🏛️",
};

export function getDestIcon(dest) {
  return DEST_ICONS[dest.nom] ?? CAT_ICONS[dest.categorie] ?? "🌍";
}

// Mots-clés → émoji pour les activités
const ACT_KEYWORDS = [
  ["🏄", ["surf", "surfing", "bodyboard"]],
  ["🤿", ["plongée", "plongee", "snorkeling", "snorkel", "apnée", "apnee"]],
  ["🥾", ["randonnée", "randonnee", "trek", "trekking", "rando", "hiking"]],
  ["⛷️", ["ski", "snowboard", "luge", "ski de fond"]],
  ["🧗", ["escalade", "via ferrata", "grimpe", "varappe"]],
  ["🚴", ["vélo", "velo", "cyclisme", "bike", "véloroute"]],
  ["🧘", ["yoga", "méditation", "meditation", "pilates", "mindfulness"]],
  ["💆", ["massage", "hammam", "bain", "spa", "relaxation", "soin"]],
  ["⛵", ["voilier", "voile", "catamaran", "croisière", "croisiere", "régate", "regata"]],
  ["🛶", ["kayak", "rafting", "canoë", "canoe", "paddle"]],
  ["🍽️", ["cuisine", "gastronomie", "cours de cuisine", "street food", "cooking"]],
  ["🍷", ["vin", "dégustation de vin", "cave", "vignoble", "winery", "dégustation", "degustation"]],
  ["🍹", ["cocktail", "rhum", "mojito", "bar", "tapas", "dégustation de rhum"]],
  ["🏛️", ["musée", "musee", "visite guidée", "visite guidee", "patrimoine", "monuments", "visite historique"]],
  ["🦁", ["safari", "faune", "animaux", "wildlife", "game drive"]],
  ["🎨", ["art", "street art", "graffiti", "galerie", "peinture", "atelier", "fresque"]],
  ["🛍️", ["marché", "marche", "shopping", "souk", "bazar", "marché local"]],
  ["🎵", ["concert", "musique", "festival", "opéra", "opera"]],
  ["💃", ["danse", "tango", "flamenco", "samba", "salsa", "rumba"]],
  ["🎈", ["montgolfière", "montgolfiere", "ballon"]],
  ["🪂", ["parachute", "saut en parachute", "parapente", "base jump"]],
  ["🏎️", ["quad", "4x4", "buggy", "moto", "motoneige"]],
  ["🎣", ["pêche", "peche", "fishing"]],
  ["📸", ["photo", "photographie", "shooting", "atelier photo"]],
  ["🌅", ["coucher de soleil", "lever du soleil", "sunset", "sunrise"]],
  ["🐘", ["éléphant", "elephant"]],
  ["🐬", ["dauphin", "requin", "baleine", "tortue", "observation des"]],
  ["🎋", ["temple", "pagode", "sanctuaire", "shinto", "bouddhiste"]],
  ["🕌", ["mosquée", "mosquee", "medina", "mellah"]],
  ["🌋", ["volcan", "volcanic"]],
  ["🧊", ["glacier", "glace", "iceberg"]],
  ["🌿", ["jungle", "forêt", "foret", "mangrove", "nature", "botanique", "jardin"]],
  ["🚡", ["téléphérique", "telepherique", "funiculaire", "télécabine"]],
  ["🎯", ["tyrolienne", "accrobranche", "zip line"]],
  ["🏊", ["natation", "piscine", "aqua", "water park", "thermes"]],
  ["🎭", ["théâtre", "theatre", "spectacle", "show"]],
  ["🏇", ["équitation", "equitation", "cheval", "horse"]],
  ["🛥️", ["jet ski", "motonautisme", "speedboat"]],
  ["🌸", ["jardins", "cherry blossom", "hanami", "fleurs"]],
  ["🎆", ["feux d'artifice", "festival nocturne", "illumination"]],
  ["🎑", ["célébration", "celebration", "cérémonie", "ceremonie", "rituel"]],
  ["🏋️", ["sport", "fitness", "entrainement"]],
  ["🌊", ["vagues", "bodysurf", "surfcasting"]],
  ["🚵", ["vtt", "descente", "mountain bike"]],
];

export function getActivityIcon(nom) {
  const lower = nom.toLowerCase();
  for (const [emoji, keywords] of ACT_KEYWORDS) {
    if (keywords.some(k => lower.includes(k))) return emoji;
  }
  return "🎯";
}
