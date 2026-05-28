import { useAuth } from "../context/AuthContext";
import { Link } from "react-router-dom";

export default function Dashboard() {
  const { user } = useAuth();

  return (
    <div style={styles.page}>
      <div style={styles.header}>
        <h1 style={styles.title}>Bonjour, {user?.nom} 👋</h1>
        <p style={styles.sub}>Bienvenue sur votre espace GroupTrip</p>
      </div>

      <div style={styles.grid}>
        <div style={styles.card}>
          <div style={styles.icon}>🌍</div>
          <h3>Mes voyages</h3>
          <p style={styles.cardSub}>Aucun voyage pour l'instant</p>
          <button style={styles.btn}>Créer un GroupTrip</button>
        </div>
        <div style={styles.card}>
          <div style={styles.icon}>🗳️</div>
          <h3>Votes en cours</h3>
          <p style={styles.cardSub}>Aucun vote en attente</p>
        </div>
        <div style={styles.card}>
          <div style={styles.icon}>🔔</div>
          <h3>Notifications</h3>
          <p style={styles.cardSub}>Aucune notification</p>
        </div>
        <div style={styles.card}>
          <div style={styles.icon}>💸</div>
          <h3>Dépenses</h3>
          <p style={styles.cardSub}>Aucune dépense enregistrée</p>
        </div>
      </div>

      <div style={styles.quickLinks}>
        <Link to="/catalogue" style={styles.link}>
          🌍 Explorer les destinations
        </Link>
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
  header: { background: "#0C447C", color: "white", padding: "40px 32px" },
  title: { fontSize: "28px", fontWeight: "bold", marginBottom: "8px" },
  sub: { opacity: 0.85, fontSize: "15px" },
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
    gap: "20px",
    padding: "32px",
  },
  card: {
    background: "white",
    borderRadius: "12px",
    padding: "24px",
    boxShadow: "0 2px 8px rgba(0,0,0,0.07)",
  },
  icon: { fontSize: "32px", marginBottom: "12px" },
  cardSub: { color: "#999", fontSize: "13px", margin: "8px 0 16px" },
  btn: {
    background: "#185FA5",
    color: "white",
    border: "none",
    padding: "8px 16px",
    borderRadius: "6px",
    cursor: "pointer",
    fontSize: "13px",
  },
  quickLinks: { padding: "0 32px 32px" },
  link: {
    display: "inline-block",
    background: "white",
    color: "#185FA5",
    padding: "12px 20px",
    borderRadius: "8px",
    textDecoration: "none",
    fontWeight: "500",
    boxShadow: "0 2px 8px rgba(0,0,0,0.07)",
  },
};
