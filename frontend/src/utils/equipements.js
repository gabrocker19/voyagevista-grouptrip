export const EQUIPEMENTS_META = {
  wifi:               { label: "Wi-Fi",            icon: "📶" },
  piscine:            { label: "Piscine",           icon: "🏊" },
  piscine_infinie:    { label: "Piscine à débord",  icon: "🏊" },
  piscine_privee:     { label: "Piscine privée",    icon: "🏊" },
  spa:                { label: "Spa",               icon: "💆" },
  restaurant:         { label: "Restaurant",        icon: "🍽️" },
  restaurant_etoile:  { label: "Restaurant étoilé", icon: "⭐" },
  bar:                { label: "Bar",               icon: "🍹" },
  bar_rooftop:        { label: "Bar rooftop",       icon: "🍸" },
  plage_privee:       { label: "Plage privée",      icon: "🏖️" },
  room_service:       { label: "Room service",      icon: "🛎️" },
  climatisation:      { label: "Climatisation",     icon: "❄️" },
  salle_sport:        { label: "Salle de sport",    icon: "🏋️" },
  parking:            { label: "Parking",           icon: "🅿️" },
  concierge:          { label: "Concierge",         icon: "🎩" },
  transfert_aeroport: { label: "Navette aéroport",  icon: "🚌" },
  butler_service:     { label: "Service butler",    icon: "🤵" },
  cuisine_equipee:    { label: "Cuisine équipée",   icon: "🍳" },
  cuisine_commune:    { label: "Cuisine commune",   icon: "🍳" },
  jardin:             { label: "Jardin",            icon: "🌿" },
  barbecue:           { label: "Barbecue",          icon: "🔥" },
  jacuzzi:            { label: "Jacuzzi",           icon: "🛁" },
  machine_a_laver:    { label: "Lave-linge",        icon: "🫧" },
  petit_dejeuner:     { label: "Petit-déj inclus",  icon: "🥐" },
  bagagerie:          { label: "Bagagerie",         icon: "🧳" },
  casiers:            { label: "Casiers",           icon: "🔒" },
  terrasse:           { label: "Terrasse",          icon: "🌅" },
  evenements_sociaux: { label: "Soirées / events",  icon: "🎉" },
  location_velos:     { label: "Location vélos",    icon: "🚲" },
  snorkeling:         { label: "Snorkeling",        icon: "🤿" },
  plongee:            { label: "Plongée",           icon: "🤿" },
};

export function parseEquipements(raw) {
  if (!raw) return [];
  if (Array.isArray(raw)) return raw;
  try { return JSON.parse(raw); } catch { return []; }
}
