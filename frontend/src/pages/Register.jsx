import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { authService } from "../services/auth.service";

export default function Register() {
  const [form, setForm] = useState({ nom: "", email: "", password: "" });
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    try {
      await authService.register({
        nom: form.nom,
        email: form.email,
        password: form.password,
      });
      navigate("/login");
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <h2 style={styles.title}>✈ Créer un compte</h2>
        <p style={styles.sub}>Rejoignez VoyageVista GroupTrip</p>

        {error && <div style={styles.error}>{error}</div>}

        <form onSubmit={handleSubmit}>
          <label style={styles.label}>Nom complet</label>
          <input
            style={styles.input}
            type="text"
            placeholder="Prénom Nom"
            value={form.nom}
            onChange={(e) => setForm({ ...form, nom: e.target.value })}
            required
          />
          <label style={styles.label}>Email</label>
          <input
            style={styles.input}
            type="email"
            placeholder="votre@email.fr"
            value={form.email}
            onChange={(e) => setForm({ ...form, email: e.target.value })}
            required
          />
          <label style={styles.label}>Mot de passe</label>
          <input
            style={styles.input}
            type="password"
            placeholder="••••••••"
            value={form.password}
            onChange={(e) => setForm({ ...form, password: e.target.value })}
            required
            minLength={6}
          />
          <button type="submit" style={styles.btn}>
            Créer mon compte
          </button>
        </form>

        <p style={styles.footer}>
          Déjà un compte ? <Link to="/login">Se connecter</Link>
        </p>
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
    maxWidth: "420px",
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
    marginTop: "4px",
  },
  footer: { textAlign: "center", marginTop: "20px", fontSize: "14px" },
};
