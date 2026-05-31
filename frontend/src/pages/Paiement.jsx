import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { api } from "../services/api";
import { useAuth } from "../context/AuthContext";
import { groupService } from "../services/group.service";
import PageHeader from "../components/PageHeader";

export default function Paiement() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();

  const [itineraire, setItineraire] = useState(null);
  const [groupe, setGroupe] = useState(null);
  const [loading, setLoading] = useState(true);
  const [paying, setPaying] = useState(false);
  const [confirmation, setConfirmation] = useState(null);
  const [error, setError] = useState("");

  // Formulaire carte
  const [cardNumber, setCardNumber] = useState("");
  const [expiry, setExpiry] = useState("");
  const [cvc, setCvc] = useState("");
  const [titular, setTitular] = useState("");

  useEffect(() => {
    Promise.all([
      api.get(`/api/itineraires/groupe/${id}`),
      groupService.getOne(id),
    ])
      .then(([itin, g]) => {
        setItineraire(itin);
        setGroupe(g);
        setTitular(user?.nom || "");
      })
      .catch(() => setError("Impossible de charger les informations."))
      .finally(() => setLoading(false));
  }, [id]);

  // Formater le numéro de carte : XXXX XXXX XXXX XXXX
  const handleCardNumber = (e) => {
    const raw = e.target.value.replace(/\D/g, "").slice(0, 16);
    const formatted = raw.match(/.{1,4}/g)?.join(" ") || raw;
    setCardNumber(formatted);
  };

  // Formater l'expiration : MM/AA
  const handleExpiry = (e) => {
    const raw = e.target.value.replace(/\D/g, "").slice(0, 4);
    if (raw.length >= 3) {
      setExpiry(raw.slice(0, 2) + "/" + raw.slice(2));
    } else {
      setExpiry(raw);
    }
  };

  const handleCvc = (e) => {
    setCvc(e.target.value.replace(/\D/g, "").slice(0, 3));
  };

  const isFormValid = () =>
    titular.trim().length > 0 &&
    cardNumber.replace(/\s/g, "").length === 16 &&
    expiry.length === 5 &&
    cvc.length === 3;

  const handlePay = async (e) => {
    e.preventDefault();
    if (!isFormValid()) return;
    setPaying(true);
    setError("");
    try {
      const res = await api.post("/api/reservations", { groupe_id: id });
      setConfirmation(res);
    } catch (err) {
      setError(err.message || "Erreur lors du paiement.");
    } finally {
      setPaying(false);
    }
  };

  if (loading) return <div style={styles.loading}>Chargement...</div>;

  const nbMembres =
    groupe?.membres?.filter((m) => m.statut === "accepte").length || 1;
  const montantTotal = itineraire
    ? (parseFloat(itineraire.cout_total) * nbMembres).toFixed(0)
    : "0";

  // ── Écran de confirmation ────────────────────────────────────────────────────
  if (confirmation) {
    return (
      <div style={styles.page}>
        <PageHeader title="✅ Réservation confirmée !" subtitle={groupe?.nom} />
        <div style={styles.body}>
          <div style={styles.confirmBox}>
            <div style={styles.confirmIcon}>🎉</div>
            <h2 style={styles.confirmTitle}>Votre voyage est réservé !</h2>
            <div style={styles.refBox}>
              <span style={styles.refLabel}>Référence de réservation</span>
              <span style={styles.refValue}>{confirmation.reference}</span>
            </div>
            <div style={styles.confirmDetails}>
              <div style={styles.confirmRow}>
                <span>Montant total payé</span>
                <strong>{montantTotal}€</strong>
              </div>
              <div style={styles.confirmRow}>
                <span>Par personne</span>
                <strong>{parseFloat(itineraire.cout_total).toFixed(0)}€</strong>
              </div>
              <div style={styles.confirmRow}>
                <span>Voyageurs</span>
                <strong>{nbMembres} membre{nbMembres > 1 ? "s" : ""}</strong>
              </div>
            </div>
            <p style={styles.confirmNote}>
              Une notification a été envoyée à tous les membres du groupe.
            </p>
            <div style={styles.confirmActions}>
              <button
                onClick={() => navigate(`/groupes/${id}`)}
                style={styles.btnPrimary}
              >
                Voir le groupe
              </button>
              <button
                onClick={() => navigate("/dashboard")}
                style={styles.btnSecondary}
              >
                Tableau de bord
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ── Formulaire de paiement ───────────────────────────────────────────────────
  return (
    <div style={styles.page}>
      <PageHeader
        title="🔒 Paiement sécurisé"
        subtitle={groupe?.nom}
        backLabel="Retour au panier"
        backTo={`/groupes/${id}/panier`}
        right={
          <span style={styles.montantBadge}>{montantTotal}€ total</span>
        }
      />

      <div style={styles.body}>
        {error && <div style={styles.errorBox}>{error}</div>}

        <div style={styles.layout}>
          {/* Formulaire carte */}
          <form onSubmit={handlePay} style={styles.formSection}>
            <h2 style={styles.sectionTitle}>Informations de paiement</h2>

            {/* Titular */}
            <div style={styles.field}>
              <label style={styles.label}>Titulaire de la carte</label>
              <input
                style={styles.input}
                type="text"
                placeholder="Jean Dupont"
                value={titular}
                onChange={(e) => setTitular(e.target.value)}
                required
              />
            </div>

            {/* Numéro de carte */}
            <div style={styles.field}>
              <label style={styles.label}>Numéro de carte</label>
              <div style={styles.cardInputWrapper}>
                <input
                  style={{ ...styles.input, letterSpacing: "2px" }}
                  type="text"
                  placeholder="4242 4242 4242 4242"
                  value={cardNumber}
                  onChange={handleCardNumber}
                  maxLength={19}
                  required
                />
                <span style={styles.cardIcons}>💳</span>
              </div>
            </div>

            {/* Expiration + CVC */}
            <div style={styles.row}>
              <div style={{ ...styles.field, flex: 1 }}>
                <label style={styles.label}>Date d'expiration</label>
                <input
                  style={styles.input}
                  type="text"
                  placeholder="MM/AA"
                  value={expiry}
                  onChange={handleExpiry}
                  maxLength={5}
                  required
                />
              </div>
              <div style={{ ...styles.field, flex: 1 }}>
                <label style={styles.label}>CVC</label>
                <input
                  style={styles.input}
                  type="text"
                  placeholder="123"
                  value={cvc}
                  onChange={handleCvc}
                  maxLength={3}
                  required
                />
              </div>
            </div>

            {/* Badges sécurité */}
            <div style={styles.securityBadges}>
              <span style={styles.secBadge}>🔐 SSL</span>
              <span style={styles.secBadge}>✅ 3D Secure</span>
              <span style={styles.secBadge}>🏦 Simulation pédagogique</span>
            </div>

            <button
              type="submit"
              disabled={paying || !isFormValid()}
              style={{
                ...styles.btnPay,
                opacity: paying || !isFormValid() ? 0.6 : 1,
                cursor: paying || !isFormValid() ? "not-allowed" : "pointer",
              }}
            >
              {paying ? "Traitement en cours..." : `Payer ${montantTotal}€`}
            </button>

            <p style={styles.cancelLink}>
              <span
                onClick={() => navigate(`/groupes/${id}/panier`)}
                style={{ cursor: "pointer", color: "#185FA5", fontSize: "13px" }}
              >
                ← Retour au panier
              </span>
            </p>
          </form>

          {/* Récapitulatif commande */}
          <div style={styles.summarySection}>
            <h2 style={styles.sectionTitle}>Récapitulatif</h2>

            {itineraire?.compagnie && (
              <div style={styles.summaryRow}>
                <span>✈️ {itineraire.compagnie}</span>
                <span>{itineraire.transport_prix}€</span>
              </div>
            )}
            {itineraire?.heb_nom && (
              <div style={styles.summaryRow}>
                <span>🏨 {itineraire.heb_nom}</span>
                <span>{itineraire.prix_nuit}€/nuit</span>
              </div>
            )}
            {itineraire?.activites?.map((a) => (
              <div key={a.id} style={styles.summaryRow}>
                <span>🎯 {a.nom}</span>
                <span>{a.prix}€</span>
              </div>
            ))}

            <div style={styles.summarySep} />

            <div style={styles.summaryRow}>
              <span style={{ color: "#73726c" }}>Par personne</span>
              <strong>{parseFloat(itineraire?.cout_total || 0).toFixed(0)}€</strong>
            </div>
            <div style={styles.summaryRow}>
              <span style={{ color: "#73726c" }}>× {nbMembres} voyageur{nbMembres > 1 ? "s" : ""}</span>
              <strong style={{ color: "#0C447C", fontSize: "22px" }}>{montantTotal}€</strong>
            </div>

            {/* Carte de démo */}
            <div style={styles.demoCard}>
              <div style={styles.demoCardTop}>
                <span style={styles.demoCardLabel}>Carte de test</span>
                <span>💳</span>
              </div>
              <div style={styles.demoCardNumber}>4242 4242 4242 4242</div>
              <div style={styles.demoCardBottom}>
                <span>MM/AA : 12/26</span>
                <span>CVC : 123</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

const styles = {
  page: { fontFamily: "Arial, sans-serif", minHeight: "100vh", background: "#F5F4F0" },
  loading: { textAlign: "center", padding: "60px", color: "#73726c" },
  montantBadge: {
    background: "rgba(255,255,255,0.15)", color: "white",
    padding: "6px 14px", borderRadius: "20px", fontSize: "14px", fontWeight: "700",
  },
  body: { padding: "24px 32px", maxWidth: "900px", margin: "0 auto" },
  errorBox: {
    background: "#FCEBEB", color: "#A32D2D", padding: "12px 16px",
    borderRadius: "8px", marginBottom: "16px", fontSize: "14px",
  },
  layout: { display: "grid", gridTemplateColumns: "1fr 360px", gap: "20px", alignItems: "start" },
  formSection: {
    background: "white", borderRadius: "12px", padding: "24px",
    boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
  },
  summarySection: {
    background: "white", borderRadius: "12px", padding: "24px",
    boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
  },
  sectionTitle: { fontSize: "15px", fontWeight: "bold", color: "#0C447C", marginBottom: "20px" },
  field: { marginBottom: "16px" },
  label: { display: "block", fontSize: "13px", fontWeight: "600", color: "#2C2C2A", marginBottom: "6px" },
  input: {
    width: "100%", padding: "11px 14px", borderRadius: "8px",
    border: "1.5px solid #D1CFC5", fontSize: "14px",
    outline: "none", boxSizing: "border-box",
    transition: "border-color 0.2s",
  },
  cardInputWrapper: { position: "relative" },
  cardIcons: { position: "absolute", right: "12px", top: "50%", transform: "translateY(-50%)", fontSize: "18px" },
  row: { display: "flex", gap: "12px" },
  securityBadges: { display: "flex", gap: "8px", flexWrap: "wrap", margin: "16px 0" },
  secBadge: {
    background: "#F5F4F0", padding: "4px 10px", borderRadius: "20px",
    fontSize: "11px", color: "#73726c", fontWeight: "500",
  },
  btnPay: {
    background: "#185FA5", color: "white", border: "none",
    padding: "14px", borderRadius: "10px", fontSize: "16px",
    fontWeight: "bold", width: "100%",
    boxShadow: "0 4px 12px rgba(24,95,165,0.3)",
  },
  cancelLink: { textAlign: "center", marginTop: "12px" },
  summaryRow: {
    display: "flex", justifyContent: "space-between", alignItems: "center",
    padding: "8px 0", fontSize: "14px", color: "#2C2C2A",
    borderBottom: "1px solid #F5F4F0",
  },
  summarySep: { borderTop: "2px solid #E0DED6", margin: "12px 0" },
  demoCard: {
    marginTop: "20px", background: "linear-gradient(135deg, #0C447C, #185FA5)",
    borderRadius: "12px", padding: "16px", color: "white",
  },
  demoCardTop: { display: "flex", justifyContent: "space-between", marginBottom: "16px", fontSize: "11px", opacity: 0.8 },
  demoCardLabel: { fontWeight: "600", textTransform: "uppercase", letterSpacing: "1px" },
  demoCardNumber: { fontSize: "18px", letterSpacing: "3px", fontWeight: "bold", marginBottom: "12px" },
  demoCardBottom: { display: "flex", justifyContent: "space-between", fontSize: "12px", opacity: 0.9 },
  // Confirmation
  confirmBox: {
    background: "white", borderRadius: "12px", padding: "48px 32px",
    textAlign: "center", boxShadow: "0 2px 6px rgba(0,0,0,0.06)", maxWidth: "500px", margin: "0 auto",
  },
  confirmIcon: { fontSize: "56px", marginBottom: "16px" },
  confirmTitle: { fontSize: "24px", color: "#2E7D32", marginBottom: "24px" },
  refBox: {
    background: "#EAF3DE", borderRadius: "10px", padding: "16px 24px",
    marginBottom: "24px", display: "flex", flexDirection: "column", gap: "4px",
  },
  refLabel: { fontSize: "12px", color: "#3B6D11", textTransform: "uppercase", letterSpacing: "1px" },
  refValue: { fontSize: "22px", fontWeight: "bold", color: "#2E7D32", letterSpacing: "2px" },
  confirmDetails: { textAlign: "left", marginBottom: "20px" },
  confirmRow: {
    display: "flex", justifyContent: "space-between",
    padding: "8px 0", borderBottom: "1px solid #F5F4F0", fontSize: "14px", color: "#444",
  },
  confirmNote: { fontSize: "13px", color: "#73726c", marginBottom: "24px" },
  confirmActions: { display: "flex", gap: "12px", justifyContent: "center" },
  btnPrimary: {
    background: "#185FA5", color: "white", border: "none",
    padding: "12px 24px", borderRadius: "8px", cursor: "pointer",
    fontSize: "14px", fontWeight: "bold",
  },
  btnSecondary: {
    background: "white", color: "#185FA5", border: "1px solid #185FA5",
    padding: "12px 24px", borderRadius: "8px", cursor: "pointer", fontSize: "14px",
  },
};
