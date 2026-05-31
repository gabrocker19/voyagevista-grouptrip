import { useState, useEffect, useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { catalogueService } from "../services/catalogue.service";
import { groupService } from "../services/group.service";
import { voteService } from "../services/vote.service";
import { api } from "../services/api";
import { useAuth } from "../context/AuthContext";
import PageHeader from "../components/PageHeader";
import BudgetBar from "../components/BudgetBar";

const TRANSP_ICONS = { avion:"✈️", train:"🚆", bus:"🚌", bateau:"⛴️" };

export default function Transport() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();

  const [groupe,      setGroupe]      = useState(null);
  const [destination, setDestination] = useState(null);
  const [transports,  setTransports]  = useState([]);
  const [itineraire,  setItineraire]  = useState(null);
  const [loading,     setLoading]     = useState(true);
  const [filtre,      setFiltre]      = useState(null);

  const [resultats,     setResultats]     = useState([]);
  const [monVote,       setMonVote]       = useState(null);
  const [totalMembres,  setTotalMembres]  = useState(0);
  const [message,       setMessage]       = useState("");
  const [error,         setError]         = useState("");

  const chargerVotes = async (groupeId) => {
    try {
      const res = await voteService.resultats(groupeId, "transport");
      setResultats(res.resultats);
      setMonVote(res.mon_vote);
      setTotalMembres(res.total_membres);
    } catch {}
  };

  useEffect(() => {
    groupService.getOne(id).then(async (g) => {
      setGroupe(g);

      // Itinéraire existant
      api.get(`/api/itineraires/groupe/${id}`).then(setItineraire).catch(() => {});

      // Votes
      chargerVotes(id);

      if (!g.destination_id) {
        const all = await catalogueService.transports({});
        setTransports(all);
        setLoading(false);
        return;
      }
      const dest = await api.get(`/api/destinations/${g.destination_id}`);
      setDestination(dest);
      let results = await catalogueService.transports({ destination: dest.nom });
      if (results.length === 0) results = await catalogueService.transports({ destination: dest.pays });
      setTransports(results);
      if (results.length > 0) setFiltre(results[0].type);
      setLoading(false);
    }).catch(console.error);
  }, [id]);

  const typesDisponibles = useMemo(() => [...new Set(transports.map(t => t.type))], [transports]);
  const transportsFiltres = useMemo(() => filtre ? transports.filter(t => t.type === filtre) : transports, [transports, filtre]);

  const totalVotes = resultats.reduce((a, r) => a + parseInt(r.nb_votes), 0);
  const isOrganisateur = groupe?.organisateur_id === user?.id;

  const handleVoter = async (transportId) => {
    setError("");
    try {
      await voteService.voter({ groupe_id: id, type: "transport", valeur: String(transportId) });
      setMonVote(String(transportId));
      setMessage("✓ Vote enregistré !");
      await chargerVotes(id);
    } catch (err) { setError(err.message); }
  };

  const handleValider = async (valeur) => {
    setError("");
    try {
      await voteService.valider({ groupe_id: id, type: "transport", valeur });
      const itin = await api.get(`/api/itineraires/groupe/${id}`).catch(() => null);
      setItineraire(itin);
      setMessage("✓ Transport validé !");
    } catch (err) { setError(err.message); }
  };

  if (loading) return <div style={s.loading}>Chargement...</div>;

  const transportValideId = itineraire?.transport_id ? String(itineraire.transport_id) : null;

  return (
    <div style={s.page}>
      <style>{`@keyframes valPulse{0%{box-shadow:0 0 0 0 rgba(66,168,90,.55)}50%{box-shadow:0 0 0 8px rgba(66,168,90,0)}100%{box-shadow:0 0 0 4px rgba(66,168,90,.18)}}`}</style>

      <PageHeader
        title="✈️ Transport"
        subtitle={groupe?.nom}
        backLabel="Retour au groupe"
        backTo={`/groupes/${id}`}
        right={
          <div style={{ display:"flex", alignItems:"center", gap:"10px" }}>
            <span style={s.voteCount}>{totalVotes}/{totalMembres} vote{totalMembres>1?"s":""}</span>
            <button
              onClick={() => navigate(`/groupes/${id}/hebergement`)}
              style={s.btnNext}
            >
              Hébergement →
            </button>
          </div>
        }
      />

      <div style={s.body}>
        {error   && <div style={s.errorBox}>{error}</div>}
        {message && <div style={s.toast}>{message}</div>}
        {monVote && (
          <div style={s.banner}>
            ✓ Vous avez voté pour <strong>{transports.find(t=>String(t.id)===monVote)?.compagnie}</strong>
          </div>
        )}
        {destination && (
          <div style={s.destBanner}>📍 Destination : <strong>{destination.nom}</strong>, {destination.pays}</div>
        )}

        {/* Filtre type */}
        {typesDisponibles.length > 1 && (
          <div style={s.filterBar}>
            {typesDisponibles.map(t => (
              <button key={t} onClick={() => setFiltre(t)} style={filtre===t ? s.chipOn : s.chip}>
                {TRANSP_ICONS[t]} {t}
              </button>
            ))}
          </div>
        )}

        {/* Barre de budget */}
        {(() => {
          const valide       = itineraire?.cout_total || 0;
          const monVoteExtra = transportValideId
            ? 0
            : parseFloat(transports.find(t => String(t.id) === monVote)?.prix || 0);
          return (
            <BudgetBar
              budget={groupe?.budget_max}
              valide={valide}
              monVoteExtra={monVoteExtra}
            />
          );
        })()}

        {/* Liste transports */}
        <div style={s.list}>
          {transportsFiltres.length === 0
            ? <p style={s.empty}>Aucun transport disponible.</p>
            : transportsFiltres.map(t => {
              const res = resultats.find(r => r.valeur === String(t.id));
              const nbVotes = res ? parseInt(res.nb_votes) : 0;
              const pct = totalMembres > 0 ? Math.round((nbVotes/totalMembres)*100) : 0;
              const isMyVote = monVote === String(t.id);
              const isValidated = transportValideId === String(t.id);

              return (
                <div key={t.id} style={{
                  ...s.card,
                  border: isValidated ? "2px solid #42A85A" : isMyVote ? "2px solid #185FA5" : "1px solid #E0DED6",
                  boxShadow: isValidated ? "0 0 0 4px rgba(66,168,90,0.18)" : undefined,
                  animation: isValidated ? "valPulse 0.7s ease-out" : undefined,
                }}>
                  <div style={s.cardLeft}>
                    <div style={s.typeChip}>{TRANSP_ICONS[t.type]} {t.type}</div>
                    <div style={s.compagnie}>
                      {t.compagnie}
                      {isValidated && <span style={s.validBadge}>✓ Validé</span>}
                    </div>
                    <div style={s.trajet}>
                      <span style={s.ville}>{t.origine}</span>
                      <span style={s.arrow}>→</span>
                      <span style={s.ville}>{t.destination}</span>
                    </div>
                    <div style={s.dates}>🗓️ {new Date(t.date_depart).toLocaleDateString("fr-FR",{day:"2-digit",month:"short",year:"numeric",hour:"2-digit",minute:"2-digit"})}</div>
                    <div style={s.places}>💺 {t.places_dispo} places</div>
                    {/* Barre de vote */}
                    <div style={s.voteBarBg}><div style={{...s.voteBarFill, width:`${pct}%`}}/></div>
                    <div style={s.voteStats}>{nbVotes} vote{nbVotes!==1?"s":""} ({pct}%) {res?.votants && <span style={s.votants}>— {res.votants}</span>}</div>
                  </div>
                  <div style={s.cardRight}>
                    <div style={s.prix}>{t.prix}€<span style={s.perPers}>/pers</span></div>
                    <button
                      onClick={() => handleVoter(t.id)}
                      style={{...s.btnVote, background:isMyVote?"#185FA5":"white", color:isMyVote?"white":"#185FA5"}}
                    >
                      {isMyVote ? "✓ Voté" : "Voter"}
                    </button>
                    {isOrganisateur && nbVotes > 0 && !isValidated && (() => {
                      const placesInsuff = t.places_dispo < totalMembres;
                      return (
                        <button
                          onClick={() => placesInsuff ? setError(`Places insuffisantes : ${t.places_dispo} dispo, ${totalMembres} membres.`) : handleValider(String(t.id))}
                          style={{ ...s.btnValider, opacity: placesInsuff ? 0.5 : 1, cursor: placesInsuff ? "not-allowed" : "pointer" }}
                          title={placesInsuff ? `Seulement ${t.places_dispo} place(s) pour ${totalMembres} membres` : ""}
                        >
                          {placesInsuff ? "⚠️ Places insuffisantes" : "👑 Valider"}
                        </button>
                      );
                    })()}
                  </div>
                </div>
              );
            })
          }
        </div>

        {isOrganisateur && (
          <div style={s.infoBox}>
            👑 En tant qu'organisateur, cliquez sur <strong>"Valider"</strong> sur le transport qui a remporté le vote.
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
  toast:    { background:"#EAF3DE", color:"#3B6D11", padding:"10px 16px", borderRadius:"8px", fontSize:"13px" },
  errorBox: { background:"#FCEBEB", color:"#A32D2D", padding:"10px 16px", borderRadius:"8px", fontSize:"13px" },
  banner:  { background:"#E6F1FB", color:"#0C447C", padding:"10px 16px", borderRadius:"8px", fontSize:"13px" },
  destBanner: { background:"rgba(12,68,124,0.07)", color:"#0C447C", padding:"8px 16px", borderRadius:"8px", fontSize:"13px" },
  voteCount: { background:"rgba(255,255,255,0.15)", padding:"4px 12px", borderRadius:"20px", fontSize:"13px" },
  btnNext: { background:"rgba(255,255,255,0.18)", border:"1px solid rgba(255,255,255,0.45)", color:"white", padding:"6px 14px", borderRadius:"20px", cursor:"pointer", fontSize:"13px", fontWeight:"600", whiteSpace:"nowrap" },
  filterBar: { display:"flex", gap:"8px", flexWrap:"wrap", background:"white", padding:"12px 16px", borderRadius:"10px", boxShadow:"0 1px 4px rgba(0,0,0,0.05)" },
  chip:    { padding:"6px 16px", borderRadius:"20px", border:"1px solid #D1CFC5", background:"white", cursor:"pointer", fontSize:"13px" },
  chipOn:  { padding:"6px 16px", borderRadius:"20px", border:"1px solid #185FA5", background:"#185FA5", color:"white", cursor:"pointer", fontSize:"13px" },
  list:    { display:"flex", flexDirection:"column", gap:"10px" },
  card:    { display:"flex", justifyContent:"space-between", alignItems:"flex-start", padding:"16px", borderRadius:"12px", background:"white", gap:"16px", boxShadow:"0 2px 6px rgba(0,0,0,0.06)", transition:"box-shadow 0.15s" },
  cardLeft:  { flex:1 },
  typeChip:  { display:"inline-block", background:"#E6F1FB", color:"#0C447C", padding:"2px 10px", borderRadius:"12px", fontSize:"11px", marginBottom:"6px" },
  compagnie: { fontSize:"15px", fontWeight:"bold", color:"#0C447C", marginBottom:"4px", display:"flex", alignItems:"center", gap:"8px" },
  validBadge:{ background:"#42A85A", color:"white", padding:"2px 8px", borderRadius:"12px", fontSize:"11px", fontWeight:"bold" },
  trajet:    { display:"flex", alignItems:"center", gap:"8px", marginBottom:"4px" },
  ville:     { fontSize:"14px", fontWeight:"500", color:"#2C2C2A" },
  arrow:     { color:"#185FA5", fontWeight:"bold" },
  dates:     { fontSize:"12px", color:"#73726c", marginBottom:"2px" },
  places:    { fontSize:"12px", color:"#73726c", marginBottom:"8px" },
  voteBarBg: { height:"5px", background:"#E0DED6", borderRadius:"3px", overflow:"hidden", marginBottom:"4px" },
  voteBarFill:{ height:"100%", background:"#185FA5", borderRadius:"3px", transition:"width 0.3s" },
  voteStats: { fontSize:"11px", color:"#73726c" },
  votants:   { color:"#185FA5" },
  cardRight: { textAlign:"center", flexShrink:0, display:"flex", flexDirection:"column", gap:"8px", alignItems:"center" },
  prix:      { fontSize:"22px", fontWeight:"bold", color:"#0C447C" },
  perPers:   { fontSize:"12px", fontWeight:"normal", color:"#73726c" },
  btnVote:   { padding:"8px 16px", borderRadius:"6px", border:"1px solid #185FA5", cursor:"pointer", fontSize:"13px", fontWeight:"500", whiteSpace:"nowrap" },
  btnValider:{ padding:"7px 12px", borderRadius:"6px", border:"none", background:"#EAF3DE", color:"#3B6D11", cursor:"pointer", fontSize:"12px", fontWeight:"500" },
  empty:     { textAlign:"center", padding:"32px", color:"#73726c" },
  infoBox:   { background:"#E6F1FB", color:"#0C447C", padding:"14px 18px", borderRadius:"8px", fontSize:"13px" },
};
