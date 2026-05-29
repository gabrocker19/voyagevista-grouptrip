import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { useState, useEffect } from "react";
import { api } from "../services/api";

export default function Navbar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [nbNotifs, setNbNotifs] = useState(0);

  useEffect(() => {
    if (!user) return;
    api.get("/api/notifications")
      .then((notifs) => {
        const nonLues = notifs.filter((n) => n.lu === "0" || n.lu === 0).length;
        setNbNotifs(nonLues);
      })
      .catch(() => {});
  }, [user]);

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
            {user.role === "admin" && (
              <Link to="/admin" style={{ ...styles.link, color: "#FFD580" }}>
                ⚙️ Admin
              </Link>
            )}
            <Link to="/notifications" style={styles.notifLink}>
              🔔
              {nbNotifs > 0 && (
                <span style={styles.notifBadge}>{nbNotifs > 9 ? "9+" : nbNotifs}</span>
              )}
            </Link>
            <Link to="/profil" style={styles.profilLink}>
              <div style={styles.avatarSmall}>
                {user.nom.charAt(0).toUpperCase()}
              </div>
              <span style={styles.username}>{user.nom}</span>
            </Link>
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
  notifLink: {
    color: "white",
    textDecoration: "none",
    fontSize: "18px",
    position: "relative",
    display: "flex",
    alignItems: "center",
  },
  notifBadge: {
    position: "absolute",
    top: "-6px",
    right: "-8px",
    background: "#E84848",
    color: "white",
    borderRadius: "10px",
    fontSize: "10px",
    fontWeight: "bold",
    padding: "1px 5px",
    minWidth: "16px",
    textAlign: "center",
  },
  profilLink: {
    color: "white",
    textDecoration: "none",
    display: "flex",
    alignItems: "center",
    gap: "8px",
  },
  avatarSmall: {
    width: "28px",
    height: "28px",
    borderRadius: "50%",
    background: "rgba(255,255,255,0.2)",
    border: "1px solid rgba(255,255,255,0.5)",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "13px",
    fontWeight: "bold",
  },
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
