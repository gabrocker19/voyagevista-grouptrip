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
          ← {backLabel}
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
    background: "none",
    border: "none",
    color: "rgba(255,255,255,0.7)",
    cursor: "pointer",
    fontSize: "13px",
    padding: "0",
    marginBottom: "14px",
    display: "block",
    letterSpacing: "0.2px",
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
