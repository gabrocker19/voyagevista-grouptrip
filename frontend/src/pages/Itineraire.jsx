import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { groupService } from "../services/group.service";
import { api } from "../services/api";
import PageHeader from "../components/PageHeader";
import Toast from "../components/Toast";

export default function Itineraire() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [groupe,     setGroupe]    = useState(null);
  const [itineraire, setItineraire]= useState(null);
  const [transport,  setTransport] = useState(null);
  const [heb,        setHeb]       = useState(null);
  const [activites,  setActivites] = useState([]);
  const [loading,    setLoading]   = useState(true);
  const [saving,     setSaving]    = useState(false);
  const [toast,      setToast]     = useState(null);

  useEffect(() => {
    Promise.all([
      groupService.getOne(id),
      api.get(`/api/itineraires/groupe/${id}`).catch(() => null),
    ]).then(async ([g, itin]) => {
      setGroupe(g);
      if (itin) {
        setItineraire(itin);
        setActivites(itin.activites || []);
      } else {
        const transportId = sessionStorage.getItem(`transport_${id}`);
        const hebId       = sessionStorage.getItem(`hebergement_${id}`);
        const actIds      = JSON.parse(sessionStorage.getItem(`activites_${id}`) || "[]");
        const [t, h, a]   = await Promise.all([
          transportId ? api.get(`/api/transports/${transportId}`) : Promise.resolve(null),
          hebId       ? api.get(`/api/hebergements/${hebId}`) : Promise.resolve(null),
          actIds.length > 0 ? api.get(`/api/activites?ids=${actIds.join(",")}`) : Promise.resolve([]),
        ]);
        setTransport(t);
        setHeb(h);
        setActivites(Array.isArray(a) ? a : []);
      }
    }).catch(console.error).finally(() => setLoading(false));
  }, [id]);

  const compagnie   = itineraire?.compagnie   || transport?.compagnie;
  const origine     = itineraire?.origine     || transport?.origine;
  const transDest   = itineraire?.transport_dest || transport?.destination;
  const transPrix   = itineraire ? parseFloat(itineraire.transport_prix || 0) : (transport ? parseFloat(transport.prix) : 0);
  const hebNom      = itineraire?.heb_nom     || heb?.nom;
  const hebPrixNuit = itineraire ? parseFloat(itineraire.prix_nuit || 0) : (heb ? parseFloat(heb.prix_nuit) : 0);

  const nbMembres = groupe?.membres?.filter(m => m.statut === "accepte").length || 1;
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
  const budgetPct     = budgetMax ? Math.min((coutTotal / budgetMax) * 100, 100) : 0;

  const pret = !!(itineraire?.transport_id && itineraire?.hebergement_id) || !!(transport && heb);
  const manquant = !itineraire?.transport_id && !transport ? "transport"
    : !itineraire?.hebergement_id && !heb ? "hébergement" : null;

  const handleSave = async () => {
    setSaving(true);
    setError("");
    try {
      if (itineraire) {
        await api.post("/api/itineraires", {
          groupe_id:      id,
          transport_id:   itineraire.transport_id,
          hebergement_id: itineraire.hebergement_id,
          activite_ids:   activites.map(a => a.id),
          cout_total:     coutTotal,
        });
      } else {
        const transportId = sessionStorage.getItem(`transport_${id}`);
        const hebId       = sessionStorage.getItem(`hebergement_${id}`);
        const actIds      = JSON.parse(sessionStorage.getItem(`activites_${id}`) || "[]");
        await api.post("/api/itineraires", {
          groupe_id: id, transport_id: transportId,
          hebergement_id: hebId, activite_ids: actIds, cout_total: coutTotal,
        });
      }
      setToast({ message: "Itinéraire validé !", type: "success" });
      setTimeout(() => navigate(`/groupes/${id}/panier`), 400);
    } catch (err) {
      setToast({ message: err.message, type: "error" });
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <div style={st.loading}>Chargement...</div>;

  const items = [
    {
      icon: "✈️",
      label: compagnie ? `${compagnie}` : "Transport",
      sub: compagnie ? `${origine} → ${transDest}` : "Non sélectionné",
      prix: coutTransport,
      ok: !!compagnie,
    },
    {
      icon: "🏨",
      label: hebNom || "Hébergement",
      sub: hebNom ? `${hebPrixNuit}€/nuit × ${nbNuits} nuits` : "Non sélectionné",
      prix: coutHeb,
      ok: !!hebNom,
    },
    ...activites.map(a => ({
      icon: "🎯",
      label: a.nom,
      sub: a.duree_heures ? `${a.duree_heures}h` : "Activité",
      prix: parseFloat(a.prix),
      ok: true,
    })),
  ];

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
          >
            {saving ? "Sauvegarde..." : pret ? "Valider → Panier" : "🔒 Valider → Panier"}
          </button>
        }
      />

      <Toast message={toast?.message} type={toast?.type} onClose={() => setToast(null)} />
      <div style={st.body}>
        {!pret && (
          <div style={st.alertManquant}>
            <span style={st.alertIcon}>🔒</span>
            <div>
              <strong>
                {manquant === "transport"
                  ? "Transport non validé"
                  : "Hébergement non validé"}
              </strong>
              <div style={st.alertSub}>
                Retournez valider ce choix avant de confirmer l'itinéraire.
              </div>
            </div>
            <button
              onClick={() => navigate(`/groupes/${id}/${manquant === "transport" ? "transport" : "hebergement"}`)}
              style={st.alertBtn}
            >
              Valider →
            </button>
          </div>
        )}

        <div style={st.grid}>
          {/* Récapitulatif */}
          <div style={st.section}>
            <h2 style={st.sectionTitle}>📋 Récapitulatif</h2>

            <div style={st.receipt}>
              {items.map((item, i) => (
                <div key={i} style={{ ...st.receiptRow, opacity: item.ok ? 1 : 0.5 }}>
                  <div style={st.receiptLeft}>
                    <span style={st.receiptIcon}>{item.icon}</span>
                    <div>
                      <div style={st.receiptLabel}>{item.label}</div>
                      <div style={st.receiptSub}>{item.sub}</div>
                    </div>
                  </div>
                  <div style={st.receiptPrix}>
                    {item.prix > 0 ? `${item.prix.toFixed(0)}€` : "—"}
                  </div>
                </div>
              ))}
              {activites.length === 0 && (
                <div style={{ ...st.receiptRow, opacity: 0.4 }}>
                  <div style={st.receiptLeft}>
                    <span style={st.receiptIcon}>🎯</span>
                    <div style={st.receiptLabel}>Aucune activité</div>
                  </div>
                  <div style={st.receiptPrix}>—</div>
                </div>
              )}
            </div>

            <div style={st.sep} />

            <div style={st.totalRow}>
              <span style={st.totalLabel}>Total / personne</span>
              <span style={{ ...st.totalPrix, color: budgetDepasse ? "#A32D2D" : "#0C447C" }}>
                {coutTotal.toFixed(0)}€
              </span>
            </div>

            {budgetMax && (
              <div style={{ ...st.budgetBar, marginTop: "16px" }}>
                <div style={st.budgetBarTop}>
                  <span style={{ fontSize: "12px", color: "#73726c" }}>Budget utilisé</span>
                  <span style={{ fontSize: "12px", fontWeight: "700", color: budgetDepasse ? "#A32D2D" : "#3B6D11" }}>
                    {coutTotal.toFixed(0)}€ / {budgetMax}€
                  </span>
                </div>
                <div style={st.budgetTrack}>
                  <div style={{
                    ...st.budgetFill,
                    width: `${budgetPct}%`,
                    background: budgetDepasse ? "#E84848" : budgetPct > 85 ? "#F0A500" : "#42A85A",
                  }} />
                </div>
                <div style={{
                  ...st.budgetTag,
                  background: budgetDepasse ? "#FCEBEB" : "#EAF3DE",
                  color: budgetDepasse ? "#A32D2D" : "#3B6D11",
                }}>
                  {budgetDepasse
                    ? `⚠️ Dépassement de ${(coutTotal - budgetMax).toFixed(0)}€`
                    : `✓ Dans le budget — ${(budgetMax - coutTotal).toFixed(0)}€ restants`}
                </div>
              </div>
            )}
          </div>

          {/* Répartition membres */}
          <div style={st.section}>
            <h2 style={st.sectionTitle}>👥 Répartition du groupe</h2>
            <div style={st.memberList}>
              {groupe?.membres?.filter(m => m.statut === "accepte").map(m => (
                <div key={m.id} style={st.memberRow}>
                  <div style={st.avatar}>{m.nom.charAt(0).toUpperCase()}</div>
                  <div style={st.memberInfo}>
                    <div style={st.memberName}>{m.nom}</div>
                    <div style={st.memberRole}>{m.role === "organisateur" ? "👑 Organisateur" : "Membre"}</div>
                  </div>
                  <div style={st.memberPrix}>{coutTotal.toFixed(0)}€</div>
                </div>
              ))}
            </div>

            <div style={st.totalGroupe}>
              <div style={st.totalGroupeLabel}>Total du groupe</div>
              <div style={st.totalGroupePrix}>{(coutTotal * nbMembres).toFixed(0)}€</div>
            </div>

            <div style={st.membresInfo}>
              {nbMembres} voyageur{nbMembres > 1 ? "s" : ""} × {coutTotal.toFixed(0)}€/pers.
            </div>
          </div>
        </div>

        {/* Bouton principal */}
        <button
          onClick={pret && !budgetDepasse ? handleSave : undefined}
          disabled={saving}
          style={{
            ...st.btnSave,
            opacity: (pret && !budgetDepasse && !saving) ? 1 : 0.5,
            cursor:  (pret && !budgetDepasse && !saving) ? "pointer" : "not-allowed",
            background: budgetDepasse
              ? "#C0392B"
              : (pret ? "linear-gradient(135deg, #0C447C, #185FA5)" : "#9AA5AE"),
          }}
        >
          {saving ? "Sauvegarde en cours..."
            : budgetDepasse ? "⚠️ Budget dépassé — ajustez l'itinéraire"
            : !pret ? "🔒 Validez d'abord tous les choix"
            : "✓ Valider l'itinéraire → Panier"}
        </button>
      </div>
    </div>
  );
}

