import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { api } from "../services/api";

const LOCAL_IMG = "/voyagevista-grouptrip/frontend/dist/images/autre/gettyimages-1465570166-612x612.jpg";

export default function Profil() {
  const { user, setUser, logout } = useAuth();
  const navigate = useNavigate();

  const [nom,        setNom]        = useState("");
  const [email,      setEmail]      = useState("");
  const [ancienMdp,  setAncienMdp]  = useState("");
  const [nouveauMdp, setNouveauMdp] = useState("");
  const [confirmMdp, setConfirmMdp] = useState("");
  const [showMdp,    setShowMdp]    = useState(false);
  const [loading,    setLoading]    = useState(false);
  const [success,    setSuccess]    = useState("");
  const [error,      setError]      = useState("");
  const [stats,      setStats]      = useState(null);

  useEffect(() => {
    if (user) { setNom(user.nom || ""); setEmail(user.email || ""); }
    api.get("/api/groupes").then(g => setStats({ nbGroupes: g.length })).catch(() => {});
  }, [user]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(""); setSuccess("");
    if (showMdp) {
      if (!ancienMdp) { setError("Entrez votre mot de passe actuel."); return; }
      if (nouveauMdp.length < 6) { setError("6 caractères minimum."); return; }
      if (nouveauMdp !== confirmMdp) { setError("Les mots de passe ne correspondent pas."); return; }
    }
    setLoading(true);
    try {
      const payload = { nom, email };
      if (showMdp && nouveauMdp) { payload.ancien_mot_de_passe = ancienMdp; payload.nouveau_mot_de_passe = nouveauMdp; }
      const updatedUser = await api.put("/api/profil", payload);
      setUser(updatedUser);
      setSuccess("Profil mis à jour !");
      setAncienMdp(""); setNouveauMdp(""); setConfirmMdp(""); setShowMdp(false);
    } catch (err) {
      setError(err.message || "Erreur lors de la mise à jour.");
    } finally { setLoading(false); }
  };

  const initiale = (user?.nom || "?").charAt(0).toUpperCase();
  const dateInscription = user?.created_at
    ? new Date(user.created_at).toLocaleDateString("fr-FR", { month:"long", year:"numeric" })
    : null;

  return (
    <div style={s.page}>

      {/* ── Panneau gauche : identité + image ── */}
      <div style={s.panel}>
        <img src={LOCAL_IMG} alt="profil" style={s.panelImg} />
        <div style={s.panelOverlay} />
        <div style={s.panelContent}>
          <button onClick={() => navigate("/dashboard")} style={s.btnBack}>
            <span style={s.btnBackArrow}>←</span> Tableau de bord
          </button>

          <div style={s.identity}>
            <div style={s.avatar}>{initiale}</div>
            <h2 style={s.userName}>{user?.nom}</h2>
            <p style={s.userEmail}>{user?.email}</p>
            {dateInscription && <p style={s.userDate}>Membre depuis {dateInscription}</p>}
          </div>

          {stats !== null && (
            <div style={s.statsRow}>
              <div style={s.statCard}>
                <div style={s.statNum}>{stats.nbGroupes}</div>
                <div style={s.statLabel}>voyage{stats.nbGroupes > 1 ? "s" : ""}</div>
              </div>
              <div style={s.statCard}>
                <div style={s.statNum}>{user?.role === "admin" ? "👑" : "🧳"}</div>
                <div style={s.statLabel}>{user?.role}</div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* ── Panneau droit : formulaires ── */}
      <div style={s.formSide}>
        <div style={s.formWrap}>

          <h1 style={s.pageTitle}>Mon profil</h1>
          <p style={s.pageSub}>Gérez vos informations personnelles et votre mot de passe.</p>

          {success && <div style={s.alertSuccess}>✓ {success}</div>}
          {error   && <div style={s.alertError}>⚠️ {error}</div>}

          {/* Infos */}
          <div style={s.section}>
            <h3 style={s.sectionTitle}>Informations personnelles</h3>
            <form onSubmit={handleSubmit} style={s.form}>
              <div style={s.fieldGroup}>
                <label style={s.label}>Nom complet</label>
                <div style={s.inputWrap}>
                  <span style={s.inputIcon}>👤</span>
                  <input style={s.input} value={nom} onChange={e => setNom(e.target.value)} required />
                </div>
              </div>
              <div style={s.fieldGroup}>
                <label style={s.label}>Adresse e-mail</label>
                <div style={s.inputWrap}>
                  <span style={s.inputIcon}>✉️</span>
                  <input style={s.input} type="email" value={email} onChange={e => setEmail(e.target.value)} required />
                </div>
              </div>

              {/* Mot de passe */}
              <button type="button" onClick={() => { setShowMdp(!showMdp); setError(""); }} style={s.btnToggle}>
                {showMdp ? "▲ Annuler" : "🔒 Changer mon mot de passe"}
              </button>

              {showMdp && (
                <div style={s.mdpBlock}>
                  <div style={s.fieldGroup}>
                    <label style={s.label}>Mot de passe actuel</label>
                    <div style={s.inputWrap}>
                      <span style={s.inputIcon}>🔑</span>
                      <input style={s.input} type="password" value={ancienMdp} onChange={e => setAncienMdp(e.target.value)} placeholder="••••••••" />
                    </div>
                  </div>
                  <div style={s.fieldGroup}>
                    <label style={s.label}>Nouveau mot de passe</label>
                    <div style={s.inputWrap}>
                      <span style={s.inputIcon}>🔐</span>
                      <input style={s.input} type="password" value={nouveauMdp} onChange={e => setNouveauMdp(e.target.value)} placeholder="6 caractères minimum" />
                    </div>
                  </div>
                  <div style={s.fieldGroup}>
                    <label style={s.label}>Confirmer</label>
                    <div style={s.inputWrap}>
                      <span style={s.inputIcon}>🔐</span>
                      <input style={s.input} type="password" value={confirmMdp} onChange={e => setConfirmMdp(e.target.value)} placeholder="••••••••" />
                    </div>
                  </div>
                </div>
              )}

              <button type="submit" style={{ ...s.btnSave, opacity: loading ? 0.7 : 1 }} disabled={loading}>
                {loading ? "Enregistrement…" : "Enregistrer les modifications →"}
              </button>
            </form>
          </div>

          {/* Déconnexion */}
          <div style={s.section}>
            <h3 style={s.sectionTitle}>Compte</h3>
            <p style={s.logoutHint}>Connecté en tant que <strong>{user?.email}</strong></p>
            <button onClick={async () => { await logout(); navigate("/login"); }} style={s.btnLogout}>
              Se déconnecter
            </button>
          </div>

        </div>
      </div>
    </div>
  );
}

const s = {
  page:    { display:"flex", minHeight:"calc(100vh - 56px)", fontFamily:"'Inter', Arial, sans-serif" },

  /* Panneau gauche */
  panel:        { flex:"0 0 380px", position:"relative", overflow:"hidden" },
  panelImg:     { position:"absolute", inset:0, width:"100%", height:"100%", objectFit:"cover" },
  panelOverlay: { position:"absolute", inset:0, background:"linear-gradient(160deg, rgba(7,30,61,0.82) 0%, rgba(12,68,124,0.65) 100%)" },
  panelContent: { position:"relative", zIndex:1, display:"flex", flexDirection:"column", justifyContent:"space-between", padding:"32px", height:"100%" },

  btnBack:     { display:"inline-flex", alignItems:"center", gap:"6px", padding:"7px 14px 7px 10px", borderRadius:"20px", border:"1px solid rgba(255,255,255,0.25)", background:"rgba(255,255,255,0.1)", backdropFilter:"blur(6px)", color:"white", cursor:"pointer", fontSize:"12px", fontWeight:"600", width:"fit-content" },
  btnBackArrow:{ display:"inline-flex", alignItems:"center", justifyContent:"center", width:"18px", height:"18px", borderRadius:"50%", background:"rgba(255,255,255,0.2)", fontSize:"11px" },

  identity: { textAlign:"center", padding:"20px 0" },
  avatar:   { width:"80px", height:"80px", borderRadius:"50%", background:"rgba(255,255,255,0.15)", border:"3px solid rgba(255,255,255,0.35)", color:"white", display:"flex", alignItems:"center", justifyContent:"center", fontSize:"32px", fontWeight:"800", margin:"0 auto 16px", backdropFilter:"blur(6px)" },
  userName: { fontSize:"22px", fontWeight:"800", color:"white", margin:"0 0 4px" },
  userEmail:{ fontSize:"13px", color:"rgba(255,255,255,0.65)", margin:"0 0 4px" },
  userDate: { fontSize:"11px", color:"rgba(255,255,255,0.45)", margin:0 },

  statsRow: { display:"flex", gap:"12px" },
  statCard: { flex:1, background:"rgba(255,255,255,0.1)", backdropFilter:"blur(6px)", border:"1px solid rgba(255,255,255,0.15)", borderRadius:"12px", padding:"16px", textAlign:"center" },
  statNum:  { fontSize:"26px", fontWeight:"800", color:"white" },
  statLabel:{ fontSize:"11px", color:"rgba(255,255,255,0.6)", marginTop:"2px", textTransform:"uppercase", letterSpacing:"0.5px" },

  /* Formulaire */
  formSide: { flex:1, display:"flex", alignItems:"flex-start", justifyContent:"center", background:"#FAFAF8", padding:"48px 32px", overflowY:"auto" },
  formWrap: { width:"100%", maxWidth:"460px" },

  pageTitle: { fontSize:"28px", fontWeight:"800", color:"#0C447C", margin:"0 0 6px", letterSpacing:"-0.5px" },
  pageSub:   { fontSize:"14px", color:"#73726c", margin:"0 0 32px" },

  alertSuccess: { background:"#EAF3DE", color:"#3B6D11", padding:"12px 16px", borderRadius:"10px", fontSize:"13px", marginBottom:"20px" },
  alertError:   { background:"#FCEBEB", color:"#A32D2D", padding:"12px 16px", borderRadius:"10px", fontSize:"13px", marginBottom:"20px" },

  section:      { background:"white", borderRadius:"14px", padding:"24px", boxShadow:"0 2px 8px rgba(0,0,0,0.06)", marginBottom:"16px" },
  sectionTitle: { fontSize:"15px", fontWeight:"700", color:"#0C447C", margin:"0 0 20px" },

  form:       { display:"flex", flexDirection:"column", gap:"16px" },
  fieldGroup: { display:"flex", flexDirection:"column", gap:"6px" },
  label:      { fontSize:"12px", fontWeight:"600", color:"#555", textTransform:"uppercase", letterSpacing:"0.4px" },
  inputWrap:  { position:"relative", display:"flex", alignItems:"center" },
  inputIcon:  { position:"absolute", left:"12px", fontSize:"15px", pointerEvents:"none" },
  input:      { width:"100%", padding:"11px 14px 11px 40px", borderRadius:"10px", border:"1.5px solid #E0DED6", fontSize:"14px", background:"white", boxSizing:"border-box", outline:"none" },

  btnToggle: { background:"none", border:"1.5px solid #D1CFC5", color:"#185FA5", padding:"9px 16px", borderRadius:"8px", cursor:"pointer", fontSize:"13px", fontWeight:"600", width:"fit-content" },
  mdpBlock:  { background:"#F5F4F0", borderRadius:"10px", padding:"16px", display:"flex", flexDirection:"column", gap:"14px" },

  btnSave:   { padding:"13px", background:"linear-gradient(135deg, #0C447C, #185FA5)", color:"white", border:"none", borderRadius:"10px", cursor:"pointer", fontSize:"14px", fontWeight:"700", boxShadow:"0 4px 14px rgba(12,68,124,0.25)" },

  logoutHint: { fontSize:"13px", color:"#73726c", margin:"0 0 14px" },
  btnLogout:  { background:"#FCEBEB", color:"#A32D2D", border:"1px solid #F5C6C6", padding:"10px 20px", borderRadius:"8px", cursor:"pointer", fontSize:"14px", fontWeight:"600" },
};
