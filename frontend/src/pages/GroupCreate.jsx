import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { groupService } from "../services/group.service";
import PageHeader from "../components/PageHeader";

const today = new Date().toISOString().split("T")[0];

const TIPS = [
  { icon: "🗳️", text: "Chaque membre peut voter pour ses préférences" },
  { icon: "👑", text: "L'organisateur valide les choix finaux" },
  { icon: "💳", text: "Un seul paiement groupé à la fin" },
];

export default function GroupCreate() {
  const [form, setForm] = useState({ nom: "", budget_max: "", date_depart: "", date_retour: "" });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const nbNuits = form.date_depart && form.date_retour
    ? Math.round((new Date(form.date_retour) - new Date(form.date_depart)) / 86400000)
    : null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    if (form.date_depart && form.date_retour && form.date_retour <= form.date_depart) {
      setError("La date de retour doit être après la date de départ.");
      return;
    }
    setLoading(true);
    try {
      const res = await groupService.create(form);
      navigate(`/groupes/${res.groupe_id}`);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const progress = [
    { done: form.nom.trim().length > 0, label: "Nom" },
    { done: !!form.budget_max, label: "Budget" },
    { done: !!form.date_depart && !!form.date_retour && nbNuits > 0, label: "Dates" },
  ];
  const progressPct = Math.round((progress.filter(p => p.done).length / progress.length) * 100);

  return (
    <div style={s.page}>
      <PageHeader
        title="Créer un GroupTrip"
        subtitle="Organisez votre voyage en groupe"
        backLabel="Mes voyages"
        backTo="/dashboard"
      />

      <div style={s.body}>
        <div style={s.layout}>
          {/* Formulaire principal */}
          <div style={s.card}>
            {error && <div style={s.error}>⚠️ {error}</div>}

            {/* Progression */}
            <div style={s.progressHeader}>
              <span style={s.progressLabel}>Complétion du formulaire</span>
              <span style={s.progressPct}>{progressPct}%</span>
            </div>
            <div style={s.progressTrack}>
              <div style={{ ...s.progressFill, width: `${progressPct}%` }} />
            </div>
            <div style={s.progressSteps}>
              {progress.map((p, i) => (
                <div key={i} style={{ ...s.progressStep, color: p.done ? "#3B6D11" : "#B0AFA8" }}>
                  <span style={{ ...s.progressDot, background: p.done ? "#42A85A" : "#D1CFC5" }} />
                  {p.label}
                </div>
              ))}
            </div>

            <form onSubmit={handleSubmit}>
              {/* Nom */}
              <div style={s.section}>
                <div style={s.sectionHeader}>
                  <span style={s.sectionNum}>1</span>
                  <div>
                    <div style={s.sectionTitle}>Nom du voyage</div>
                    <div style={s.sectionSub}>Choisissez un nom mémorable pour votre groupe</div>
                  </div>
                </div>
                <div style={s.inputWrap}>
                  <span style={s.inputIcon}>✈️</span>
                  <input
                    style={s.input}
                    type="text"
                    placeholder='Ex : "Bali entre amis 2026"'
                    value={form.nom}
                    onChange={(e) => setForm({ ...form, nom: e.target.value })}
                    required
                    autoFocus
                  />
                  {form.nom.trim().length > 0 && <span style={s.checkMark}>✓</span>}
                </div>
              </div>

              {/* Budget */}
              <div style={s.section}>
                <div style={s.sectionHeader}>
                  <span style={s.sectionNum}>2</span>
                  <div>
                    <div style={s.sectionTitle}>Budget maximum par personne</div>
                    <div style={s.sectionSub}>Une estimation pour cadrer les choix de vote</div>
                  </div>
                </div>
                <div style={s.inputWrap}>
                  <span style={s.inputIcon}>💶</span>
                  <input
                    style={s.input}
                    type="number"
                    placeholder="Ex : 1 500"
                    min="0"
                    step="50"
                    value={form.budget_max}
                    onChange={(e) => setForm({ ...form, budget_max: e.target.value })}
                  />
                  <span style={s.inputSuffix}>€ / pers.</span>
                </div>
                {form.budget_max && (
                  <div style={s.budgetHint}>
                    Pour un groupe de 4 : <strong>{(parseFloat(form.budget_max) * 4).toFixed(0)}€</strong> au total
                  </div>
                )}
              </div>

              {/* Dates */}
              <div style={s.section}>
                <div style={s.sectionHeader}>
                  <span style={s.sectionNum}>3</span>
                  <div>
                    <div style={s.sectionTitle}>Dates du voyage</div>
                    <div style={s.sectionSub}>Utilisées pour filtrer les transports disponibles</div>
                  </div>
                </div>
                <div style={s.datesRow}>
                  <div style={s.dateField}>
                    <label style={s.dateLabel}>Départ</label>
                    <input
                      style={s.inputDate}
                      type="date"
                      min={today}
                      value={form.date_depart}
                      onChange={(e) => setForm({ ...form, date_depart: e.target.value, date_retour: "" })}
                    />
                  </div>
                  <div style={s.dateArrowWrap}>
                    <div style={s.dateArrow}>→</div>
                  </div>
                  <div style={s.dateField}>
                    <label style={s.dateLabel}>Retour</label>
                    <input
                      style={{ ...s.inputDate, opacity: !form.date_depart ? 0.5 : 1 }}
                      type="date"
                      min={form.date_depart || today}
                      value={form.date_retour}
                      onChange={(e) => setForm({ ...form, date_retour: e.target.value })}
                      disabled={!form.date_depart}
                    />
                  </div>
                </div>
                {nbNuits !== null && nbNuits > 0 && (
                  <div style={s.nightsBadge}>
                    <span style={s.nightsIcon}>🌙</span>
                    <div>
                      <div style={s.nightsNum}>{nbNuits} nuit{nbNuits > 1 ? "s" : ""}</div>
                      <div style={s.nightsDates}>
                        du {new Date(form.date_depart).toLocaleDateString("fr-FR", { day: "numeric", month: "long" })} au{" "}
                        {new Date(form.date_retour).toLocaleDateString("fr-FR", { day: "numeric", month: "long", year: "numeric" })}
                      </div>
                    </div>
                  </div>
                )}
              </div>

              {/* Info organisateur */}
              <div style={s.infoBox}>
                <span style={s.infoIcon}>👑</span>
                <p style={s.infoText}>
                  Vous serez l'organisateur de ce voyage. Vous pourrez inviter vos amis et valider les choix de vote après la création.
                </p>
              </div>

              <button type="submit" style={{ ...s.btn, opacity: loading ? 0.7 : 1 }} disabled={loading}>
                {loading ? "Création en cours..." : "Créer le GroupTrip →"}
              </button>
            </form>
          </div>

          {/* Panneau latéral — info */}
          <div style={s.sidebar}>
            <div style={s.sideCard}>
              <h3 style={s.sideTitle}>Comment ça marche ?</h3>
              {TIPS.map((tip, i) => (
                <div key={i} style={s.tipItem}>
                  <span style={s.tipIcon}>{tip.icon}</span>
                  <span style={s.tipText}>{tip.text}</span>
                </div>
              ))}
            </div>
            <div style={s.sideCard}>
              <h3 style={s.sideTitle}>Étapes à venir</h3>
              {[
                { icon: "✈️", label: "Choisir le transport" },
                { icon: "🏨", label: "Choisir l'hébergement" },
                { icon: "🎯", label: "Sélectionner les activités" },
                { icon: "🗺️", label: "Valider l'itinéraire" },
                { icon: "💳", label: "Payer en groupe" },
              ].map((step, i) => (
                <div key={i} style={s.stepItem}>
                  <div style={s.stepLine}>
                    <div style={s.stepDot} />
                    {i < 4 && <div style={s.stepConnector} />}
                  </div>
                  <div style={s.stepLabel}>
                    <span>{step.icon}</span>
                    <span style={s.stepText}>{step.label}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

const s = {
  page: { fontFamily: "Arial, sans-serif", minHeight: "100vh", background: "#F5F4F0" },
  body: { padding: "28px 32px 48px", maxWidth: "1080px", margin: "0 auto" },
  layout: { display: "grid", gridTemplateColumns: "1fr 280px", gap: "20px", alignItems: "start" },

  card: {
    background: "white", borderRadius: "16px",
    padding: "32px 36px", boxShadow: "0 4px 20px rgba(0,0,0,0.07)",
  },
  error: {
    background: "#FCEBEB", color: "#A32D2D",
    padding: "10px 14px", borderRadius: "8px",
    marginBottom: "20px", fontSize: "13px",
  },

  progressHeader: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "8px" },
  progressLabel: { fontSize: "12px", fontWeight: "600", color: "#73726c", textTransform: "uppercase", letterSpacing: "0.3px" },
  progressPct: { fontSize: "13px", fontWeight: "700", color: "#0C447C" },
  progressTrack: { height: 6, background: "#E0DED6", borderRadius: 3, overflow: "hidden", marginBottom: "10px" },
  progressFill: { height: "100%", background: "linear-gradient(90deg, #0C447C, #185FA5)", borderRadius: 3, transition: "width 0.4s" },
  progressSteps: { display: "flex", gap: "16px", marginBottom: "28px" },
  progressStep: { display: "flex", alignItems: "center", gap: "5px", fontSize: "12px", fontWeight: "600", transition: "color 0.3s" },
  progressDot: { width: 8, height: 8, borderRadius: "50%", flexShrink: 0, transition: "background 0.3s" },

  section: {
    padding: "20px 0",
    borderBottom: "1px solid #F5F4F0",
    marginBottom: "4px",
  },
  sectionHeader: { display: "flex", alignItems: "flex-start", gap: "12px", marginBottom: "14px" },
  sectionNum: {
    width: 28, height: 28, borderRadius: "50%",
    background: "linear-gradient(135deg, #0C447C, #185FA5)",
    color: "white", display: "flex", alignItems: "center",
    justifyContent: "center", fontSize: "13px",
    fontWeight: "800", flexShrink: 0, marginTop: "1px",
  },
  sectionTitle: { fontSize: "15px", fontWeight: "700", color: "#0C447C", marginBottom: "2px" },
  sectionSub: { fontSize: "12px", color: "#73726c" },

  inputWrap: { position: "relative", display: "flex", alignItems: "center" },
  inputIcon: { position: "absolute", left: "12px", fontSize: "15px", pointerEvents: "none" },
  input: {
    width: "100%", padding: "12px 44px 12px 40px",
    borderRadius: "10px", fontSize: "14px",
    border: "1.5px solid #E0DED6", boxSizing: "border-box",
    outline: "none", background: "#FAFAFA",
    transition: "border-color 0.2s",
  },
  checkMark: { position: "absolute", right: "12px", fontSize: "15px", color: "#42A85A", fontWeight: "bold" },
  inputSuffix: { position: "absolute", right: "12px", fontSize: "13px", color: "#73726c", pointerEvents: "none" },

  budgetHint: { marginTop: "8px", fontSize: "12px", color: "#73726c", paddingLeft: "4px" },

  datesRow: { display: "flex", gap: "10px", alignItems: "flex-end" },
  dateField: { flex: 1 },
  dateLabel: { display: "block", fontSize: "11px", fontWeight: "600", color: "#73726c", textTransform: "uppercase", letterSpacing: "0.3px", marginBottom: "6px" },
  inputDate: {
    width: "100%", padding: "12px", borderRadius: "10px",
    fontSize: "14px", border: "1.5px solid #E0DED6",
    boxSizing: "border-box", outline: "none", background: "#FAFAFA",
    color: "#2C2C2A",
  },
  dateArrowWrap: { paddingBottom: "8px", flexShrink: 0 },
  dateArrow: { fontSize: "18px", color: "#C0BEB5" },

  nightsBadge: {
    marginTop: "14px",
    display: "flex", alignItems: "center", gap: "14px",
    background: "linear-gradient(135deg, #E6F1FB, #D4E8F5)",
    padding: "14px 18px", borderRadius: "12px",
    border: "1px solid #C5DDF0",
  },
  nightsIcon: { fontSize: "28px" },
  nightsNum: { fontSize: "18px", fontWeight: "800", color: "#0C447C" },
  nightsDates: { fontSize: "12px", color: "#185FA5", marginTop: "2px" },

  infoBox: {
    display: "flex", gap: "12px", alignItems: "flex-start",
    background: "#FFF8E6", border: "1px solid #F5DFA0",
    borderRadius: "10px", padding: "14px 16px",
    margin: "24px 0",
  },
  infoIcon: { fontSize: "18px", flexShrink: 0, marginTop: "1px" },
  infoText: { fontSize: "13px", color: "#854F0B", lineHeight: 1.55, margin: 0 },

  btn: {
    width: "100%", padding: "14px",
    background: "linear-gradient(135deg, #0C447C, #185FA5)",
    color: "white", border: "none",
    borderRadius: "12px", fontSize: "15px",
    fontWeight: "700", cursor: "pointer",
    boxShadow: "0 4px 14px rgba(12,68,124,0.25)",
    letterSpacing: "0.2px",
  },

  // Sidebar
  sidebar: { display: "flex", flexDirection: "column", gap: "14px" },
  sideCard: {
    background: "white", borderRadius: "14px",
    padding: "20px 22px", boxShadow: "0 2px 10px rgba(0,0,0,0.06)",
  },
  sideTitle: { fontSize: "13px", fontWeight: "700", color: "#0C447C", marginBottom: "14px", textTransform: "uppercase", letterSpacing: "0.4px" },
  tipItem: { display: "flex", alignItems: "flex-start", gap: "10px", marginBottom: "12px", fontSize: "13px", color: "#444", lineHeight: 1.45 },
  tipIcon: { fontSize: "18px", flexShrink: 0 },
  tipText: {},

  stepItem: { display: "flex", alignItems: "flex-start", gap: "10px", marginBottom: "0" },
  stepLine: { display: "flex", flexDirection: "column", alignItems: "center", width: 14 },
  stepDot: { width: 10, height: 10, borderRadius: "50%", background: "#D1CFC5", flexShrink: 0, marginTop: "4px" },
  stepConnector: { width: 2, height: 20, background: "#E0DED6", margin: "2px 0" },
  stepLabel: { display: "flex", alignItems: "center", gap: "8px", paddingBottom: "14px" },
  stepText: { fontSize: "13px", color: "#444" },
};
