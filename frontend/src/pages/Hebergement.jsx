import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { catalogueService } from "../services/catalogue.service";
import { groupService } from "../services/group.service";
import { voteService } from "../services/vote.service";
import { api } from "../services/api";
import { useAuth } from "../context/AuthContext";
import PageHeader from "../components/PageHeader";
import BudgetBar from "../components/BudgetBar";
import { EQUIPEMENTS_META, parseEquipements } from "../utils/equipements";
import EquipementsModal from "../components/EquipementsModal";

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
  const [modalHeb,     setModalHeb]     = useState(null);
  const [filtreType,   setFiltreType]   = useState("");
  const [filtrePrix,   setFiltrePrix]   = useState("");

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

  // Nuits = durée du transport validé (priorité) ou dates du groupe (fallback)
  // Déclaré ici pour être utilisable dans le useEffect ci-dessous
  const nbNuits = itineraire?.transport_date_depart && itineraire?.transport_date_arrivee
    ? Math.round((new Date(itineraire.transport_date_arrivee) - new Date(itineraire.transport_date_depart)) / 86400000)
    : (groupe?.date_depart && groupe?.date_retour
        ? Math.round((new Date(groupe.date_retour) - new Date(groupe.date_depart)) / 86400000)
        : null);

  // Persister le coût voté de cette page pour les autres pages
  useEffect(() => {
    const cost = hebValideId ? 0
      : parseFloat(hebergements.find(h => String(h.id) === monVote)?.prix_nuit || 0) * (nbNuits || 7);
    sessionStorage.setItem(`vv_v_h_${id}`, cost);
  }, [monVote, hebergements, hebValideId, nbNuits, id]);

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

  // Blocage si transport non validé
  if (!itineraire?.transport_id) {
    return (
      <div style={s.page}>
        <PageHeader title="🏨 Hébergement" subtitle={groupe?.nom} backLabel="Retour au groupe" backTo={`/groupes/${id}`} />
        <div style={{ padding:"48px 32px", textAlign:"center" }}>
          <div style={s.blockCard}>
            <div style={{ fontSize:"48px", marginBottom:"16px" }}>🔒</div>
            <h2 style={{ color:"#0C447C", marginBottom:"8px", fontSize:"20px" }}>Transport requis</h2>
            <p style={{ color:"#73726c", marginBottom:"24px", fontSize:"14px", lineHeight:1.6 }}>
              Vous devez d'abord valider un transport avant de choisir l'hébergement.<br />
              Le nombre de nuits sera calculé automatiquement depuis les dates du transport.
            </p>
            <button onClick={() => navigate(`/groupes/${id}/transport`)} style={s.btnGoTransport}>
              Choisir le transport →
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div style={s.page}>
      <EquipementsModal heb={modalHeb} onClose={() => setModalHeb(null)} />
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
              onClick={() => navigate(`/groupes/${id}/activites`)}
              style={s.btnNext}
            >
              Activités →
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
        {nbNuits !== null && (() => {
          const dateDebut = itineraire?.transport_date_depart || groupe?.date_depart;
          const dateFin   = itineraire?.transport_date_arrivee || groupe?.date_retour;
          const source    = itineraire?.transport_date_depart ? "transport" : "voyage";
          return (
            <div style={s.dateBanner}>
              🗓️ Séjour de <strong>{nbNuits} nuit{nbNuits > 1 ? "s" : ""}</strong>
              {dateDebut && dateFin && (
                <> · du {new Date(dateDebut).toLocaleDateString("fr-FR",{day:"numeric",month:"long"})} au {new Date(dateFin).toLocaleDateString("fr-FR",{day:"numeric",month:"long",year:"numeric"})}</>
              )}
              {source === "transport"
                ? " — durée basée sur votre transport validé."
                : " — durée basée sur les dates du voyage."}
            </div>
          );
        })()}

        {/* Barre de budget */}
        {(() => {
          const valide       = itineraire?.cout_total || 0;
          const hebVote      = hebergements.find(h => String(h.id) === monVote);
          const myExtra    = hebValideId ? 0
            : parseFloat(hebVote?.prix_nuit || 0) * (nbNuits || 7);
          const votedTrans = parseFloat(sessionStorage.getItem(`vv_v_t_${id}`) || 0);
          const votedAct   = parseFloat(sessionStorage.getItem(`vv_v_a_${id}`) || 0);
          return (
            <BudgetBar
              budget={groupe?.budget_max}
              valide={valide}
              monVoteExtra={myExtra + votedTrans + votedAct}
            />
          );
        })()}

        {/* Filtres */}
        <div style={s.filterBar}>
          <select value={filtreType} onChange={e => setFiltreType(e.target.value)} style={s.filterSelect}>
            <option value="">Tous les types</option>
            {[...new Set(hebergements.map(h => h.type))].map(t => (
              <option key={t} value={t}>{t.charAt(0).toUpperCase()+t.slice(1)}</option>
            ))}
          </select>
          <select value={filtrePrix} onChange={e => setFiltrePrix(e.target.value)} style={s.filterSelect}>
            <option value="">Tous les prix</option>
            <option value="0-100">Moins de 100€/nuit</option>
            <option value="100-300">100€ – 300€/nuit</option>
            <option value="300-999999">Plus de 300€/nuit</option>
          </select>
          {(filtreType || filtrePrix) && (
            <button onClick={() => { setFiltreType(""); setFiltrePrix(""); }} style={s.filterReset}>
              ✕ Réinitialiser
            </button>
          )}
        </div>

        <div style={s.grid}>
          {hebergements.filter(h => {
            if (filtreType && h.type !== filtreType) return false;
            if (filtrePrix) {
              const [min, max] = filtrePrix.split("-").map(Number);
              if (h.prix_nuit < min || h.prix_nuit > max) return false;
            }
            return true;
          }).map(h => {
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
                  {/* Équipements */}
                  {(() => {
                    const equips = parseEquipements(h.equipements);
                    if (!equips.length) return null;
                    return (
                      <div style={s.equips}>
                        {equips.slice(0, 4).map(e => {
                          const m = EQUIPEMENTS_META[e] || { icon: "•", label: e };
                          return <span key={e} style={s.equipChip}>{m.icon} {m.label}</span>;
                        })}
                        {equips.length > 4 && (
                          <button onClick={() => setModalHeb(h)} style={s.equipToggle}>
                            +{equips.length - 4} équipements
                          </button>
                        )}
                      </div>
                    );
                  })()}
                  {/* Animaux */}
                  <div style={s.animaux}>
                    {h.animaux_acceptes ? "🐾 Animaux acceptés" : "🚫 Animaux non acceptés"}
                  </div>
                  {/* Barre de vote */}
                  <div style={s.voteBarBg}><div style={{...s.voteBarFill, width:`${pct}%`}}/></div>
                  <div style={s.voteStats}>{nbVotes} vote{nbVotes!==1?"s":""} ({pct}%) {res?.votants && <span style={s.votants}>— {res.votants}</span>}</div>
                  <div style={s.cardFooter}>
                    <div>
                      {nbNuits ? (
                        <>
                          <div style={s.prix}>{(h.prix_nuit * nbNuits).toFixed(0)}€<span style={s.perNuit}>/séjour</span></div>
                          <div style={s.prixSub}>{h.prix_nuit}€/nuit × {nbNuits} nuits</div>
                        </>
                      ) : (
                        <div style={s.prix}>{h.prix_nuit}€<span style={s.perNuit}>/nuit</span></div>
                      )}
                    </div>
                    <div style={{ display:"flex", gap:"6px" }}>
                      <button
                        onClick={() => handleVoter(h.id)}
                        style={{...s.btnVote, background:isMyVote?"#185FA5":"white", color:isMyVote?"white":"#185FA5"}}
                      >
                        {isMyVote ? "✓ Voté" : "Voter"}
                      </button>
                      {isOrganisateur && nbVotes > 0 && !isValidated && (() => {
                        const placesInsuff = h.capacite < totalMembres;
                        return (
                          <button
                            onClick={() => placesInsuff ? setError(`Capacité insuffisante : ${h.capacite} place(s), ${totalMembres} membres.`) : handleValider(String(h.id))}
                            style={{ ...s.btnValider, opacity: placesInsuff ? 0.5 : 1, cursor: placesInsuff ? "not-allowed" : "pointer" }}
                            title={placesInsuff ? `Seulement ${h.capacite} place(s) pour ${totalMembres} membres` : ""}
                          >
                            {placesInsuff ? "⚠️ Capacité insuffisante" : "👑 Valider"}
                          </button>
                        );
                      })()}
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
  infoBox:    { background:"#E6F1FB", color:"#0C447C", padding:"14px 18px", borderRadius:"8px", fontSize:"13px" },
  dateBanner: { background:"#FFF8E6", color:"#854F0B", padding:"10px 16px", borderRadius:"8px", fontSize:"13px", border:"1px solid #F5DFA0" },
  prixSub:    { fontSize:"11px", color:"#73726c", marginTop:"1px" },
  equips:     { display:"flex", flexWrap:"wrap", gap:"5px", margin:"6px 0" },
  equipChip:  { fontSize:"11px", background:"#F0F4F8", color:"#444", padding:"3px 8px", borderRadius:"20px", whiteSpace:"nowrap" },
  equipToggle:{ fontSize:"11px", background:"none", border:"none", color:"#185FA5", cursor:"pointer", padding:"3px 4px", fontWeight:"600", textDecoration:"underline" },
  animaux:    { fontSize:"11px", color:"#73726c", marginTop:"4px" },
  blockCard:  { background:"white", borderRadius:"16px", padding:"48px 40px", maxWidth:"420px", margin:"0 auto", boxShadow:"0 4px 20px rgba(0,0,0,0.08)" },
  btnGoTransport: { padding:"12px 28px", background:"linear-gradient(135deg,#0C447C,#185FA5)", color:"white", border:"none", borderRadius:"10px", fontSize:"14px", fontWeight:"700", cursor:"pointer" },
  filterBar:    { display:"flex", gap:"10px", flexWrap:"wrap", alignItems:"center", background:"white", padding:"12px 16px", borderRadius:"10px", boxShadow:"0 1px 4px rgba(0,0,0,0.05)" },
  filterSelect: { padding:"7px 10px", borderRadius:"8px", border:"1px solid #D1CFC5", fontSize:"13px", background:"white", cursor:"pointer" },
  filterReset:  { padding:"6px 12px", borderRadius:"8px", border:"1px solid #F09595", background:"#FCEBEB", color:"#A32D2D", cursor:"pointer", fontSize:"12px", fontWeight:"600" },
};
