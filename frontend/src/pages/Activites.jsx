import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { catalogueService } from "../services/catalogue.service";
import { groupService } from "../services/group.service";

export default function Activites() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [groupe, setGroupe] = useState(null);
  const [activites, setActivites] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState([]);
  const [message, setMessage] = useState("");

  useEffect(() => {
    groupService
      .getOne(id)
      .then((g) => {
        setGroupe(g);
        const params = g.destination_id
          ? { destination_id: g.destination_id }
          : {};
        return catalogueService.activites(params);
      })
      .then(setActivites)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [id]);

  const handleToggle = (activite) => {
    if (activite.places_restantes === 0) return;
    setSelected((prev) =>
      prev.includes(activite.id)
        ? prev.filter((i) => i !== activite.id)
        : [...prev, activite.id],
    );
  };

  const handleContinue = () => {
    sessionStorage.setItem(`activites_${id}`, JSON.stringify(selected));
    navigate(`/groupes/${id}/itineraire`);
  };

  if (loading) return <div style={styles.loading}>Chargement...</div>;

  return (
    <div style={styles.page}>
      <div style={styles.header}>
        <div>
          <button onClick={() => navigate(`/groupes/${id}/hebergement`)} style={styles.btnBack}>
            ← Hébergement
          </button>
          <h1 style={styles.title}>🎯 Activités</h1>
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
          <span
            onClick={() => navigate(`/groupes/${id}/hebergement`)}
            style={{ ...styles.stepDone, cursor: "pointer" }}
          >
            ✓ Hébergement
          </span>
          <span style={styles.stepArrow}>→</span>
          <span style={styles.stepActive}>3. Activités</span>
          <span style={styles.stepArrow}>→</span>
          <span style={styles.stepInactive}>4. Itinéraire</span>
        </div>
      </div>

      <div style={styles.body}>
        {message && <div style={styles.success}>{message}</div>}

        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>
            Choisissez vos activités
            <span style={styles.counter}>
              {selected.length} sélectionnée{selected.length > 1 ? "s" : ""}
            </span>
          </h2>

          <div style={styles.grid}>
            {activites.map((a) => {
              const isSelected = selected.includes(a.id);
              const isComplet = a.places_restantes === 0;

              return (
                <div
                  key={a.id}
                  onClick={() => handleToggle(a)}
                  style={{
                    ...styles.card,
                    border: isSelected
                      ? "2px solid #185FA5"
                      : isComplet
                        ? "1px solid #F09595"
                        : "1px solid #E0DED6",
                    opacity: isComplet ? 0.7 : 1,
                    cursor: isComplet ? "not-allowed" : "pointer",
                  }}
                >
                  <div style={styles.cardTop}>
                    <h3 style={styles.cardName}>{a.nom}</h3>
                    {isComplet ? (
                      <span style={styles.badgeComplet}>Complet</span>
                    ) : isSelected ? (
                      <span style={styles.badgeSelected}>✓ Ajouté</span>
                    ) : (
                      <span style={styles.badgeDisponible}>
                        {a.places_restantes} places
                      </span>
                    )}
                  </div>
                  <p style={styles.cardDesc}>{a.description}</p>
                  <div style={styles.cardFooter}>
                    <div style={styles.cardInfo}>
                      {a.duree_heures && <span>⏱️ {a.duree_heures}h</span>}
                    </div>
                    <div style={styles.prix}>
                      {a.prix}€<span style={styles.perPers}>/pers</span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        <div style={styles.bottomBar}>
          <div style={styles.totalActivites}>
            {selected.length > 0 ? (
              <span>
                {selected.length} activité{selected.length > 1 ? "s" : ""}{" "}
                sélectionnée{selected.length > 1 ? "s" : ""} —{" "}
                {activites
                  .filter((a) => selected.includes(a.id))
                  .reduce((sum, a) => sum + parseFloat(a.prix), 0)
                  .toFixed(0)}
                €/pers
              </span>
            ) : (
              <span style={{ color: "#73726c" }}>
                Aucune activité sélectionnée (optionnel)
              </span>
            )}
          </div>
          <button onClick={handleContinue} style={styles.btnContinue}>
            Continuer → Itinéraire
          </button>
        </div>
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
  header: { background: "linear-gradient(135deg, #0C447C 0%, #1A7FC4 100%)", color: "white", padding: "28px 32px", display: "flex", justifyContent: "space-between", alignItems: "flex-start" },
  title: { fontSize: "26px", fontWeight: "800", marginBottom: "4px", letterSpacing: "-0.3px" },
  sub: { opacity: 0.82, fontSize: "13px", marginBottom: "12px" },
  steps: {
    display: "flex",
    alignItems: "center",
    gap: "8px",
    flexWrap: "wrap",
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
    gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))",
    gap: "12px",
  },
  card: { borderRadius: "10px", background: "#FAFAF8", padding: "14px" },
  cardTop: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "flex-start",
    marginBottom: "6px",
    gap: "8px",
  },
  cardName: { fontSize: "14px", fontWeight: "bold", color: "#0C447C", flex: 1 },
  badgeComplet: {
    fontSize: "10px",
    padding: "2px 8px",
    borderRadius: "12px",
    background: "#FCEBEB",
    color: "#A32D2D",
    whiteSpace: "nowrap",
  },
  badgeSelected: {
    fontSize: "10px",
    padding: "2px 8px",
    borderRadius: "12px",
    background: "#E6F1FB",
    color: "#185FA5",
    whiteSpace: "nowrap",
  },
  badgeDisponible: {
    fontSize: "10px",
    padding: "2px 8px",
    borderRadius: "12px",
    background: "#EAF3DE",
    color: "#3B6D11",
    whiteSpace: "nowrap",
  },
  cardDesc: {
    fontSize: "12px",
    color: "#73726c",
    marginBottom: "10px",
    lineHeight: "1.4",
  },
  cardFooter: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },
  cardInfo: { fontSize: "12px", color: "#73726c" },
  prix: { fontSize: "16px", fontWeight: "bold", color: "#0C447C" },
  perPers: { fontSize: "11px", fontWeight: "normal", color: "#73726c" },
  bottomBar: {
    background: "white",
    borderRadius: "12px",
    padding: "16px 24px",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
  },
  totalActivites: { fontSize: "14px", color: "#0C447C", fontWeight: "500" },
  btnContinue: {
    background: "#185FA5",
    color: "white",
    border: "none",
    padding: "12px 24px",
    borderRadius: "8px",
    cursor: "pointer",
    fontSize: "14px",
    fontWeight: "bold",
  },
};
