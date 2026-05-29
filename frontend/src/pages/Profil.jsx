import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { api } from "../services/api";

export default function Profil() {
  const { user, setUser } = useAuth();
  const navigate = useNavigate();

  const [nom, setNom] = useState("");
  const [email, setEmail] = useState("");
  const [ancienMdp, setAncienMdp] = useState("");
  const [nouveauMdp, setNouveauMdp] = useState("");
  const [confirmMdp, setConfirmMdp] = useState("");
  const [showMdp, setShowMdp] = useState(false);

  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState("");
  const [error, setError] = useState("");
  const [stats, setStats] = useState(null);

  useEffect(() => {
    if (user) {
      setNom(user.nom || "");
      setEmail(user.email || "");
    }
    // Charger stats (groupes)
    api.get("/api/groupes").then((groupes) => {
      setStats({ nbGroupes: groupes.length });
    }).catch(() => {});
  }, [user]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");

    if (showMdp) {
      if (!ancienMdp) { setError("Entrez votre mot de passe actuel."); return; }
      if (nouveauMdp.length < 6) { setError("Le nouveau mot de passe doit faire au moins 6 caractères."); return; }
      if (nouveauMdp !== confirmMdp) { setError("Les mots de passe ne correspondent pas."); return; }
    }

    setLoading(true);
    try {
      const payload = { nom, email };
      if (showMdp && nouveauMdp) {
        payload.ancien_mot_de_passe = ancienMdp;
        payload.nouveau_mot_de_passe = nouveauMdp;
      }

      const updatedUser = await api.put("/api/profil", payload);
      setUser(updatedUser);
      setSuccess("Profil mis à jour avec succès !");
      setAncienMdp("");
      setNouveauMdp("");
      setConfirmMdp("");
      setShowMdp(false);
    } catch (err) {
      setError(err.message || "Erreur lors de la mise à jour.");
    } finally {
      setLoading(false);
    }
  };

  const initiale = (user?.nom || "?").charAt(0).toUpperCase();
  const dateInscription = user?.created_at
    ? new Date(user.created_at).toLocaleDateString("fr-FR", { month: "long", year: "numeric" })
    : null;

  return (
    <div style={styles.page}>
      <div style={styles.header}>
        <button onClick={() => navigate("/dashboard")} style={styles.btnBack}>
          ← Tableau de bord
        </button>
        <h1 style={styles.title}>👤 Mon profil</h1>
      </div>

      <div style={styles.body}>
        {/* Carte identité */}
        <div style={styles.card}>
          <div style={styles.avatarWrap}>
            <div style={styles.avatar}>{initiale}</div>
            <div>
              <div style={styles.userName}>{user?.nom}</div>
              <div style={styles.userEmail}>{user?.email}</div>
              {dateInscription && (
                <div style={styles.userDate}>Membre depuis {dateInscription}</div>
              )}
            </div>
          </div>
          {stats !== null && (
            <div style={styles.statsRow}>
              <div style={styles.statBox}>
                <div style={styles.statNum}>{stats.nbGroupes}</div>
                <div style={styles.statLabel}>voyage{stats.nbGroupes > 1 ? "s" : ""}</div>
              </div>
              <div style={styles.statBox}>
                <div style={styles.statNum}>{user?.role === "admin" ? "👑" : "🧳"}</div>
                <div style={styles.statLabel}>{user?.role}</div>
              </div>
            </div>
          )}
        </div>

        {/* Formulaire */}
        <div style={styles.card}>
          <h2 style={styles.cardTitle}>Modifier mes informations</h2>

          {success && <div style={styles.alertSuccess}>{success}</div>}
          {error && <div style={styles.alertError}>{error}</div>}

          <form onSubmit={handleSubmit}>
            <div style={styles.field}>
              <label style={styles.label}>Nom complet</label>
              <input
                style={styles.input}
                value={nom}
                onChange={(e) => setNom(e.target.value)}
                required
              />
            </div>

            <div style={styles.field}>
              <label style={styles.label}>Adresse email</label>
              <input
                style={styles.input}
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>

            {/* Changer mot de passe */}
            <div style={styles.mdpToggle}>
              <button
                type="button"
                onClick={() => { setShowMdp(!showMdp); setError(""); }}
                style={styles.btnToggle}
              >
                {showMdp ? "▲ Annuler le changement de mot de passe" : "🔒 Changer mon mot de passe"}
              </button>
            </div>

            {showMdp && (
              <div style={styles.mdpBlock}>
                <div style={styles.field}>
                  <label style={styles.label}>Mot de passe actuel</label>
                  <input
                    style={styles.input}
                    type="password"
                    value={ancienMdp}
                    onChange={(e) => setAncienMdp(e.target.value)}
                    placeholder="••••••••"
                  />
                </div>
                <div style={styles.field}>
                  <label style={styles.label}>Nouveau mot de passe</label>
                  <input
                    style={styles.input}
                    type="password"
                    value={nouveauMdp}
                    onChange={(e) => setNouveauMdp(e.target.value)}
                    placeholder="6 caractères minimum"
                  />
                </div>
                <div style={styles.field}>
                  <label style={styles.label}>Confirmer le nouveau mot de passe</label>
                  <input
                    style={styles.input}
                    type="password"
                    value={confirmMdp}
                    onChange={(e) => setConfirmMdp(e.target.value)}
                    placeholder="••••••••"
                  />
                </div>
              </div>
            )}

            <button type="submit" style={styles.btnSave} disabled={loading}>
              {loading ? "Enregistrement..." : "Enregistrer les modifications"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

const styles = {
  page: { fontFamily: "Arial, sans-serif", minHeight: "100vh", background: "#F5F4F0" },
  header: { background: "#0C447C", color: "white", padding: "24px 32px" },
  title: { fontSize: "24px", fontWeight: "bold", margin: "4px 0 0" },
  btnBack: {
    background: "none", border: "none", color: "rgba(255,255,255,0.8)",
    cursor: "pointer", fontSize: "13px", padding: "0", marginBottom: "8px", display: "block",
  },
  body: { padding: "24px 32px", display: "flex", flexDirection: "column", gap: "16px", maxWidth: "560px", margin: "0 auto" },
  card: { background: "white", borderRadius: "12px", padding: "24px", boxShadow: "0 2px 6px rgba(0,0,0,0.06)" },
  cardTitle: { fontSize: "16px", fontWeight: "bold", color: "#0C447C", marginBottom: "20px" },
  avatarWrap: { display: "flex", alignItems: "center", gap: "16px", marginBottom: "20px" },
  avatar: {
    width: "64px", height: "64px", borderRadius: "50%", background: "#185FA5",
    color: "white", display: "flex", alignItems: "center", justifyContent: "center",
    fontSize: "26px", fontWeight: "bold", flexShrink: 0,
  },
  userName: { fontSize: "20px", fontWeight: "bold", color: "#0C447C" },
  userEmail: { fontSize: "14px", color: "#73726c", marginTop: "2px" },
  userDate: { fontSize: "12px", color: "#999", marginTop: "4px" },
  statsRow: { display: "flex", gap: "16px", borderTop: "1px solid #F5F4F0", paddingTop: "16px" },
  statBox: { textAlign: "center", flex: 1 },
  statNum: { fontSize: "24px", fontWeight: "bold", color: "#0C447C" },
  statLabel: { fontSize: "12px", color: "#73726c", marginTop: "2px" },
  field: { marginBottom: "16px" },
  label: { display: "block", fontSize: "13px", fontWeight: "600", color: "#2C2C2A", marginBottom: "6px" },
  input: {
    width: "100%", padding: "10px 12px", borderRadius: "8px",
    border: "1px solid #D1CFC5", fontSize: "14px", boxSizing: "border-box",
    outline: "none",
  },
  mdpToggle: { marginBottom: "16px" },
  btnToggle: {
    background: "none", border: "1px solid #D1CFC5", color: "#185FA5",
    padding: "8px 14px", borderRadius: "6px", cursor: "pointer", fontSize: "13px",
  },
  mdpBlock: {
    background: "#F5F4F0", borderRadius: "8px", padding: "16px", marginBottom: "16px",
  },
  btnSave: {
    background: "#185FA5", color: "white", border: "none",
    padding: "12px 24px", borderRadius: "8px", cursor: "pointer",
    fontSize: "15px", fontWeight: "bold", width: "100%",
  },
  alertSuccess: {
    background: "#EAF3DE", color: "#3B6D11", padding: "10px 14px",
    borderRadius: "8px", fontSize: "14px", marginBottom: "16px",
  },
  alertError: {
    background: "#FCEBEB", color: "#A32D2D", padding: "10px 14px",
    borderRadius: "8px", fontSize: "14px", marginBottom: "16px",
  },
};