const st = {
  page:    { fontFamily: "Arial, sans-serif", minHeight: "100vh", backgroundImage: "linear-gradient(rgba(245,244,240,0.50), rgba(245,244,240,0.56)), url('/voyagevista-grouptrip/frontend/dist/images/autre/gettyimages-1340942749-612x612.jpg')", backgroundSize: "cover", backgroundAttachment: "fixed", backgroundPosition: "center" },
  loading: { textAlign: "center", padding: "60px", color: "#73726c" },
  body:    { padding: "24px 32px 48px", maxWidth: "900px", margin: "0 auto", display: "flex", flexDirection: "column", gap: "16px" },


  alertManquant: {
    display: "flex", alignItems: "center", gap: "14px",
    background: "#FFF8E6", border: "1px solid #F5DFA0",
    borderRadius: "12px", padding: "16px 20px",
  },
  alertIcon: { fontSize: "24px", flexShrink: 0 },
  alertSub:  { fontSize: "12px", color: "#854F0B", marginTop: "2px" },
  alertBtn: {
    marginLeft: "auto", padding: "8px 18px", borderRadius: "8px",
    background: "#185FA5", color: "white", border: "none",
    cursor: "pointer", fontSize: "13px", fontWeight: "700", flexShrink: 0,
  },

  btnHeader: {
    background: "white", color: "#0C447C",
    border: "none", padding: "8px 18px",
    borderRadius: "20px", fontSize: "13px", fontWeight: "bold",
  },

  grid: { display: "grid", gridTemplateColumns: "1fr 1fr", gap: "16px" },

  section: {
    background: "white", borderRadius: "14px",
    padding: "22px 24px", boxShadow: "0 2px 8px rgba(0,0,0,0.06)",
  },
  sectionTitle: { fontSize: "14px", fontWeight: "700", color: "#0C447C", marginBottom: "18px", textTransform: "uppercase", letterSpacing: "0.4px" },

  receipt: { display: "flex", flexDirection: "column", gap: "0" },
  receiptRow: {
    display: "flex", justifyContent: "space-between",
    alignItems: "center", padding: "10px 0",
    borderBottom: "1px solid #F5F4F0", gap: "12px",
  },
  receiptLeft: { display: "flex", alignItems: "center", gap: "10px", flex: 1 },
  receiptIcon: { fontSize: "20px", flexShrink: 0 },
  receiptLabel: { fontSize: "14px", fontWeight: "600", color: "#2C2C2A" },
  receiptSub: { fontSize: "11px", color: "#73726c", marginTop: "2px" },
  receiptPrix: { fontSize: "15px", fontWeight: "700", color: "#0C447C", flexShrink: 0 },

  sep: { borderTop: "2px dashed #E0DED6", margin: "14px 0" },

  totalRow: { display: "flex", justifyContent: "space-between", alignItems: "center" },
  totalLabel: { fontSize: "16px", fontWeight: "700", color: "#2C2C2A" },
  totalPrix: { fontSize: "30px", fontWeight: "800", lineHeight: 1 },

  budgetBar: {},
  budgetBarTop: { display: "flex", justifyContent: "space-between", marginBottom: "6px" },
  budgetTrack: { height: 8, background: "#E0DED6", borderRadius: 4, overflow: "hidden", marginBottom: "8px" },
  budgetFill: { height: "100%", borderRadius: 4, transition: "width 0.5s" },
  budgetTag: { padding: "8px 12px", borderRadius: "8px", fontSize: "12px", fontWeight: "600" },

  memberList: { display: "flex", flexDirection: "column", gap: "10px", marginBottom: "16px" },
  memberRow: { display: "flex", alignItems: "center", gap: "12px" },
  avatar: {
    width: 36, height: 36, borderRadius: "50%",
    background: "linear-gradient(135deg, #0C447C, #185FA5)",
    color: "white", display: "flex",
    alignItems: "center", justifyContent: "center",
    fontSize: "14px", fontWeight: "800", flexShrink: 0,
  },
  memberInfo: { flex: 1 },
  memberName: { fontSize: "14px", fontWeight: "600", color: "#2C2C2A" },
  memberRole: { fontSize: "11px", color: "#73726c" },
  memberPrix: { fontSize: "14px", fontWeight: "700", color: "#0C447C" },

  totalGroupe: {
    display: "flex", justifyContent: "space-between",
    alignItems: "center", padding: "14px 16px",
    background: "linear-gradient(135deg, #E6F1FB, #D4E8F5)",
    borderRadius: "10px", marginBottom: "8px",
  },
  totalGroupeLabel: { fontSize: "13px", fontWeight: "600", color: "#0C447C" },
  totalGroupePrix: { fontSize: "22px", fontWeight: "800", color: "#0C447C" },
  membresInfo: { fontSize: "12px", color: "#73726c", textAlign: "center" },

  btnSave: {
    color: "white", border: "none",
    padding: "15px", borderRadius: "12px",
    fontSize: "15px", fontWeight: "700",
    boxShadow: "0 4px 16px rgba(12,68,124,0.2)",
    transition: "opacity 0.2s",
  },
};
