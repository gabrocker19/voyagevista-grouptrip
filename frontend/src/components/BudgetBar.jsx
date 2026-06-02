export default function BudgetBar({ budget, valide = 0, monVoteExtra = 0 }) {
  const b  = Number(budget)      || 0;
  const v  = Number(valide)      || 0;
  const mv = Number(monVoteExtra) || 0;

  if (b <= 0) return null;

  const pctValide  = Math.min(100, (v / b) * 100);
  const pctVote    = Math.min(100, ((v + mv) / b) * 100);
  const overBudget = v + mv > b;

  return (
    <div style={s.wrap}>
      <div style={s.header}>
        <span style={s.title}>💶 Budget</span>
        <div style={s.amounts}>
          {v > 0 && (
            <span style={s.chipGreen}>✓ Validé : {v.toFixed(0)}€</span>
          )}
          {mv > 0 && (
            <span style={s.chipBlue}>Mon vote : +{mv.toFixed(0)}€</span>
          )}
          <span style={{ ...s.chipBudget, color: overBudget ? "#A32D2D" : "#0C447C" }}>
            {overBudget ? "⚠️ " : ""}Budget : {b.toFixed(0)}€/pers
          </span>
        </div>
      </div>

      {/* Barre */}
      <div style={s.track}>
        {/* Portion validée (verte) */}
        <div style={{ ...s.barGreen, width: `${pctValide}%` }} />
        {/* Portion de mon vote non encore validé (bleue) */}
        {mv > 0 && (
          <div style={{ ...s.barBlue, width: `${pctVote - pctValide}%` }} />
        )}
      </div>

      <div style={s.footer}>
        <span style={{ color: overBudget ? "#A32D2D" : "#73726c" }}>
          {overBudget
            ? `⚠️ Dépassement de ${(v + mv - b).toFixed(0)}€`
            : `Restant : ${(b - v - mv).toFixed(0)}€`}
        </span>
        <span style={s.pct}>
          {Math.round(((v + mv) / b) * 100)}%
        </span>
      </div>
    </div>
  );
}

const s = {
  wrap: {
    background: "white", borderRadius: "10px",
    padding: "14px 18px", boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
  },
  header: { display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "8px", marginBottom: "10px" },
  title:  { fontWeight: "bold", fontSize: "13px", color: "#0C447C" },
  amounts:{ display: "flex", gap: "8px", flexWrap: "wrap", alignItems: "center" },
  chipGreen:  { background: "#EAF3DE", color: "#3B6D11", padding: "3px 10px", borderRadius: "20px", fontSize: "12px", fontWeight: "600" },
  chipBlue:   { background: "#E6F1FB", color: "#185FA5", padding: "3px 10px", borderRadius: "20px", fontSize: "12px", fontWeight: "600" },
  chipBudget: { padding: "3px 10px", borderRadius: "20px", fontSize: "12px", fontWeight: "600", background: "#F5F4F0" },
  track: {
    height: "12px", background: "#E0DED6", borderRadius: "8px",
    overflow: "hidden", display: "flex",
  },
  barGreen: { height: "100%", background: "#42A85A", transition: "width 0.4s ease", borderRadius: "8px 0 0 8px" },
  barBlue:  { height: "100%", background: "#185FA5", transition: "width 0.4s ease" },
  footer: { display: "flex", justifyContent: "space-between", marginTop: "6px", fontSize: "12px", color: "#73726c" },
  pct:    { fontWeight: "bold", color: "#0C447C" },
};
