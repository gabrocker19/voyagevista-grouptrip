import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { api } from "../services/api";
import PageHeader from "../components/PageHeader";

const TYPE_META = {
  invitation: { icon: "✉️", color: "#185FA5", bg: "#E6F1FB", label: "Invitation" },
  vote:        { icon: "🗳️", color: "#854F0B", bg: "#FFF8E6", label: "Vote" },
  itineraire:  { icon: "🗺️", color: "#2E5E9E", bg: "#E8EFF9", label: "Itinéraire" },
  reservation: { icon: "🎫", color: "#3B6D11", bg: "#EAF3DE", label: "Réservation" },
  paiement:    { icon: "💳", color: "#6B3A9E", bg: "#F2EBFC", label: "Paiement" },
  groupe:      { icon: "👥", color: "#0C447C", bg: "#E6F1FB", label: "Groupe" },
};

export default function Notifications() {
  const navigate = useNavigate();
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("all");

  useEffect(() => {
    api.get("/api/notifications")
      .then(setNotifications)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const marquerLue = async (id) => {
    try {
      await api.put(`/api/notifications/${id}/lire`, {});
      setNotifications(prev => prev.map(n => n.id === id ? { ...n, lu: "1" } : n));
    } catch {}
  };

  const marquerToutesLues = async () => {
    try {
      await api.put("/api/notifications/lire-tout", {});
      setNotifications(prev => prev.map(n => ({ ...n, lu: "1" })));
    } catch {}
  };

  const handleClick = async (n) => {
    if (n.lu !== "1" && n.lu !== 1) await marquerLue(n.id);
    if (n.lien) navigate(n.lien);
  };

  const nbNonLues = notifications.filter(n => n.lu === "0" || n.lu === 0).length;

  const formatDate = (dt) => {
    const d = new Date(dt);
    const now = new Date();
    const diffMin = Math.floor((now - d) / 60000);
    if (diffMin < 1) return "À l'instant";
    if (diffMin < 60) return `Il y a ${diffMin} min`;
    const diffH = Math.floor(diffMin / 60);
    if (diffH < 24) return `Il y a ${diffH}h`;
    const diffD = Math.floor(diffH / 24);
    if (diffD === 1) return "Hier";
    if (diffD < 7) return `Il y a ${diffD} jours`;
    return d.toLocaleDateString("fr-FR", { day: "numeric", month: "short" });
  };

  const groupByDate = (list) => {
    const now = new Date();
    const today = [], yesterday = [], older = [];
    list.forEach(n => {
      const d = new Date(n.created_at);
      const diffH = (now - d) / 3600000;
      if (diffH < 24) today.push(n);
      else if (diffH < 48) yesterday.push(n);
      else older.push(n);
    });
    return [
      ...(today.length > 0 ? [{ sep: "Aujourd'hui" }, ...today] : []),
      ...(yesterday.length > 0 ? [{ sep: "Hier" }, ...yesterday] : []),
      ...(older.length > 0 ? [{ sep: "Plus ancien" }, ...older] : []),
    ];
  };

  const types = [...new Set(notifications.map(n => n.type))];
  const filtered = filter === "all"
    ? notifications
    : filter === "nonlues"
      ? notifications.filter(n => n.lu === "0" || n.lu === 0)
      : notifications.filter(n => n.type === filter);

  const grouped = groupByDate(filtered);

  if (loading) return <div style={s.loading}>Chargement...</div>;

  return (
    <div style={s.page}>
      <PageHeader
        title={
          <span style={{ display: "flex", alignItems: "center", gap: "10px" }}>
            🔔 Notifications
            {nbNonLues > 0 && <span style={s.badge}>{nbNonLues}</span>}
          </span>
        }
        backLabel="Tableau de bord"
        backTo="/dashboard"
        right={nbNonLues > 0 && (
          <button onClick={marquerToutesLues} style={s.btnToutLire}>
            Tout marquer comme lu
          </button>
        )}
      />

      <div style={s.body}>
        {/* Filtres */}
        {notifications.length > 0 && (
          <div style={s.filters}>
            <button
              onClick={() => setFilter("all")}
              style={{ ...s.filterChip, ...(filter === "all" ? s.filterChipActive : {}) }}
            >
              Toutes ({notifications.length})
            </button>
            {nbNonLues > 0 && (
              <button
                onClick={() => setFilter("nonlues")}
                style={{ ...s.filterChip, ...(filter === "nonlues" ? s.filterChipActive : {}) }}
              >
                Non lues ({nbNonLues})
              </button>
            )}
            {types.map(t => {
              const meta = TYPE_META[t] || { icon: "📌", label: t, color: "#73726c", bg: "#F5F4F0" };
              return (
                <button
                  key={t}
                  onClick={() => setFilter(t)}
                  style={{ ...s.filterChip, ...(filter === t ? s.filterChipActive : {}), ...(filter === t ? { borderColor: meta.color } : {}) }}
                >
                  {meta.icon} {meta.label}
                </button>
              );
            })}
          </div>
        )}

        {filtered.length === 0 ? (
          <div style={s.empty}>
            <div style={s.emptyIllustration}>
              {filter === "nonlues" ? "✅" : "🔔"}
            </div>
            <h3 style={s.emptyTitle}>
              {filter === "nonlues" ? "Tout est lu !" : "Aucune notification"}
            </h3>
            <p style={s.emptyText}>
              {filter === "nonlues"
                ? "Vous êtes à jour sur toutes vos notifications."
                : "Vous recevrez des notifications pour les invitations, votes et mises à jour de vos voyages."}
            </p>
            {filter !== "all" && (
              <button onClick={() => setFilter("all")} style={s.btnReset}>
                Voir toutes les notifications
              </button>
            )}
          </div>
        ) : (
          <div style={s.list}>
            {grouped.map((item, idx) => {
              if (item.sep) {
                return (
                  <div key={`sep-${idx}`} style={s.dateSep}>
                    <div style={s.dateSepLine} />
                    <span style={s.dateSepLabel}>{item.sep}</span>
                    <div style={s.dateSepLine} />
                  </div>
                );
              }
              const n = item;
              const estLue = n.lu === "1" || n.lu === 1;
              const meta = TYPE_META[n.type] || { icon: "📌", color: "#73726c", bg: "#F5F4F0", label: "Autre" };

              return (
                <div
                  key={n.id}
                  style={{
                    ...s.notif,
                    background: estLue ? "white" : "#F0F6FF",
                    borderLeft: estLue ? "3px solid transparent" : `3px solid ${meta.color}`,
                    cursor: n.lien ? "pointer" : (estLue ? "default" : "pointer"),
                  }}
                  onClick={() => handleClick(n)}
                >
                  <div style={{ ...s.notifIconWrap, background: meta.bg }}>
                    <span style={s.notifIcon}>{meta.icon}</span>
                  </div>

                  <div style={s.notifBody}>
                    <div style={s.notifTopRow}>
                      <span style={{ ...s.typePill, background: meta.bg, color: meta.color }}>
                        {meta.label}
                      </span>
                      <span style={s.notifDate}>{formatDate(n.created_at)}</span>
                    </div>
                    <p style={{ ...s.notifMsg, fontWeight: estLue ? "400" : "600" }}>
                      {n.message}
                    </p>
                  </div>

                  <div style={s.notifRight}>
                    {!estLue && <div style={{ ...s.dot, background: meta.color }} />}
                    {n.lien && <span style={s.arrow}>›</span>}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

const s = {
  page:    { fontFamily: "Arial, sans-serif", minHeight: "100vh", backgroundImage: "linear-gradient(rgba(245,244,240,0.50), rgba(245,244,240,0.56)), url('/voyagevista-grouptrip/frontend/dist/images/autre/gettyimages-1297349747-612x612.jpg')", backgroundSize: "cover", backgroundAttachment: "fixed", backgroundPosition: "center" },
  loading: { textAlign: "center", padding: "60px", color: "#73726c" },
  badge: {
    background: "#E84848", color: "white", borderRadius: "20px",
    padding: "1px 8px", fontSize: "12px", fontWeight: "700",
  },
  btnToutLire: {
    background: "rgba(255,255,255,0.15)", border: "1px solid rgba(255,255,255,0.4)",
    color: "white", padding: "7px 14px", borderRadius: "8px",
    cursor: "pointer", fontSize: "13px", fontWeight: "600",
  },

  body: { padding: "24px 32px 48px", maxWidth: "720px", margin: "0 auto" },

  filters: {
    display: "flex", flexWrap: "wrap", gap: "8px",
    marginBottom: "16px",
  },
  filterChip: {
    padding: "6px 14px", borderRadius: "20px",
    border: "1.5px solid #D1CFC5", background: "white",
    cursor: "pointer", fontSize: "12px", fontWeight: "600",
    color: "#444", transition: "all 0.15s",
  },
  filterChipActive: {
    background: "#0C447C", color: "white",
    borderColor: "#0C447C",
  },

  empty: { textAlign: "center", padding: "60px 0 40px" },
  emptyIllustration: { fontSize: "52px", marginBottom: "14px" },
  emptyTitle: { fontSize: "18px", fontWeight: "700", color: "#0C447C", marginBottom: "8px" },
  emptyText: { fontSize: "14px", color: "#73726c", maxWidth: "320px", margin: "0 auto 20px", lineHeight: 1.6 },
  btnReset: {
    padding: "9px 20px", borderRadius: "8px",
    border: "1.5px solid #185FA5", background: "white",
    color: "#185FA5", cursor: "pointer", fontSize: "13px", fontWeight: "600",
  },

  dateSep: { display: "flex", alignItems: "center", gap: "10px", margin: "10px 0 4px" },
  dateSepLine: { flex: 1, height: 1, background: "#E0DED6" },
  dateSepLabel: { fontSize: "11px", fontWeight: "700", color: "#B0AFA8", textTransform: "uppercase", letterSpacing: "0.5px", whiteSpace: "nowrap" },

  list: { display: "flex", flexDirection: "column", gap: "6px" },
  notif: {
    display: "flex", alignItems: "flex-start", gap: "14px",
    padding: "14px 16px", borderRadius: "12px",
    boxShadow: "0 1px 4px rgba(0,0,0,0.05)",
    transition: "background 0.15s, transform 0.1s",
  },
  notifIconWrap: {
    width: 40, height: 40, borderRadius: "10px",
    display: "flex", alignItems: "center", justifyContent: "center",
    flexShrink: 0,
  },
  notifIcon: { fontSize: "18px" },
  notifBody: { flex: 1, minWidth: 0 },
  notifTopRow: { display: "flex", alignItems: "center", gap: "8px", marginBottom: "4px" },
  typePill: { fontSize: "10px", fontWeight: "700", padding: "2px 8px", borderRadius: "12px", textTransform: "uppercase", letterSpacing: "0.3px" },
  notifDate: { fontSize: "11px", color: "#B0AFA8", marginLeft: "auto" },
  notifMsg: { fontSize: "14px", color: "#2C2C2A", margin: 0, lineHeight: 1.5 },
  notifRight: { display: "flex", flexDirection: "column", alignItems: "center", gap: "6px", flexShrink: 0 },
  dot: { width: 9, height: 9, borderRadius: "50%" },
  arrow: { fontSize: "20px", color: "#C0BEB5", lineHeight: 1 },
};
