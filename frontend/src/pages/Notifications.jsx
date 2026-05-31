import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { api } from "../services/api";
import PageHeader from "../components/PageHeader";

export default function Notifications() {
  const navigate = useNavigate();
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get("/api/notifications")
      .then(setNotifications)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const marquerLue = async (id) => {
    try {
      await api.put(`/api/notifications/${id}/lire`, {});
      setNotifications((prev) =>
        prev.map((n) => (n.id === id ? { ...n, lu: "1" } : n))
      );
    } catch (e) {
      console.error(e);
    }
  };

  const handleClick = async (n) => {
    if (n.lu !== "1" && n.lu !== 1) await marquerLue(n.id);
    if (n.lien) navigate(n.lien);
  };

  const marquerToutesLues = async () => {
    try {
      await api.put("/api/notifications/lire-tout", {});
      setNotifications((prev) => prev.map((n) => ({ ...n, lu: "1" })));
    } catch (e) {
      console.error(e);
    }
  };

  const nbNonLues = notifications.filter((n) => n.lu === "0" || n.lu === 0).length;

  const typeIcon = {
    invitation: "✉️",
    vote: "🗳️",
    itineraire: "🗺️",
    reservation: "🎫",
    paiement: "💳",
    groupe: "👥",
  };

  const formatDate = (dt) => {
    const d = new Date(dt);
    const now = new Date();
    const diffMin = Math.floor((now - d) / 60000);
    if (diffMin < 1) return "À l'instant";
    if (diffMin < 60) return `Il y a ${diffMin} min`;
    const diffH = Math.floor(diffMin / 60);
    if (diffH < 24) return `Il y a ${diffH}h`;
    return d.toLocaleDateString("fr-FR", { day: "numeric", month: "short" });
  };

  if (loading) return <div style={styles.loading}>Chargement...</div>;

  return (
    <div style={styles.page}>
      <PageHeader
        title={<>🔔 Notifications {nbNonLues > 0 && <span style={styles.badge}>{nbNonLues}</span>}</>}
        backLabel="Tableau de bord"
        backTo="/dashboard"
        right={nbNonLues > 0 && (
          <button onClick={marquerToutesLues} style={styles.btnToutLire}>
            Tout marquer comme lu
          </button>
        )}
      />

      <div style={styles.body}>
        {notifications.length === 0 ? (
          <div style={styles.empty}>
            <div style={styles.emptyIcon}>🔔</div>
            <p style={styles.emptyText}>Aucune notification pour l'instant.</p>
          </div>
        ) : (
          <div style={styles.list}>
            {notifications.map((n) => {
              const estLue = n.lu === "1" || n.lu === 1;
              return (
                <div
                  key={n.id}
                  style={{
                    ...styles.notif,
                    background: estLue ? "white" : "#EEF5FF",
                    borderLeft: estLue ? "3px solid transparent" : "3px solid #185FA5",
                    cursor: n.lien ? "pointer" : (estLue ? "default" : "pointer"),
                  }}
                  onClick={() => handleClick(n)}
                >
                  <div style={styles.notifIcon}>
                    {typeIcon[n.type] || "📌"}
                  </div>
                  <div style={styles.notifBody}>
                    <p style={styles.notifMsg}>{n.message}</p>
                    <span style={styles.notifDate}>{formatDate(n.created_at)}</span>
                  </div>
                  {!estLue && <div style={styles.dot} title="Non lue" />}
                  {n.lien && <span style={styles.arrow}>›</span>}
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

const styles = {
  page: { fontFamily: "Arial, sans-serif", minHeight: "100vh", background: "#F5F4F0" },
  loading: { textAlign: "center", padding: "60px", color: "#73726c" },
  badge: {
    background: "#E84848", color: "white", borderRadius: "50%",
    width: "24px", height: "24px", display: "inline-flex", alignItems: "center",
    justifyContent: "center", fontSize: "12px", fontWeight: "bold",
  },
  btnToutLire: {
    background: "rgba(255,255,255,0.15)", border: "1px solid rgba(255,255,255,0.4)",
    color: "white", padding: "6px 14px", borderRadius: "6px",
    cursor: "pointer", fontSize: "13px",
  },
  body: { padding: "24px 32px", maxWidth: "680px", margin: "0 auto" },
  empty: { textAlign: "center", padding: "60px 0" },
  emptyIcon: { fontSize: "48px", marginBottom: "12px" },
  emptyText: { color: "#73726c", fontSize: "15px" },
  list: { display: "flex", flexDirection: "column", gap: "8px" },
  notif: {
    display: "flex", alignItems: "flex-start", gap: "14px",
    padding: "14px 16px", borderRadius: "10px",
    boxShadow: "0 1px 4px rgba(0,0,0,0.06)", cursor: "pointer",
    transition: "background 0.15s",
  },
  notifIcon: { fontSize: "22px", flexShrink: 0, marginTop: "2px" },
  notifBody: { flex: 1 },
  notifMsg: { fontSize: "14px", color: "#2C2C2A", margin: "0 0 4px", lineHeight: "1.5" },
  notifDate: { fontSize: "12px", color: "#999" },
  dot: {
    width: "10px", height: "10px", borderRadius: "50%",
    background: "#185FA5", flexShrink: 0, marginTop: "6px",
  },
  arrow: {
    fontSize: "20px", color: "#B0AFA8", flexShrink: 0,
    marginLeft: "4px", lineHeight: 1,
  },
};
