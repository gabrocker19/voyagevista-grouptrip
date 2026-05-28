import { Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Home() {
  const { user } = useAuth();

  return (
    <div style={styles.page}>
      <div style={styles.hero}>
        <h1 style={styles.title}>Planifiez. Explorez. Vivez.</h1>
        <p style={styles.sub}>
          Organisez vos voyages en groupe, votez pour les destinations, partagez
          les dépenses. Tout en un.
        </p>
        {user ? (
          <Link to="/dashboard" style={styles.btnPrimary}>
            Accéder à mon espace →
          </Link>
        ) : (
          <div
            style={{ display: "flex", gap: "16px", justifyContent: "center" }}
          >
            <Link to="/register" style={styles.btnPrimary}>
              Créer un compte
            </Link>
            <Link to="/login" style={styles.btnSecondary}>
              Se connecter
            </Link>
          </div>
        )}
      </div>

      <div style={styles.features}>
        <div style={styles.card}>
          <div style={styles.icon}>🗳️</div>
          <h3>Votez ensemble</h3>
          <p>
            Destination, dates, hébergement — chaque décision se prend
            collectivement.
          </p>
        </div>
        <div style={styles.card}>
          <div style={styles.icon}>✈️</div>
          <h3>Planifiez facilement</h3>
          <p>
            Transport, hébergement et activités réunis dans un seul itinéraire.
          </p>
        </div>
        <div style={styles.card}>
          <div style={styles.icon}>💸</div>
          <h3>Partagez les dépenses</h3>
          <p>
            Suivez les dépenses sur place et sachez exactement qui doit quoi.
          </p>
        </div>
      </div>
    </div>
  );
}

const styles = {
  page: { fontFamily: "Arial, sans-serif" },
  hero: {
    textAlign: "center",
    padding: "80px 32px",
    background: "linear-gradient(135deg, #0C447C, #185FA5)",
    color: "white",
  },
  title: { fontSize: "42px", fontWeight: "bold", marginBottom: "16px" },
  sub: {
    fontSize: "18px",
    marginBottom: "32px",
    opacity: 0.9,
    maxWidth: "500px",
    margin: "0 auto 32px",
  },
  btnPrimary: {
    background: "white",
    color: "#0C447C",
    padding: "12px 28px",
    borderRadius: "8px",
    textDecoration: "none",
    fontWeight: "bold",
    fontSize: "16px",
  },
  btnSecondary: {
    background: "transparent",
    color: "white",
    padding: "12px 28px",
    borderRadius: "8px",
    textDecoration: "none",
    fontWeight: "bold",
    fontSize: "16px",
    border: "2px solid white",
  },
  features: {
    display: "flex",
    gap: "24px",
    padding: "48px 32px",
    justifyContent: "center",
    background: "#F5F4F0",
  },
  card: {
    background: "white",
    borderRadius: "12px",
    padding: "28px",
    textAlign: "center",
    maxWidth: "260px",
    boxShadow: "0 2px 8px rgba(0,0,0,0.08)",
  },
  icon: { fontSize: "36px", marginBottom: "12px" },
};
