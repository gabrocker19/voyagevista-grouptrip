import { Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const LOCAL_IMG  = "/voyagevista-grouptrip/frontend/dist/images/autre/gettyimages-1465570166-612x612.jpg";
const HERO_IMG   = "/voyagevista-grouptrip/frontend/dist/images/destinations/3.jpg";

const STEPS = [
  { num: "01", icon: "👥", titre: "Créez votre groupe", texte: "Invitez vos amis, fixez un budget et lancez l'aventure." },
  { num: "02", icon: "🗳️", titre: "Votez ensemble", texte: "Destination, dates, hébergement — chaque décision est collective." },
  { num: "03", icon: "✈️", titre: "Partez l'esprit libre", texte: "Itinéraire validé, dépenses partagées, il ne reste qu'à profiter." },
];

const FEATURES = [
  { icon: "🗺️", titre: "Catalogue complet", texte: "Des centaines de destinations, hébergements et activités." },
  { icon: "💬", titre: "Votes transparents", texte: "Chaque membre donne son avis, le groupe décide ensemble." },
  { icon: "💰", titre: "Budget maîtrisé", texte: "Suivez les dépenses et partagez les frais équitablement." },
  { icon: "📋", titre: "Itinéraire auto", texte: "Votre programme se construit au fur et à mesure des votes." },
];

export default function Home() {
  const { user } = useAuth();

  return (
    <div style={s.page}>

      {/* ── HERO ── */}
      <section style={s.hero}>
        <img src={HERO_IMG} alt="" style={s.heroBg} />
        <div style={s.heroOverlay} />
        <div style={s.heroContent}>
          <div style={s.heroBadge}>🌍 Voyagez. Ensemble.</div>
          <h1 style={s.heroTitle}>Planifiez vos voyages<br />en groupe, sans prise de tête.</h1>
          <p style={s.heroSub}>
            VoyageVista réunit votre groupe, organise les votes, gère le budget et génère l'itinéraire parfait.
          </p>
          <div style={s.heroCtas}>
            {user ? (
              <Link to="/dashboard" style={s.btnPrimary}>Mon espace →</Link>
            ) : (
              <>
                <Link to="/register" style={s.btnPrimary}>Commencer gratuitement</Link>
                <Link to="/login" style={s.btnGhost}>Se connecter</Link>
              </>
            )}
          </div>
          <div style={s.heroTrust}>
            <span style={s.trustBadge}>✓ Gratuit</span>
            <span style={s.trustBadge}>✓ Sans engagement</span>
            <span style={s.trustBadge}>✓ Prêt en 2 minutes</span>
          </div>
        </div>
      </section>

      {/* ── ÉTAPES ── */}
      <section style={s.stepsSection}>
        <div style={s.sectionHead}>
          <span style={s.sectionPill}>Comment ça marche</span>
          <h2 style={s.sectionTitle}>De l'idée au départ en 3 étapes</h2>
        </div>
        <div style={s.stepsRow}>
          {STEPS.map((step, i) => (
            <div key={i} style={s.stepCard}>
              <div style={s.stepNum}>{step.num}</div>
              <div style={s.stepIcon}>{step.icon}</div>
              <h3 style={s.stepTitle}>{step.titre}</h3>
              <p style={s.stepText}>{step.texte}</p>
              {i < STEPS.length - 1 && <div style={s.stepArrow}>→</div>}
            </div>
          ))}
        </div>
      </section>

      {/* ── FEATURES ── */}
      <section style={s.featSection}>
        <div style={s.sectionHead}>
          <span style={{ ...s.sectionPill, background:"rgba(255,255,255,0.15)", color:"white" }}>Fonctionnalités</span>
          <h2 style={{ ...s.sectionTitle, color:"white" }}>Tout ce qu'il vous faut</h2>
        </div>
        <div style={s.featGrid}>
          {FEATURES.map((f, i) => (
            <div key={i} style={s.featCard}>
              <div style={s.featIcon}>{f.icon}</div>
              <h3 style={s.featTitle}>{f.titre}</h3>
              <p style={s.featText}>{f.texte}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ── CTA FINAL avec image locale ── */}
      <section style={s.ctaSection}>
        <img src={LOCAL_IMG} alt="voyage en groupe" style={s.ctaImg} />
        <div style={s.ctaOverlay} />
        <div style={s.ctaContent}>
          <h2 style={s.ctaTitle}>Votre prochain voyage commence ici.</h2>
          <p style={s.ctaSub}>Rejoignez des groupes qui planifient déjà leurs aventures sur VoyageVista.</p>
          <div style={s.heroCtas}>
            {user ? (
              <Link to="/dashboard" style={s.btnPrimary}>Accéder à mon espace →</Link>
            ) : (
              <>
                <Link to="/register" style={s.btnPrimary}>Créer mon compte</Link>
                <Link to="/login" style={s.btnGhost}>J'ai déjà un compte</Link>
              </>
            )}
          </div>
        </div>
      </section>

    </div>
  );
}

const s = {
  page: { fontFamily:"'Inter', Arial, sans-serif", background:"#F5F4F0", overflowX:"hidden" },

  /* Hero */
  hero:        { position:"relative", minHeight:"88vh", display:"flex", alignItems:"center", justifyContent:"center", padding:"80px 48px", overflow:"hidden" },
  heroBg:      { position:"absolute", inset:0, width:"100%", height:"100%", objectFit:"cover", objectPosition:"center", zIndex:0 },
  heroOverlay: { position:"absolute", inset:0, background:"linear-gradient(135deg, rgba(7,30,61,0.82) 0%, rgba(12,68,124,0.60) 60%, rgba(7,30,61,0.5) 100%)", zIndex:1 },
  heroContent: { position:"relative", zIndex:2, maxWidth:"640px", textAlign:"center" },
  heroBadge:   { display:"inline-block", background:"rgba(255,255,255,0.12)", border:"1px solid rgba(255,255,255,0.2)", color:"rgba(255,255,255,0.9)", padding:"6px 18px", borderRadius:"20px", fontSize:"13px", fontWeight:"600", marginBottom:"24px", backdropFilter:"blur(6px)" },
  heroTitle:   { fontSize:"50px", fontWeight:"900", color:"white", margin:"0 0 20px", lineHeight:1.1, letterSpacing:"-1px" },
  heroSub:     { fontSize:"17px", color:"rgba(255,255,255,0.75)", lineHeight:1.7, margin:"0 0 36px", maxWidth:"500px", marginLeft:"auto", marginRight:"auto" },
  heroCtas:    { display:"flex", gap:"14px", flexWrap:"wrap", justifyContent:"center" },
  heroTrust:   { display:"flex", gap:"16px", marginTop:"28px", flexWrap:"wrap", justifyContent:"center" },
  trustBadge:  { fontSize:"12px", color:"rgba(255,255,255,0.55)", fontWeight:"500" },

  btnPrimary: { display:"inline-block", background:"white", color:"#0C447C", padding:"13px 28px", borderRadius:"10px", textDecoration:"none", fontWeight:"800", fontSize:"15px", boxShadow:"0 4px 20px rgba(0,0,0,0.2)", whiteSpace:"nowrap" },
  btnGhost:   { display:"inline-block", background:"rgba(255,255,255,0.1)", border:"1px solid rgba(255,255,255,0.3)", backdropFilter:"blur(6px)", color:"white", padding:"13px 28px", borderRadius:"10px", textDecoration:"none", fontWeight:"600", fontSize:"15px", whiteSpace:"nowrap" },

  sectionHead:  { textAlign:"center", marginBottom:"48px" },
  sectionPill:  { display:"inline-block", background:"#E6F1FB", color:"#185FA5", padding:"5px 16px", borderRadius:"20px", fontSize:"11px", fontWeight:"700", textTransform:"uppercase", letterSpacing:"1px", marginBottom:"14px" },
  sectionTitle: { fontSize:"34px", fontWeight:"800", color:"#0C447C", margin:"0 0 12px", letterSpacing:"-0.5px" },

  /* Steps */
  stepsSection: { padding:"88px 48px", background:"white" },
  stepsRow:     { display:"flex", gap:"0", justifyContent:"center", maxWidth:"900px", margin:"0 auto", position:"relative" },
  stepCard:     { flex:1, maxWidth:"280px", textAlign:"center", padding:"32px 20px", position:"relative" },
  stepNum:      { fontSize:"11px", fontWeight:"900", color:"#185FA5", letterSpacing:"2px", marginBottom:"10px", opacity:0.45 },
  stepIcon:     { fontSize:"38px", marginBottom:"14px" },
  stepTitle:    { fontSize:"17px", fontWeight:"700", color:"#0C447C", marginBottom:"8px" },
  stepText:     { fontSize:"13px", color:"#73726c", lineHeight:"1.65" },
  stepArrow:    { position:"absolute", top:"44%", right:"-18px", fontSize:"22px", color:"#D1CFC5" },

  /* Features */
  featSection: { padding:"88px 48px", background:"linear-gradient(135deg, #071E3D 0%, #0C447C 100%)" },
  featGrid:    { display:"grid", gridTemplateColumns:"repeat(auto-fill, minmax(200px, 1fr))", gap:"16px", maxWidth:"900px", margin:"0 auto" },
  featCard:    { background:"rgba(255,255,255,0.07)", border:"1px solid rgba(255,255,255,0.1)", borderRadius:"14px", padding:"24px 20px", backdropFilter:"blur(6px)" },
  featIcon:    { fontSize:"32px", marginBottom:"14px" },
  featTitle:   { fontSize:"15px", fontWeight:"700", color:"white", marginBottom:"6px" },
  featText:    { fontSize:"13px", color:"rgba(255,255,255,0.6)", lineHeight:"1.6" },

  /* CTA */
  ctaSection:  { position:"relative", padding:"120px 48px", textAlign:"center", overflow:"hidden" },
  ctaImg:      { position:"absolute", inset:0, width:"100%", height:"100%", objectFit:"cover", zIndex:0 },
  ctaOverlay:  { position:"absolute", inset:0, background:"rgba(7,30,61,0.78)", zIndex:1 },
  ctaContent:  { position:"relative", zIndex:2, maxWidth:"600px", margin:"0 auto" },
  ctaTitle:    { fontSize:"40px", fontWeight:"900", color:"white", margin:"0 0 16px", letterSpacing:"-0.5px" },
  ctaSub:      { fontSize:"16px", color:"rgba(255,255,255,0.7)", margin:"0 0 40px", lineHeight:1.7 },
};
