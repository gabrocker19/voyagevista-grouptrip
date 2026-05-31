import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { groupService } from "../services/group.service";
import { api } from "../services/api";
import PageHeader from "../components/PageHeader";

export default function Itineraire() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [groupe,    setGroupe]    = useState(null);
  const [itineraire,setItineraire]= useState(null); // données DB
  // Fallback sessionStorage
  const [transport, setTransport] = useState(null);
  const [heb,       setHeb]       = useState(null);
  const [activites, setActivites] = useState([]);

  const [loading, setLoading] = useState(true);
  const [saving,  setSaving]  = useState(false);
  const [message, setMessage] = useState("");
  const [error,   setError]   = useState("");

  useEffect(() => {
    Promise.all([
      groupService.getOne(id),
      api.get(`/api/itineraires/groupe/${id}`).catch(() => null),
    ]).then(async ([g, itin]) => {
      setGroupe(g);

      if (itin) {
        // Données depuis la BD (vote validé)
        setItineraire(itin);
        setActivites(itin.activites || []);
      } else {
        // Fallback sessionStorage (ancien flux)
        const transportId = sessionStorage.getItem(`transport_${id}`);
        const hebId       = sessionStorage.getItem(`hebergement_${id}`);
        const actIds      = JSON.parse(sessionStorage.getItem(`activites_${id}`) || "[]");
        const [t, h, a]   = await Promise.all([
          transportId ? api.get(`/api/transports/${transportId}`)              : Promise.resolve(null),
          hebId       ? api.get(`/api/hebergements/${hebId}`)                  : Promise.resolve(null),
          actIds.length > 0 ? api.get(`/api/activites?ids=${actIds.join(",")}`) : Promise.resolve([]),
        ]);
        setTransport(t);
        setHeb(h);
        setActivites(Array.isArray(a) ? a : []);
      }
    }).catch(console.error).finally(() => setLoading(false));
  }, [id]);

  // Sources de données : BD si dispo, sinon sessionStorage
  const compagnie   = itineraire?.compagnie   || transport?.compagnie;
  const origine     = itineraire?.origine     || transport?.origine;
  const transDest   = itineraire?.transport_dest || transport?.destination;
  const transPrix   = itineraire ? parseFloat(itineraire.transport_prix || 0) : (transport ? parseFloat(transport.prix) : 0);
  const hebNom      = itineraire?.heb_nom     || heb?.nom;
  const hebPrixNuit = itineraire ? parseFloat(itineraire.prix_nuit || 0) : (heb ? parseFloat(heb.prix_nuit) : 0);

  const nbMembres = groupe?.membres?.filter(m => m.statut === "accepte").length || 1;
  // Nuits = durée du transport validé (priorité) > dates du groupe > fallback 7
  const nbNuits = itineraire?.transport_date_depart && itineraire?.transport_date_arrivee
    ? Math.round((new Date(itineraire.transport_date_arrivee) - new Date(itineraire.transport_date_depart)) / 86400000)
    : (groupe?.date_depart && groupe?.date_retour
        ? Math.ceil((new Date(groupe.date_retour) - new Date(groupe.date_depart)) / 86400000)
        : 7);

  const coutTransport = transPrix;
  const coutHeb       = hebPrixNuit * nbNuits;
  const coutActivites = activites.reduce((s, a) => s + parseFloat(a.prix), 0);
  const coutTotal     = coutTransport + coutHeb + coutActivites;
  const budgetMax     = groupe?.budget_max ? parseFloat(groupe.budget_max) : null;
  const budgetDepasse = budgetMax && coutTotal > budgetMax;
  const pret = !!(itineraire?.transport_id && itineraire?.hebergement_id)
    || !!(transport && heb); // fallback sessionStorage
  const manquant = !itineraire?.transport_id && !transport ? "transport"
    : !itineraire?.hebergement_id && !heb ? "hébergement" : null;

  const handleSave = async () => {
    setSaving(true);
    setError("");
    try {
      if (itineraire) {
        // Itinéraire déjà en BD — juste mettre à jour le cout_total et naviguer
        await api.post("/api/itineraires", {
          groupe_id:      id,
          transport_id:   itineraire.transport_id,
          hebergement_id: itineraire.hebergement_id,
          activite_ids:   activites.map(a => a.id),
          cout_total:     coutTotal,
        });
      } else {
        // Flux sessionStorage
        const transportId = sessionStorage.getItem(`transport_${id}`);
        const hebId       = sessionStorage.getItem(`hebergement_${id}`);
        const actIds      = JSON.parse(sessionStorage.getItem(`activites_${id}`) || "[]");
        await api.post("/api/itineraires", {
          groupe_id:      id,
          transport_id:   transportId,
          hebergement_id: hebId,
          activite_ids:   actIds,
          cout_total:     coutTotal,
        });
      }
      setMessage("Itinéraire validé !");
      setTimeout(() => navigate(`/groupes/${id}/panier`), 800);
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <div style={st.loading}>Chargement...</div>;

  return (
    <div style={st.page}>
      <PageHeader
        title="🗺️ Itinéraire"
        subtitle={groupe?.nom}
        backLabel="Retour au groupe"
        backTo={`/groupes/${id}`}
        right={
          <button
            onClick={pret && !budgetDepasse ? handleSave : undefined}
            disabled={saving}
            style={{
              ...st.btnHeader,
              opacity: (pret && !budgetDepasse && !saving) ? 1 : 0.45,
              cursor:  (pret && !budgetDepasse && !saving) ? "pointer" : "not-allowed",
            }}
            title={!pret ? `${manquant} non validé` : budgetDepasse ? "Budget dépassé" : ""}
          >
            {saving ? "Sauvegarde..."
              : !pret ? `🔒 Valider → Panier`
              : "Valider → Panier"}
          </button>
        }
      />

      <div style={st.body}>
        {message && <div style={st.success}>{message}</div>}
        {error   && <div style={st.error}>{error}</div>}
        {budgetDepasse && (
          <div style={st.alert}>
            ⚠️ Budget dépassé : {coutTotal.toFixed(0)}€ &gt; {budgetMax}€ ({(coutTotal - budgetMax).toFixed(0)}€ de plus)
          </div>
        )}

        {/* Récapitulatif */}
        <div style={st.section}>
          <h2 style={st.sectionTitle}>Récapitulatif du voyage</h2>

          <div style={st.ligne}>
            <div style={st.ligneLeft}>
              <span style={st.ligneIcon}>✈️</span>
              <div>
                <div style={st.ligneTitle}>
                  {compagnie ? `${compagnie} — ${origine} → ${transDest}` : "Aucun transport sélectionné"}
                </div>
                {compagnie && <div style={st.ligneSub}>Prix/pers.</div>}
              </div>
            </div>
            <div style={st.lignePrix}>{coutTransport > 0 ? `${coutTransport}€` : "—"}</div>
          </div>

          <div style={st.ligne}>
            <div style={st.ligneLeft}>
              <span style={st.ligneIcon}>🏨</span>
              <div>
                <div style={st.ligneTitle}>
                  {hebNom || "Aucun hébergement sélectionné"}
                </div>
                {hebNom && <div style={st.ligneSub}>{hebPrixNuit}€/nuit × {nbNuits} nuits</div>}
              </div>
            </div>
            <div style={st.lignePrix}>{coutHeb > 0 ? `${coutHeb}€` : "—"}</div>
          </div>

          {activites.length > 0
            ? activites.map(a => (
              <div key={a.id} style={st.ligne}>
                <div style={st.ligneLeft}>
                  <span style={st.ligneIcon}>🎯</span>
                  <div>
                    <div style={st.ligneTitle}>{a.nom}</div>
                    {a.duree_heures && <div style={st.ligneSub}>{a.duree_heures}h</div>}
                  </div>
                </div>
                <div style={st.lignePrix}>{a.prix}€</div>
              </div>
            ))
            : (
              <div style={st.ligne}>
                <div style={st.ligneLeft}>
                  <span style={st.ligneIcon}>🎯</span>
                  <div style={st.ligneTitle}>Aucune activité</div>
                </div>
                <div style={st.lignePrix}>—</div>
              </div>
            )
          }

          <div style={st.sep} />
          <div style={st.totalRow}>
            <div style={st.totalLabel}>Total par personne</div>
            <div style={{...st.totalPrix, color: budgetDepasse ? "#A32D2D" : "#0C447C"}}>
              {coutTotal.toFixed(0)}€
            </div>
          </div>
          {budgetMax && (
            <div style={{ ...st.budgetRow, background: budgetDepasse ? "#FCEBEB" : "#EAF3DE", color: budgetDepasse ? "#A32D2D" : "#3B6D11" }}>
              {budgetDepasse
                ? `⚠️ Budget dépassé de ${(coutTotal - budgetMax).toFixed(0)}€`
                : `✓ Dans le budget (max ${budgetMax}€/pers.)`}
            </div>
          )}
        </div>

        {/* Répartition groupe */}
        <div style={st.section}>
          <h2 style={st.sectionTitle}>👥 Répartition par membre</h2>
          <div style={st.memberList}>
            {groupe?.membres?.filter(m => m.statut === "accepte").map(m => (
              <div key={m.id} style={st.memberRow}>
                <div style={st.avatar}>{m.nom.charAt(0)}</div>
                <div style={st.memberName}>{m.nom}</div>
                <div style={st.memberPrix}>{coutTotal.toFixed(0)}€</div>
              </div>
            ))}
          </div>
          <div style={st.totalGroupe}>
            Total groupe : <strong>{(coutTotal * nbMembres).toFixed(0)}€</strong>
          </div>
        </div>

        {!pret && (
          <div style={st.alertManquant}>
            🔒 {manquant === "transport"
              ? "Le transport n'a pas encore été validé."
              : "L'hébergement n'a pas encore été validé."}{" "}
            Retournez valider ce choix avant de continuer.
          </div>
        )}
        <button
          onClick={pret && !budgetDepasse ? handleSave : undefined}
          disabled={saving}
          style={{
            ...st.btnSave,
            opacity: (pret && !budgetDepasse && !saving) ? 1 : 0.5,
            cursor:  (pret && !budgetDepasse && !saving) ? "pointer" : "not-allowed",
          }}
        >
          {saving ? "Sauvegarde..."
            : budgetDepasse ? "⚠️ Budget dépassé — ajustez l'itinéraire"
            : !pret ? "🔒 Validez d'abord tous les choix"
            : "✓ Valider l'itinéraire → Panier"}
        </button>
      </div>
    </div>
  );
}

const st = {
  page:    { fontFamily:"Arial, sans-serif", minHeight:"100vh", background:"#F5F4F0" },
  loading: { textAlign:"center", padding:"60px", color:"#73726c" },
  body:    { padding:"24px 32px", display:"flex", flexDirection:"column", gap:"16px", maxWidth:"720px", margin:"0 auto" },
  success: { background:"#EAF3DE", color:"#3B6D11", padding:"12px 16px", borderRadius:"8px", fontSize:"14px" },
  error:   { background:"#FCEBEB", color:"#A32D2D", padding:"12px 16px", borderRadius:"8px", fontSize:"14px" },
  alert:   { background:"#FFF3CD", color:"#856404", padding:"12px 16px", borderRadius:"8px", fontSize:"14px", fontWeight:"500" },
  btnHeader: { background:"white", color:"#0C447C", border:"none", padding:"8px 18px", borderRadius:"20px", fontSize:"13px", fontWeight:"bold" },
  section: { background:"white", borderRadius:"12px", padding:"20px 24px", boxShadow:"0 2px 6px rgba(0,0,0,0.06)" },
  sectionTitle: { fontSize:"15px", fontWeight:"bold", color:"#0C447C", marginBottom:"16px" },
  ligne:   { display:"flex", justifyContent:"space-between", alignItems:"center", padding:"10px 0", borderBottom:"1px solid #F5F4F0", gap:"12px" },
  ligneLeft: { display:"flex", alignItems:"center", gap:"12px", flex:1 },
  ligneIcon: { fontSize:"20px", flexShrink:0 },
  ligneTitle:{ fontSize:"14px", fontWeight:"500", color:"#2C2C2A" },
  ligneSub:  { fontSize:"12px", color:"#73726c", marginTop:"2px" },
  lignePrix: { fontSize:"15px", fontWeight:"bold", color:"#0C447C", flexShrink:0 },
  sep:       { borderTop:"2px solid #E0DED6", margin:"12px 0" },
  totalRow:  { display:"flex", justifyContent:"space-between", alignItems:"center", padding:"4px 0" },
  totalLabel:{ fontSize:"16px", fontWeight:"bold", color:"#2C2C2A" },
  totalPrix: { fontSize:"26px", fontWeight:"bold" },
  budgetRow: { padding:"10px 14px", borderRadius:"8px", fontSize:"13px", marginTop:"10px", fontWeight:"500" },
  memberList:{ display:"flex", flexDirection:"column", gap:"8px", marginBottom:"12px" },
  memberRow: { display:"flex", alignItems:"center", gap:"10px" },
  avatar:    { width:"30px", height:"30px", borderRadius:"50%", background:"#185FA5", color:"white", display:"flex", alignItems:"center", justifyContent:"center", fontSize:"13px", fontWeight:"bold" },
  memberName:{ flex:1, fontSize:"14px", color:"#2C2C2A" },
  memberPrix:{ fontSize:"14px", fontWeight:"bold", color:"#0C447C" },
  totalGroupe:{ fontSize:"13px", color:"#73726c", borderTop:"1px solid #F5F4F0", paddingTop:"10px" },
  btnSave:      { background:"#185FA5", color:"white", border:"none", padding:"14px", borderRadius:"8px", fontSize:"15px", fontWeight:"bold", width:"100%" },
  alertManquant:{ background:"#FFF3CD", color:"#856404", padding:"12px 16px", borderRadius:"8px", fontSize:"13px", fontWeight:"500" },
};
