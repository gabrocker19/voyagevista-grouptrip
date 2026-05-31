import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { groupService } from "../services/group.service";
import { useAuth } from "../context/AuthContext";
import { api } from "../services/api";
import PageHeader from "../components/PageHeader";

export default function GroupDetail() {
  const { id } = useParams();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [groupe, setGroupe] = useState(null);
  const [loading, setLoading] = useState(true);
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [itineraire, setItineraire] = useState(null);
  const [destinationNom, setDestinationNom] = useState(null);
  const [confirmRefus, setConfirmRefus] = useState(false);

  useEffect(() => {
    Promise.all([
      groupService.getOne(id),
      api.get(`/api/itineraires/groupe/${id}`).catch(() => null),
    ])
      .then(([g, itin]) => {
        setGroupe(g);
        setItineraire(itin);
        if (g.destination_id) {
          api.get(`/api/destinations/${g.destination_id}`)
            .then((dest) => setDestinationNom(dest.nom))
            .catch(() => {});
        }
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [id]);

  const handleInvite = async (e) => {
    e.preventDefault();
    setMessage("");
    setError("");
    try {
      const res = await groupService.inviter(id, {
        email,
        groupe_nom: groupe.nom,
      });
      setMessage(res.message);
      setEmail("");
      groupService.getOne(id).then(setGroupe);
    } catch (err) {
      setError(err.message);
    }
  };

  if (loading) return <div style={styles.loading}>Chargement...</div>;
  if (!groupe) return <div style={styles.loading}>Groupe introuvable.</div>;

  const isOrganisateur = groupe.organisateur_id === user?.id;
  const monStatut = groupe.membres?.find((m) => m.id === user?.id)?.statut;
  const enAttente = monStatut === "en_attente";
  const destinationValidee = !!groupe.destination_id;
  // itineraireValide = le groupe a été passé en plan_valide (bouton "Valider → Panier" cliqué)
  const itineraireValide = groupe.statut === "plan_valide" || groupe.statut === "reservation_confirmee";

  const handleRepondreInvitation = async (statut) => {
    try {
      await groupService.rejoindre(id, statut);
      if (statut === "refuse") {
        setMessage("Invitation refusée. Vous allez être redirigé...");
        setTimeout(() => navigate("/dashboard"), 2000);
      } else {
        groupService.getOne(id).then(setGroupe);
      }
    } catch (err) {
      setError(err.message);
    }
  };

  const statutColors = {
    en_formation: { bg: "#FAEEDA", color: "#854F0B" },
    vote_en_cours: { bg: "#E6F1FB", color: "#185FA5" },
    plan_valide: { bg: "#EAF3DE", color: "#3B6D11" },
    reservation_confirmee: { bg: "#EAF3DE", color: "#3B6D11" },
  };
  const sc = statutColors[groupe.statut] || statutColors.en_formation;

  const transportChoisi   = !!itineraire?.transport_id;
  const hebergementChoisi = !!itineraire?.hebergement_id;
  const activitesChoisies = (itineraire?.activites?.length ?? 0) > 0;

  // Étapes dynamiques
  const etapes = [
    {
      emoji: "👥",
      label: "Former le groupe",
      done: true,
      action: null,
    },
    {
      emoji: "🗳️",
      label: "Voter pour la destination",
      done: destinationValidee,
      action: () => navigate(`/groupes/${id}/vote`),
    },
    {
      emoji: "✈️",
      label: "Choisir le transport",
      done: transportChoisi,
      action: destinationValidee ? () => navigate(`/groupes/${id}/transport`) : null,
    },
    {
      emoji: "🏨",
      label: "Choisir l'hébergement",
      done: hebergementChoisi,
      action: destinationValidee ? () => navigate(`/groupes/${id}/hebergement`) : null,
    },
    {
      emoji: "🎯",
      label: "Choisir les activités",
      done: activitesChoisies,
      action: destinationValidee ? () => navigate(`/groupes/${id}/activites`) : null,
    },
    {
      emoji: "🗺️",
      label: "Valider l'itinéraire",
      done: itineraireValide,
      action: (transportChoisi && hebergementChoisi)
        ? () => navigate(`/groupes/${id}/itineraire`)
        : null,
    },
    {
      emoji: "💳",
      label: "Valider et payer",
      done: groupe.statut === "reservation_confirmee",
      action: itineraireValide ? () => navigate(`/groupes/${id}/panier`) : null,
    },
  ];

  return (
    <div style={styles.page}>
      {confirmRefus && (
        <div style={styles.overlay} onClick={() => setConfirmRefus(false)}>
          <div style={styles.modal} onClick={e => e.stopPropagation()}>
            <h3 style={styles.modalTitle}>Refuser l'invitation ?</h3>
            <p style={{ color: "#444", fontSize: "14px", marginBottom: "20px" }}>
              Êtes-vous sûr de vouloir refuser l'invitation au voyage <strong>"{groupe.nom}"</strong> ?
              Vous ne pourrez plus accéder à ce groupe.
            </p>
            <div style={styles.modalActions}>
              <button style={styles.btnCancel} onClick={() => setConfirmRefus(false)}>
                Annuler
              </button>
              <button style={styles.btnConfirmRefus} onClick={() => { setConfirmRefus(false); handleRepondreInvitation("refuse"); }}>
                Refuser l'invitation
              </button>
            </div>
          </div>
        </div>
      )}

      <PageHeader
        title={groupe.nom}
        subtitle={<>Organisé par <strong>{groupe.organisateur_nom}</strong></>}
        backLabel="Mes voyages"
        backTo="/dashboard"
        right={
          <span style={{ ...styles.statut, background: sc.bg, color: sc.color }}>
            {groupe.statut.replace(/_/g, " ")}
          </span>
        }
      >
        {/* Barre stats en bas du gradient */}
        <div style={styles.headerStats}>
          <div style={styles.headerStat}>
            <span style={styles.headerStatVal}>{groupe.membres?.length || 0}</span>
            <span style={styles.headerStatLabel}>👥 Membres</span>
          </div>
          <div style={styles.headerStatDivider} />
          <div style={styles.headerStat}>
            <span style={styles.headerStatVal}>{groupe.budget_max ? `${groupe.budget_max}€` : "—"}</span>
            <span style={styles.headerStatLabel}>💶 Budget / pers.</span>
          </div>
          <div style={styles.headerStatDivider} />
          <div style={styles.headerStat}>
            <span style={styles.headerStatVal}>{groupe.date_depart || "—"}</span>
            <span style={styles.headerStatLabel}>📅 Départ</span>
          </div>
          <div style={styles.headerStatDivider} />
          <div style={styles.headerStat}>
            <span style={{ ...styles.headerStatVal, fontSize: destinationNom ? "13px" : "16px" }}>
              {destinationNom || (destinationValidee ? "✓" : "À voter")}
            </span>
            <span style={styles.headerStatLabel}>🌍 Destination</span>
          </div>
        </div>
      </PageHeader>

      <div style={styles.body}>
        {/* Bannière invitation en attente */}
        {enAttente && (
          <div style={styles.inviteBanner}>
            <div>
              <strong style={{ fontSize: "15px" }}>✉️ Vous avez été invité à rejoindre ce groupe</strong>
              <p style={{ margin: "4px 0 0", fontSize: "13px", opacity: 0.9 }}>
                Acceptez l'invitation pour participer à la planification du voyage.
              </p>
            </div>
            <div style={styles.inviteBtns}>
              <button onClick={() => handleRepondreInvitation("accepte")} style={styles.btnAccepter}>
                ✓ Accepter
              </button>
              <button onClick={() => setConfirmRefus(true)} style={styles.btnRefuser}>
                ✗ Refuser
              </button>
            </div>
          </div>
        )}

        {/* ── Étapes (cartes cliquables) ── */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>🗺️ Prochaines étapes</h2>
          <div style={styles.stepsGrid}>
            {etapes.map((step, i) => {
              const isActive = !step.done && !!step.action;
              const isLocked = !step.done && !step.action;
              return (
                <div
                  key={i}
                  onClick={step.action || undefined}
                  style={{
                    ...styles.stepCard,
                    ...(step.done  ? styles.stepCardDone   : {}),
                    ...(isActive   ? styles.stepCardActive  : {}),
                    ...(isLocked   ? styles.stepCardLocked  : {}),
                    cursor: step.action ? "pointer" : "default",
                  }}
                >
                  <div style={{ fontSize: "26px", marginBottom: "2px" }}>{step.emoji}</div>
                  <div style={{
                    ...styles.stepNum,
                    background: step.done ? "#3B6D11" : isActive ? "#185FA5" : "#C8C6BC",
                  }}>
                    {step.done ? "✓" : i + 1}
                  </div>
                  <div style={styles.stepCardLabel}>{step.label}</div>
                  {isActive && (
                    <div style={styles.stepCardCta}>
                      {i === 0 ? "Voir" : "Commencer →"}
                    </div>
                  )}
                  {step.done && step.action && (
                    <div style={styles.stepCardEdit}>Modifier</div>
                  )}
                  {isLocked && (
                    <div style={styles.stepCardLock}>🔒 En attente</div>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Itinéraire résumé si existe */}
        {itineraire && (
          <div style={styles.section}>
            <h2 style={styles.sectionTitle}>🗺️ Itinéraire actuel</h2>
            <div style={styles.itinRow}>
              <span>✈️ Transport</span>
              <span style={styles.itinVal}>
                {itineraire.compagnie ? `${itineraire.compagnie} — ${itineraire.transport_prix}€` : "Non sélectionné"}
              </span>
            </div>
            <div style={styles.itinRow}>
              <span>🏨 Hébergement</span>
              <span style={styles.itinVal}>
                {itineraire.heb_nom ? `${itineraire.heb_nom} — ${itineraire.prix_nuit}€/nuit` : "Non sélectionné"}
              </span>
            </div>
            <div style={styles.itinRow}>
              <span>🎯 Activités</span>
              <span style={styles.itinVal}>
                {itineraire.activites?.length > 0 ? `${itineraire.activites.length} activité(s)` : "Aucune"}
              </span>
            </div>
            <div style={{ ...styles.itinRow, borderTop: "2px solid #E0DED6", marginTop: "8px", paddingTop: "8px" }}>
              <span style={{ fontWeight: "bold" }}>Total / personne</span>
              <span style={{ fontWeight: "bold", color: "#0C447C", fontSize: "18px" }}>
                {itineraire.cout_total}€
              </span>
            </div>
          </div>
        )}

        {/* Membres */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>👥 Membres du groupe</h2>
          <div style={styles.memberList}>
            {groupe.membres?.map((m) => (
              <div key={m.id} style={styles.memberRow}>
                <div style={styles.avatar}>{m.nom.charAt(0).toUpperCase()}</div>
                <div style={styles.memberInfo}>
                  <div style={styles.memberName}>{m.nom}</div>
                  <div style={styles.memberEmail}>{m.email}</div>
                </div>
                <span style={{
                  ...styles.memberBadge,
                  background: m.role === "organisateur" ? "#E6F1FB" : "#F5F4F0",
                  color: m.role === "organisateur" ? "#0C447C" : "#73726c",
                }}>
                  {m.role}
                </span>
                <span style={{
                  ...styles.memberBadge,
                  background: m.statut === "accepte" ? "#EAF3DE" : m.statut === "en_attente" ? "#FAEEDA" : "#FCEBEB",
                  color: m.statut === "accepte" ? "#3B6D11" : m.statut === "en_attente" ? "#854F0B" : "#A32D2D",
                }}>
                  {m.statut}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Inviter */}
        {isOrganisateur && (
          <div style={styles.section}>
            <h2 style={styles.sectionTitle}>✉️ Inviter un membre</h2>
            {message && <div style={styles.success}>{message}</div>}
            {error && <div style={styles.error}>{error}</div>}
            <form onSubmit={handleInvite} style={styles.inviteForm}>
              <input
                style={styles.input}
                type="email"
                placeholder="Email de l'ami à inviter"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <button type="submit" style={styles.btnInvite}>Inviter</button>
            </form>
            <p style={styles.hint}>
              Comptes de test : aurelien@test.fr · brice@test.fr · isiah@test.fr
            </p>
          </div>
        )}
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
  inviteBanner: {
    background: "linear-gradient(135deg, #185FA5, #0C447C)",
    color: "white",
    borderRadius: "12px",
    padding: "20px 24px",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    gap: "16px",
    flexWrap: "wrap",
    boxShadow: "0 4px 12px rgba(24,95,165,0.3)",
  },
  inviteBtns: { display: "flex", gap: "10px", flexShrink: 0 },
  btnAccepter: {
    background: "#3B6D11", color: "white", border: "none",
    padding: "10px 20px", borderRadius: "8px", cursor: "pointer",
    fontSize: "14px", fontWeight: "bold",
  },
  btnRefuser: {
    background: "rgba(255,255,255,0.15)", color: "white",
    border: "1px solid rgba(255,255,255,0.4)",
    padding: "10px 20px", borderRadius: "8px", cursor: "pointer",
    fontSize: "14px",
  },
  statut: {
    padding: "6px 14px",
    borderRadius: "20px",
    fontSize: "12px",
    fontWeight: "600",
    whiteSpace: "nowrap",
    flexShrink: 0,
  },
  headerStats: {
    display: "flex",
    gap: "0",
    background: "rgba(0,0,0,0.18)",
    borderRadius: "12px 12px 0 0",
    overflow: "hidden",
    marginTop: "4px",
  },
  headerStat: {
    flex: 1,
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    padding: "14px 12px",
    gap: "4px",
  },
  headerStatVal: { fontSize: "16px", fontWeight: "700", color: "white" },
  headerStatLabel: { fontSize: "11px", color: "rgba(255,255,255,0.7)", whiteSpace: "nowrap" },
  headerStatDivider: { width: "1px", background: "rgba(255,255,255,0.15)", margin: "10px 0" },
  body: {
    padding: "24px 32px",
    display: "flex",
    flexDirection: "column",
    gap: "20px",
  },
  section: {
    background: "white",
    borderRadius: "12px",
    padding: "24px",
    boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
  },
  sectionTitle: {
    fontSize: "16px",
    fontWeight: "bold",
    color: "#0C447C",
    marginBottom: "16px",
  },
  itinRow: {
    display: "flex",
    justifyContent: "space-between",
    padding: "8px 0",
    borderBottom: "1px solid #F5F4F0",
    fontSize: "14px",
    color: "#444",
  },
  itinVal: { fontWeight: "500", color: "#0C447C" },
  memberList: { display: "flex", flexDirection: "column", gap: "10px" },
  memberRow: {
    display: "flex",
    alignItems: "center",
    gap: "12px",
    padding: "8px 0",
    borderBottom: "1px solid #F5F4F0",
  },
  avatar: {
    width: "36px",
    height: "36px",
    borderRadius: "50%",
    background: "#185FA5",
    color: "white",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontWeight: "bold",
    fontSize: "14px",
    flexShrink: 0,
  },
  memberInfo: { flex: 1 },
  memberName: { fontSize: "14px", fontWeight: "500", color: "#2C2C2A" },
  memberEmail: { fontSize: "12px", color: "#73726c" },
  memberBadge: {
    fontSize: "11px",
    padding: "3px 8px",
    borderRadius: "12px",
    fontWeight: "500",
  },
  inviteForm: { display: "flex", gap: "10px" },
  input: {
    flex: 1,
    padding: "10px 12px",
    borderRadius: "6px",
    border: "1px solid #D1CFC5",
    fontSize: "14px",
  },
  btnInvite: {
    background: "#185FA5",
    color: "white",
    border: "none",
    padding: "10px 20px",
    borderRadius: "6px",
    cursor: "pointer",
    fontSize: "14px",
    fontWeight: "500",
    whiteSpace: "nowrap",
  },
  hint: { fontSize: "12px", color: "#999", marginTop: "8px" },
  success: {
    background: "#EAF3DE",
    color: "#3B6D11",
    padding: "10px 14px",
    borderRadius: "6px",
    marginBottom: "12px",
    fontSize: "14px",
  },
  error: {
    background: "#FCEBEB",
    color: "#A32D2D",
    padding: "10px 14px",
    borderRadius: "6px",
    marginBottom: "12px",
    fontSize: "14px",
  },
  // Grille étapes
  stepsGrid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fill, minmax(130px, 1fr))",
    gap: "12px",
  },
  stepCard: {
    background: "#F5F4F0",
    border: "2px solid #E0DED6",
    borderRadius: "12px",
    padding: "18px 16px",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    textAlign: "center",
    gap: "10px",
    transition: "box-shadow 0.15s",
  },
  stepCardActive: {
    background: "#EBF3FC",
    border: "2px solid #185FA5",
    boxShadow: "0 4px 16px rgba(24,95,165,0.15)",
  },
  stepCardDone: {
    background: "#F0F7EA",
    border: "2px solid #84C257",
  },
  stepCardLocked: {
    opacity: 0.55,
  },
  stepNum: {
    width: "36px",
    height: "36px",
    borderRadius: "50%",
    color: "white",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "14px",
    fontWeight: "bold",
    flexShrink: 0,
  },
  stepCardLabel: {
    fontSize: "13px",
    fontWeight: "600",
    color: "#2C2C2A",
    lineHeight: "1.35",
  },
  stepCardCta: {
    marginTop: "auto",
    background: "#185FA5",
    color: "white",
    padding: "7px 16px",
    borderRadius: "8px",
    fontSize: "12px",
    fontWeight: "600",
    width: "100%",
  },
  stepCardEdit: {
    marginTop: "auto",
    background: "white",
    color: "#73726c",
    border: "1px solid #D1CFC5",
    padding: "6px 16px",
    borderRadius: "8px",
    fontSize: "12px",
    width: "100%",
  },
  stepCardLock: {
    marginTop: "auto",
    color: "#999",
    fontSize: "11px",
  },
  // Modale refus invitation
  overlay: {
    position: "fixed", inset: 0, background: "rgba(0,0,0,0.4)",
    display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1000,
  },
  modal: {
    background: "white", borderRadius: "14px", padding: "28px 32px",
    width: "100%", maxWidth: "420px", boxShadow: "0 8px 32px rgba(0,0,0,0.18)",
  },
  modalTitle: { fontSize: "17px", fontWeight: "bold", color: "#0C447C", marginBottom: "16px" },
  modalActions: { display: "flex", gap: "10px", justifyContent: "flex-end" },
  btnCancel: {
    padding: "9px 20px", borderRadius: "8px", border: "1px solid #D1CFC5",
    background: "white", color: "#444", cursor: "pointer", fontSize: "14px",
  },
  btnConfirmRefus: {
    padding: "9px 20px", borderRadius: "8px", border: "none",
    background: "#C0392B", color: "white", cursor: "pointer", fontSize: "14px", fontWeight: "bold",
  },
};
