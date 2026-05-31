import { useState, useEffect, useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { catalogueService } from "../services/catalogue.service";
import { groupService } from "../services/group.service";
import { voteService } from "../services/vote.service";
import { api } from "../services/api";
import { useAuth } from "../context/AuthContext";
import PageHeader from "../components/PageHeader";

export default function Activites() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();

  const [groupe,    setGroupe]    = useState(null);
  const [activites, setActivites] = useState([]);
  const [itineraire,setItineraire]= useState(null);
  const [loading,   setLoading]   = useState(true);

  // Ma sélection locale (IDs)
  const [selection,    setSelection]    = useState([]);
  const [resultats,    setResultats]    = useState([]);
  const [totalMembres, setTotalMembres] = useState(0);
  const [message,      setMessage]      = useState("");
  const [error,        setError]        = useState("");
  const [voted,        setVoted]        = useState(false);

  const chargerVotes = async () => {
    try {
      const res = await voteService.resultats(id, "activite");
      setResultats(res.resultats);
      setTotalMembres(res.total_membres);
      // Charger ma sélection depuis mon vote existant
      if (res.mon_vote) {
        const ids = res.mon_vote.split(",").filter(Boolean).map(Number);
        setSelection(ids);
        setVoted(true);
      }
    } catch {}
  };

  useEffect(() => {
    Promise.all([
      groupService.getOne(id),
      api.get(`/api/itineraires/groupe/${id}`).catch(() => null),
    ]).then(([g, itin]) => {
      setGroupe(g);
      setItineraire(itin);
      // Pré-remplir depuis itinéraire validé
      if (itin?.activites?.length > 0) {
        setSelection(itin.activites.map(a => a.id));
      }
      const params = g.destination_id ? { destination_id: g.destination_id } : {};
      return catalogueService.activites(params);
    }).then(setActivites)
      .catch(console.error)
      .finally(() => setLoading(false));

    chargerVotes();
  }, [id]);

  // Nombre de votes par activité (chaque valeur = liste CSV des IDs votés par un membre)
  const votesCounts = useMemo(() => {
    const counts = {};
    resultats.forEach(r => {
      if (!r.valeur) return;
      r.valeur.split(",").filter(Boolean).forEach(actId => {
        counts[actId] = (counts[actId] || 0) + parseInt(r.nb_votes || 1);
      });
    });
    return counts;
  }, [resultats]);

  const isOrganisateur = groupe?.organisateur_id === user?.id;
  const activitesValidees = itineraire?.activites?.map(a => a.id) || [];

  const handleToggle = (activite) => {
    if (activite.places_restantes === 0) return;
    setSelection(prev =>
      prev.includes(activite.id) ? prev.filter(i => i !== activite.id) : [...prev, activite.id]
    );
  };

  const handleVoter = async () => {
    try {
      const valeur = selection.join(",") || "0";
      await voteService.voter({ groupe_id: id, type: "activite", valeur });
      setVoted(true);
      setMessage("✓ Votes enregistrés !");
      await chargerVotes();
    } catch (err) { setMessage(err.message); }
  };

  const handleValider = async () => {
    if (!isOrganisateur) return;
    try {
      const valeur = selection.join(",") || "";
      await voteService.valider({ groupe_id: id, type: "activite", valeur });
      const itin = await api.get(`/api/itineraires/groupe/${id}`).catch(() => null);
      setItineraire(itin);
      setMessage("✓ Activités validées !");
    } catch (err) { setMessage(err.message); }
  };

  if (loading) return <div style={s.loading}>Chargement...</div>;

  const totalActivitesPrix = activites
    .filter(a => selection.includes(a.id))
    .reduce((sum, a) => sum + parseFloat(a.prix), 0);

  return (
    <div style={s.page}>
      <PageHeader
        title="🎯 Activités"
        subtitle={groupe?.nom}
        backLabel="Retour au groupe"
        backTo={`/groupes/${id}`}
        right={
          (() => {
            const pret = itineraire?.transport_id && itineraire?.hebergement_id;
            return (
              <button
                onClick={() => pret
                  ? navigate(`/groupes/${id}/itineraire`)
                  : setError("Transport et hébergement doivent être validés avant de passer à l'itinéraire.")
                }
                style={{ ...s.btnNext, opacity: pret ? 1 : 0.45, cursor: pret ? "pointer" : "not-allowed" }}
                title={pret ? "" : "Transport et hébergement requis"}
              >
                {pret ? "Itinéraire →" : "🔒 Itinéraire"}
              </button>
            );
          })()
        }
      />

      <div style={s.body}>
        {error   && <div style={s.errorBox}>{error}</div>}
        {message && <div style={s.toast}>{message}</div>}

        <div style={s.infoBar}>
          <span>
            {selection.length > 0
              ? `${selection.length} activité${selection.length>1?"s":""} sélectionnée${selection.length>1?"s":""} — ${totalActivitesPrix.toFixed(0)}€/pers`
              : "Sélectionnez les activités souhaitées (optionnel)"}
          </span>
          <div style={{ display:"flex", gap:"8px" }}>
            <button onClick={handleVoter} style={s.btnVoter}>
              {voted ? "✓ Mettre à jour mon vote" : "Enregistrer mon vote"}
            </button>
            {isOrganisateur && (
              <button onClick={handleValider} style={s.btnValider}>
                👑 Valider la sélection
              </button>
            )}
          </div>
        </div>

        <div style={s.grid}>
          {activites.map(a => {
            const isSelected = selection.includes(a.id);
            const isComplet = a.places_restantes === 0;
            const isValidee = activitesValidees.includes(a.id);
            const nbVotes = votesCounts[String(a.id)] || 0;
            const pct = totalMembres > 0 ? Math.round((nbVotes / totalMembres) * 100) : 0;

            return (
              <div
                key={a.id}
                onClick={() => !isComplet && handleToggle(a)}
                style={{
                  ...s.card,
                  border: isValidee ? "2px solid #42A85A" : isSelected ? "2px solid #185FA5" : isComplet ? "1px solid #F09595" : "1px solid #E0DED6",
                  opacity: isComplet ? 0.7 : 1,
                  cursor: isComplet ? "not-allowed" : "pointer",
                }}
              >
                <div style={s.cardTop}>
                  <h3 style={s.cardName}>{a.nom}</h3>
                  {isValidee
                    ? <span style={s.badgeValidee}>✓ Validée</span>
                    : isComplet
                      ? <span style={s.badgeComplet}>Complet</span>
                      : isSelected
                        ? <span style={s.badgeSelected}>✓ Ajouté</span>
                        : <span style={s.badgeDisponible}>{a.places_restantes} places</span>
                  }
                </div>
                <p style={s.cardDesc}>{a.description}</p>
                {/* Barre de vote */}
                <div style={s.voteBarBg}><div style={{...s.voteBarFill, width:`${pct}%`}}/></div>
                <div style={s.voteStats}>{nbVotes} vote{nbVotes!==1?"s":""} ({pct}%)</div>
                <div style={s.cardFooter}>
                  {a.duree_heures && <span style={s.cardInfo}>⏱️ {a.duree_heures}h</span>}
                  <div style={s.prix}>{a.prix}€<span style={s.perPers}>/pers</span></div>
                </div>
              </div>
            );
          })}
        </div>

        {isOrganisateur && (
          <div style={s.infoBox}>
            👑 Sélectionnez les activités à inclure puis cliquez sur <strong>"Valider la sélection"</strong> pour les confirmer.
          </div>
        )}
      </div>
    </div>
  );
}

