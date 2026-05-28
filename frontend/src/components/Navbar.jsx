import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Navbar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate("/login");
  };

  return (
    <nav style={styles.nav}>
      <Link to="/" style={styles.logo}>
        ✈ VoyageVista
      </Link>
      <div style={styles.links}>
        {user ? (
          <>
            <Link to="/dashboard" style={styles.link}>
              Mon espace
            </Link>
            <Link to="/catalogue" style={styles.link}>
              Destinations
            </Link>
            <span style={styles.username}>👤 {user.nom}</span>
            <button onClick={handleLogout} style={styles.btn}>
              Déconnexion
            </button>
          </>
        ) : (
          <>
            <Link to="/login" style={styles.link}>
              Connexion
            </Link>
            <Link to="/register" style={styles.link}>
              Inscription
            </Link>
          </>
        )}
      </div>
    </nav>
  );
}

const styles = {
  nav: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    padding: "12px 32px",
    background: "#0C447C",
    color: "white",
  },
  logo: {
    color: "white",
    textDecoration: "none",
    fontSize: "20px",
    fontWeight: "bold",
  },
  links: { display: "flex", alignItems: "center", gap: "20px" },
  link: { color: "white", textDecoration: "none", fontSize: "14px" },
  username: { color: "#E6F1FB", fontSize: "14px" },
  btn: {
    background: "#185FA5",
    color: "white",
    border: "1px solid white",
    padding: "6px 14px",
    borderRadius: "6px",
    cursor: "pointer",
    fontSize: "14px",
  },
};
