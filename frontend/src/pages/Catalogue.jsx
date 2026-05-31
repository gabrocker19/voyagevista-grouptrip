import { useState, useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import { catalogueService } from "../services/catalogue.service";
import { CAT_ICONS, getDestIcon, getActivityIcon } from "../utils/icons";
import PageHeader from "../components/PageHeader";

const HEBERG_ICO = { hotel:"🏨", airbnb:"🏠", hostel:"🛏️", villa:"🏡", resort:"🌴" };
const TRANSP_ICO = { avion:"✈️", train:"🚆", bus:"🚌", bateau:"⛴️" };

const CATEGORIES  = ["plage","montagne","ville","aventure","culture"];
const TYPES_HEB   = ["hotel","airbnb","hostel","villa","resort"];
const TYPES_TRANS = ["avion","train","bus","bateau"];

export default function Catalogue() {
  const navigate = useNavigate();
  const [tab, setTab] = useState("destinations");

  const [destinations,  setDestinations]  = useState([]);
  const [hebergements,  setHebergements]  = useState([]);
  const [transports,    setTransports]    = useState([]);
  const [activites,     setActivites]     = useState([]);
  const [loading,       setLoading]       = useState(false);

  // Filtres destinations
  const [searchDest, setSearchDest] = useState("");
  const [catFiltre,  setCatFiltre]  = useState("");

  // Filtres hébergements
  const [destIdHeb, setDestIdHeb] = useState("");
  const [typeHeb,   setTypeHeb]   = useState("");

  // Filtres transports
  const [typeTransport, setTypeTransport] = useState("");
  const [destIdTrans,   setDestIdTrans]   = useState("");

  // Filtres activités
  const [destIdAct, setDestIdAct] = useState("");

  // Charger les destinations une seule fois (utilisées aussi comme référence dans les autres onglets)
  useEffect(() => {
    catalogueService.destinations().then(setDestinations).catch(console.error);
  }, []);

  // Charger hébergements quand l'onglet est actif ou que le filtre change
  useEffect(() => {
    if (tab !== "hebergements") return;
    setLoading(true);
    const params = {};
    if (destIdHeb) params.destination_id = destIdHeb;
    catalogueService.hebergements(params).then(setHebergements).catch(console.error).finally(() => setLoading(false));
  }, [tab, destIdHeb]);

  // Charger transports quand l'onglet est actif ou que le filtre change
  useEffect(() => {
    if (tab !== "transports") return;
    setLoading(true);
    const params = {};
    if (typeTransport) params.type = typeTransport;
    if (destIdTrans) {
      const nomD = destinations.find(d => String(d.id) === String(destIdTrans))?.nom;
      if (nomD) params.destination = nomD;
    }
    catalogueService.transports(params).then(setTransports).catch(console.error).finally(() => setLoading(false));
  }, [tab, typeTransport, destIdTrans, destinations]);

  // Charger activités quand l'onglet est actif ou que le filtre change
  useEffect(() => {
    if (tab !== "activites") return;
    setLoading(true);
    const params = {};
    if (destIdAct) params.destination_id = destIdAct;
    catalogueService.activites(params).then(setActivites).catch(console.error).finally(() => setLoading(false));
  }, [tab, destIdAct]);

  // Filtrage client destinations
  const destsFiltrees = useMemo(() => destinations.filter(d => {
    const q = searchDest.toLowerCase();
    const matchSearch = !q || d.nom.toLowerCase().includes(q) || d.pays.toLowerCase().includes(q);
    const matchCat    = !catFiltre || d.categorie === catFiltre;
    return matchSearch && matchCat;
  }), [destinations, searchDest, catFiltre]);

  // Filtrage client hébergements par type
  const hebFiltres = useMemo(
    () => typeHeb ? hebergements.filter(h => h.type === typeHeb) : hebergements,
    [hebergements, typeHeb]
  );

  const nomDest = (id) => destinations.find(d => String(d.id) === String(id))?.nom || `#${id}`;

  const TABS = [
    { key:"destinations", label:`🌍 Destinations`, count: destinations.length },
    { key:"hebergements", label:`🏨 Hébergements`, count: hebergements.length },
    { key:"transports",   label:`✈️ Transports`,  count: transports.length   },
    { key:"activites",    label:`🎯 Activités`,    count: activites.length    },
  ];

  return (
    <div style={s.page}>

      <PageHeader
        title="🌍 Catalogue"
        subtitle="Explorez toutes nos destinations, hébergements, transports et activités"
        backLabel="Tableau de bord"
        backTo="/dashboard"
      />

      {/* ── Onglets ── */}
      <div style={s.tabBar}>
        {TABS.map(t => (
          <button key={t.key} onClick={() => setTab(t.key)} style={tab === t.key ? s.tabActive : s.tab}>
            {t.label}
            {t.count > 0 && <span style={s.tabCount}>{t.count}</span>}
          </button>
        ))}
      </div>

      {/* ══════════════ DESTINATIONS ══════════════ */}
      {tab === "destinations" && (
        <>
          <div style={s.filtersBar}>
            <input
              style={s.searchInput}
              type="text"
              placeholder="🔍 Rechercher une destination ou un pays..."
              value={searchDest}
              onChange={e => setSearchDest(e.target.value)}
            />
            <div style={s.chips}>
              <button style={catFiltre === "" ? s.chipOn : s.chip} onClick={() => setCatFiltre("")}>
                Toutes ({destinations.length})
              </button>
              {CATEGORIES.map(c => (
                <button key={c} style={catFiltre === c ? s.chipOn : s.chip} onClick={() => setCatFiltre(c)}>
                  {CAT_ICONS[c]} {c.charAt(0).toUpperCase()+c.slice(1)}&nbsp;({destinations.filter(d=>d.categorie===c).length})
                </button>
              ))}
            </div>
          </div>

          <div style={s.destGrid}>
            {destsFiltrees.length === 0
              ? <p style={s.empty}>Aucune destination trouvée.</p>
              : destsFiltrees.map(d => (
                <div
                  key={d.id}
                  style={{ ...s.destCard, cursor:"pointer" }}
                  onClick={() => navigate(`/catalogue/destinations/${d.id}`)}
                >
                  <div
                    style={{
                      ...s.destImg,
                      backgroundImage: d.image_url ? `url(${d.image_url})` : undefined,
                      backgroundColor: d.image_url ? undefined : "#E6F1FB",
                    }}
                  >
                    {!d.image_url
                      ? <span style={s.destEmoji}>{getDestIcon(d)}</span>
                      : <span style={s.destIconBadge}>{getDestIcon(d)}</span>
                    }
                    <span style={s.destBadge}>{d.categorie}</span>
                  </div>
                  <div style={s.destBody}>
                    <div style={s.destTitle}>{d.nom}</div>
                    <div style={s.destPays}>📍 {d.pays}</div>
                    <div style={s.destDesc}>{d.description}</div>
                    <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center" }}>
                      <div style={s.destPrice}>À partir de {d.prix_min}€</div>
                      <span style={s.destCta}>Voir →</span>
                    </div>
                  </div>
                </div>
              ))
            }
          </div>
        </>
      )}

      {/* ══════════════ HÉBERGEMENTS ══════════════ */}
      {tab === "hebergements" && (
        <>
          <div style={s.filtersBar}>
            <div style={s.filterRow}>
              <select style={s.select} value={destIdHeb} onChange={e => setDestIdHeb(e.target.value)}>
                <option value="">🌍 Toutes les destinations</option>
                {destinations.map(d => (
                  <option key={d.id} value={d.id}>{d.nom} — {d.pays}</option>
                ))}
              </select>
              <div style={s.chips}>
                <button style={typeHeb==="" ? s.chipOn : s.chip} onClick={() => setTypeHeb("")}>Tous les types</button>
                {TYPES_HEB.map(t => (
                  <button key={t} style={typeHeb===t ? s.chipOn : s.chip} onClick={() => setTypeHeb(t)}>
                    {HEBERG_ICO[t]} {t.charAt(0).toUpperCase()+t.slice(1)}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {loading ? <div style={s.loading}>Chargement...</div> : (
            <div style={s.listWrap}>
              <div style={s.resultsCount}>{hebFiltres.length} hébergement{hebFiltres.length>1?"s":""} trouvé{hebFiltres.length>1?"s":""}</div>
              {hebFiltres.length === 0
                ? <p style={s.empty}>Aucun hébergement trouvé.</p>
                : hebFiltres.map(h => (
                  <div key={h.id} style={s.listCard}>
                    <div style={s.listIcon}>{HEBERG_ICO[h.type] || "🏨"}</div>
                    <div style={s.listBody}>
                      <div style={s.listTitle}>{h.nom}</div>
                      <div style={s.listSub}>📍 {nomDest(h.destination_id)}</div>
                      <div style={s.listDesc}>{h.description}</div>
                      <div style={s.tags}>
                        <span style={s.tag}>{HEBERG_ICO[h.type]} {h.type}</span>
                        <span style={s.tag}>👤 {h.capacite} pers. max</span>
                      </div>
                    </div>
                    <div style={s.listPrice}>
                      <div style={s.priceMain}>{h.prix_nuit}€</div>
                      <div style={s.priceSub}>/nuit</div>
                    </div>
                  </div>
                ))
              }
            </div>
          )}
        </>
      )}

      {/* ══════════════ TRANSPORTS ══════════════ */}
      {tab === "transports" && (
        <>
          <div style={s.filtersBar}>
            <div style={s.filterRow}>
              <select style={s.select} value={destIdTrans} onChange={e => setDestIdTrans(e.target.value)}>
                <option value="">🌍 Toutes les destinations</option>
                {destinations.map(d => (
                  <option key={d.id} value={d.id}>{d.nom} — {d.pays}</option>
                ))}
              </select>
              <div style={s.chips}>
                <button style={typeTransport==="" ? s.chipOn : s.chip} onClick={() => setTypeTransport("")}>
                  Tous les moyens
                </button>
                {TYPES_TRANS.map(t => (
                  <button key={t} style={typeTransport===t ? s.chipOn : s.chip} onClick={() => setTypeTransport(t)}>
                    {TRANSP_ICO[t]} {t.charAt(0).toUpperCase()+t.slice(1)}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {loading ? <div style={s.loading}>Chargement...</div> : (
            <div style={s.listWrap}>
              <div style={s.resultsCount}>{transports.length} trajet{transports.length>1?"s":""} disponible{transports.length>1?"s":""}</div>
              {transports.length === 0
                ? <p style={s.empty}>Aucun transport trouvé.</p>
                : transports.map(t => (
                  <div key={t.id} style={s.listCard}>
                    <div style={s.listIcon}>{TRANSP_ICO[t.type] || "🚀"}</div>
                    <div style={s.listBody}>
                      <div style={s.listTitle}>{t.compagnie}</div>
                      <div style={s.trajetRow}>
                        <span style={s.villeFrom}>{t.origine}</span>
                        <span style={s.arrow}>→</span>
                        <span style={s.villeTo}>{t.destination}</span>
                      </div>
                      <div style={s.listSub}>
                        🗓️&nbsp;{new Date(t.date_depart).toLocaleDateString("fr-FR",{day:"2-digit",month:"short",year:"numeric",hour:"2-digit",minute:"2-digit"})}
                      </div>
                      <div style={s.tags}>
                        <span style={s.tag}>{TRANSP_ICO[t.type]} {t.type}</span>
                        <span style={s.tag}>💺 {t.places_dispo} places</span>
                      </div>
                    </div>
                    <div style={s.listPrice}>
                      <div style={s.priceMain}>{t.prix}€</div>
                      <div style={s.priceSub}>/pers.</div>
                    </div>
                  </div>
                ))
              }
            </div>
          )}
        </>
      )}

      {/* ══════════════ ACTIVITÉS ══════════════ */}
      {tab === "activites" && (
        <>
          <div style={s.filtersBar}>
            <div style={s.filterRow}>
              <select style={s.select} value={destIdAct} onChange={e => setDestIdAct(e.target.value)}>
                <option value="">🌍 Toutes les destinations</option>
                {destinations.map(d => (
                  <option key={d.id} value={d.id}>{d.nom} — {d.pays}</option>
                ))}
              </select>
            </div>
          </div>

          {loading ? <div style={s.loading}>Chargement...</div> : (
            <div style={s.listWrap}>
              <div style={s.resultsCount}>{activites.length} activité{activites.length>1?"s":""} trouvée{activites.length>1?"s":""}</div>
              {activites.length === 0
                ? <p style={s.empty}>Aucune activité trouvée.</p>
                : activites.map(a => (
                  <div key={a.id} style={s.listCard}>
                    <div style={s.listIcon}>{getActivityIcon(a.nom)}</div>
                    <div style={s.listBody}>
                      <div style={s.listTitle}>{a.nom}</div>
                      <div style={s.listSub}>📍 {nomDest(a.destination_id)}</div>
                      <div style={s.listDesc}>{a.description}</div>
                      <div style={s.tags}>
                        <span style={s.tag}>⏱ {a.duree_heures}h</span>
                        <span style={a.places_restantes === 0 ? s.tagFull : s.tag}>
                          {a.places_restantes === 0 ? "Complet" : `💺 ${a.places_restantes}/${a.capacite_max} places`}
                        </span>
                      </div>
                    </div>
                    <div style={s.listPrice}>
                      <div style={s.priceMain}>{a.prix}€</div>
                      <div style={s.priceSub}>/pers.</div>
                    </div>
                  </div>
                ))
              }
            </div>
          )}
        </>
      )}
    </div>
  );
}

const s = {
  page: { fontFamily: "Arial, sans-serif", minHeight: "100vh", background: "#F5F4F0" },
  loading: { textAlign: "center", padding: "60px", color: "#73726c" },
  empty:   { textAlign: "center", padding: "40px", color: "#73726c", fontSize: "14px" },


  // Tabs
  tabBar: { display:"flex", background:"white", borderBottom:"1px solid #E0DED6", padding:"0 24px", overflowX:"auto" },
  tab:       { padding:"14px 18px", border:"none", background:"none", cursor:"pointer", fontSize:"13px", color:"#73726c", borderBottom:"3px solid transparent", whiteSpace:"nowrap", display:"flex", alignItems:"center", gap:"6px" },
  tabActive: { padding:"14px 18px", border:"none", background:"none", cursor:"pointer", fontSize:"13px", color:"#185FA5", fontWeight:"bold", borderBottom:"3px solid #185FA5", whiteSpace:"nowrap", display:"flex", alignItems:"center", gap:"6px" },
  tabCount:  { background:"#E6F1FB", color:"#185FA5", borderRadius:"20px", padding:"1px 7px", fontSize:"11px", fontWeight:"bold" },

  // Filters bar
  filtersBar: { background:"white", padding:"14px 24px", boxShadow:"0 2px 4px rgba(0,0,0,0.05)" },
  filterRow:  { display:"flex", gap:"12px", flexWrap:"wrap", alignItems:"flex-start" },
  searchInput: { width:"100%", padding:"10px 14px", borderRadius:"8px", fontSize:"14px", border:"1px solid #D1CFC5", marginBottom:"10px", boxSizing:"border-box" },
  chips: { display:"flex", gap:"8px", flexWrap:"wrap" },
  chip:  { padding:"6px 14px", borderRadius:"20px", border:"1px solid #D1CFC5", background:"white", cursor:"pointer", fontSize:"12px" },
  chipOn:{ padding:"6px 14px", borderRadius:"20px", border:"1px solid #185FA5", background:"#185FA5", color:"white", cursor:"pointer", fontSize:"12px" },
  select: { padding:"9px 14px", borderRadius:"8px", border:"1px solid #D1CFC5", fontSize:"13px", background:"white", cursor:"pointer", minWidth:"240px" },

  // Destinations grid
  destGrid: { display:"grid", gridTemplateColumns:"repeat(auto-fill, minmax(270px, 1fr))", gap:"16px", padding:"24px" },
  destCard: { background:"white", borderRadius:"12px", overflow:"hidden", boxShadow:"0 2px 8px rgba(0,0,0,0.07)" },
  destImg:  { height:"150px", backgroundSize:"cover", backgroundPosition:"center", position:"relative", display:"flex", alignItems:"center", justifyContent:"center" },
  destEmoji:    { fontSize:"52px" },
  destIconBadge:{ position:"absolute", bottom:"10px", right:"10px", fontSize:"22px", background:"rgba(255,255,255,0.88)", borderRadius:"10px", padding:"4px 8px", lineHeight:1, backdropFilter:"blur(4px)" },
  destBadge:    { position:"absolute", top:"10px", left:"10px", background:"rgba(0,0,0,0.45)", color:"white", padding:"3px 10px", borderRadius:"12px", fontSize:"11px" },
  destBody: { padding:"14px 16px" },
  destTitle:{ fontSize:"17px", fontWeight:"bold", color:"#0C447C", marginBottom:"2px" },
  destPays: { fontSize:"12px", color:"#73726c", marginBottom:"4px" },
  destDesc: { fontSize:"12px", color:"#555", lineHeight:"1.4", marginBottom:"8px", display:"-webkit-box", WebkitLineClamp:2, WebkitBoxOrient:"vertical", overflow:"hidden" },
  destPrice:{ fontSize:"14px", fontWeight:"bold", color:"#185FA5" },
  destCta:  { fontSize:"12px", color:"#185FA5", fontWeight:"600", background:"#E6F1FB", padding:"3px 10px", borderRadius:"12px" },

  // List items (hébergements / transports / activités)
  listWrap: { padding:"16px 24px", display:"flex", flexDirection:"column", gap:"10px" },
  resultsCount: { fontSize:"13px", color:"#73726c", marginBottom:"4px" },
  listCard: { background:"white", borderRadius:"10px", padding:"14px 16px", display:"flex", alignItems:"flex-start", gap:"14px", boxShadow:"0 2px 6px rgba(0,0,0,0.06)" },
  listIcon: { fontSize:"28px", flexShrink:0, width:"48px", height:"48px", background:"#F0F4F8", borderRadius:"10px", display:"flex", alignItems:"center", justifyContent:"center" },
  listBody: { flex:1, minWidth:0 },
  listTitle:{ fontSize:"15px", fontWeight:"bold", color:"#0C447C", marginBottom:"2px" },
  listSub:  { fontSize:"12px", color:"#73726c", marginBottom:"4px" },
  listDesc: { fontSize:"12px", color:"#555", lineHeight:"1.4", marginBottom:"6px", display:"-webkit-box", WebkitLineClamp:2, WebkitBoxOrient:"vertical", overflow:"hidden" },
  tags: { display:"flex", gap:"6px", flexWrap:"wrap" },
  tag:  { background:"#F0F4F8", color:"#444", padding:"3px 9px", borderRadius:"10px", fontSize:"11px" },
  tagFull: { background:"#FDE8E8", color:"#C0392B", padding:"3px 9px", borderRadius:"10px", fontSize:"11px" },
  listPrice: { textAlign:"right", flexShrink:0 },
  priceMain: { fontSize:"20px", fontWeight:"bold", color:"#0C447C" },
  priceSub:  { fontSize:"11px", color:"#73726c" },

  // Transport specific
  trajetRow: { display:"flex", alignItems:"center", gap:"8px", marginBottom:"4px" },
  villeFrom: { fontSize:"14px", fontWeight:"600", color:"#2C2C2A" },
  villeTo:   { fontSize:"14px", fontWeight:"600", color:"#2C2C2A" },
  arrow:     { color:"#185FA5", fontWeight:"bold", fontSize:"16px" },
};
