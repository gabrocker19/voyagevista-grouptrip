import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { useState, useEffect } from "react";
import { api } from "../services/api";

export default function Navbar() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [nbNotifs, setNbNotifs] = useState(0);

  useEffect(() => {
    if (!user) return;
    api.get("/api/notifications")
      .then((notifs) => {
        setNbNotifs(notifs.filter((n) => n.lu === "0" || n.lu === 0).length);
      })
      .catch(() => {});
  }, [user, location.pathname]);

  return (
    <nav style={s.nav}>
      <Link to="/" style={s.logo}>
        <span style={s.logoIcon}>✈</span>
        VoyageVista
      </Link>

      <div style={s.links}>
        {user ? (
          <>
            <Link
              to="/dashboard"
              style={location.pathname === "/dashboard" ? { ...s.btnPrimary, ...s.btnPrimaryActive } : s.btnPrimary}
            >
              Mon espace
            </Link>
            <Link
              to="/catalogue"
              style={location.pathname === "/catalogue" ? { ...s.btnOutline, ...s.btnOutlineActive } : s.btnOutline}
            >
              Destinations
            </Link>

            {user.role === "admin" && (
              <Link to="/admin" style={s.btnAdmin}>
                ⚙️ Admin
              </Link>
            )}

            <Link to="/notifications" style={s.notifLink}>
              🔔
              {nbNotifs > 0 && (
                <span style={s.notifBadge}>{nbNotifs > 9 ? "9+" : nbNotifs}</span>
              )}
            </Link>

            <Link to="/profil" style={s.profilLink}>
              <div style={s.avatar}>{user.nom.charAt(0).toUpperCase()}</div>
              <span style={s.username}>{user.nom.split(" ")[0]}</span>
            </Link>
          </>
        ) : (
          <>
            <Link to="/login"    style={s.btnOutline}>Connexion</Link>
            <Link to="/register" style={s.btnPrimary}>Inscription</Link>
          </>
        )}
      </div>
    </nav>
  );
}

const s = {
  nav: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    padding: "0 32px",
    height: "54px",
    background: "linear-gradient(90deg, #0A3C6E 0%, #1260A8 100%)",
    boxShadow: "0 2px 10px rgba(0,0,0,0.22)",
    position: "sticky",
    top: 0,
    zIndex: 100,
  },

  logo: {
    color: "white",
    textDecoration: "none",
    fontSize: "17px",
    fontWeight: "800",
    letterSpacing: "0.3px",
    display: "flex",
    alignItems: "center",
    gap: "7px",
  },
  logoIcon: {
    fontSize: "20px",
    display: "inline-block",
  },

  links: { display: "flex", alignItems: "center", gap: "10px" },

  // Bouton plein blanc — navigation principale
  btnPrimary: {
    background: "white",
    color: "#0C447C",
    border: "none",
    padding: "7px 18px",
    borderRadius: "20px",
    cursor: "pointer",
    fontSize: "13px",
    fontWeight: "700",
    textDecoration: "none",
    display: "flex",
    alignItems: "center",
    transition: "opacity 0.15s",
  },
  btnPrimaryActive: {
    background: "#E6F1FB",
    color: "#0A3C6E",
  },

  // Bouton contour blanc — navigation secondaire
  btnOutline: {
    background: "transparent",
    color: "white",
    border: "1.5px solid rgba(255,255,255,0.55)",
    padding: "6px 17px",
    borderRadius: "20px",
    cursor: "pointer",
    fontSize: "13px",
    fontWeight: "600",
    textDecoration: "none",
    display: "flex",
    alignItems: "center",
    transition: "border-color 0.15s, background 0.15s",
  },
  btnOutlineActive: {
    borderColor: "white",
    background: "rgba(255,255,255,0.12)",
  },

  // Admin
  btnAdmin: {
    color: "#FFD580",
    textDecoration: "none",
    fontSize: "13px",
    fontWeight: "600",
    padding: "6px 4px",
  },

  // Notifications
  notifLink: {
    color: "white",
    textDecoration: "none",
    fontSize: "18px",
    position: "relative",
    display: "flex",
    alignItems: "center",
    padding: "0 4px",
  },
  notifBadge: {
    position: "absolute",
    top: "-5px",
    right: "-4px",
    background: "#E84848",
    color: "white",
    borderRadius: "10px",
    fontSize: "10px",
    fontWeight: "bold",
    padding: "1px 5px",
    minWidth: "16px",
    textAlign: "center",
  },

  // Profil
  profilLink: {
    color: "white",
    textDecoration: "none",
    display: "flex",
    alignItems: "center",
    gap: "8px",
    padding: "0 4px",
  },
  avatar: {
    width: "30px",
    height: "30px",
    borderRadius: "50%",
    background: "rgba(255,255,255,0.18)",
    border: "1.5px solid rgba(255,255,255,0.45)",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "13px",
    fontWeight: "bold",
  },
  username: {
    color: "rgba(255,255,255,0.9)",
    fontSize: "13px",
    fontWeight: "500",
  },
};
