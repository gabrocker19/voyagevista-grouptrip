import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { authService } from "../services/auth.service";

export default function Register() {
  const [form, setForm] = useState({ nom: "", email: "", password: "" });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      await authService.register({ nom: form.nom, email: form.email, password: form.password });
      navigate("/login");
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const features = [
    { icon: "✈️", label: "Planifiez ensemble", desc: "Transport, hébergement, activités — tout en un." },
    { icon: "🗳️", label: "Votez en groupe", desc: "Chaque membre vote, l'organisateur valide." },
    { icon: "💳", label: "Paiement simplifié", desc: "Un itinéraire commun, un paiement groupé." },
  ];

  return (
    <div style={s.page}>
      {/* Panneau gauche — branding */}
      <div style={s.brand}>
        <div style={s.brandInner}>
          <div style={s.logo}>
            <span style={s.logoIcon}>✈</span>
            <span style={s.logoText}>VoyageVista</span>
          </div>
          <h1 style={s.brandTitle}>Voyagez en groupe,<br />sans la prise de tête.</h1>
          <p style={s.brandSub}>Organisez, votez, réservez — avec tous vos amis sur la même page.</p>
          <div style={s.features}>
            {features.map((f, i) => (
              <div key={i} style={s.featureItem}>
                <span style={s.featureIcon}>{f.icon}</span>
                <div>
                  <div style={s.featureLabel}>{f.label}</div>
                  <div style={s.featureDesc}>{f.desc}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
        <div style={s.brandWave} />
      </div>

      {/* Panneau droit — formulaire */}
      <div style={s.formPanel}>
        <div style={s.formCard}>
          <h2 style={s.title}>Créer un compte</h2>
          <p style={s.sub}>C'est gratuit et rapide 🎒</p>

          {error && (
            <div style={s.errorBox}>
              <span>⚠️</span> {error}
            </div>
          )}

          <form onSubmit={handleSubmit}>
            <div style={s.field}>
              <label style={s.label}>Nom complet</label>
              <div style={s.inputWrap}>
                <span style={s.inputIcon}>👤</span>
                <input
                  style={s.input}
                  type="text"
                  placeholder="Prénom Nom"
                  value={form.nom}
                  onChange={(e) => setForm({ ...form, nom: e.target.value })}
                  required
                  autoFocus
                />
              </div>
            </div>

            <div style={s.field}>
              <label style={s.label}>Adresse e-mail</label>
              <div style={s.inputWrap}>
                <span style={s.inputIcon}>✉️</span>
                <input
                  style={s.input}
                  type="email"
                  placeholder="votre@email.fr"
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                  required
                />
              </div>
            </div>

            <div style={s.field}>
              <label style={s.label}>Mot de passe</label>
              <div style={s.inputWrap}>
                <span style={s.inputIcon}>🔒</span>
                <input
                  style={s.input}
                  type="password"
                  placeholder="6 caractères minimum"
                  value={form.password}
                  onChange={(e) => setForm({ ...form, password: e.target.value })}
                  required
                  minLength={6}
                />
              </div>
              {form.password.length > 0 && (
                <div style={s.pwStrength}>
                  <div style={{ ...s.pwBar, width: form.password.length >= 10 ? "100%" : form.password.length >= 6 ? "60%" : "30%", background: form.password.length >= 10 ? "#42A85A" : form.password.length >= 6 ? "#F0A500" : "#E84848" }} />
                </div>
              )}
            </div>

            <button
              type="submit"
              style={{ ...s.btn, opacity: loading ? 0.7 : 1 }}
              disabled={loading}
            >
              {loading ? "Création en cours..." : "Créer mon compte →"}
            </button>
          </form>

          <div style={s.divider}><span style={s.dividerText}>ou</span></div>

          <p style={s.footer}>
            Déjà un compte ?{" "}
            <Link to="/login" style={s.link}>Se connecter</Link>
          </p>
        </div>
      </div>
    </div>
  );
}

const s = {
  page: { display: "flex", minHeight: "100vh", fontFamily: "Arial, sans-serif" },

  // Panneau gauche
  brand: {
    flex: "0 0 42%",
    background: "linear-gradient(150deg, #0C447C 0%, #1A7FC4 60%, #2196D3 100%)",
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    position: "relative",
    overflow: "hidden",
    padding: "48px",
  },
  brandInner: { position: "relative", zIndex: 1 },
  brandWave: {
    position: "absolute", bottom: -80, right: -80,
    width: 280, height: 280, borderRadius: "50%",
    background: "rgba(255,255,255,0.07)",
  },
  logo: { display: "flex", alignItems: "center", gap: "10px", marginBottom: "40px" },
  logoIcon: { fontSize: "28px", background: "rgba(255,255,255,0.15)", width: 44, height: 44, borderRadius: "12px", display: "flex", alignItems: "center", justifyContent: "center" },
  logoText: { fontSize: "18px", fontWeight: "800", color: "white", letterSpacing: "-0.3px" },
  brandTitle: { fontSize: "30px", fontWeight: "800", color: "white", lineHeight: 1.25, margin: "0 0 14px", letterSpacing: "-0.5px" },
  brandSub: { fontSize: "15px", color: "rgba(255,255,255,0.75)", lineHeight: 1.6, marginBottom: "36px" },
  features: { display: "flex", flexDirection: "column", gap: "18px" },
  featureItem: { display: "flex", alignItems: "flex-start", gap: "14px" },
  featureIcon: { fontSize: "22px", background: "rgba(255,255,255,0.12)", width: 40, height: 40, borderRadius: "10px", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 },
  featureLabel: { fontSize: "14px", fontWeight: "700", color: "white", marginBottom: "2px" },
  featureDesc: { fontSize: "12px", color: "rgba(255,255,255,0.65)", lineHeight: 1.5 },

  // Panneau droit
  formPanel: {
    flex: 1,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    backgroundImage: "linear-gradient(rgba(245,244,240,0.48), rgba(245,244,240,0.54)), url('/voyagevista-grouptrip/frontend/dist/images/destinations/9.jpg')",
    backgroundSize: "cover",
    backgroundPosition: "center",
    padding: "32px 24px",
  },
  formCard: {
    background: "white",
    borderRadius: "20px",
    padding: "40px 36px",
    width: "100%",
    maxWidth: "420px",
    boxShadow: "0 8px 32px rgba(0,0,0,0.1)",
  },
  title: { fontSize: "24px", fontWeight: "800", color: "#0C447C", margin: "0 0 4px", letterSpacing: "-0.3px" },
  sub: { fontSize: "14px", color: "#73726c", marginBottom: "28px" },

  errorBox: {
    display: "flex", alignItems: "center", gap: "8px",
    background: "#FCEBEB", color: "#A32D2D",
    padding: "10px 14px", borderRadius: "8px",
    marginBottom: "20px", fontSize: "13px",
  },

  field: { marginBottom: "18px" },
  label: { display: "block", fontSize: "12px", fontWeight: "700", color: "#444", marginBottom: "7px", textTransform: "uppercase", letterSpacing: "0.4px" },
  inputWrap: { position: "relative", display: "flex", alignItems: "center" },
  inputIcon: { position: "absolute", left: "12px", fontSize: "15px", pointerEvents: "none" },
  input: {
    width: "100%", padding: "12px 14px 12px 40px",
    borderRadius: "10px", fontSize: "14px",
    border: "1.5px solid #E0DED6", boxSizing: "border-box",
    outline: "none", background: "#FAFAFA",
    transition: "border-color 0.2s",
  },

  pwStrength: { height: 3, background: "#E0DED6", borderRadius: "3px", marginTop: "6px", overflow: "hidden" },
  pwBar: { height: "100%", borderRadius: "3px", transition: "width 0.3s, background 0.3s" },

  btn: {
    width: "100%", padding: "13px",
    background: "linear-gradient(135deg, #0C447C, #185FA5)",
    color: "white", border: "none",
    borderRadius: "10px", fontSize: "15px",
    fontWeight: "700", cursor: "pointer",
    boxShadow: "0 4px 14px rgba(12,68,124,0.25)",
    marginTop: "8px",
  },

  divider: { textAlign: "center", margin: "20px 0", position: "relative" },
  dividerText: { background: "white", padding: "0 12px", fontSize: "12px", color: "#B0AFA8", position: "relative", zIndex: 1 },

  footer: { textAlign: "center", fontSize: "14px", color: "#73726c" },
  link: { color: "#185FA5", fontWeight: "700", textDecoration: "none" },
};
