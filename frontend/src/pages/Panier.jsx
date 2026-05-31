import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { api } from "../services/api";
import { groupService } from "../services/group.service";
import PageHeader from "../components/PageHeader";
import Toast from "../components/Toast";

export default function Panier() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [itineraire, setItineraire] = useState(null);
  const [groupe, setGroupe] = useState(null);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);

  useEffect(() => {
    Promise.all([
      api.get(`/api/itineraires/groupe/${id}`),
      groupService.getOne(id),
    ])
      .then(([itin, g]) => { setItineraire(itin); setGroupe(g); })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [id]);

  const recharger = () =>
    api.get(`/api/itineraires/groupe/${id}`).then(setItineraire).catch(() => setItineraire(null));

  const annulerTransport = async () => {
    if (!confirm("Annuler le transport sélectionné ?")) return;
    try {
      await api.delete(`/api/itineraires/groupe/${id}/transport`);
      setToast({ message: "Transport annulé.", type: "success" });
      recharger();
    } catch (e) { setToast({ message: e.message, type: "error" }); }
  };

  const annulerHebergement = async () => {
    if (!confirm("Annuler l'hébergement sélectionné ?")) return;
    try {
      await api.delete(`/api/itineraires/groupe/${id}/hebergement`);
      setToast({ message: "Hébergement annulé.", type: "success" });
      recharger();
    } catch (e) { setToast({ message: e.message, type: "error" }); }
  };

  const retirerActivite = async (activiteId, nom) => {
    if (!confirm(`Retirer "${nom}" ?`)) return;
    try {
      await api.delete(`/api/itineraires/groupe/${id}/activites/${activiteId}`);
      setToast({ message: `"${nom}" retirée.`, type: "success" });
      recharger();
    } catch (e) { setToast({ message: e.message, type: "error" }); }
  };

  if (loading) return <div style={s.loading}>Chargement...</div>;

  // Panier vide
  if (!itineraire) {
    return (
      <div style={s.page}>
        <PageHeader title="🛒 Panier" subtitle={groupe?.nom} backLabel="Retour au groupe" backTo={`/groupes/${id}`} />
        <div style={s.bodyCenter}>
          <div style={s.emptyCard}>
            <div style={s.emptyIllus}>🧳</div>
            <h2 style={s.emptyTitle}>Votre panier est vide</h2>
            <p style={s.emptyText}>Composez d'abord votre voyage : transport, hébergement et activités.</p>
            <button onClick={() => navigate(`/groupes/${id}/transport`)} style={s.btnEmpty}>
              Composer mon voyage →
            </button>
          </div>
        </div>
      </div>
    );
  }

  const nbMembres = groupe?.membres?.filter(m => m.statut === "accepte").length || 1;

  // Nuits depuis le transport validé (priorité) ou dates du groupe
  const nbNuits = itineraire?.transport_date_depart && itineraire?.transport_date_arrivee
    ? Math.round((new Date(itineraire.transport_date_arrivee) - new Date(itineraire.transport_date_depart)) / 86400000)
    : (groupe?.date_depart && groupe?.date_retour
        ? Math.ceil((new Date(groupe.date_retour) - new Date(groupe.date_depart)) / 86400000)
        : 7);

  const coutParPers  = parseFloat(itineraire.cout_total || 0);
  const totalGroupe  = (coutParPers * nbMembres).toFixed(0);
  const budgetMax    = groupe?.budget_max ? parseFloat(groupe.budget_max) : null;
  const budgetDepasse= budgetMax && coutParPers > budgetMax;
  const budgetPct    = budgetMax ? Math.min((coutParPers / budgetMax) * 100, 100) : 0;

  const coutTransport = parseFloat(itineraire.transport_prix || 0);
  const coutHeb       = itineraire.prix_nuit ? parseFloat(itineraire.prix_nuit) * nbNuits : 0;
  const coutActivites = itineraire.activites?.reduce((s, a) => s + parseFloat(a.prix), 0) || 0;

  const breakdownItems = [
    {
      icon: "✈️", key: "transport",
      label: itineraire.compagnie ? `${itineraire.compagnie}` : "Aucun transport",
      sub: itineraire.compagnie ? `${itineraire.origine || ""} → ${itineraire.transport_dest || ""}` : null,
      prix: coutTransport,
      ok: !!itineraire.compagnie,
      actions: [
        { label: "Modifier", onClick: () => navigate(`/groupes/${id}/transport`), variant: "edit" },
        itineraire.compagnie && { label: "Annuler", onClick: annulerTransport, variant: "cancel" },
      ].filter(Boolean),
    },
    {
      icon: "🏨", key: "heb",
      label: itineraire.heb_nom || "Aucun hébergement",
      sub: itineraire.heb_nom ? `${itineraire.prix_nuit}€/nuit × ${nbNuits} nuits` : null,
      prix: coutHeb,
      ok: !!itineraire.heb_nom,
      actions: [
        { label: "Modifier", onClick: () => navigate(`/groupes/${id}/hebergement`), variant: "edit" },
        itineraire.heb_nom && { label: "Annuler", onClick: annulerHebergement, variant: "cancel" },
      ].filter(Boolean),
    },
  ];

  return (
    <div style={s.page}>
      <PageHeader
        title="🛒 Panier de voyage"
        subtitle={groupe?.nom}
        backLabel="Retour au groupe"
        backTo={`/groupes/${id}`}
        right={
          <div style={s.headerRight}>
            <span style={s.membresCount}>{nbMembres} voyageur{nbMembres > 1 ? "s" : ""}</span>
            <span style={s.totalBadge}>{totalGroupe}€ total</span>
          </div>
        }
      />

      <Toast message={toast?.message} type={toast?.type} onClose={() => setToast(null)} />
      <div style={s.body}>
        <div style={s.layout}>
          {/* Colonne principale */}
          <div style={s.left}>

            {/* Section articles */}
            <div style={s.card}>
              <div style={s.cardHeader}>
                <h2 style={s.cardTitle}>Récapitulatif</h2>
                <span style={s.articleCount}>
                  {[itineraire.compagnie, itineraire.heb_nom, ...(itineraire.activites || [])].filter(Boolean).length} article{itineraire.activites?.length > 1 ? "s" : ""}
                </span>
              </div>

              {/* Transport + Hébergement */}
              {breakdownItems.map((item) => (
                <div key={item.key} style={s.lineItem}>
                  <div style={{ ...s.lineIconWrap, background: item.ok ? "#E6F1FB" : "#F5F4F0" }}>
                    <span style={s.lineIcon}>{item.icon}</span>
                  </div>
                  <div style={s.lineBody}>
                    <div style={s.lineName}>{item.label}</div>
                    {item.sub && <div style={s.lineSub}>{item.sub}</div>}
                  </div>
                  <div style={s.lineRight}>
                    <div style={s.linePrix}>{item.prix > 0 ? `${item.prix.toFixed(0)}€` : "—"}</div>
                    <div style={s.lineActions}>
                      {item.actions.map((a, i) => (
                        <button key={i} onClick={a.onClick} style={a.variant === "cancel" ? s.btnCancel : s.btnEdit}>
                          {a.label}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              ))}

              {/* Activités */}
              <div style={s.activitesSection}>
                <div style={s.activitesSectionHead}>
                  <span style={s.activitesSectionTitle}>🎯 Activités</span>
                  <button onClick={() => navigate(`/groupes/${id}/activites`)} style={s.btnEditSmall}>
                    {itineraire.activites?.length > 0 ? "Modifier" : "+ Ajouter"}
                  </button>
                </div>

                {itineraire.activites?.length > 0 ? (
                  itineraire.activites.map(a => (
                    <div key={a.id} style={s.activiteRow}>
                      <div style={s.activiteLeft}>
                        <span style={s.activiteDot} />
                        <div>
                          <div style={s.activiteName}>{a.nom}</div>
                          {a.duree_heures && <div style={s.activiteSub}>{a.duree_heures}h</div>}
                        </div>
                      </div>
                      <div style={s.activiteRight}>
                        <span style={s.activitePrix}>{a.prix}€</span>
                        <button onClick={() => retirerActivite(a.id, a.nom)} style={s.btnRetirer}>
                          ✕
                        </button>
                      </div>
                    </div>
                  ))
                ) : (
                  <div style={s.activitesEmpty}>
                    Aucune activité — optionnel
                  </div>
                )}
              </div>

              {/* Total */}
              <div style={s.sepDash} />
              <div style={s.totalRow}>
                <div>
                  <div style={s.totalLabel}>Total par personne</div>
                  {budgetMax && (
                    <div style={{ fontSize: "11px", color: budgetDepasse ? "#A32D2D" : "#3B6D11", marginTop: "2px" }}>
                      {budgetDepasse
                        ? `⚠️ Dépasse le budget de ${(coutParPers - budgetMax).toFixed(0)}€`
                        : `✓ Dans le budget (max ${budgetMax}€)`}
                    </div>
                  )}
                </div>
                <div style={{ ...s.totalPrix, color: budgetDepasse ? "#A32D2D" : "#0C447C" }}>
                  {coutParPers.toFixed(0)}€
                </div>
              </div>

              {/* Barre budget */}
              {budgetMax && (
                <div style={s.budgetBarWrap}>
                  <div style={s.budgetBarTrack}>
                    <div style={{
                      ...s.budgetBarFill,
                      width: `${budgetPct}%`,
                      background: budgetDepasse ? "#E84848" : budgetPct > 85 ? "#F0A500" : "#42A85A",
                    }} />
                  </div>
                  <div style={s.budgetBarLabels}>
                    <span style={{ fontSize: "11px", color: "#73726c" }}>0€</span>
                    <span style={{ fontSize: "11px", color: "#73726c" }}>{budgetMax}€</span>
                  </div>
                </div>
              )}
            </div>

            {/* Décomposition des coûts */}
            <div style={s.card}>
              <h2 style={s.cardTitle}>Décomposition des coûts</h2>
              <div style={s.breakdownGrid}>
                {[
                  { label: "Transport", prix: coutTransport, icon: "✈️", pct: coutParPers > 0 ? Math.round(coutTransport / coutParPers * 100) : 0 },
                  { label: "Hébergement", prix: coutHeb, icon: "🏨", pct: coutParPers > 0 ? Math.round(coutHeb / coutParPers * 100) : 0 },
                  { label: "Activités", prix: coutActivites, icon: "🎯", pct: coutParPers > 0 ? Math.round(coutActivites / coutParPers * 100) : 0 },
                ].map((b, i) => (
                  <div key={i} style={s.breakdownItem}>
                    <div style={s.breakdownTop}>
                      <span style={s.breakdownIcon}>{b.icon}</span>
                      <span style={s.breakdownPrix}>{b.prix.toFixed(0)}€</span>
                    </div>
                    <div style={s.breakdownTrack}>
                      <div style={{ ...s.breakdownFill, width: `${b.pct}%` }} />
                    </div>
                    <div style={s.breakdownLabel}>{b.label} · {b.pct}%</div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Colonne droite — récap + CTA */}
          <div style={s.right}>
            <div style={s.summaryCard}>
              <h2 style={s.summaryTitle}>Récap groupe</h2>

              <div style={s.memberList}>
                {groupe?.membres?.filter(m => m.statut === "accepte").map(m => (
                  <div key={m.id} style={s.memberRow}>
                    <div style={s.avatar}>{m.nom.charAt(0).toUpperCase()}</div>
                    <div style={s.memberInfo}>
                      <div style={s.memberName}>{m.nom}</div>
                      <div style={s.memberRole}>{m.role === "organisateur" ? "👑" : "👤"}</div>
                    </div>
                    <div style={s.memberPrix}>{coutParPers.toFixed(0)}€</div>
                  </div>
                ))}
              </div>

              <div style={s.summaryTotal}>
                <div style={s.summaryTotalLabel}>Total groupe</div>
                <div style={s.summaryTotalPrix}>{totalGroupe}€</div>
                <div style={s.summaryTotalSub}>{nbMembres} × {coutParPers.toFixed(0)}€</div>
              </div>

              <button
                onClick={() => navigate(`/groupes/${id}/paiement`)}
                style={{
                  ...s.btnPay,
                  opacity: budgetDepasse ? 0.6 : 1,
                  cursor: budgetDepasse ? "not-allowed" : "pointer",
                  background: budgetDepasse
                    ? "#9AA5AE"
                    : "linear-gradient(135deg, #0C447C, #185FA5)",
                }}
                disabled={budgetDepasse}
                title={budgetDepasse ? "Budget dépassé — ajustez l'itinéraire" : ""}
              >
                {budgetDepasse ? "⚠️ Budget dépassé" : `🔒 Payer ${totalGroupe}€`}
              </button>

              <div style={s.secBadges}>
                <span style={s.secBadge}>🔐 SSL</span>
                <span style={s.secBadge}>✅ 3D Secure</span>
              </div>
              <p style={s.simNote}>🎓 Simulation pédagogique — aucun paiement réel</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

const s = {
  page:    { fontFamily: "Arial, sans-serif", minHeight: "100vh", backgroundImage: "linear-gradient(rgba(245,244,240,0.50), rgba(245,244,240,0.56)), url('/voyagevista-grouptrip/frontend/dist/images/destinations/22.jpg')", backgroundSize: "cover", backgroundAttachment: "fixed", backgroundPosition: "center" },
  loading: { textAlign: "center", padding: "60px", color: "#73726c" },

  headerRight: { display: "flex", flexDirection: "column", alignItems: "flex-end", gap: "4px" },
  membresCount: { fontSize: "12px", color: "rgba(255,255,255,0.75)" },
  totalBadge: {
    background: "rgba(255,255,255,0.18)", color: "white",
    border: "1px solid rgba(255,255,255,0.35)",
    padding: "5px 14px", borderRadius: "20px",
    fontSize: "15px", fontWeight: "800",
  },

  bodyCenter: { display: "flex", justifyContent: "center", padding: "48px 24px" },
  emptyCard: {
    background: "white", borderRadius: "20px",
    padding: "56px 40px", textAlign: "center",
    boxShadow: "0 4px 20px rgba(0,0,0,0.08)", maxWidth: "440px",
  },
  emptyIllus: { fontSize: "56px", marginBottom: "16px" },
  emptyTitle: { fontSize: "22px", fontWeight: "800", color: "#0C447C", marginBottom: "10px" },
  emptyText: { fontSize: "14px", color: "#73726c", lineHeight: 1.6, marginBottom: "24px" },
  btnEmpty: {
    background: "linear-gradient(135deg, #0C447C, #185FA5)", color: "white",
    border: "none", padding: "13px 28px", borderRadius: "10px",
    cursor: "pointer", fontSize: "15px", fontWeight: "700",
    boxShadow: "0 4px 14px rgba(12,68,124,0.25)",
  },

  body:   { padding: "24px 32px 48px", maxWidth: "1020px", margin: "0 auto" },
  layout: { display: "grid", gridTemplateColumns: "1fr 300px", gap: "20px", alignItems: "start" },
  left:   { display: "flex", flexDirection: "column", gap: "16px" },


  card: {
    background: "white", borderRadius: "16px",
    padding: "22px 24px", boxShadow: "0 2px 8px rgba(0,0,0,0.06)",
  },
  cardHeader: { display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "18px" },
  cardTitle: { fontSize: "14px", fontWeight: "700", color: "#0C447C", textTransform: "uppercase", letterSpacing: "0.4px", margin: 0 },
  articleCount: { fontSize: "12px", color: "#73726c", background: "#F5F4F0", padding: "3px 10px", borderRadius: "20px" },

  // Ligne produit
  lineItem: {
    display: "flex", alignItems: "center", gap: "14px",
    padding: "14px 0", borderBottom: "1px solid #F5F4F0",
  },
  lineIconWrap: {
    width: 44, height: 44, borderRadius: "12px",
    display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0,
  },
  lineIcon: { fontSize: "20px" },
  lineBody: { flex: 1, minWidth: 0 },
  lineName: { fontSize: "14px", fontWeight: "600", color: "#2C2C2A", marginBottom: "2px" },
  lineSub:  { fontSize: "12px", color: "#73726c" },
  lineRight: { display: "flex", flexDirection: "column", alignItems: "flex-end", gap: "6px", flexShrink: 0 },
  linePrix: { fontSize: "16px", fontWeight: "700", color: "#0C447C" },
  lineActions: { display: "flex", gap: "6px" },

  btnEdit: {
    padding: "4px 10px", borderRadius: "6px",
    border: "1px solid #185FA5", background: "white",
    color: "#185FA5", cursor: "pointer", fontSize: "11px", fontWeight: "600",
  },
  btnCancel: {
    padding: "4px 10px", borderRadius: "6px",
    border: "1px solid #F09595", background: "#FFF5F5",
    color: "#A32D2D", cursor: "pointer", fontSize: "11px", fontWeight: "600",
  },

  // Activités
  activitesSection: { paddingTop: "14px" },
  activitesSectionHead: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "10px" },
  activitesSectionTitle: { fontSize: "13px", fontWeight: "700", color: "#444" },
  btnEditSmall: {
    padding: "4px 10px", borderRadius: "6px",
    border: "1px solid #185FA5", background: "white",
    color: "#185FA5", cursor: "pointer", fontSize: "11px", fontWeight: "600",
  },
  activiteRow: {
    display: "flex", alignItems: "center", justifyContent: "space-between",
    padding: "8px 0", borderBottom: "1px solid #F5F4F0",
  },
  activiteLeft: { display: "flex", alignItems: "center", gap: "10px", flex: 1 },
  activiteDot: { width: 7, height: 7, borderRadius: "50%", background: "#185FA5", flexShrink: 0 },
  activiteName: { fontSize: "13px", fontWeight: "500", color: "#2C2C2A" },
  activiteSub: { fontSize: "11px", color: "#73726c" },
  activiteRight: { display: "flex", alignItems: "center", gap: "8px", flexShrink: 0 },
  activitePrix: { fontSize: "13px", fontWeight: "700", color: "#0C447C" },
  btnRetirer: {
    width: 22, height: 22, borderRadius: "50%",
    border: "1px solid #D1CFC5", background: "#F5F4F0",
    color: "#73726c", cursor: "pointer", fontSize: "11px",
    display: "flex", alignItems: "center", justifyContent: "center",
    flexShrink: 0,
  },
  activitesEmpty: { fontSize: "13px", color: "#B0AFA8", padding: "8px 0", fontStyle: "italic" },

  // Total
  sepDash: { borderTop: "2px dashed #E0DED6", margin: "16px 0" },
  totalRow: { display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "14px" },
  totalLabel: { fontSize: "15px", fontWeight: "700", color: "#2C2C2A" },
  totalPrix: { fontSize: "32px", fontWeight: "800", lineHeight: 1 },

  // Barre budget
  budgetBarWrap: { marginTop: "4px" },
  budgetBarTrack: { height: 8, background: "#E0DED6", borderRadius: 4, overflow: "hidden", marginBottom: "4px" },
  budgetBarFill: { height: "100%", borderRadius: 4, transition: "width 0.4s" },
  budgetBarLabels: { display: "flex", justifyContent: "space-between" },

  // Décomposition
  breakdownGrid: { display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: "14px", marginTop: "14px" },
  breakdownItem: { display: "flex", flexDirection: "column", gap: "6px" },
  breakdownTop: { display: "flex", justifyContent: "space-between", alignItems: "center" },
  breakdownIcon: { fontSize: "18px" },
  breakdownPrix: { fontSize: "15px", fontWeight: "700", color: "#0C447C" },
  breakdownTrack: { height: 6, background: "#E0DED6", borderRadius: 3, overflow: "hidden" },
  breakdownFill: { height: "100%", background: "#185FA5", borderRadius: 3 },
  breakdownLabel: { fontSize: "11px", color: "#73726c" },

  // Colonne droite
  right: { position: "sticky", top: "20px" },
  summaryCard: {
    background: "white", borderRadius: "16px",
    padding: "22px 22px", boxShadow: "0 2px 8px rgba(0,0,0,0.06)",
  },
  summaryTitle: { fontSize: "14px", fontWeight: "700", color: "#0C447C", textTransform: "uppercase", letterSpacing: "0.4px", marginBottom: "18px" },

  memberList: { display: "flex", flexDirection: "column", gap: "10px", marginBottom: "18px" },
  memberRow: { display: "flex", alignItems: "center", gap: "10px" },
  avatar: {
    width: 34, height: 34, borderRadius: "50%",
    background: "linear-gradient(135deg, #0C447C, #185FA5)",
    color: "white", display: "flex",
    alignItems: "center", justifyContent: "center",
    fontSize: "13px", fontWeight: "800", flexShrink: 0,
  },
  memberInfo: { flex: 1 },
  memberName: { fontSize: "13px", fontWeight: "600", color: "#2C2C2A" },
  memberRole: { fontSize: "11px" },
  memberPrix: { fontSize: "13px", fontWeight: "700", color: "#0C447C" },

  summaryTotal: {
    background: "linear-gradient(135deg, #E6F1FB, #D4E8F5)",
    borderRadius: "12px", padding: "16px",
    textAlign: "center", marginBottom: "16px",
  },
  summaryTotalLabel: { fontSize: "11px", fontWeight: "700", color: "#185FA5", textTransform: "uppercase", letterSpacing: "0.5px", marginBottom: "4px" },
  summaryTotalPrix: { fontSize: "34px", fontWeight: "800", color: "#0C447C", lineHeight: 1 },
  summaryTotalSub: { fontSize: "12px", color: "#185FA5", marginTop: "4px" },

  btnPay: {
    width: "100%", padding: "14px",
    color: "white", border: "none",
    borderRadius: "12px", fontSize: "15px",
    fontWeight: "700", boxShadow: "0 4px 14px rgba(12,68,124,0.25)",
    marginBottom: "12px", transition: "opacity 0.2s",
  },
  secBadges: { display: "flex", justifyContent: "center", gap: "8px", marginBottom: "8px" },
  secBadge: {
    background: "#F5F4F0", padding: "4px 10px",
    borderRadius: "20px", fontSize: "11px", color: "#73726c",
  },
  simNote: { textAlign: "center", fontSize: "11px", color: "#B0AFA8", margin: 0 },
};
