import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { Link, useNavigate } from "react-router-dom";
import { groupService } from "../services/group.service";

export default function Dashboard() {
  const { user } = useAuth();
  const [groupes, setGroupes] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    groupService
      .getAll()
      .then(setGroupes)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const statutColors = {
    en_formation: { bg: "#FAEEDA", color: "#854F0B", label: "En formation" },
    vote_en_cours: { bg: "#E6F1FB", color: "#185FA5", label: "Vote en cours" },
    plan_valide: { bg: "#EAF3DE", color: "#3B6D11", label: "Plan validé" },
    reservation_confirmee: {
      bg: "#EAF3DE",
      color: "#3B6D11",
      label: "Confirmé",
    },
  };

  return (
    <div style={styles.page}>
      {/* Header */}
      <div style={styles.header}>
        <div>
          <h1 style={styles.title}>Bonjour, {user?.nom} 👋</h1>
          <p style={styles.sub}>Bienvenue sur votre espace GroupTrip</p>
        </div>
        <button
          onClick={() => navigate("/groupes/creer")}
          style={styles.btnCreate}
        >
          + Nouveau GroupTrip
        </button>
      </div>

      <div style={styles.body}>
        {/* Mes groupes */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>🌍 Mes voyages</h2>

          {loading ? (
            <p style={styles.empty}>Chargement...</p>
          ) : groupes.length === 0 ? (
            <div style={styles.emptyBox}>
              <div style={{ fontSize: "40px", marginBottom: "12px" }}>✈️</div>
              <p style={{ marginBottom: "16px", color: "#73726c" }}>
                Vous n'avez pas encore de voyage.
              </p>
              <button
                onClick={() => navigate("/groupes/creer")}
                style={styles.btnPrimary}
              >
                Créer mon premier GroupTrip
              </button>
            </div>
          ) : (
            <div style={styles.groupGrid}>
              {groupes.map((g) => {
                const sc = statutColors[g.statut] || statutColors.en_formation;
                return (
                  <div
                    key={g.id}
                    style={styles.groupCard}
                    onClick={() => navigate(`/groupes/${g.id}`)}
                  >
                    <div style={styles.groupCardTop}>
                      <div style={styles.groupIcon}>✈️</div>
                      <span
                        style={{
                          ...styles.badge,
                          background: sc.bg,
                          color: sc.color,
                        }}
                      >
                        {sc.label}
                      </span>
                    </div>
                    <h3 style={styles.groupName}>{g.nom}</h3>
                    <p style={styles.groupMeta}>
                      Organisé par {g.organisateur_nom}
                    </p>
                    {g.budget_max && (
                      <p style={styles.groupBudget}>
                        💶 Budget : {g.budget_max}€ / pers.
                      </p>
                    )}
                    <div style={styles.groupRole}>
                      <span
                        style={{
                          ...styles.roleBadge,
                          background:
                            g.mon_role === "organisateur"
                              ? "#E6F1FB"
                              : "#F5F4F0",
                          color:
                            g.mon_role === "organisateur"
                              ? "#0C447C"
                              : "#73726c",
                        }}
                      >
                        {g.mon_role === "organisateur"
                          ? "👑 Organisateur"
                          : "👤 Membre"}
                      </span>
                    </div>
                  </div>
                );
              })}

              {/* Carte + créer */}
              <div
                style={styles.groupCardAdd}
                onClick={() => navigate("/groupes/creer")}
              >
                <div style={{ fontSize: "32px", marginBottom: "8px" }}>+</div>
                <p style={{ color: "#185FA5", fontWeight: "500" }}>
                  Nouveau voyage
                </p>
              </div>
            </div>
          )}
        </div>

        {/* Liens rapides */}
        <div style={styles.quickLinks}>
          <Link to="/catalogue" style={styles.quickLink}>
            🌍 Explorer les destinations
          </Link>
        </div>
      </div>
    </div>
  );
}

const styles = {
  page: {
    fontFamily: "Arial, sans-serif",
    minHeight: "100vh",
    background: "#F5F4F0",
  },
  header: {
    background: "#0C447C",
    color: "white",
    padding: "32px",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },
  title: { fontSize: "26px", fontWeight: "bold", marginBottom: "6px" },
  sub: { opacity: 0.8, fontSize: "14px" },
  btnCreate: {
    background: "white",
    color: "#0C447C",
    border: "none",
    padding: "10px 20px",
    borderRadius: "8px",
    cursor: "pointer",
    fontWeight: "bold",
    fontSize: "14px",
  },
  body: {
    padding: "24px 32px",
    display: "flex",
    flexDirection: "column",
    gap: "20px",
  },
  section: {
    background: "white",
    borderRadius: "12px",
    padding: "24px",
    boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
  },
  sectionTitle: {
    fontSize: "16px",
    fontWeight: "bold",
    color: "#0C447C",
    marginBottom: "16px",
  },
  empty: { color: "#73726c", fontSize: "14px" },
  emptyBox: { textAlign: "center", padding: "32px" },
  btnPrimary: {
    background: "#185FA5",
    color: "white",
    border: "none",
    padding: "10px 24px",
    borderRadius: "8px",
    cursor: "pointer",
    fontSize: "14px",
    fontWeight: "500",
  },
  groupGrid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
    gap: "16px",
  },
  groupCard: {
    background: "#F5F4F0",
    borderRadius: "10px",
    padding: "18px",
    cursor: "pointer",
    transition: "box-shadow 0.2s",
    border: "1px solid #E0DED6",
  },
  groupCardAdd: {
    background: "#F5F4F0",
    borderRadius: "10px",
    padding: "18px",
    cursor: "pointer",
    border: "2px dashed #D1CFC5",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    minHeight: "140px",
  },
  groupCardTop: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: "10px",
  },
  groupIcon: { fontSize: "24px" },
  badge: {
    fontSize: "11px",
    padding: "3px 8px",
    borderRadius: "12px",
    fontWeight: "600",
  },
  groupName: {
    fontSize: "16px",
    fontWeight: "bold",
    color: "#0C447C",
    marginBottom: "4px",
  },
  groupMeta: { fontSize: "12px", color: "#73726c", marginBottom: "4px" },
  groupBudget: { fontSize: "12px", color: "#444", marginBottom: "8px" },
  groupRole: { marginTop: "8px" },
  roleBadge: { fontSize: "11px", padding: "3px 8px", borderRadius: "12px" },
  quickLinks: { display: "flex", gap: "12px" },
  quickLink: {
    background: "white",
    color: "#185FA5",
    padding: "12px 20px",
    borderRadius: "8px",
    textDecoration: "none",
    fontWeight: "500",
    boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
    fontSize: "14px",
  },
};
