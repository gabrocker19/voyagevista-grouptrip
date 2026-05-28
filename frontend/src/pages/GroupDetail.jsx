import { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { groupService } from "../services/group.service";
import { useAuth } from "../context/AuthContext";

export default function GroupDetail() {
  const { id } = useParams();
  const { user } = useAuth();
  const [groupe, setGroupe] = useState(null);
  const [loading, setLoading] = useState(true);
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    groupService
      .getOne(id)
      .then(setGroupe)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [id]);

  const handleInvite = async (e) => {
    e.preventDefault();
    setMessage("");
    setError("");
    try {
      const res = await groupService.inviter(id, {
        email,
        groupe_nom: groupe.nom,
      });
      setMessage(res.message);
      setEmail("");
      // Recharger le groupe
      groupService.getOne(id).then(setGroupe);
    } catch (err) {
      setError(err.message);
    }
  };

  if (loading) return <div style={styles.loading}>Chargement...</div>;
  if (!groupe) return <div style={styles.loading}>Groupe introuvable.</div>;

  const isOrganisateur = groupe.organisateur_id === user?.id;

  const statutColors = {
    en_formation: { bg: "#FAEEDA", color: "#854F0B" },
    vote_en_cours: { bg: "#E6F1FB", color: "#185FA5" },
    plan_valide: { bg: "#EAF3DE", color: "#3B6D11" },
    reservation_confirmee: { bg: "#EAF3DE", color: "#3B6D11" },
  };
  const sc = statutColors[groupe.statut] || statutColors.en_formation;

  return (
    <div style={styles.page}>
      {/* Header */}
      <div style={styles.header}>
        <div>
          <h1 style={styles.title}>{groupe.nom}</h1>
          <p style={styles.sub}>Organisé par {groupe.organisateur_nom}</p>
        </div>
        <span style={{ ...styles.statut, background: sc.bg, color: sc.color }}>
          {groupe.statut.replace(/_/g, " ")}
        </span>
      </div>

      <div style={styles.body}>
        {/* Infos */}
        <div style={styles.infoGrid}>
          <div style={styles.infoCard}>
            <div style={styles.infoIcon}>👥</div>
            <div style={styles.infoVal}>{groupe.membres?.length || 0}</div>
            <div style={styles.infoLabel}>Membres</div>
          </div>
          <div style={styles.infoCard}>
            <div style={styles.infoIcon}>💶</div>
            <div style={styles.infoVal}>
              {groupe.budget_max ? `${groupe.budget_max}€` : "Non défini"}
            </div>
            <div style={styles.infoLabel}>Budget max / pers.</div>
          </div>
          <div style={styles.infoCard}>
            <div style={styles.infoIcon}>📅</div>
            <div style={styles.infoVal}>
              {groupe.date_depart || "À définir"}
            </div>
            <div style={styles.infoLabel}>Date de départ</div>
          </div>
          <div style={styles.infoCard}>
            <div style={styles.infoIcon}>🌍</div>
            <div style={styles.infoVal}>
              {groupe.destination_id || "À voter"}
            </div>
            <div style={styles.infoLabel}>Destination</div>
          </div>
        </div>

        {/* Membres */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>👥 Membres du groupe</h2>
          <div style={styles.memberList}>
            {groupe.membres?.map((m) => (
              <div key={m.id} style={styles.memberRow}>
                <div style={styles.avatar}>{m.nom.charAt(0).toUpperCase()}</div>
                <div style={styles.memberInfo}>
                  <div style={styles.memberName}>{m.nom}</div>
                  <div style={styles.memberEmail}>{m.email}</div>
                </div>
                <span
                  style={{
                    ...styles.memberBadge,
                    background:
                      m.role === "organisateur" ? "#E6F1FB" : "#F5F4F0",
                    color: m.role === "organisateur" ? "#0C447C" : "#73726c",
                  }}
                >
                  {m.role}
                </span>
                <span
                  style={{
                    ...styles.memberBadge,
                    background:
                      m.statut === "accepte"
                        ? "#EAF3DE"
                        : m.statut === "en_attente"
                          ? "#FAEEDA"
                          : "#FCEBEB",
                    color:
                      m.statut === "accepte"
                        ? "#3B6D11"
                        : m.statut === "en_attente"
                          ? "#854F0B"
                          : "#A32D2D",
                  }}
                >
                  {m.statut}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Inviter — organisateur seulement */}
        {isOrganisateur && (
          <div style={styles.section}>
            <h2 style={styles.sectionTitle}>✉️ Inviter un membre</h2>
            {message && <div style={styles.success}>{message}</div>}
            {error && <div style={styles.error}>{error}</div>}
            <form onSubmit={handleInvite} style={styles.inviteForm}>
              <input
                style={styles.input}
                type="email"
                placeholder="Email de l'ami à inviter"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <button type="submit" style={styles.btnInvite}>
                Inviter
              </button>
            </form>
            <p style={styles.hint}>
              Comptes de test : aurelien@test.fr · brice@test.fr · isiah@test.fr
            </p>
          </div>
        )}

        {/* Prochaines étapes */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>🗺️ Prochaines étapes</h2>
          <div style={styles.stepList}>
            {[
              { label: "Former le groupe", done: true },
              { label: "Voter pour la destination", done: false },
              { label: "Choisir les dates", done: false },
              { label: "Sélectionner un hébergement", done: false },
              { label: "Choisir les activités", done: false },
              { label: "Valider et payer", done: false },
            ].map((s, i) => (
              <div key={i} style={styles.stepRow}>
                <span
                  style={{
                    ...styles.stepDot,
                    background: s.done ? "#3B6D11" : "#D1CFC5",
                  }}
                >
                  {s.done ? "✓" : i + 1}
                </span>
                <span
                  style={{
                    ...styles.stepLabel,
                    color: s.done ? "#3B6D11" : "#444",
                  }}
                >
                  {s.label}
                </span>
              </div>
            ))}
          </div>
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
  loading: { textAlign: "center", padding: "60px", color: "#73726c" },
  header: {
    background: "#0C447C",
    color: "white",
    padding: "32px",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "flex-start",
  },
  title: { fontSize: "26px", fontWeight: "bold", marginBottom: "6px" },
  sub: { opacity: 0.8, fontSize: "14px" },
  statut: {
    padding: "6px 14px",
    borderRadius: "20px",
    fontSize: "12px",
    fontWeight: "600",
    whiteSpace: "nowrap",
  },
  body: {
    padding: "24px 32px",
    display: "flex",
    flexDirection: "column",
    gap: "20px",
  },
  infoGrid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(140px, 1fr))",
    gap: "12px",
  },
  infoCard: {
    background: "white",
    borderRadius: "10px",
    padding: "16px",
    textAlign: "center",
    boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
  },
  infoIcon: { fontSize: "24px", marginBottom: "6px" },
  infoVal: {
    fontSize: "18px",
    fontWeight: "bold",
    color: "#0C447C",
    marginBottom: "4px",
  },
  infoLabel: { fontSize: "11px", color: "#73726c" },
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
  memberList: { display: "flex", flexDirection: "column", gap: "10px" },
  memberRow: {
    display: "flex",
    alignItems: "center",
    gap: "12px",
    padding: "8px 0",
    borderBottom: "1px solid #F5F4F0",
  },
  avatar: {
    width: "36px",
    height: "36px",
    borderRadius: "50%",
    background: "#185FA5",
    color: "white",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontWeight: "bold",
    fontSize: "14px",
    flexShrink: 0,
  },
  memberInfo: { flex: 1 },
  memberName: { fontSize: "14px", fontWeight: "500", color: "#2C2C2A" },
  memberEmail: { fontSize: "12px", color: "#73726c" },
  memberBadge: {
    fontSize: "11px",
    padding: "3px 8px",
    borderRadius: "12px",
    fontWeight: "500",
  },
  inviteForm: { display: "flex", gap: "10px" },
  input: {
    flex: 1,
    padding: "10px 12px",
    borderRadius: "6px",
    border: "1px solid #D1CFC5",
    fontSize: "14px",
  },
  btnInvite: {
    background: "#185FA5",
    color: "white",
    border: "none",
    padding: "10px 20px",
    borderRadius: "6px",
    cursor: "pointer",
    fontSize: "14px",
    fontWeight: "500",
    whiteSpace: "nowrap",
  },
  hint: { fontSize: "12px", color: "#999", marginTop: "8px" },
  success: {
    background: "#EAF3DE",
    color: "#3B6D11",
    padding: "10px 14px",
    borderRadius: "6px",
    marginBottom: "12px",
    fontSize: "14px",
  },
  error: {
    background: "#FCEBEB",
    color: "#A32D2D",
    padding: "10px 14px",
    borderRadius: "6px",
    marginBottom: "12px",
    fontSize: "14px",
  },
  stepList: { display: "flex", flexDirection: "column", gap: "10px" },
  stepRow: { display: "flex", alignItems: "center", gap: "12px" },
  stepDot: {
    width: "24px",
    height: "24px",
    borderRadius: "50%",
    color: "white",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "11px",
    fontWeight: "bold",
    flexShrink: 0,
  },
  stepLabel: { fontSize: "14px" },
};
