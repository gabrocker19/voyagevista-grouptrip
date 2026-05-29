import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { api } from "../services/api";

export default function Catalogue() {
  const navigate = useNavigate();
  const [destinations, setDestinations] = useState([]);
  const [search, setSearch] = useState("");
  const [categorie, setCategorie] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const params = new URLSearchParams();
    if (search) params.append("search", search);
    if (categorie) params.append("categorie", categorie);

    api
      .get(`/api/destinations?${params}`)
      .then(setDestinations)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [search, categorie]);

  const categories = ["plage", "montagne", "ville", "aventure", "culture"];

  return (
    <div style={styles.page}>
      <div style={styles.header}>
        <button onClick={() => navigate("/dashboard")} style={styles.btnBack}>
          ← Tableau de bord
        </button>
        <h1 style={styles.title}>🌍 Destinations</h1>
        <p style={styles.sub}>Trouvez votre prochaine aventure</p>
      </div>

      <div style={styles.filters}>
        <input
          style={styles.search}
          type="text"
          placeholder="🔍 Rechercher une destination..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <div style={styles.cats}>
          <button
            style={categorie === "" ? styles.catActive : styles.cat}
            onClick={() => setCategorie("")}
          >
            Toutes
          </button>
          {categories.map((c) => (
            <button
              key={c}
              style={categorie === c ? styles.catActive : styles.cat}
              onClick={() => setCategorie(c)}
            >
              {c.charAt(0).toUpperCase() + c.slice(1)}
            </button>
          ))}
        </div>
      </div>

      {loading ? (
        <p style={{ textAlign: "center", padding: "40px" }}>Chargement...</p>
      ) : (
        <div style={styles.grid}>
          {destinations.map((d) => (
            <div key={d.id} style={styles.card}>
              <div style={styles.imgPlaceholder}>
                {d.categorie === "plage"
                  ? "🏖️"
                  : d.categorie === "montagne"
                    ? "🏔️"
                    : d.categorie === "ville"
                      ? "🏙️"
                      : d.categorie === "aventure"
                        ? "🧗"
                        : "🏛️"}
              </div>
              <div style={styles.cardBody}>
                <div style={styles.cardTop}>
                  <h3 style={styles.cardTitle}>{d.nom}</h3>
                  <span style={styles.badge}>{d.categorie}</span>
                </div>
                <p style={styles.pays}>📍 {d.pays}</p>
                <p style={styles.desc}>{d.description}</p>
                <div style={styles.cardFooter}>
                  <span style={styles.price}>À partir de {d.prix_min}€</span>
                  <button style={styles.btn}>Voir les détails</button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

const styles = {
  page: {
    fontFamily: "Arial, sans-serif",
    minHeight: "100vh",
    background: "#F5F4F0",
  },
  btnBack: {
    background: "none",
    border: "none",
    color: "rgba(255,255,255,0.8)",
    cursor: "pointer",
    fontSize: "13px",
    padding: "0",
    marginBottom: "12px",
    display: "block",
  },
  header: { background: "#0C447C", color: "white", padding: "40px 32px" },
  title: { fontSize: "28px", fontWeight: "bold", marginBottom: "8px" },
  sub: { opacity: 0.85, fontSize: "15px" },
  filters: {
    padding: "24px 32px",
    background: "white",
    boxShadow: "0 2px 4px rgba(0,0,0,0.06)",
  },
  search: {
    width: "100%",
    padding: "10px 14px",
    borderRadius: "8px",
    fontSize: "14px",
    border: "1px solid #D1CFC5",
    marginBottom: "12px",
    boxSizing: "border-box",
  },
  cats: { display: "flex", gap: "8px", flexWrap: "wrap" },
  cat: {
    padding: "6px 16px",
    borderRadius: "20px",
    border: "1px solid #D1CFC5",
    background: "white",
    cursor: "pointer",
    fontSize: "13px",
  },
  catActive: {
    padding: "6px 16px",
    borderRadius: "20px",
    border: "1px solid #185FA5",
    background: "#185FA5",
    color: "white",
    cursor: "pointer",
    fontSize: "13px",
  },
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
    gap: "20px",
    padding: "32px",
  },
  card: {
    background: "white",
    borderRadius: "12px",
    overflow: "hidden",
    boxShadow: "0 2px 8px rgba(0,0,0,0.08)",
  },
  imgPlaceholder: {
    height: "140px",
    background: "#E6F1FB",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "56px",
  },
  cardBody: { padding: "16px" },
  cardTop: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: "4px",
  },
  cardTitle: { fontSize: "18px", fontWeight: "bold", color: "#0C447C" },
  badge: {
    fontSize: "11px",
    padding: "3px 8px",
    borderRadius: "12px",
    background: "#E6F1FB",
    color: "#185FA5",
    fontWeight: "500",
  },
  pays: { fontSize: "13px", color: "#999", margin: "4px 0 8px" },
  desc: {
    fontSize: "13px",
    color: "#555",
    lineHeight: "1.5",
    marginBottom: "12px",
  },
  cardFooter: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },
  price: { fontSize: "15px", fontWeight: "bold", color: "#185FA5" },
  btn: {
    background: "#185FA5",
    color: "white",
    border: "none",
    padding: "7px 14px",
    borderRadius: "6px",
    cursor: "pointer",
    fontSize: "13px",
  },
};
