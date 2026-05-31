import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const BG_IMAGE = "/voyagevista-grouptrip/frontend/dist/images/autre/gettyimages-1465570166-612x612.jpg";

const QUOTES = [
  { text: "Le voyage est la seule chose qu'on achète qui nous rend plus riche.", author: "Anonyme" },
  { text: "On ne voyage pas pour fuir la vie, mais pour que la vie ne nous échappe pas.", author: "Virginia Woolf" },
  { text: "Les voyages forment la jeunesse.", author: "Michel de Montaigne" },
];

export default function Login() {
  const [form, setForm]       = useState({ email: "", password: "" });
  const [error, setError]     = useState("");
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();
  const quote = QUOTES[Math.floor(Math.random() * QUOTES.length)];

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      await login({ email: form.email, password: form.password });
      navigate("/dashboard");
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={s.page}>

      {/* ── Panneau gauche : image + citation ── */}
      <div style={s.panel}>
        <img src={BG_IMAGE} alt="voyage" style={s.panelImg} />
        <div style={s.panelOverlay} />
        <div style={s.panelContent}>
          <div style={s.panelLogo}>🌍 VoyageVista</div>
          <div style={s.panelQuote}>
            <p style={s.quoteText}>« {quote.text} »</p>
            <p style={s.quoteAuthor}>— {quote.author}</p>
          </div>
          <div style={s.panelDots}>
            <div style={s.dot} /><div style={s.dot} /><div style={s.dot} />
          </div>
        </div>
      </div>

      {/* ── Panneau droit : formulaire ── */}
      <div style={s.formSide}>
        <div style={s.formWrap}>

          <div style={s.formHeader}>
            <h2 style={s.formTitle}>Bon retour 👋</h2>
            <p style={s.formSub}>Connectez-vous pour accéder à vos voyages en groupe.</p>
          </div>

          {error && (
            <div style={s.errorBox}>
              <span style={s.errorIcon}>⚠️</span> {error}
            </div>
          )}

          <form onSubmit={handleSubmit} style={s.form}>
            <div style={s.fieldGroup}>
              <label style={s.label}>Adresse e-mail</label>
              <div style={s.inputWrap}>
                <span style={s.inputIcon}>✉️</span>
                <input
                  style={s.input}
                  type="email"
                  placeholder="votre@email.fr"
                  value={form.email}
                  onChange={e => setForm({ ...form, email: e.target.value })}
                  required
                />
              </div>
            </div>

            <div style={s.fieldGroup}>
              <label style={s.label}>Mot de passe</label>
              <div style={s.inputWrap}>
                <span style={s.inputIcon}>🔑</span>
                <input
                  style={s.input}
                  type="password"
                  placeholder="••••••••"
                  value={form.password}
                  onChange={e => setForm({ ...form, password: e.target.value })}
                  required
                />
              </div>
            </div>

            <button type="submit" style={{ ...s.btn, opacity: loading ? 0.7 : 1 }} disabled={loading}>
              {loading ? "Connexion…" : "Se connecter →"}
            </button>
          </form>

          <div style={s.divider}><span style={s.dividerText}>ou</span></div>

          <div style={s.hint}>
            <span style={s.hintIcon}>💡</span>
            <span>Compte test : <strong>gabin@test.fr</strong> / <strong>password</strong></span>
          </div>

          <p style={s.footer}>
            Pas encore de compte ?{" "}
            <Link to="/register" style={s.link}>Créer un compte gratuitement</Link>
          </p>

        </div>
      </div>
    </div>
  );
}

const s = {
  page:    { display:"flex", minHeight:"calc(100vh - 56px)", fontFamily:"'Inter', Arial, sans-serif" },

  /* Panneau image */
  panel:        { flex:"1 1 50%", position:"relative", overflow:"hidden", display:"flex" },
  panelImg:     { position:"absolute", inset:0, width:"100%", height:"100%", objectFit:"cover" },
  panelOverlay: { position:"absolute", inset:0, background:"linear-gradient(135deg, rgba(7,30,61,0.85) 0%, rgba(12,68,124,0.65) 100%)" },
  panelContent: { position:"relative", zIndex:1, display:"flex", flexDirection:"column", justifyContent:"space-between", padding:"48px", width:"100%" },
  panelLogo:    { fontSize:"22px", fontWeight:"800", color:"white", letterSpacing:"-0.3px" },
  panelQuote:   { maxWidth:"380px" },
  quoteText:    { fontSize:"20px", fontStyle:"italic", color:"rgba(255,255,255,0.92)", lineHeight:1.6, margin:"0 0 12px", fontWeight:"300" },
  quoteAuthor:  { fontSize:"13px", color:"rgba(255,255,255,0.55)", fontWeight:"600", margin:0 },
  panelDots:    { display:"flex", gap:"6px" },
  dot:          { width:"6px", height:"6px", borderRadius:"50%", background:"rgba(255,255,255,0.4)" },

  /* Formulaire */
  formSide: { flex:"1 1 50%", display:"flex", alignItems:"center", justifyContent:"center", background:"#FAFAF8", padding:"48px 32px" },
  formWrap: { width:"100%", maxWidth:"400px" },
  formHeader: { marginBottom:"32px" },
  formTitle:  { fontSize:"30px", fontWeight:"800", color:"#0C447C", margin:"0 0 8px", letterSpacing:"-0.5px" },
  formSub:    { fontSize:"14px", color:"#73726c", margin:0, lineHeight:1.5 },

  errorBox:  { display:"flex", alignItems:"center", gap:"8px", background:"#FCEBEB", color:"#A32D2D", padding:"12px 16px", borderRadius:"10px", marginBottom:"20px", fontSize:"13px" },
  errorIcon: { fontSize:"16px" },

  form:       { display:"flex", flexDirection:"column", gap:"20px" },
  fieldGroup: { display:"flex", flexDirection:"column", gap:"6px" },
  label:      { fontSize:"13px", fontWeight:"600", color:"#444" },
  inputWrap:  { position:"relative", display:"flex", alignItems:"center" },
  inputIcon:  { position:"absolute", left:"12px", fontSize:"16px", pointerEvents:"none" },
  input:      { width:"100%", padding:"12px 14px 12px 40px", borderRadius:"10px", border:"1.5px solid #E0DED6", fontSize:"14px", background:"white", boxSizing:"border-box", outline:"none", transition:"border-color 0.15s" },

  btn: { width:"100%", padding:"14px", background:"linear-gradient(135deg, #0C447C, #185FA5)", color:"white", border:"none", borderRadius:"10px", fontSize:"15px", fontWeight:"700", cursor:"pointer", boxShadow:"0 4px 16px rgba(12,68,124,0.3)", letterSpacing:"0.2px" },

  divider:     { display:"flex", alignItems:"center", gap:"12px", margin:"24px 0" },
  dividerText: { fontSize:"12px", color:"#B0AEA6", background:"#FAFAF8", padding:"0 8px" },

  hint:     { display:"flex", alignItems:"center", gap:"8px", background:"#EAF3DE", color:"#3B6D11", padding:"11px 14px", borderRadius:"10px", fontSize:"12px", marginBottom:"20px" },
  hintIcon: { fontSize:"14px" },

  footer: { textAlign:"center", fontSize:"13px", color:"#73726c" },
  link:   { color:"#185FA5", fontWeight:"700", textDecoration:"none" },
};
