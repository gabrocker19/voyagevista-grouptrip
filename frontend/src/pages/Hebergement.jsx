import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { catalogueService } from "../services/catalogue.service";
import { groupService } from "../services/group.service";

export default function Hebergement() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [groupe, setGroupe] = useState(null);
  const [hebergements, setHebergements] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState(null);
  const [message, setMessage] = useState("");

  useEffect(() => {
    groupService
      .getOne(id)
      .then((g) => {
        setGroupe(g);
        const params = g.destination_id
          ? { destination_id: g.destination_id }
          : {};
        return catalogueService.hebergements(params);
      })
      .then(setHebergements)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [id]);

  const handleSelect = (heb) => {
    setSelected(heb.id);
    setMessage(
      `✓ Hébergement sélectionné : ${heb.nom} — ${heb.prix_nuit}€/nuit`,
    );
  };

  const handleContinue = () => {
    if (!selected) {
      setMessage("Veuillez sélectionner un hébergement.");
      return;
    }
    sessionStorage.setItem(`hebergement_${id}`, selected);
    navigate(`/groupes/${id}/activites`);
  };

  if (loading) return <div style={styles.loading}>Chargement...</div>;

  const typeIcons = {
    hotel: "🏨",
    airbnb: "🏠",
    hostel: "🛏️",
    villa: "🏡",
    resort: "🌴",
  };

  return (
    <div style={styles.page}>
      <div style={styles.header}>
        <div>
          <button onClick={() => navigate(`/groupes/${id}/transport`)} style={styles.btnBack}>
            ← Transport
          </button>
          <h1 style={styles.title}>🏨 Hébergement</h1>
          <p style={styles.sub}>{groupe?.nom}</p>
        </div>
        <div style={styles.steps}>
          <span
            onClick={() => navigate(`/groupes/${id}/transport`)}
            style={{ ...styles.stepDone, cursor: "pointer" }}
          >
            ✓ Transport
          </span>
          <span style={styles.stepArrow}>→</span>
          <span style={styles.stepActive}>2. Hébergement</span>
          <span style={styles.stepArrow}>→</span>
          <span style={styles.stepInactive}>3. Activités</span>
          <span style={styles.stepArrow}>→</span>
          <span style={styles.stepInactive}>4. Itinéraire</span>
        </div>
      </div>

      <div style={styles.body}>
        {message && <div style={styles.success}>{message}</div>}

        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>
            Hébergements disponibles
            <span style={styles.counter}>
              {hebergements.length} option{hebergements.length > 1 ? "s" : ""}
            </span>
          </h2>

          <div style={styles.grid}>
            {hebergements.map((h) => (
              <div
                key={h.id}
                style={{
                  ...styles.card,
                  border:
                    selected === h.id
                      ? "2px solid #185FA5"
                      : "1px solid #E0DED6",
                }}
              >
                <div style={styles.cardImg}>{typeIcons[h.type] || "🏨"}</div>
                <div style={styles.cardBody}>
                  <div style={styles.cardTop}>
                    <h3 style={styles.cardName}>{h.nom}</h3>
                    <span style={styles.typeBadge}>{h.type}</span>
                  </div>
                  <p style={styles.cardDesc}>{h.description}</p>
                  <div style={styles.cardInfo}>
                    <span>👥 Capacité : {h.capacite} pers.</span>
                  </div>
                  <div style={styles.cardFooter}>
                    <div style={styles.prix}>
                      {h.prix_nuit}€<span style={styles.perNuit}>/nuit</span>
                    </div>
                    <button
                      onClick={() => handleSelect(h)}
                      style={{
                        ...styles.btnSelect,
                        background: selected === h.id ? "#185FA5" : "white",
                        color: selected === h.id ? "white" : "#185FA5",
                      }}
                    >
                      {selected === h.id ? "✓ Sélectionné" : "Choisir"}
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <button onClick={handleContinue} style={styles.btnContinue}>
          Continuer → Activités
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
  stepDone: {
    background: "#EAF3DE",
    color: "#3B6D11",
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
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))",
    gap: "14px",
  },
  card: { borderRadius: "10px", background: "#FAFAF8", overflow: "hidden" },
  cardImg: {
    height: "80px",
    background: "#E6F1FB",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "40px",
  },
  cardBody: { padding: "14px" },
  cardTop: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: "6px",
  },
  cardName: { fontSize: "15px", fontWeight: "bold", color: "#0C447C" },
  typeBadge: {
    fontSize: "11px",
    padding: "2px 8px",
    borderRadius: "12px",
    background: "#E6F1FB",
    color: "#185FA5",
  },
  cardDesc: {
    fontSize: "12px",
    color: "#73726c",
    marginBottom: "8px",
    lineHeight: "1.4",
  },
  cardInfo: { fontSize: "12px", color: "#444", marginBottom: "10px" },
  cardFooter: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },
  prix: { fontSize: "18px", fontWeight: "bold", color: "#0C447C" },
  perNuit: { fontSize: "11px", fontWeight: "normal", color: "#73726c" },
  btnSelect: {
    padding: "7px 14px",
    borderRadius: "6px",
    border: "1px solid #185FA5",
    cursor: "pointer",
    fontSize: "12px",
    fontWeight: "500",
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
