import { useNavigate } from "react-router-dom";

/**
 * Header gradient réutilisable pour toutes les pages.
 *
 * Props :
 *   title      {string|JSX}   Titre principal (obligatoire)
 *   subtitle   {string}        Sous-titre optionnel
 *   backLabel  {string}        Texte du bouton retour (ex: "Mes voyages")
 *   backTo     {string}        Chemin de navigation du retour
 *   onBack     {function}      Callback retour (prioritaire sur backTo)
 *   right      {JSX}           Contenu aligné à droite (badge, bouton, stepper…)
 *   children                   Zone bas du header (toujours dans le gradient)
 */
export default function PageHeader({
  title, subtitle, backLabel, backTo, onBack, right, children,
}) {
  const navigate = useNavigate();
  const handleBack = onBack ?? (() => navigate(backTo));
  const hasBottom = !!children;

  return (
    <div style={{ ...s.header, paddingBottom: hasBottom ? 0 : "28px" }}>
      {backLabel && (
        <button onClick={handleBack} style={s.btnBack}>
          <span style={s.btnBackArrow}>←</span>
          {backLabel}
        </button>
      )}
      <div style={s.main}>
        <div style={s.left}>
          <h1 style={s.title}>{title}</h1>
          {subtitle && <p style={s.subtitle}>{subtitle}</p>}
        </div>
        {right && <div style={s.right}>{right}</div>}
      </div>
      {hasBottom && <div style={s.bottom}>{children}</div>}
    </div>
  );
}

const s = {
  header: {
    background: "linear-gradient(135deg, #0C447C 0%, #1A7FC4 100%)",
    color: "white",
    padding: "28px 32px 0",
  },
  btnBack: {
    display: "inline-flex",
    alignItems: "center",
    gap: "6px",
    marginBottom: "16px",
    padding: "6px 14px 6px 10px",
    borderRadius: "20px",
    border: "1px solid rgba(255,255,255,0.25)",
    background: "rgba(255,255,255,0.12)",
    backdropFilter: "blur(6px)",
    color: "rgba(255,255,255,0.9)",
    cursor: "pointer",
    fontSize: "12px",
    fontWeight: "600",
    letterSpacing: "0.2px",
    transition: "background 0.15s, border-color 0.15s",
  },
  btnBackArrow: {
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    width: "18px",
    height: "18px",
    borderRadius: "50%",
    background: "rgba(255,255,255,0.2)",
    fontSize: "11px",
    lineHeight: 1,
  },
  main: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "flex-start",
    gap: "16px",
    paddingBottom: "28px",
  },
  left: { flex: 1 },
  title: {
    fontSize: "28px",
    fontWeight: "800",
    margin: 0,
    letterSpacing: "-0.4px",
    lineHeight: 1.2,
  },
  subtitle: {
    opacity: 0.82,
    fontSize: "14px",
    margin: "6px 0 0",
  },
  right: { flexShrink: 0, display: "flex", alignItems: "flex-start" },
  bottom: {
    background: "rgba(0,0,0,0.16)",
    marginTop: "4px",
  },
};
