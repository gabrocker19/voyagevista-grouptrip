import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { groupService } from "../services/group.service";
import { api } from "../services/api";

export default function Itineraire() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [groupe, setGroupe] = useState(null);
  const [transport, setTransport] = useState(null);
  const [heb, setHeb] = useState(null);
  const [activites, setActivites] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    const transportId = sessionStorage.getItem(`transport_${id}`);
    const hebId = sessionStorage.getItem(`hebergement_${id}`);
    const activitesIds = JSON.parse(
      sessionStorage.getItem(`activites_${id}`) || "[]",
    );

    Promise.all([
      groupService.getOne(id),
      transportId
        ? api.get(`/api/transports/${transportId}`)
        : Promise.resolve(null),
      hebId ? api.get(`/api/hebergements/${hebId}`) : Promise.resolve(null),
      activitesIds.length > 0
        ? api.get(`/api/activites?ids=${activitesIds.join(",")}`)
        : Promise.resolve([]),
    ])
      .then(([g, t, h, a]) => {
        setGroupe(g);
        setTransport(t);
        setHeb(h);
        setActivites(Array.isArray(a) ? a : []);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [id]);

  // Calcul du coût total
  const nbMembres =
    groupe?.membres?.filter((m) => m.statut === "accepte").length || 1;
  const coutTransport = transport ? parseFloat(transport.prix) : 0;
  const nbNuits =
    groupe?.date_depart && groupe?.date_retour
      ? Math.ceil(
          (new Date(groupe.date_retour) - new Date(groupe.date_depart)) /
            (1000 * 60 * 60 * 24),
        )
      : 7;
  const coutHeb = heb ? parseFloat(heb.prix_nuit) * nbNuits : 0;
  const coutActivites = activites.reduce(
    (sum, a) => sum + parseFloat(a.prix),
    0,
  );
  const coutTotal = coutTransport + coutHeb + coutActivites;
  const budgetMax = groupe?.budget_max ? parseFloat(groupe.budget_max) : null;
  const budgetDepasse = budgetMax && coutTotal > budgetMax;

  const handleSave = async () => {
    setSaving(true);
    setError("");
    try {
      const transportId = sessionStorage.getItem(`transport_${id}`);
      const hebId = sessionStorage.getItem(`hebergement_${id}`);
      const activitesIds = JSON.parse(
        sessionStorage.getItem(`activites_${id}`) || "[]",
      );

      await api.post("/api/itineraires", {
        groupe_id: id,
        transport_id: transportId,
        hebergement_id: hebId,
        activite_ids: activitesIds,
        cout_total: coutTotal,
      });
      setMessage("Itinéraire sauvegardé !");
      navigate(`/groupes/${id}/panier`);
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <div style={styles.loading}>Chargement...</div>;

  return (
    <div style={styles.page}>
      <div style={styles.header}>
        <div>
          <button onClick={() => navigate(`/groupes/${id}/activites`)} style={styles.btnBack}>
            ← Activités
          </button>
          <h1 style={styles.title}>🗺️ Itinéraire</h1>
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
          <span
            onClick={() => navigate(`/groupes/${id}/activites`)}
            style={{ ...styles.stepDone, cursor: "pointer" }}
          >
            ✓ Activités
          </span>
          <span style={styles.stepArrow}>→</span>
          <span style={styles.stepActive}>4. Itinéraire</span>
        </div>
      </div>

      <div style={styles.body}>
        {message && <div style={styles.success}>{message}</div>}
        {error && <div style={styles.error}>{error}</div>}

        {/* Récapitulatif */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>Récapitulatif du voyage</h2>

          {/* Transport */}
          <div style={styles.ligne}>
            <div style={styles.ligneLeft}>
              <span style={styles.ligneIcon}>✈️</span>
              <div>
                <div style={styles.ligneTitle}>
                  {transport
                    ? `${transport.compagnie} — ${transport.origine} → ${transport.destination}`
                    : "Aucun transport sélectionné"}
                </div>
                {transport && (
                  <div style={styles.ligneSub}>
                    Aller-retour · {transport.places_dispo} places dispo
                  </div>
                )}
              </div>
            </div>
            <div style={styles.lignePrix}>
              {coutTransport > 0 ? `${coutTransport}€` : "—"}
            </div>
          </div>

          {/* Hébergement */}
          <div style={styles.ligne}>
            <div style={styles.ligneLeft}>
              <span style={styles.ligneIcon}>🏨</span>
              <div>
                <div style={styles.ligneTitle}>
                  {heb ? heb.nom : "Aucun hébergement sélectionné"}
                </div>
                {heb && (
                  <div style={styles.ligneSub}>
                    {heb.prix_nuit}€/nuit × {nbNuits} nuits
                  </div>
                )}
              </div>
            </div>
            <div style={styles.lignePrix}>
              {coutHeb > 0 ? `${coutHeb}€` : "—"}
            </div>
          </div>

          {/* Activités */}
          {activites.map((a) => (
            <div key={a.id} style={styles.ligne}>
              <div style={styles.ligneLeft}>
                <span style={styles.ligneIcon}>🎯</span>
                <div>
                  <div style={styles.ligneTitle}>{a.nom}</div>
                  <div style={styles.ligneSub}>
                    {a.duree_heures}h · {a.places_restantes} places restantes
                  </div>
                </div>
              </div>
              <div style={styles.lignePrix}>{a.prix}€</div>
            </div>
          ))}

          {activites.length === 0 && (
            <div style={styles.ligne}>
              <div style={styles.ligneLeft}>
                <span style={styles.ligneIcon}>🎯</span>
                <div style={styles.ligneTitle}>
                  Aucune activité sélectionnée
                </div>
              </div>
              <div style={styles.lignePrix}>—</div>
            </div>
          )}

          {/* Séparateur */}
          <div style={styles.sep}></div>

          {/* Total */}
          <div style={styles.totalRow}>
            <div style={styles.totalLabel}>Total par personne</div>
            <div style={styles.totalPrix}>{coutTotal.toFixed(0)}€</div>
          </div>

          {/* Budget */}
          {budgetMax && (
            <div
              style={{
                ...styles.budgetRow,
                background: budgetDepasse ? "#FCEBEB" : "#EAF3DE",
                color: budgetDepasse ? "#A32D2D" : "#3B6D11",
              }}
            >
              {budgetDepasse
                ? `⚠️ Budget dépassé : ${coutTotal.toFixed(0)}€ > ${budgetMax}€ (dépassement de ${(coutTotal - budgetMax).toFixed(0)}€)`
                : `✓ Dans le budget : ${coutTotal.toFixed(0)}€ / ${budgetMax}€ max`}
            </div>
          )}
        </div>

        {/* Groupe */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>👥 Répartition par membre</h2>
          <div style={styles.memberList}>
            {groupe?.membres
              ?.filter((m) => m.statut === "accepte")
              .map((m) => (
                <div key={m.id} style={styles.memberRow}>
                  <div style={styles.avatar}>{m.nom.charAt(0)}</div>
                  <div style={styles.memberName}>{m.nom}</div>
                  <div style={styles.memberPrix}>{coutTotal.toFixed(0)}€</div>
                </div>
              ))}
          </div>
          <div style={styles.totalGroupe}>
            Total groupe :{" "}
            <strong>{(coutTotal * nbMembres).toFixed(0)}€</strong>
          </div>
        </div>

        {/* Bouton */}
        <button
          onClick={handleSave}
          disabled={saving || budgetDepasse}
          style={{
            ...styles.btnSave,
            opacity: saving || budgetDepasse ? 0.6 : 1,
            cursor: saving || budgetDepasse ? "not-allowed" : "pointer",
          }}
        >
          {saving
            ? "Sauvegarde..."
            : budgetDepasse
              ? "⚠️ Budget dépassé — ajustez l'itinéraire"
              : "Valider l'itinéraire → Panier"}
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
  error: {
    background: "#FCEBEB",
    color: "#A32D2D",
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
    marginBottom: "16px",
  },
  ligne: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    padding: "10px 0",
    borderBottom: "1px solid #F5F4F0",
    gap: "12px",
  },
  ligneLeft: { display: "flex", alignItems: "center", gap: "12px", flex: 1 },
  ligneIcon: { fontSize: "20px", flexShrink: 0 },
  ligneTitle: { fontSize: "14px", fontWeight: "500", color: "#2C2C2A" },
  ligneSub: { fontSize: "12px", color: "#73726c", marginTop: "2px" },
  lignePrix: {
    fontSize: "15px",
    fontWeight: "bold",
    color: "#0C447C",
    flexShrink: 0,
  },
  sep: { borderTop: "2px solid #E0DED6", margin: "12px 0" },
  totalRow: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    padding: "4px 0",
  },
  totalLabel: { fontSize: "16px", fontWeight: "bold", color: "#2C2C2A" },
  totalPrix: { fontSize: "24px", fontWeight: "bold", color: "#0C447C" },
  budgetRow: {
    padding: "10px 14px",
    borderRadius: "8px",
    fontSize: "13px",
    marginTop: "10px",
    fontWeight: "500",
  },
  memberList: {
    display: "flex",
    flexDirection: "column",
    gap: "8px",
    marginBottom: "12px",
  },
  memberRow: { display: "flex", alignItems: "center", gap: "10px" },
  avatar: {
    width: "30px",
    height: "30px",
    borderRadius: "50%",
    background: "#185FA5",
    color: "white",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "13px",
    fontWeight: "bold",
  },
  memberName: { flex: 1, fontSize: "14px", color: "#2C2C2A" },
  memberPrix: { fontSize: "14px", fontWeight: "bold", color: "#0C447C" },
  totalGroupe: {
    fontSize: "13px",
    color: "#73726c",
    borderTop: "1px solid #F5F4F0",
    paddingTop: "10px",
  },
  btnSave: {
    background: "#185FA5",
    color: "white",
    border: "none",
    padding: "14px",
    borderRadius: "8px",
    fontSize: "15px",
    fontWeight: "bold",
    width: "100%",
  },
};