const s = {
  page:    { fontFamily:"Arial, sans-serif", minHeight:"100vh", background:"#F5F4F0" },
  loading: { textAlign:"center", padding:"60px", color:"#73726c" },
  body:    { padding:"20px 24px 32px", display:"flex", flexDirection:"column", gap:"14px" },
  toast:   { background:"#EAF3DE", color:"#3B6D11", padding:"10px 16px", borderRadius:"8px", fontSize:"13px" },
  btnNext:  { background:"rgba(255,255,255,0.18)", border:"1px solid rgba(255,255,255,0.45)", color:"white", padding:"6px 14px", borderRadius:"20px", cursor:"pointer", fontSize:"13px", fontWeight:"600", whiteSpace:"nowrap" },
  errorBox: { background:"#FCEBEB", color:"#A32D2D", padding:"10px 16px", borderRadius:"8px", fontSize:"13px" },
  infoBar: { background:"white", borderRadius:"10px", padding:"14px 18px", display:"flex", justifyContent:"space-between", alignItems:"center", boxShadow:"0 2px 6px rgba(0,0,0,0.06)", flexWrap:"wrap", gap:"10px" },
  btnVoter:  { padding:"8px 16px", borderRadius:"8px", background:"#185FA5", color:"white", border:"none", cursor:"pointer", fontSize:"13px", fontWeight:"600" },
  btnValider:{ padding:"8px 16px", borderRadius:"8px", background:"#EAF3DE", color:"#3B6D11", border:"none", cursor:"pointer", fontSize:"13px", fontWeight:"600" },
  grid:    { display:"grid", gridTemplateColumns:"repeat(auto-fill, minmax(240px, 1fr))", gap:"12px" },
  card:    { borderRadius:"10px", background:"white", padding:"14px", transition:"border 0.15s", boxShadow:"0 1px 4px rgba(0,0,0,0.05)" },
  cardTop: { display:"flex", justifyContent:"space-between", alignItems:"flex-start", marginBottom:"6px", gap:"6px" },
  cardName:{ fontSize:"14px", fontWeight:"bold", color:"#0C447C", flex:1 },
  badgeValidee:   { fontSize:"10px", padding:"2px 8px", borderRadius:"12px", background:"#D4EDDA", color:"#42A85A", whiteSpace:"nowrap", fontWeight:"bold" },
  badgeComplet:   { fontSize:"10px", padding:"2px 8px", borderRadius:"12px", background:"#FCEBEB", color:"#A32D2D", whiteSpace:"nowrap" },
  badgeSelected:  { fontSize:"10px", padding:"2px 8px", borderRadius:"12px", background:"#E6F1FB", color:"#185FA5", whiteSpace:"nowrap" },
  badgeDisponible:{ fontSize:"10px", padding:"2px 8px", borderRadius:"12px", background:"#EAF3DE", color:"#3B6D11", whiteSpace:"nowrap" },
  cardDesc:{ fontSize:"12px", color:"#73726c", marginBottom:"8px", lineHeight:"1.4" },
  voteBarBg:  { height:"4px", background:"#E0DED6", borderRadius:"3px", overflow:"hidden", marginBottom:"3px" },
  voteBarFill:{ height:"100%", background:"#185FA5", borderRadius:"3px", transition:"width 0.3s" },
  voteStats:  { fontSize:"11px", color:"#73726c", marginBottom:"6px" },
  cardFooter: { display:"flex", justifyContent:"space-between", alignItems:"center" },
  cardInfo:   { fontSize:"12px", color:"#73726c" },
  prix:    { fontSize:"16px", fontWeight:"bold", color:"#0C447C" },
  perPers: { fontSize:"11px", fontWeight:"normal", color:"#73726c" },
  infoBox: { background:"#E6F1FB", color:"#0C447C", padding:"14px 18px", borderRadius:"8px", fontSize:"13px" },
};
