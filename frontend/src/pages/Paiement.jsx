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
  const [groupe,     setGroupe]     = useState(null);
  const [loading,    setLoading]    = useState(true);
  const [paying,     setPaying]     = useState(false);
  const [confirmation, setConfirmation] = useState(null);
  const [error,      setError]      = useState("");

  const [cardNumber, setCardNumber] = useState("");
  const [expiry,     setExpiry]     = useState("");
  const [cvc,        setCvc]        = useState("");
  const [titular,    setTitular]    = useState("");
  const [focused,    setFocused]    = useState(null);

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

  const handleCardNumber = (e) => {
    const raw = e.target.value.replace(/\D/g, "").slice(0, 16);
    setCardNumber(raw.match(/.{1,4}/g)?.join(" ") || raw);
  };

  const handleExpiry = (e) => {
    const raw = e.target.value.replace(/\D/g, "").slice(0, 4);
    setExpiry(raw.length >= 3 ? raw.slice(0, 2) + "/" + raw.slice(2) : raw);
  };

  const handleCvc = (e) => setCvc(e.target.value.replace(/\D/g, "").slice(0, 3));

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

  if (loading) return <div style={s.loading}>Chargement...</div>;

  const nbMembres     = groupe?.membres?.filter(m => m.statut === "accepte").length || 1;
  const montantParPers = parseFloat(itineraire?.cout_total || 0);
  const montantTotal  = (montantParPers * nbMembres).toFixed(0);

  // ── Écran de confirmation ────────────────────────────────────────────────
  if (confirmation) {
    const membres = groupe?.membres?.filter(m => m.statut === "accepte") || [];
    return (
      <div style={s.confirmPage}>
        {/* Héro gradient pleine largeur */}
        <div style={s.confirmHero}>
          <div style={s.confirmCheckRing}>
            <span style={s.confirmCheck}>✓</span>
          </div>
          <h1 style={s.confirmHeroTitle}>Voyage réservé !</h1>
          <p style={s.confirmHeroSub}>Tout est confirmé. Bon voyage à toute l'équipe 🎒</p>
        </div>

        {/* Carte flottante par-dessus le héro */}
        <div style={s.confirmOuter}>
          <div style={s.confirmCard}>

            {/* Référence */}
            <div style={s.refBlock}>
              <div style={s.refTopRow}>
                <span style={s.refLabel}>Référence de réservation</span>
                <span style={s.refBadge}>✓ Confirmée</span>
              </div>
              <div style={s.refValue}>{confirmation.reference}</div>
              <div style={s.refSub}>Conservez cette référence pour vos billets.</div>
            </div>

            {/* Montants */}
            <div style={s.amountsRow}>
              <div style={s.amountItem}>
                <div style={s.amountVal}>{montantParPers.toFixed(0)}€</div>
                <div style={s.amountLabel}>par personne</div>
              </div>
              <div style={s.amountDivider} />
              <div style={s.amountItem}>
                <div style={{ ...s.amountVal, fontSize: "30px", color: "#0C447C" }}>{montantTotal}€</div>
                <div style={s.amountLabel}>total groupe</div>
              </div>
              <div style={s.amountDivider} />
              <div style={s.amountItem}>
                <div style={s.amountVal}>{nbMembres}</div>
                <div style={s.amountLabel}>voyageur{nbMembres > 1 ? "s" : ""}</div>
              </div>
            </div>

            {/* Membres */}
            {membres.length > 0 && (
              <div style={s.membresBlock}>
                <div style={s.membresTitle}>Membres notifiés</div>
                <div style={s.membresRow}>
                  {membres.map((m, i) => (
                    <div key={m.id} style={{ ...s.membreAvatar, marginLeft: i === 0 ? 0 : -10, zIndex: membres.length - i }}>
                      {m.nom.charAt(0).toUpperCase()}
                    </div>
                  ))}
                  <span style={s.membresNames}>
                    {membres.map(m => m.nom.split(" ")[0]).join(", ")}
                  </span>
                </div>
              </div>
            )}

            {/* Notification */}
            <div style={s.infoRow}>
              <span>📧</span>
              <span>Une notification a été envoyée à tous les membres du groupe.</span>
            </div>

            {/* Actions */}
            <div style={s.confirmActions}>
              <button onClick={() => navigate(`/groupes/${id}`)} style={s.btnConfirmPrimary}>
                ✈️ Voir le groupe
              </button>
              <button onClick={() => navigate("/dashboard")} style={s.btnConfirmSecondary}>
                Tableau de bord
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ── Formulaire de paiement ───────────────────────────────────────────────
  const displayNumber  = cardNumber || "•••• •••• •••• ••••";
  const displayExpiry  = expiry || "MM/AA";
  const displayTitular = titular || "VOTRE NOM";

  return (
    <div style={s.page}>
      <PageHeader
        title="🔒 Paiement sécurisé"
        subtitle={groupe?.nom}
        backLabel="Retour au panier"
        backTo={`/groupes/${id}/panier`}
        right={
          <div style={s.montantBadge}>
            <span style={s.montantAmt}>{montantTotal}€</span>
            <span style={s.montantSub}>total groupe</span>
          </div>
        }
      />

      <div style={s.body}>
        {error && <div style={s.errorBox}>⚠️ {error}</div>}

        <div style={s.layout}>

          {/* ── Formulaire ── */}
          <form onSubmit={handlePay} style={s.formCard}>
            <h2 style={s.sectionTitle}>Informations de paiement</h2>

            {/* Prévisualisation carte */}
            <div style={s.cardPreview}>
              <div style={s.cardPreviewTop}>
                <div style={s.cardChip}>▬▬</div>
                <span style={{ fontSize: "22px" }}>💳</span>
              </div>
              <div style={{ ...s.cardNum, opacity: cardNumber ? 1 : 0.4 }}>
                {displayNumber}
              </div>
              <div style={s.cardPreviewBottom}>
                <div>
                  <div style={s.cardFieldLabel}>Titulaire</div>
                  <div style={{ ...s.cardFieldValue, opacity: titular ? 1 : 0.4 }}>
                    {displayTitular.toUpperCase()}
                  </div>
                </div>
                <div style={{ textAlign: "right" }}>
                  <div style={s.cardFieldLabel}>Expire</div>
                  <div style={{ ...s.cardFieldValue, opacity: expiry ? 1 : 0.4 }}>
                    {displayExpiry}
                  </div>
                </div>
              </div>
            </div>

            <div style={s.field}>
              <label style={s.label}>Titulaire de la carte</label>
              <input style={s.input} type="text" placeholder="Jean Dupont"
                value={titular} onChange={e => setTitular(e.target.value)}
                onFocus={() => setFocused("name")} onBlur={() => setFocused(null)} required />
            </div>

            <div style={s.field}>
              <label style={s.label}>Numéro de carte</label>
              <div style={{ position: "relative" }}>
                <input style={s.input} type="text" placeholder="4242 4242 4242 4242"
                  value={cardNumber} onChange={handleCardNumber}
                  onFocus={() => setFocused("number")} onBlur={() => setFocused(null)}
                  maxLength={19} required />
                <span style={s.inputRight}>💳</span>
              </div>
            </div>

            <div style={s.rowFields}>
              <div style={{ ...s.field, flex: 1 }}>
                <label style={s.label}>Expiration</label>
                <input style={s.input} type="text" placeholder="MM/AA"
                  value={expiry} onChange={handleExpiry}
                  onFocus={() => setFocused("expiry")} onBlur={() => setFocused(null)}
                  maxLength={5} required />
              </div>
              <div style={{ ...s.field, flex: 1 }}>
                <label style={s.label}>CVC</label>
                <input style={s.input} type="text" placeholder="123"
                  value={cvc} onChange={handleCvc}
                  onFocus={() => setFocused("cvc")} onBlur={() => setFocused(null)}
                  maxLength={3} required />
              </div>
            </div>

            <div style={s.secRow}>
              {["🔐 SSL", "✅ 3D Secure", "🏦 Simulation"].map((b, i) => (
                <span key={i} style={s.secBadge}>{b}</span>
              ))}
            </div>

            <button type="submit" disabled={paying || !isFormValid()} style={{
              ...s.btnPay,
              opacity: paying || !isFormValid() ? 0.55 : 1,
              cursor: paying || !isFormValid() ? "not-allowed" : "pointer",
            }}>
              {paying ? "⏳ Traitement en cours..." : `🔒 Payer ${montantTotal}€`}
            </button>

            <p style={{ textAlign: "center", marginTop: "12px" }}>
              <span onClick={() => navigate(`/groupes/${id}/panier`)}
                style={{ cursor: "pointer", color: "#185FA5", fontSize: "13px" }}>
                ← Retour au panier
              </span>
            </p>
          </form>

          {/* ── Récapitulatif ── */}
          <div style={s.summaryCard}>
            <h2 style={s.sectionTitle}>Récapitulatif</h2>

            <div style={s.summaryItems}>
              {itineraire?.compagnie && (
                <div style={s.summaryRow}>
                  <span>✈️ {itineraire.compagnie}</span>
                  <span style={s.summaryPrix}>{itineraire.transport_prix}€</span>
                </div>
              )}
              {itineraire?.heb_nom && (
                <div style={s.summaryRow}>
                  <span>🏨 {itineraire.heb_nom}</span>
                  <span style={s.summaryPrix}>{itineraire.prix_nuit}€/nuit</span>
                </div>
              )}
              {itineraire?.activites?.map(a => (
                <div key={a.id} style={s.summaryRow}>
                  <span>🎯 {a.nom}</span>
                  <span style={s.summaryPrix}>{a.prix}€</span>
                </div>
              ))}
            </div>

            <div style={s.summarySep} />

            <div style={s.summaryTotalRow}>
              <span style={{ fontSize: "13px", color: "#73726c" }}>Par personne</span>
              <span style={{ fontSize: "17px", fontWeight: "700", color: "#0C447C" }}>{montantParPers.toFixed(0)}€</span>
            </div>
            <div style={s.summaryGroup}>
              <span style={{ fontSize: "13px", color: "#185FA5" }}>× {nbMembres} voyageur{nbMembres > 1 ? "s" : ""}</span>
              <span style={{ fontSize: "26px", fontWeight: "800", color: "#0C447C" }}>{montantTotal}€</span>
            </div>

            {/* Carte de test */}
            <div style={s.testCard}>
              <div style={s.testCardHead}>
                <span style={{ fontSize: "12px", fontWeight: "700", color: "#0C447C" }}>🎓 Carte de test</span>
                <span style={{ fontSize: "11px", color: "#73726c" }}>Aucun paiement réel</span>
              </div>
              {[
                { k: "Numéro", v: "4242 4242 4242 4242" },
                { k: "Expire",  v: "12/26" },
                { k: "CVC",     v: "123" },
              ].map((f, i) => (
                <div key={i} style={s.testRow}>
                  <span style={{ fontSize: "11px", color: "#73726c" }}>{f.k}</span>
                  <code style={s.testVal}>{f.v}</code>
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
  // ── Page formulaire ──────────────────────────────────────────────────────
  page: {
    fontFamily: "Arial, sans-serif",
    minHeight: "100vh",
    backgroundImage: "linear-gradient(rgba(245,244,240,0.50), rgba(245,244,240,0.56)), url('/voyagevista-grouptrip/frontend/dist/images/destinations/5.jpg')",
    backgroundSize: "cover",
    backgroundAttachment: "fixed",
    backgroundPosition: "center",
  },
  loading: { textAlign: "center", padding: "60px", color: "#73726c" },

  montantBadge: { display: "flex", flexDirection: "column", alignItems: "flex-end" },
  montantAmt:   { fontSize: "20px", fontWeight: "800", color: "white" },
  montantSub:   { fontSize: "11px", color: "rgba(255,255,255,0.7)" },

  body:    { padding: "28px 32px 56px", maxWidth: "980px", margin: "0 auto" },
  errorBox:{ background: "#FCEBEB", color: "#A32D2D", padding: "12px 16px", borderRadius: "8px", marginBottom: "16px", fontSize: "14px" },

  layout:  { display: "grid", gridTemplateColumns: "1fr 300px", gap: "20px", alignItems: "start" },

  formCard: {
    background: "white", borderRadius: "16px",
    padding: "28px", boxShadow: "0 4px 20px rgba(0,0,0,0.10)",
  },
  summaryCard: {
    background: "white", borderRadius: "16px",
    padding: "24px", boxShadow: "0 4px 20px rgba(0,0,0,0.10)",
  },
  sectionTitle: { fontSize: "13px", fontWeight: "700", color: "#0C447C", textTransform: "uppercase", letterSpacing: "0.5px", marginBottom: "20px" },

  cardPreview: {
    background: "linear-gradient(135deg, #0C447C 0%, #1A7FC4 100%)",
    borderRadius: "14px", padding: "20px 22px",
    marginBottom: "22px", color: "white",
    boxShadow: "0 8px 24px rgba(12,68,124,0.3)",
    display: "flex", flexDirection: "column", gap: "10px",
    minHeight: "155px", justifyContent: "space-between",
  },
  cardPreviewTop:    { display: "flex", justifyContent: "space-between", alignItems: "center" },
  cardChip:          { background: "rgba(255,255,255,0.25)", borderRadius: "4px", padding: "3px 8px", fontSize: "11px", letterSpacing: "2px" },
  cardNum:           { fontSize: "17px", letterSpacing: "3px", fontWeight: "600", transition: "opacity 0.2s" },
  cardPreviewBottom: { display: "flex", justifyContent: "space-between" },
  cardFieldLabel:    { fontSize: "9px", textTransform: "uppercase", letterSpacing: "1px", opacity: 0.6, marginBottom: "3px" },
  cardFieldValue:    { fontSize: "13px", fontWeight: "600", transition: "opacity 0.2s" },

  field:      { marginBottom: "14px" },
  label:      { display: "block", fontSize: "12px", fontWeight: "700", color: "#444", marginBottom: "6px", textTransform: "uppercase", letterSpacing: "0.4px" },
  input:      { width: "100%", padding: "11px 14px", borderRadius: "10px", fontSize: "14px", border: "1.5px solid #E0DED6", boxSizing: "border-box", outline: "none", background: "#FAFAFA" },
  inputRight: { position: "absolute", right: "12px", top: "50%", transform: "translateY(-50%)", fontSize: "18px", pointerEvents: "none" },
  rowFields:  { display: "flex", gap: "12px" },

  secRow:    { display: "flex", gap: "6px", flexWrap: "wrap", margin: "4px 0 18px" },
  secBadge:  { background: "#F5F4F0", padding: "5px 10px", borderRadius: "20px", fontSize: "11px", color: "#73726c" },

  btnPay: {
    width: "100%", padding: "14px",
    background: "linear-gradient(135deg, #0C447C, #185FA5)",
    color: "white", border: "none", borderRadius: "10px",
    fontSize: "15px", fontWeight: "700",
    boxShadow: "0 4px 12px rgba(24,95,165,0.3)",
    transition: "opacity 0.2s",
  },

  summaryItems:    { display: "flex", flexDirection: "column" },
  summaryRow:      { display: "flex", justifyContent: "space-between", alignItems: "center", padding: "8px 0", borderBottom: "1px solid #F5F4F0", fontSize: "13px", color: "#2C2C2A" },
  summaryPrix:     { fontWeight: "600", color: "#0C447C" },
  summarySep:      { borderTop: "2px dashed #E0DED6", margin: "14px 0" },
  summaryTotalRow: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "8px" },
  summaryGroup:    { display: "flex", justifyContent: "space-between", alignItems: "center", background: "linear-gradient(135deg, #E6F1FB, #D4E8F5)", borderRadius: "10px", padding: "12px 14px", marginBottom: "18px" },

  testCard:     { background: "#F5F4F0", borderRadius: "10px", padding: "14px 16px", border: "1px dashed #D1CFC5" },
  testCardHead: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "10px" },
  testRow:      { display: "flex", justifyContent: "space-between", alignItems: "center", paddingBottom: "4px" },
  testVal:      { fontSize: "12px", fontWeight: "600", color: "#0C447C", background: "white", padding: "2px 8px", borderRadius: "4px" },

  // ── Page confirmation ────────────────────────────────────────────────────
  confirmPage: {
    fontFamily: "Arial, sans-serif",
    minHeight: "100vh",
    backgroundImage: "linear-gradient(rgba(245,244,240,0.50), rgba(245,244,240,0.56)), url('/voyagevista-grouptrip/frontend/dist/images/destinations/5.jpg')",
    backgroundSize: "cover",
    backgroundAttachment: "fixed",
    backgroundPosition: "center",
  },
  confirmHero: {
    background: "linear-gradient(135deg, rgba(12,68,124,0.92) 0%, rgba(26,127,196,0.92) 100%)",
    padding: "60px 32px 90px",
    textAlign: "center",
  },
  confirmCheckRing: {
    width: 72, height: 72, borderRadius: "50%",
    background: "rgba(255,255,255,0.15)",
    border: "3px solid rgba(255,255,255,0.45)",
    display: "flex", alignItems: "center", justifyContent: "center",
    margin: "0 auto 20px",
    boxShadow: "0 0 0 14px rgba(255,255,255,0.06)",
  },
  confirmCheck:     { fontSize: "32px", color: "white", fontWeight: "800" },
  confirmHeroTitle: { fontSize: "34px", fontWeight: "800", color: "white", margin: "0 0 10px", letterSpacing: "-0.5px" },
  confirmHeroSub:   { fontSize: "16px", color: "rgba(255,255,255,0.82)", margin: 0 },

  confirmOuter: {
    display: "flex",
    justifyContent: "center",
    padding: "0 24px 56px",
    marginTop: "-48px",
  },
  confirmCard: {
    background: "white",
    borderRadius: "20px",
    padding: "32px 36px",
    boxShadow: "0 12px 48px rgba(0,0,0,0.15)",
    width: "100%",
    maxWidth: "520px",
  },

  refBlock:  { background: "#F5F4F0", borderRadius: "14px", padding: "20px 22px", marginBottom: "22px", border: "1px solid #E0DED6" },
  refTopRow: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "8px" },
  refLabel:  { fontSize: "11px", fontWeight: "700", color: "#73726c", textTransform: "uppercase", letterSpacing: "0.8px" },
  refBadge:  { background: "#EAF3DE", color: "#3B6D11", fontSize: "11px", fontWeight: "700", padding: "3px 10px", borderRadius: "20px" },
  refValue:  { fontSize: "28px", fontWeight: "800", color: "#0C447C", letterSpacing: "4px", marginBottom: "6px", fontFamily: "monospace" },
  refSub:    { fontSize: "12px", color: "#73726c" },

  amountsRow:   { display: "flex", alignItems: "center", background: "linear-gradient(135deg, #E6F1FB, #D4E8F5)", borderRadius: "14px", padding: "20px", marginBottom: "22px" },
  amountItem:   { flex: 1, textAlign: "center" },
  amountVal:    { fontSize: "26px", fontWeight: "800", color: "#185FA5", lineHeight: 1 },
  amountLabel:  { fontSize: "11px", color: "#185FA5", marginTop: "4px", textTransform: "uppercase", letterSpacing: "0.3px" },
  amountDivider:{ width: 1, height: 40, background: "rgba(12,68,124,0.15)", flexShrink: 0 },

  membresBlock: { marginBottom: "20px" },
  membresTitle: { fontSize: "12px", fontWeight: "700", color: "#73726c", textTransform: "uppercase", letterSpacing: "0.4px", marginBottom: "10px" },
  membresRow:   { display: "flex", alignItems: "center", gap: "8px" },
  membreAvatar: {
    width: 34, height: 34, borderRadius: "50%",
    background: "linear-gradient(135deg, #0C447C, #185FA5)",
    color: "white", display: "flex", alignItems: "center",
    justifyContent: "center", fontSize: "13px", fontWeight: "800",
    border: "2px solid white", flexShrink: 0,
  },
  membresNames: { fontSize: "13px", color: "#444", marginLeft: "6px" },

  infoRow: {
    display: "flex", gap: "8px", alignItems: "flex-start",
    background: "#FFF8E6", border: "1px solid #F5DFA0",
    borderRadius: "10px", padding: "12px 14px",
    fontSize: "13px", color: "#854F0B", marginBottom: "22px",
  },

  confirmActions:       { display: "flex", gap: "10px" },
  btnConfirmPrimary:    { flex: 1, padding: "13px", background: "linear-gradient(135deg, #0C447C, #185FA5)", color: "white", border: "none", borderRadius: "10px", cursor: "pointer", fontSize: "14px", fontWeight: "700", boxShadow: "0 4px 12px rgba(12,68,124,0.25)" },
  btnConfirmSecondary:  { flex: 1, padding: "13px", background: "white", color: "#185FA5", border: "1.5px solid #D1CFC5", borderRadius: "10px", cursor: "pointer", fontSize: "14px", fontWeight: "600" },
};
