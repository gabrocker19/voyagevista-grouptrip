import { useState, useEffect, useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { catalogueService } from "../services/catalogue.service";
import { groupService } from "../services/group.service";
import { api } from "../services/api";

const TRANSP_ICONS = { avion:"✈️", train:"🚆", bus:"🚌", bateau:"⛴️" };

export default function Transport() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [groupe,      setGroupe]      = useState(null);
  const [destination, setDestination] = useState(null);
  const [transports,  setTransports]  = useState([]);
  const [loading,     setLoading]     = useState(true);
  const [selected,    setSelected]    = useState(null);
  const [message,     setMessage]     = useState("");
  const [filtre,      setFiltre]      = useState(null); // null = tous les types disponibles

  useEffect(() => {
    setLoading(true);

    groupService.getOne(id)
      .then(async (g) => {
        setGroupe(g);

        if (!g.destination_id) {
          // Pas de destination validée → tous les transports
          const all = await catalogueService.transports({});
          setTransports(all);
          return;
        }

        // Récupérer la destination validée
        const dest = await api.get(`/api/destinations/${g.destination_id}`);
        setDestination(dest);

        // Recherche serveur par nom de destination (LIKE %nom%)
        let results = await catalogueService.transports({ destination: dest.nom });

        // Si aucun résultat avec le nom, essayer avec le pays
        if (results.length === 0) {
          results = await catalogueService.transports({ destination: dest.pays });
        }

        setTransports(results);

        // Sélectionner automatiquement le premier type disponible
        if (results.length > 0) {
          const premierType = results[0].type;
          setFiltre(premierType);
        }
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [id]);

  // Types disponibles parmi les transports filtrés pour cette destination
  const typesDisponibles = useMemo(() => {
    const types = [...new Set(transports.map(t => t.type))];
    return types;
  }, [transports]);

  // Transports affichés selon le filtre de type sélectionné
  const transportsFiltres = useMemo(() => {
    if (!filtre) return transports;
    return transports.filter(t => t.type === filtre);
  }, [transports, filtre]);

  // Si filtre actif n'est plus dans les types dispos, reset
  useEffect(() => {
    if (filtre && typesDisponibles.length > 0 && !typesDisponibles.includes(filtre)) {
      setFiltre(typesDisponibles[0]);
    }
  }, [typesDisponibles]);

  const handleSelect = (transport) => {
    setSelected(transport.id);
    setMessage(`✓ Transport sélectionné : ${transport.compagnie} — ${transport.prix}€/pers`);
  };

  const handleContinue = () => {
    if (!selected) { setMessage("Veuillez sélectionner un transport."); return; }
    sessionStorage.setItem(`transport_${id}`, selected);
    navigate(`/groupes/${id}/hebergement`);
  };

  if (loading) return <div style={s.loading}>Chargement...</div>;

  return (
    <div style={s.page}>

      {/* Header */}
      <div style={s.header}>
        <div>
          <button onClick={() => navigate(`/groupes/${id}`)} style={s.btnBack}>← Retour au groupe</button>
          <h1 style={s.title}>✈️ Transport</h1>
          <p style={s.sub}>{groupe?.nom}</p>
          {destination && (
            <div style={s.destBadge}>
              📍 Destination validée : <strong>{destination.nom}</strong>, {destination.pays}
            </div>
          )}
        </div>
        <div style={s.steps}>
          <span style={s.stepActive}>1. Transport</span>
          <span style={s.stepArrow}>→</span>
          <span style={s.stepInactive}>2. Hébergement</span>
          <span style={s.stepArrow}>→</span>
          <span style={s.stepInactive}>3. Activités</span>
          <span style={s.stepArrow}>→</span>
          <span style={s.stepInactive}>4. Itinéraire</span>
        </div>
      </div>

      <div style={s.body}>
        {message && <div style={s.success}>{message}</div>}

        {/* Filtre par type — uniquement les types disponibles pour cette destination */}
        {typesDisponibles.length > 1 && (
          <div style={s.section}>
            <h2 style={s.sectionTitle}>Moyen de transport</h2>
            <div style={s.typeFilters}>
              {typesDisponibles.map(t => (
                <button
                  key={t}
                  onClick={() => setFiltre(t)}
                  style={filtre === t ? s.typeActive : s.typeBtn}
                >
                  {TRANSP_ICONS[t]} {t}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Liste transports */}
        <div style={s.section}>
          <h2 style={s.sectionTitle}>
            Trajets disponibles
            {destination && (
              <span style={s.destLabel}>
                → {destination.nom}
              </span>
            )}
            <span style={s.counter}>{transportsFiltres.length} résultat{transportsFiltres.length > 1 ? "s" : ""}</span>
          </h2>

          {transportsFiltres.length === 0 ? (
            <div style={s.empty}>
              <p>Aucun trajet disponible{destination ? ` vers ${destination.nom}` : ""}.</p>
              {!destination && <p style={s.emptyHint}>La destination du groupe n'a pas encore été validée.</p>}
            </div>
          ) : (
            <div style={s.list}>
              {transportsFiltres.map(t => (
                <div
                  key={t.id}
                  style={{
                    ...s.card,
                    border: selected === t.id ? "2px solid #185FA5" : "1px solid #E0DED6",
                  }}
                >
                  <div style={s.cardLeft}>
                    <div style={s.typeChip}>{TRANSP_ICONS[t.type]} {t.type}</div>
                    <div style={s.compagnie}>{t.compagnie}</div>
                    <div style={s.trajet}>
                      <span style={s.ville}>{t.origine}</span>
                      <span style={s.arrow}>→</span>
                      <span style={s.ville}>{t.destination}</span>
                    </div>
                    <div style={s.dates}>
                      🗓️ {new Date(t.date_depart).toLocaleDateString("fr-FR", {
                        day: "2-digit", month: "short", year: "numeric",
                        hour: "2-digit", minute: "2-digit",
                      })}
                    </div>
                    <div style={s.places}>💺 {t.places_dispo} places disponibles</div>
                  </div>
                  <div style={s.cardRight}>
                    <div style={s.prix}>{t.prix}€<span style={s.perPers}>/pers</span></div>
                    <button
                      onClick={() => handleSelect(t)}
                      style={{
                        ...s.btnSelect,
                        background: selected === t.id ? "#185FA5" : "white",
                        color:      selected === t.id ? "white"   : "#185FA5",
                      }}
                    >
                      {selected === t.id ? "✓ Sélectionné" : "Sélectionner"}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <button onClick={handleContinue} style={s.btnContinue}>
          Continuer → Hébergement
        </button>
      </div>
    </div>
  );
}

const s = {
  page:    { fontFamily:"Arial, sans-serif", minHeight:"100vh", background:"#F5F4F0" },
  loading: { textAlign:"center", padding:"60px", color:"#73726c" },
  btnBack: { background:"none", border:"none", color:"rgba(255,255,255,0.7)", cursor:"pointer", fontSize:"13px", padding:"0", marginBottom:"14px", display:"block" },
  header:  { background:"linear-gradient(135deg, #0C447C 0%, #1A7FC4 100%)", color:"white", padding:"28px 32px", display:"flex", justifyContent:"space-between", alignItems:"flex-start" },
  title:   { fontSize:"26px", fontWeight:"800", marginBottom:"4px", letterSpacing:"-0.3px" },
  sub:     { opacity:0.82, fontSize:"13px", marginBottom:"6px" },
  destBadge: { display:"inline-block", background:"rgba(255,255,255,0.15)", padding:"5px 12px", borderRadius:"20px", fontSize:"13px", marginTop:"6px" },
  steps:   { display:"flex", alignItems:"center", gap:"8px", flexWrap:"wrap", marginTop:"12px" },
  stepActive:   { background:"white", color:"#0C447C", padding:"4px 12px", borderRadius:"20px", fontSize:"12px", fontWeight:"bold" },
  stepInactive: { color:"rgba(255,255,255,0.6)", fontSize:"12px" },
  stepArrow:    { color:"rgba(255,255,255,0.4)", fontSize:"12px" },
  body:    { padding:"24px 32px", display:"flex", flexDirection:"column", gap:"16px" },
  success: { background:"#EAF3DE", color:"#3B6D11", padding:"12px 16px", borderRadius:"8px", fontSize:"14px" },
  section: { background:"white", borderRadius:"12px", padding:"20px 24px", boxShadow:"0 2px 6px rgba(0,0,0,0.06)" },
  sectionTitle: { fontSize:"15px", fontWeight:"bold", color:"#0C447C", marginBottom:"14px", display:"flex", justifyContent:"space-between", alignItems:"center", gap:"8px" },
  destLabel: { flex:1, fontSize:"13px", fontWeight:"normal", color:"#185FA5" },
  counter: { fontSize:"12px", fontWeight:"normal", color:"#73726c" },
  typeFilters: { display:"flex", gap:"8px", flexWrap:"wrap" },
  typeBtn:    { padding:"8px 18px", borderRadius:"20px", border:"1px solid #D1CFC5", background:"white", cursor:"pointer", fontSize:"13px" },
  typeActive: { padding:"8px 18px", borderRadius:"20px", border:"1px solid #185FA5", background:"#185FA5", color:"white", cursor:"pointer", fontSize:"13px" },
  list:  { display:"flex", flexDirection:"column", gap:"10px" },
  card:  { display:"flex", justifyContent:"space-between", alignItems:"center", padding:"16px", borderRadius:"10px", background:"#FAFAF8", gap:"16px" },
  cardLeft:  { flex:1 },
  typeChip:  { display:"inline-block", background:"#E6F1FB", color:"#0C447C", padding:"2px 10px", borderRadius:"12px", fontSize:"11px", marginBottom:"6px" },
  compagnie: { fontSize:"15px", fontWeight:"bold", color:"#0C447C", marginBottom:"4px" },
  trajet:    { display:"flex", alignItems:"center", gap:"8px", marginBottom:"4px" },
  ville:     { fontSize:"14px", fontWeight:"500", color:"#2C2C2A" },
  arrow:     { color:"#185FA5", fontWeight:"bold" },
  dates:     { fontSize:"12px", color:"#73726c", marginBottom:"2px" },
  places:    { fontSize:"12px", color:"#73726c" },
  cardRight: { textAlign:"center", flexShrink:0 },
  prix:      { fontSize:"22px", fontWeight:"bold", color:"#0C447C", marginBottom:"8px" },
  perPers:   { fontSize:"12px", fontWeight:"normal", color:"#73726c" },
  btnSelect: { padding:"8px 16px", borderRadius:"6px", border:"1px solid #185FA5", cursor:"pointer", fontSize:"13px", fontWeight:"500", whiteSpace:"nowrap" },
  empty:     { color:"#73726c", fontSize:"14px", textAlign:"center", padding:"20px" },
  emptyHint: { fontSize:"12px", marginTop:"8px" },
  btnContinue: { background:"#185FA5", color:"white", border:"none", padding:"14px", borderRadius:"8px", cursor:"pointer", fontSize:"15px", fontWeight:"bold" },
};
