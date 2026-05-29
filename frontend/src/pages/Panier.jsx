import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { api } from "../services/api";
import { groupService } from "../services/group.service";

export default function Panier() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [itineraire, setItineraire] = useState(null);
  const [groupe, setGroupe] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [annulation, setAnnulation] = useState("");

  useEffect(() => {
    Promise.all([
      api.get(`/api/itineraires/groupe/${id}`),
      groupService.getOne(id),
    ])
      .then(([itin, g]) => {
        setItineraire(itin);
        setGroupe(g);
      })
      .catch(() => setError("Impossible de charger le panier."))
      .finally(() => setLoading(false));
  }, [id]);

  if (loading) return <div style={styles.loading}>Chargement...</div>;

  if (error || !itineraire) {
    return (
      <div style={styles.page}>
        <div style={styles.header}>
          <h1 style={styles.title}>🛒 Panier</h1>
        </div>
        <div style={styles.body}>
          <div style={styles.emptyBox}>
            <div style={styles.emptyIcon}>🧳</div>
            <h2 style={styles.emptyTitle}>Aucun itinéraire trouvé</h2>
            <p style={styles.emptyText}>
              Composez d'abord votre voyage avant d'accéder au panier.
            </p>
            <button
              onClick={() => navigate(`/groupes/${id}/transport`)}
              style={styles.btnPrimary}
            >
              Composer mon voyage →
            </button>
          </div>
        </div>
      </div>
    );
  }

  const recharger = () => {
    api.get(`/api/itineraires/groupe/${id}`).then(setItineraire).catch(() => setItineraire(null));
  };

  const annulerTransport = async () => {
    if (!confirm("Annuler le transport sélectionné ?")) return;
    try {
      await api.delete(`/api/itineraires/groupe/${id}/transport`);
      setAnnulation("Transport annulé.");
      recharger();
    } catch (e) { setError(e.message); }
  };

  const retirerActivite = async (activiteId, nom) => {
    if (!confirm(`Retirer "${nom}" de l'itinéraire ?`)) return;
    try {
      await api.delete(`/api/itineraires/groupe/${id}/activites/${activiteId}`);
      setAnnulation(`"${nom}" retirée.`);
      recharger();
    } catch (e) { setError(e.message); }
  };

  const nbMembres =
    groupe?.membres?.filter((m) => m.statut === "accepte").length || 1;
  const nbNuits =
    groupe?.date_depart && groupe?.date_retour
      ? Math.ceil(
          (new Date(groupe.date_retour) - new Date(groupe.date_depart)) /
            (1000 * 60 * 60 * 24),
        )
      : 7;
  const totalGroupe = (parseFloat(itineraire.cout_total) * nbMembres).toFixed(0);

  return (
    <div style={styles.page}>
      {/* Header */}
      <div style={styles.header}>
        <div>
          <button onClick={() => navigate(`/groupes/${id}`)} style={styles.btnBack}>
            ← Retour au groupe
          </button>
          <h1 style={styles.title}>🛒 Panier de voyage</h1>
          <p style={styles.sub}>{groupe?.nom}</p>
        </div>
        <span style={styles.badge}>
          {nbMembres} voyageur{nbMembres > 1 ? "s" : ""}
        </span>
      </div>

      <div style={styles.body}>
        {annulation && <div style={styles.alertOk}>{annulation}</div>}
        {error && <div style={styles.alertErr}>{error}</div>}

        {/* Récapitulatif */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>Récapitulatif du voyage</h2>

          {/* Transport */}
          <div style={styles.item}>
            <div style={styles.itemLeft}>
              <span style={styles.itemIcon}>✈️</span>
              <div style={styles.itemInfo}>
                <div style={styles.itemName}>
                  {itineraire.compagnie
                    ? `${itineraire.compagnie} — ${itineraire.transport_dest}`
                    : "Aucun transport"}
                </div>
                {itineraire.compagnie && (
                  <div style={styles.itemSub}>Transport aller-retour · /pers</div>
                )}
              </div>
            </div>
            <div style={styles.itemRight}>
              <span style={styles.itemPrice}>
                {itineraire.transport_prix
                  ? `${itineraire.transport_prix}€`
                  : "—"}
              </span>
              <button
                onClick={() => navigate(`/groupes/${id}/transport`)}
                style={styles.btnModif}
              >
                Modifier
              </button>
              {itineraire.compagnie && (
                <button onClick={annulerTransport} style={styles.btnAnnuler}>
                  Annuler
                </button>
              )}
            </div>
          </div>

          {/* Hébergement */}
          <div style={styles.item}>
            <div style={styles.itemLeft}>
              <span style={styles.itemIcon}>🏨</span>
              <div style={styles.itemInfo}>
                <div style={styles.itemName}>
                  {itineraire.heb_nom || "Aucun hébergement"}
                </div>
                {itineraire.heb_nom && (
                  <div style={styles.itemSub}>
                    {itineraire.prix_nuit}€/nuit × {nbNuits} nuits
                  </div>
                )}
              </div>
            </div>
            <div style={styles.itemRight}>
              <span style={styles.itemPrice}>
                {itineraire.prix_nuit
                  ? `${(parseFloat(itineraire.prix_nuit) * nbNuits).toFixed(0)}€`
                  : "—"}
              </span>
              <button
                onClick={() => navigate(`/groupes/${id}/hebergement`)}
                style={styles.btnModif}
              >
                Modifier
              </button>
            </div>
          </div>

          {/* Activités */}
          {itineraire.activites?.length > 0 ? (
            itineraire.activites.map((a) => (
              <div key={a.id} style={styles.item}>
                <div style={styles.itemLeft}>
                  <span style={styles.itemIcon}>🎯</span>
                  <div style={styles.itemInfo}>
                    <div style={styles.itemName}>{a.nom}</div>
                    <div style={styles.itemSub}>{a.duree_heures}h · activité</div>
                  </div>
                </div>
                <div style={styles.itemRight}>
                  <span style={styles.itemPrice}>{a.prix}€</span>
                  <button onClick={() => retirerActivite(a.id, a.nom)} style={styles.btnAnnuler}>
                    Retirer
                  </button>
                </div>
              </div>
            ))
          ) : (
            <div style={styles.item}>
              <div style={styles.itemLeft}>
                <span style={styles.itemIcon}>🎯</span>
                <div style={styles.itemInfo}>
                  <div style={styles.itemName}>Aucune activité</div>
                </div>
              </div>
              <div style={styles.itemRight}>
                <button
                  onClick={() => navigate(`/groupes/${id}/activites`)}
                  style={styles.btnModif}
                >
                  Ajouter
                </button>
              </div>
            </div>
          )}

          {itineraire.activites?.length > 0 && (
            <div style={{ textAlign: "right", marginTop: "4px" }}>
              <button
                onClick={() => navigate(`/groupes/${id}/activites`)}
                style={styles.btnModif}
              >
                Modifier les activités
              </button>
            </div>
          )}

          {/* Séparateur + Total */}
          <div style={styles.sep} />
          <div style={styles.totalRow}>
            <span style={styles.totalLabel}>Total par personne</span>
            <span style={styles.totalPrice}>
              {parseFloat(itineraire.cout_total).toFixed(0)}€
            </span>
          </div>
        </div>

        {/* Membres + total groupe */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>👥 Voyageurs ({nbMembres})</h2>
          <div style={styles.memberList}>
            {groupe?.membres
              ?.filter((m) => m.statut === "accepte")
              .map((m) => (
                <div key={m.id} style={styles.memberRow}>
                  <div style={styles.avatar}>{m.nom.charAt(0).toUpperCase()}</div>
                  <span style={styles.memberName}>{m.nom}</span>
                  <span style={styles.memberPrice}>
                    {parseFloat(itineraire.cout_total).toFixed(0)}€
                  </span>
                </div>
              ))}
          </div>
          <div style={styles.totalGroupe}>
            <span>Total groupe</span>
            <strong style={{ color: "#0C447C", fontSize: "20px" }}>
              {totalGroupe}€
            </strong>
          </div>
        </div>

        {/* CTA */}
        <button
          onClick={() => navigate(`/groupes/${id}/paiement`)}
          style={styles.btnPay}
        >
          🔒 Procéder au paiement — {totalGroupe}€
        </button>

        <p style={styles.securityNote}>
          🔐 Paiement 100% sécurisé · Simulation pédagogique
        </p>
      </div>
    </div>
  );
}

const styles = {
  page: { fontFamily: "Arial, sans-serif", minHeight: "100vh", background: "#F5F4F0" },
  loading: { textAlign: "center", padding: "60px", color: "#73726c" },
  header: {
    background: "#0C447C", color: "white", padding: "28px 32px",
    display: "flex", justifyContent: "space-between", alignItems: "center",
  },
  title: { fontSize: "24px", fontWeight: "bold", marginBottom: "4px" },
  sub: { opacity: 0.8, fontSize: "13px" },
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
  badge: {
    background: "rgba(255,255,255,0.15)", padding: "6px 14px",
    borderRadius: "20px", fontSize: "13px", fontWeight: "600",
  },
  body: { padding: "24px 32px", display: "flex", flexDirection: "column", gap: "16px", maxWidth: "760px", margin: "0 auto" },
  emptyBox: {
    background: "white", borderRadius: "12px", padding: "48px 24px",
    textAlign: "center", boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
  },
  emptyIcon: { fontSize: "48px", marginBottom: "16px" },
  emptyTitle: { fontSize: "20px", color: "#0C447C", marginBottom: "8px" },
  emptyText: { color: "#73726c", fontSize: "14px", marginBottom: "24px" },
  section: {
    background: "white", borderRadius: "12px", padding: "20px 24px",
    boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
  },
  sectionTitle: { fontSize: "15px", fontWeight: "bold", color: "#0C447C", marginBottom: "16px" },
  item: {
    display: "flex", justifyContent: "space-between", alignItems: "center",
    padding: "12px 0", borderBottom: "1px solid #F5F4F0", gap: "12px",
  },
  itemLeft: { display: "flex", alignItems: "center", gap: "12px", flex: 1 },
  itemIcon: { fontSize: "22px", flexShrink: 0 },
  itemInfo: { flex: 1 },
  itemName: { fontSize: "14px", fontWeight: "500", color: "#2C2C2A" },
  itemSub: { fontSize: "12px", color: "#73726c", marginTop: "2px" },
  itemRight: { display: "flex", alignItems: "center", gap: "10px", flexShrink: 0 },
  itemPrice: { fontSize: "15px", fontWeight: "bold", color: "#0C447C" },
  alertOk: { background: "#EAF3DE", color: "#3B6D11", padding: "10px 14px", borderRadius: "8px", fontSize: "14px" },
  alertErr: { background: "#FCEBEB", color: "#A32D2D", padding: "10px 14px", borderRadius: "8px", fontSize: "14px" },
  btnAnnuler: {
    background: "#FCEBEB", color: "#A32D2D", border: "1px solid #F09595",
    padding: "5px 10px", borderRadius: "6px", cursor: "pointer",
    fontSize: "12px", fontWeight: "500", whiteSpace: "nowrap",
  },
  btnModif: {
    background: "white", color: "#185FA5", border: "1px solid #185FA5",
    padding: "5px 12px", borderRadius: "6px", cursor: "pointer",
    fontSize: "12px", fontWeight: "500", whiteSpace: "nowrap",
  },
  sep: { borderTop: "2px solid #E0DED6", margin: "14px 0" },
  totalRow: { display: "flex", justifyContent: "space-between", alignItems: "center" },
  totalLabel: { fontSize: "16px", fontWeight: "bold", color: "#2C2C2A" },
  totalPrice: { fontSize: "26px", fontWeight: "bold", color: "#0C447C" },
  memberList: { display: "flex", flexDirection: "column", gap: "10px", marginBottom: "14px" },
  memberRow: { display: "flex", alignItems: "center", gap: "10px" },
  avatar: {
    width: "32px", height: "32px", borderRadius: "50%", background: "#185FA5",
    color: "white", display: "flex", alignItems: "center", justifyContent: "center",
    fontSize: "13px", fontWeight: "bold", flexShrink: 0,
  },
  memberName: { flex: 1, fontSize: "14px", color: "#2C2C2A" },
  memberPrice: { fontSize: "14px", fontWeight: "bold", color: "#0C447C" },
  totalGroupe: {
    display: "flex", justifyContent: "space-between", alignItems: "center",
    borderTop: "2px solid #E0DED6", paddingTop: "12px",
    fontSize: "15px", color: "#73726c",
  },
  btnPay: {
    background: "#185FA5", color: "white", border: "none",
    padding: "16px", borderRadius: "10px", cursor: "pointer",
    fontSize: "16px", fontWeight: "bold", width: "100%",
    boxShadow: "0 4px 12px rgba(24,95,165,0.3)",
  },
  btnPrimary: {
    background: "#185FA5", color: "white", border: "none",
    padding: "12px 24px", borderRadius: "8px", cursor: "pointer",
    fontSize: "14px", fontWeight: "bold",
  },
  securityNote: { textAlign: "center", fontSize: "12px", color: "#999", margin: "0" },
};
