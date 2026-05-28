import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { groupService } from "../services/group.service";

export default function GroupCreate() {
  const [form, setForm] = useState({ nom: "", budget_max: "" });
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    try {
      const res = await groupService.create(form);
      navigate(`/groupes/${res.groupe_id}`);
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <h2 style={styles.title}>✈ Créer un GroupTrip</h2>
        <p style={styles.sub}>Organisez votre voyage en groupe</p>

        {error && <div style={styles.error}>{error}</div>}

        <form onSubmit={handleSubmit}>
          <label style={styles.label}>Nom du voyage</label>
          <input
            style={styles.input}
            type="text"
            placeholder='Ex: "Bali entre amis 2026"'
            value={form.nom}
            onChange={(e) => setForm({ ...form, nom: e.target.value })}
            required
          />

          <label style={styles.label}>Budget maximum par personne (€)</label>
          <input
            style={styles.input}
            type="number"
            placeholder="Ex: 1500"
            value={form.budget_max}
            onChange={(e) => setForm({ ...form, budget_max: e.target.value })}
          />

          <div style={styles.info}>
            ℹ️ Vous deviendrez automatiquement l'organisateur du groupe. Vous
            pourrez inviter vos amis après la création.
          </div>

          <button type="submit" style={styles.btn}>
            Créer le GroupTrip →
          </button>
        </form>
      </div>
    </div>
  );
}

const styles = {
  page: {
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    minHeight: "calc(100vh - 56px)",
    background: "#F5F4F0",
  },
  card: {
    background: "white",
    borderRadius: "12px",
    padding: "40px",
    width: "100%",
    maxWidth: "480px",
    boxShadow: "0 4px 16px rgba(0,0,0,0.1)",
  },
  title: {
    fontSize: "24px",
    fontWeight: "bold",
    color: "#0C447C",
    marginBottom: "4px",
  },
  sub: { color: "#73726c", marginBottom: "24px", fontSize: "14px" },
  error: {
    background: "#FCEBEB",
    color: "#A32D2D",
    padding: "10px 14px",
    borderRadius: "6px",
    marginBottom: "16px",
    fontSize: "14px",
  },
  label: {
    display: "block",
    fontSize: "13px",
    fontWeight: "500",
    marginBottom: "6px",
    color: "#444",
  },
  input: {
    width: "100%",
    padding: "10px 12px",
    borderRadius: "6px",
    fontSize: "14px",
    border: "1px solid #D1CFC5",
    marginBottom: "16px",
    boxSizing: "border-box",
  },
  info: {
    background: "#E6F1FB",
    color: "#0C447C",
    padding: "12px 14px",
    borderRadius: "6px",
    fontSize: "13px",
    marginBottom: "20px",
    lineHeight: "1.5",
  },
  btn: {
    width: "100%",
    padding: "12px",
    background: "#185FA5",
    color: "white",
    border: "none",
    borderRadius: "8px",
    fontSize: "15px",
    fontWeight: "bold",
    cursor: "pointer",
  },
};
