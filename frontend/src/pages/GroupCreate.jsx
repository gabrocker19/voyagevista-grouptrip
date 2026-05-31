import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { groupService } from "../services/group.service";
import PageHeader from "../components/PageHeader";

const today = new Date().toISOString().split("T")[0];

export default function GroupCreate() {
  const [form, setForm] = useState({ nom: "", budget_max: "", date_depart: "", date_retour: "" });
  const [error, setError] = useState("");
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
    try {
      const res = await groupService.create(form);
      navigate(`/groupes/${res.groupe_id}`);
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div style={s.page}>
      <PageHeader
        title="✈ Créer un GroupTrip"
        subtitle="Organisez votre voyage en groupe"
        backLabel="Mes voyages"
        backTo="/dashboard"
      />

      <div style={s.body}>
        <div style={s.card}>
          {error && <div style={s.error}>{error}</div>}

          <form onSubmit={handleSubmit}>

            {/* Nom */}
            <div style={s.fieldGroup}>
              <label style={s.label}>Nom du voyage</label>
              <div style={s.inputWrap}>
                <span style={s.inputIcon}>✈️</span>
                <input
                  style={s.input}
                  type="text"
                  placeholder='Ex : "Bali entre amis 2026"'
                  value={form.nom}
                  onChange={(e) => setForm({ ...form, nom: e.target.value })}
                  required
                />
              </div>
            </div>

            {/* Budget */}
            <div style={s.fieldGroup}>
              <label style={s.label}>Budget maximum par personne (€)</label>
              <div style={s.inputWrap}>
                <span style={s.inputIcon}>💰</span>
                <input
                  style={s.input}
                  type="number"
                  placeholder="Ex : 1500"
                  min="0"
                  value={form.budget_max}
                  onChange={(e) => setForm({ ...form, budget_max: e.target.value })}
                />
              </div>
            </div>

            {/* Dates */}
            <div style={s.datesRow}>
              <div style={{ ...s.fieldGroup, flex: 1 }}>
                <label style={s.label}>📅 Date de départ</label>
                <input
                  style={s.inputDate}
                  type="date"
                  min={today}
                  value={form.date_depart}
                  onChange={(e) => setForm({ ...form, date_depart: e.target.value, date_retour: "" })}
                />
              </div>
              <div style={s.dateArrow}>→</div>
              <div style={{ ...s.fieldGroup, flex: 1 }}>
                <label style={s.label}>📅 Date de retour</label>
                <input
                  style={s.inputDate}
                  type="date"
                  min={form.date_depart || today}
                  value={form.date_retour}
                  onChange={(e) => setForm({ ...form, date_retour: e.target.value })}
                  disabled={!form.date_depart}
                />
              </div>
            </div>

            {/* Indicateur nuits */}
            {nbNuits !== null && nbNuits > 0 && (
              <div style={s.nightsBadge}>
                🌙 {nbNuits} nuit{nbNuits > 1 ? "s" : ""} · du{" "}
                {new Date(form.date_depart).toLocaleDateString("fr-FR", { day:"numeric", month:"short" })} au{" "}
                {new Date(form.date_retour).toLocaleDateString("fr-FR", { day:"numeric", month:"short", year:"numeric" })}
              </div>
            )}

            <div style={s.info}>
              ℹ️ Vous deviendrez automatiquement l'organisateur. Vous pourrez inviter vos amis après la création.
            </div>

            <button type="submit" style={s.btn}>
              Créer le GroupTrip →
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

const s = {
  page: { fontFamily: "'Inter', Arial, sans-serif", minHeight: "100vh", background: "#F5F4F0" },
  body: { display: "flex", justifyContent: "center", padding: "40px 16px" },
  card: { background: "white", borderRadius: "16px", padding: "36px 40px", width: "100%", maxWidth: "520px", boxShadow: "0 4px 24px rgba(0,0,0,0.09)" },

  error: { background: "#FCEBEB", color: "#A32D2D", padding: "10px 14px", borderRadius: "8px", marginBottom: "20px", fontSize: "13px" },

  fieldGroup: { marginBottom: "20px" },
  label: { display: "block", fontSize: "12px", fontWeight: "700", marginBottom: "7px", color: "#444", textTransform: "uppercase", letterSpacing: "0.4px" },

  inputWrap: { position: "relative", display: "flex", alignItems: "center" },
  inputIcon: { position: "absolute", left: "12px", fontSize: "15px", pointerEvents: "none" },
  input: { width: "100%", padding: "11px 14px 11px 40px", borderRadius: "10px", fontSize: "14px", border: "1.5px solid #E0DED6", boxSizing: "border-box", outline: "none", background: "white" },

  datesRow:  { display: "flex", gap: "12px", alignItems: "flex-end", marginBottom: "16px" },
  dateArrow: { fontSize: "20px", color: "#C0BEB5", paddingBottom: "10px", flexShrink: 0 },
  inputDate: { width: "100%", padding: "11px 12px", borderRadius: "10px", fontSize: "14px", border: "1.5px solid #E0DED6", boxSizing: "border-box", outline: "none", background: "white", color: "#2C2C2A" },

  nightsBadge: { background: "linear-gradient(135deg, #E6F1FB, #D0E8F8)", color: "#0C447C", padding: "10px 16px", borderRadius: "10px", fontSize: "13px", fontWeight: "600", marginBottom: "20px", textAlign: "center" },

  info: { background: "#F5F4F0", color: "#73726c", padding: "12px 14px", borderRadius: "8px", fontSize: "13px", marginBottom: "24px", lineHeight: "1.5" },

  btn: { width: "100%", padding: "13px", background: "linear-gradient(135deg, #0C447C, #185FA5)", color: "white", border: "none", borderRadius: "10px", fontSize: "15px", fontWeight: "700", cursor: "pointer", boxShadow: "0 4px 14px rgba(12,68,124,0.25)" },
};
