import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { catalogueService } from "../services/catalogue.service";
import { groupService } from "../services/group.service";
import { voteService } from "../services/vote.service";
import { api } from "../services/api";
import { useAuth } from "../context/AuthContext";
import PageHeader from "../components/PageHeader";

const TYPE_ICONS = { hotel:"🏨", airbnb:"🏠", hostel:"🛏️", villa:"🏡", resort:"🌴" };

export default function Hebergement() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();

  const [groupe,       setGroupe]       = useState(null);
  const [hebergements, setHebergements] = useState([]);
  const [itineraire,   setItineraire]   = useState(null);
  const [loading,      setLoading]      = useState(true);

  const [resultats,    setResultats]    = useState([]);
  const [monVote,      setMonVote]      = useState(null);
  const [totalMembres, setTotalMembres] = useState(0);
  const [message,      setMessage]      = useState("");
  const [error,        setError]        = useState("");

  const chargerVotes = async () => {
    try {
      const res = await voteService.resultats(id, "hebergement");
      setResultats(res.resultats);
      setMonVote(res.mon_vote);
      setTotalMembres(res.total_membres);
    } catch {}
  };

  useEffect(() => {
    Promise.all([
      groupService.getOne(id),
      api.get(`/api/itineraires/groupe/${id}`).catch(() => null),
    ]).then(([g, itin]) => {
      setGroupe(g);
      setItineraire(itin);
      const params = g.destination_id ? { destination_id: g.destination_id } : {};
      return catalogueService.hebergements(params);
    }).then(setHebergements)
      .catch(console.error)
      .finally(() => setLoading(false));

    chargerVotes();
  }, [id]);

  const totalVotes = resultats.reduce((a, r) => a + parseInt(r.nb_votes), 0);
  const isOrganisateur = groupe?.organisateur_id === user?.id;
  const hebValideId = itineraire?.hebergement_id ? String(itineraire.hebergement_id) : null;

  const handleVoter = async (hebId) => {
    try {
      await voteService.voter({ groupe_id: id, type: "hebergement", valeur: String(hebId) });
      setMonVote(String(hebId));
      await chargerVotes();
    } catch (err) { setMessage(err.message); }
  };

  const handleValider = async (valeur) => {
    try {
      await voteService.valider({ groupe_id: id, type: "hebergement", valeur });
      const itin = await api.get(`/api/itineraires/groupe/${id}`).catch(() => null);
      setItineraire(itin);
      setMessage("✓ Hébergement validé !");
    } catch (err) { setMessage(err.message); }
  };

  if (loading) return <div style={s.loading}>Chargement...</div>;

  return (
    <div style={s.page}>
      <style>{`@keyframes valPulse{0%{box-shadow:0 0 0 0 rgba(66,168,90,.55)}50%{box-shadow:0 0 0 8px rgba(66,168,90,0)}100%{box-shadow:0 0 0 4px rgba(66,168,90,.18)}}`}</style>

      <PageHeader
        title="🏨 Hébergement"
        subtitle={groupe?.nom}
        backLabel="Retour au groupe"
        backTo={`/groupes/${id}`}
        right={
          <div style={{ display:"flex", alignItems:"center", gap:"10px" }}>
            <span style={s.voteCount}>{totalVotes}/{totalMembres} vote{totalMembres>1?"s":""}</span>
            <button
              onClick={() => itineraire?.hebergement_id
                ? navigate(`/groupes/${id}/activites`)
                : setError("Validez d'abord un hébergement avant de passer aux activités.")
              }
              style={{ ...s.btnNext, opacity: itineraire?.hebergement_id ? 1 : 0.45, cursor: itineraire?.hebergement_id ? "pointer" : "not-allowed" }}
              title={itineraire?.hebergement_id ? "" : "Hébergement non validé"}
            >
              {itineraire?.hebergement_id ? "Activités →" : "🔒 Activités"}
            </button>
          </div>
        }
      />

      <div style={s.body}>
        {error   && <div style={s.errorBox}>{error}</div>}
        {message && <div style={s.toast}>{message}</div>}
        {monVote && (
          <div style={s.banner}>
            ✓ Vous avez voté pour <strong>{hebergements.find(h=>String(h.id)===monVote)?.nom}</strong>
          </div>
        )}

        <div style={s.grid}>
          {hebergements.map(h => {
            const res = resultats.find(r => r.valeur === String(h.id));
            const nbVotes = res ? parseInt(res.nb_votes) : 0;
            const pct = totalMembres > 0 ? Math.round((nbVotes/totalMembres)*100) : 0;
            const isMyVote = monVote === String(h.id);
            const isValidated = hebValideId === String(h.id);

            return (
              <div key={h.id} style={{
                ...s.card,
                border: isValidated ? "2px solid #42A85A" : isMyVote ? "2px solid #185FA5" : "1px solid #E0DED6",
                boxShadow: isValidated ? "0 0 0 4px rgba(66,168,90,0.18)" : "0 2px 6px rgba(0,0,0,0.06)",
                animation: isValidated ? "valPulse 0.7s ease-out" : undefined,
              }}>
                <div style={s.cardImg}>{TYPE_ICONS[h.type] || "🏨"}</div>
                <div style={s.cardBody}>
                  <div style={s.cardTop}>
                    <h3 style={s.cardName}>
                      {h.nom}
                      {isValidated && <span style={s.validBadge}>✓ Validé</span>}
                    </h3>
                    <span style={s.typeBadge}>{h.type}</span>
                  </div>
                  <p style={s.cardDesc}>{h.description}</p>
                  <div style={s.cardInfo}>👥 Capacité : {h.capacite} pers.</div>
                  {/* Barre de vote */}
                  <div style={s.voteBarBg}><div style={{...s.voteBarFill, width:`${pct}%`}}/></div>
                  <div style={s.voteStats}>{nbVotes} vote{nbVotes!==1?"s":""} ({pct}%) {res?.votants && <span style={s.votants}>— {res.votants}</span>}</div>
                  <div style={s.cardFooter}>
                    <div style={s.prix}>{h.prix_nuit}€<span style={s.perNuit}>/nuit</span></div>
                    <div style={{ display:"flex", gap:"6px" }}>
                      <button
                        onClick={() => handleVoter(h.id)}
                        style={{...s.btnVote, background:isMyVote?"#185FA5":"white", color:isMyVote?"white":"#185FA5"}}
                      >
                        {isMyVote ? "✓ Voté" : "Voter"}
                      </button>
                      {isOrganisateur && nbVotes > 0 && !isValidated && (
                        <button onClick={() => handleValider(String(h.id))} style={s.btnValider}>
                          👑 Valider
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {isOrganisateur && (
          <div style={s.infoBox}>
            👑 En tant qu'organisateur, cliquez sur <strong>"Valider"</strong> sur l'hébergement qui a remporté le vote.
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
  banner:  { background:"#E6F1FB", color:"#0C447C", padding:"10px 16px", borderRadius:"8px", fontSize:"13px" },
  voteCount: { background:"rgba(255,255,255,0.15)", padding:"4px 12px", borderRadius:"20px", fontSize:"13px" },
  btnNext:  { background:"rgba(255,255,255,0.18)", border:"1px solid rgba(255,255,255,0.45)", color:"white", padding:"6px 14px", borderRadius:"20px", cursor:"pointer", fontSize:"13px", fontWeight:"600", whiteSpace:"nowrap" },
  errorBox: { background:"#FCEBEB", color:"#A32D2D", padding:"10px 16px", borderRadius:"8px", fontSize:"13px" },
  grid:    { display:"grid", gridTemplateColumns:"repeat(auto-fill, minmax(280px, 1fr))", gap:"14px" },
  card:    { borderRadius:"12px", background:"white", overflow:"hidden", transition:"box-shadow 0.15s" },
  cardImg: { height:"70px", background:"#E6F1FB", display:"flex", alignItems:"center", justifyContent:"center", fontSize:"36px" },
  cardBody:{ padding:"14px" },
  cardTop: { display:"flex", justifyContent:"space-between", alignItems:"flex-start", marginBottom:"6px", gap:"6px" },
  cardName:{ fontSize:"15px", fontWeight:"bold", color:"#0C447C", display:"flex", alignItems:"center", gap:"6px", flex:1 },
  validBadge:{ background:"#42A85A", color:"white", padding:"2px 8px", borderRadius:"12px", fontSize:"10px", fontWeight:"bold", whiteSpace:"nowrap" },
  typeBadge: { fontSize:"11px", padding:"2px 8px", borderRadius:"12px", background:"#E6F1FB", color:"#185FA5", whiteSpace:"nowrap" },
  cardDesc:{ fontSize:"12px", color:"#73726c", marginBottom:"6px", lineHeight:"1.4" },
  cardInfo:{ fontSize:"12px", color:"#444", marginBottom:"8px" },
  voteBarBg:  { height:"5px", background:"#E0DED6", borderRadius:"3px", overflow:"hidden", marginBottom:"4px" },
  voteBarFill:{ height:"100%", background:"#185FA5", borderRadius:"3px", transition:"width 0.3s" },
  voteStats:  { fontSize:"11px", color:"#73726c", marginBottom:"8px" },
  votants:    { color:"#185FA5" },
  cardFooter: { display:"flex", justifyContent:"space-between", alignItems:"center" },
  prix:    { fontSize:"18px", fontWeight:"bold", color:"#0C447C" },
  perNuit: { fontSize:"11px", fontWeight:"normal", color:"#73726c" },
  btnVote: { padding:"7px 14px", borderRadius:"6px", border:"1px solid #185FA5", cursor:"pointer", fontSize:"12px", fontWeight:"500" },
  btnValider:{ padding:"6px 10px", borderRadius:"6px", border:"none", background:"#EAF3DE", color:"#3B6D11", cursor:"pointer", fontSize:"11px", fontWeight:"500" },
  infoBox: { background:"#E6F1FB", color:"#0C447C", padding:"14px 18px", borderRadius:"8px", fontSize:"13px" },
};
