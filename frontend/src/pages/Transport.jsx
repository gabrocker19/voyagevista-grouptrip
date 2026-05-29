import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { catalogueService } from "../services/catalogue.service";
import { groupService } from "../services/group.service";
import { api } from "../services/api";

export default function Transport() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [groupe, setGroupe] = useState(null);
  const [transports, setTransports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState(null);
  const [message, setMessage] = useState("");
  const [filtre, setFiltre] = useState("avion");

  useEffect(() => {
    setLoading(true);
    groupService
      .getOne(id)
      .then((g) => {
        setGroupe(g);
        // Récupérer le nom de la destination pour filtrer les transports
        if (g.destination_id) {
          return Promise.all([
            catalogueService.transports({ type: filtre }),
            api.get(`/api/destinations/${g.destination_id}`),
          ]).then(([t, dest]) => {
            // Filtrer les transports qui vont vers cette destination
            const filtered = t.filter(
              (tr) =>
                tr.destination.toLowerCase().includes(dest.nom.toLowerCase()) ||
                dest.pays.toLowerCase().includes(tr.destination.toLowerCase()),
            );
            setTransports(filtered.length > 0 ? filtered : t);
          });
        } else {
          return catalogueService
            .transports({ type: filtre })
            .then(setTransports);
        }
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [id, filtre]);

  const handleSelect = async (transport) => {
    setSelected(transport.id);
    setMessage(
      `✓ Transport sélectionné : ${transport.compagnie} — ${transport.prix}€/pers`,
    );
  };

  const handleContinue = () => {
    if (!selected) {
      setMessage("Veuillez sélectionner un transport.");
      return;
    }
    // Sauvegarder dans sessionStorage pour l'itinéraire
    sessionStorage.setItem(`transport_${id}`, selected);
    navigate(`/groupes/${id}/hebergement`);
  };

  if (loading) return <div style={styles.loading}>Chargement...</div>;

  const types = ["avion", "train"];

  return (
    <div style={styles.page}>
      <div style={styles.header}>
        <div>
          <button onClick={() => navigate(`/groupes/${id}`)} style={styles.btnBack}>
            ← Retour au groupe
          </button>
          <h1 style={styles.title}>✈️ Transport</h1>
          <p style={styles.sub}>{groupe?.nom}</p>
        </div>
        <div style={styles.steps}>
          <span style={styles.stepActive}>1. Transport</span>
          <span style={styles.stepArrow}>→</span>
          <span style={styles.stepInactive}>2. Hébergement</span>
          <span style={styles.stepArrow}>→</span>
          <span style={styles.stepInactive}>3. Activités</span>
          <span style={styles.stepArrow}>→</span>
          <span style={styles.stepInactive}>4. Itinéraire</span>
        </div>
      </div>

      <div style={styles.body}>
        {message && <div style={styles.success}>{message}</div>}

        {/* Filtres type */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>Type de transport</h2>
          <div style={styles.typeFilters}>
            {types.map((t) => (
              <button
                key={t}
                onClick={() => setFiltre(t)}
                style={filtre === t ? styles.typeActive : styles.typeBtn}
              >
                {t === "avion"
                  ? "✈️"
                  : t === "train"
                    ? "🚆"
                    : t === "bus"
                      ? "🚌"
                      : "⛴️"}{" "}
                {t}
              </button>
            ))}
          </div>
        </div>

        {/* Liste transports */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>
            Trajets disponibles
            <span style={styles.counter}>
              {transports.length} résultat{transports.length > 1 ? "s" : ""}
            </span>
          </h2>

          {transports.length === 0 ? (
            <p style={styles.empty}>Aucun trajet disponible pour ce type.</p>
          ) : (
            <div style={styles.list}>
              {transports.map((t) => (
                <div
                  key={t.id}
                  style={{
                    ...styles.card,
                    border:
                      selected === t.id
                        ? "2px solid #185FA5"
                        : "1px solid #E0DED6",
                  }}
                >
                  <div style={styles.cardLeft}>
                    <div style={styles.compagnie}>{t.compagnie}</div>
                    <div style={styles.trajet}>
                      <span style={styles.ville}>{t.origine}</span>
                      <span style={styles.arrow}>→</span>
                      <span style={styles.ville}>{t.destination}</span>
                    </div>
                    <div style={styles.dates}>
                      🗓️{" "}
                      {new Date(t.date_depart).toLocaleDateString("fr-FR", {
                        day: "2-digit",
                        month: "short",
                        year: "numeric",
                        hour: "2-digit",
                        minute: "2-digit",
                      })}
                    </div>
                    <div style={styles.places}>
                      💺 {t.places_dispo} places disponibles
                    </div>
                  </div>
                  <div style={styles.cardRight}>
                    <div style={styles.prix}>
                      {t.prix}€<span style={styles.perPers}>/pers</span>
                    </div>
                    <button
                      onClick={() => handleSelect(t)}
                      style={{
                        ...styles.btnSelect,
                        background: selected === t.id ? "#185FA5" : "white",
                        color: selected === t.id ? "white" : "#185FA5",
                      }}
                    >
                      {selected === t.id ? "✓ Sélectionné" : "Sélectionner"}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <button onClick={handleContinue} style={styles.btnContinue}>
          Continuer → Hébergement
        </button>
      </div>
    </div>
  );
}

const styles = {
  page: {
    fontFamily: "Arial, sans-serif",
    minHeight: "100vh",
    background: "#F5F4F0",
  },
  loading: { textAlign: "center", padding: "60px", color: "#73726c" },
  header: { background: "#0C447C", color: "white", padding: "24px 32px" },
  title: { fontSize: "24px", fontWeight: "bold", marginBottom: "4px" },
  sub: { opacity: 0.8, fontSize: "13px", marginBottom: "12px" },
  steps: {
    display: "flex",
    alignItems: "center",
    gap: "8px",
    flexWrap: "wrap",
  },
  btnBack: {
    background: "none",
    border: "none",
    color: "rgba(255,255,255,0.8)",
    cursor: "pointer",
    fontSize: "13px",
    padding: "0",
    marginBottom: "8px",
    display: "block",
  },
  stepActive: {
    background: "white",
    color: "#0C447C",
    padding: "4px 12px",
    borderRadius: "20px",
    fontSize: "12px",
    fontWeight: "bold",
  },
  stepInactive: { color: "rgba(255,255,255,0.6)", fontSize: "12px" },
  stepArrow: { color: "rgba(255,255,255,0.4)", fontSize: "12px" },
  body: {
    padding: "24px 32px",
    display: "flex",
    flexDirection: "column",
    gap: "16px",
  },
  success: {
    background: "#EAF3DE",
    color: "#3B6D11",
    padding: "12px 16px",
    borderRadius: "8px",
    fontSize: "14px",
  },
  section: {
    background: "white",
    borderRadius: "12px",
    padding: "20px 24px",
    boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
  },
  sectionTitle: {
    fontSize: "15px",
    fontWeight: "bold",
    color: "#0C447C",
    marginBottom: "14px",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },
  counter: { fontSize: "12px", fontWeight: "normal", color: "#73726c" },
  typeFilters: { display: "flex", gap: "8px", flexWrap: "wrap" },
  typeBtn: {
    padding: "8px 18px",
    borderRadius: "20px",
    border: "1px solid #D1CFC5",
    background: "white",
    cursor: "pointer",
    fontSize: "13px",
  },
  typeActive: {
    padding: "8px 18px",
    borderRadius: "20px",
    border: "1px solid #185FA5",
    background: "#185FA5",
    color: "white",
    cursor: "pointer",
    fontSize: "13px",
  },
  list: { display: "flex", flexDirection: "column", gap: "10px" },
  card: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    padding: "16px",
    borderRadius: "10px",
    background: "#FAFAF8",
    gap: "16px",
  },
  cardLeft: { flex: 1 },
  compagnie: {
    fontSize: "15px",
    fontWeight: "bold",
    color: "#0C447C",
    marginBottom: "6px",
  },
  trajet: {
    display: "flex",
    alignItems: "center",
    gap: "8px",
    marginBottom: "4px",
  },
  ville: { fontSize: "14px", fontWeight: "500", color: "#2C2C2A" },
  arrow: { color: "#185FA5", fontWeight: "bold" },
  dates: { fontSize: "12px", color: "#73726c", marginBottom: "2px" },
  places: { fontSize: "12px", color: "#73726c" },
  cardRight: { textAlign: "center", flexShrink: 0 },
  prix: {
    fontSize: "22px",
    fontWeight: "bold",
    color: "#0C447C",
    marginBottom: "8px",
  },
  perPers: { fontSize: "12px", fontWeight: "normal", color: "#73726c" },
  btnSelect: {
    padding: "8px 16px",
    borderRadius: "6px",
    border: "1px solid #185FA5",
    cursor: "pointer",
    fontSize: "13px",
    fontWeight: "500",
    whiteSpace: "nowrap",
  },
  empty: {
    color: "#73726c",
    fontSize: "14px",
    textAlign: "center",
    padding: "20px",
  },
  btnContinue: {
    background: "#185FA5",
    color: "white",
    border: "none",
    padding: "14px",
    borderRadius: "8px",
    cursor: "pointer",
    fontSize: "15px",
    fontWeight: "bold",
  },
};
