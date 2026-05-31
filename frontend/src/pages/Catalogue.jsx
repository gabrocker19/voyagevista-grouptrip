import { useState, useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import { catalogueService } from "../services/catalogue.service";
import { CAT_ICONS, getDestIcon } from "../utils/icons";
import PageHeader from "../components/PageHeader";

const CATEGORIES = ["plage","montagne","ville","aventure","culture"];

export default function Catalogue() {
  const navigate = useNavigate();

  const [destinations, setDestinations] = useState([]);
  const [searchDest,   setSearchDest]   = useState("");
  const [catFiltre,    setCatFiltre]    = useState("");

  useEffect(() => {
    catalogueService.destinations().then(setDestinations).catch(console.error);
  }, []);

  const destsFiltrees = useMemo(() => destinations.filter(d => {
    const q = searchDest.toLowerCase();
    const matchSearch = !q || d.nom.toLowerCase().includes(q) || d.pays.toLowerCase().includes(q);
    const matchCat    = !catFiltre || d.categorie === catFiltre;
    return matchSearch && matchCat;
  }), [destinations, searchDest, catFiltre]);

  return (
    <div style={s.page}>

      <PageHeader
        title="🌍 Catalogue"
        subtitle="Explorez toutes nos destinations"
        backLabel="Tableau de bord"
        backTo="/dashboard"
      />

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
    </div>
  );
}

const s = {
  page: { fontFamily: "Arial, sans-serif", minHeight: "100vh", background: "#F5F4F0" },
  empty: { textAlign: "center", padding: "40px", color: "#73726c", fontSize: "14px" },

  filtersBar: { background:"white", padding:"14px 24px", boxShadow:"0 2px 4px rgba(0,0,0,0.05)", position:"sticky", top:0, zIndex:10 },
  searchInput: { width:"100%", padding:"10px 14px", borderRadius:"8px", fontSize:"14px", border:"1px solid #D1CFC5", marginBottom:"10px", boxSizing:"border-box" },
  chips: { display:"flex", gap:"8px", flexWrap:"wrap" },
  chip:  { padding:"6px 14px", borderRadius:"20px", border:"1px solid #D1CFC5", background:"white", cursor:"pointer", fontSize:"12px" },
  chipOn:{ padding:"6px 14px", borderRadius:"20px", border:"1px solid #185FA5", background:"#185FA5", color:"white", cursor:"pointer", fontSize:"12px" },

  destGrid: { display:"grid", gridTemplateColumns:"repeat(auto-fill, minmax(270px, 1fr))", gap:"16px", padding:"24px" },
  destCard: { background:"white", borderRadius:"12px", overflow:"hidden", boxShadow:"0 2px 8px rgba(0,0,0,0.07)", transition:"transform 0.15s, box-shadow 0.15s" },
  destImg:  { height:"160px", backgroundSize:"cover", backgroundPosition:"center", position:"relative", display:"flex", alignItems:"center", justifyContent:"center" },
  destEmoji:    { fontSize:"56px" },
  destIconBadge:{ position:"absolute", bottom:"10px", right:"10px", fontSize:"22px", background:"rgba(255,255,255,0.88)", borderRadius:"10px", padding:"4px 8px", lineHeight:1, backdropFilter:"blur(4px)" },
  destBadge:    { position:"absolute", top:"10px", left:"10px", background:"rgba(0,0,0,0.5)", color:"white", padding:"3px 10px", borderRadius:"12px", fontSize:"11px" },
  destBody:  { padding:"14px 16px" },
  destTitle: { fontSize:"16px", fontWeight:"bold", color:"#0C447C", marginBottom:"2px" },
  destPays:  { fontSize:"12px", color:"#73726c", marginBottom:"6px" },
  destDesc:  { fontSize:"12px", color:"#555", lineHeight:"1.4", marginBottom:"8px", display:"-webkit-box", WebkitLineClamp:2, WebkitBoxOrient:"vertical", overflow:"hidden" },
  destPrice: { fontSize:"13px", fontWeight:"bold", color:"#185FA5" },
  destCta:   { fontSize:"12px", color:"#185FA5", fontWeight:"600" },
};
