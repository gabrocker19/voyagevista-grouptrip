import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { Link, useNavigate } from "react-router-dom";
import { groupService } from "../services/group.service";
import PageHeader from "../components/PageHeader";

export default function Dashboard() {
  const { user } = useAuth();
  const [groupes, setGroupes] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  const [editModal, setEditModal] = useState(null); // groupe en cours d'édition
  const [editNom, setEditNom] = useState("");
  const [editBudget, setEditBudget] = useState("");
  const [deleteConfirm, setDeleteConfirm] = useState(null); // groupe à supprimer
  const [actionError, setActionError] = useState("");

  useEffect(() => {
    groupService
      .getAll()
      .then(setGroupes)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const openEdit = (e, g) => {
    e.stopPropagation();
    setEditModal(g);
    setEditNom(g.nom);
    setEditBudget(g.budget_max || "");
    setActionError("");
  };

  const handleUpdate = async () => {
    if (!editNom.trim()) { setActionError("Le nom est requis."); return; }
    try {
      await groupService.update(editModal.id, { nom: editNom.trim(), budget_max: editBudget || null });
      setGroupes(groupes.map(g => g.id === editModal.id ? { ...g, nom: editNom.trim(), budget_max: editBudget || null } : g));
      setEditModal(null);
    } catch (err) {
      setActionError(err.message);
    }
  };

  const handleDelete = async () => {
    try {
      await groupService.delete(deleteConfirm.id);
      setGroupes(groupes.filter(g => g.id !== deleteConfirm.id));
      setDeleteConfirm(null);
    } catch (err) {
      setActionError(err.message);
    }
  };

  const statutColors = {
    en_formation: { bg: "#FAEEDA", color: "#854F0B", label: "En formation" },
    vote_en_cours: { bg: "#E6F1FB", color: "#185FA5", label: "Vote en cours" },
    plan_valide: { bg: "#EAF3DE", color: "#3B6D11", label: "Plan validé" },
    reservation_confirmee: {
      bg: "#EAF3DE",
      color: "#3B6D11",
      label: "Confirmé",
    },
  };

  return (
    <div style={styles.page}>
      {/* Modale modification */}
      {editModal && (
        <div style={styles.overlay} onClick={() => setEditModal(null)}>
          <div style={styles.modal} onClick={e => e.stopPropagation()}>
            <h3 style={styles.modalTitle}>Modifier le voyage</h3>
            {actionError && <p style={styles.modalError}>{actionError}</p>}
            <label style={styles.modalLabel}>Nom du voyage</label>
            <input
              style={styles.modalInput}
              value={editNom}
              onChange={e => setEditNom(e.target.value)}
              placeholder="Nom du voyage"
            />
            <label style={styles.modalLabel}>Budget max (€/pers.)</label>
            <input
              style={styles.modalInput}
              type="number"
              value={editBudget}
              onChange={e => setEditBudget(e.target.value)}
              placeholder="Ex : 1500"
            />
            <div style={styles.modalActions}>
              <button style={styles.btnCancel} onClick={() => setEditModal(null)}>Annuler</button>
              <button style={styles.btnSave} onClick={handleUpdate}>Enregistrer</button>
            </div>
          </div>
        </div>
      )}

      {/* Modale confirmation suppression */}
      {deleteConfirm && (
        <div style={styles.overlay} onClick={() => setDeleteConfirm(null)}>
          <div style={styles.modal} onClick={e => e.stopPropagation()}>
            <h3 style={styles.modalTitle}>Supprimer le voyage ?</h3>
            {actionError && <p style={styles.modalError}>{actionError}</p>}
            <p style={{ color: "#444", fontSize: "14px", marginBottom: "20px" }}>
              Êtes-vous sûr de vouloir supprimer <strong>"{deleteConfirm.nom}"</strong> ?
              Cette action est irréversible et supprimera tous les votes associés.
            </p>
            <div style={styles.modalActions}>
              <button style={styles.btnCancel} onClick={() => setDeleteConfirm(null)}>Annuler</button>
              <button style={styles.btnDelete} onClick={handleDelete}>Supprimer</button>
            </div>
          </div>
        </div>
      )}

      <PageHeader
        title={`Bonjour, ${user?.nom} 👋`}
        subtitle="Bienvenue sur votre espace GroupTrip"
        right={
          <button onClick={() => navigate("/groupes/creer")} style={styles.btnCreate}>
            + Nouveau GroupTrip
          </button>
        }
      />

      <div style={styles.body}>
        {/* Mes groupes */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>🌍 Mes voyages</h2>

          {loading ? (
            <p style={styles.empty}>Chargement...</p>
          ) : groupes.length === 0 ? (
            <div style={styles.emptyBox}>
              <div style={{ fontSize: "40px", marginBottom: "12px" }}>✈️</div>
              <p style={{ marginBottom: "16px", color: "#73726c" }}>
                Vous n'avez pas encore de voyage.
              </p>
              <button
                onClick={() => navigate("/groupes/creer")}
                style={styles.btnPrimary}
              >
                Créer mon premier GroupTrip
              </button>
            </div>
          ) : (
            <div style={styles.groupGrid}>
              {groupes.map((g) => {
                const sc = statutColors[g.statut] || statutColors.en_formation;
                return (
                  <div
                    key={g.id}
                    style={styles.groupCard}
                    onClick={() => navigate(`/groupes/${g.id}`)}
                  >
                    <div style={styles.groupCardTop}>
                      <div style={styles.groupIcon}>✈️</div>
                      <span
                        style={{
                          ...styles.badge,
                          background: sc.bg,
                          color: sc.color,
                        }}
                      >
                        {sc.label}
                      </span>
                    </div>
                    <h3 style={styles.groupName}>{g.nom}</h3>
                    <p style={styles.groupMeta}>
                      Organisé par {g.organisateur_nom}
                    </p>
                    {g.budget_max && (
                      <p style={styles.groupBudget}>
                        💶 Budget : {g.budget_max}€ / pers.
                      </p>
                    )}
                    <div style={styles.groupRole}>
                      <span
                        style={{
                          ...styles.roleBadge,
                          background:
                            g.mon_role === "organisateur"
                              ? "#E6F1FB"
                              : "#F5F4F0",
                          color:
                            g.mon_role === "organisateur"
                              ? "#0C447C"
                              : "#73726c",
                        }}
                      >
                        {g.mon_role === "organisateur"
                          ? "👑 Organisateur"
                          : "👤 Membre"}
                      </span>
                    </div>

                    {g.mon_role === "organisateur" && (
                      <div style={styles.cardActions} onClick={e => e.stopPropagation()}>
                        <button
                          style={styles.btnEdit}
                          onClick={e => openEdit(e, g)}
                        >
                          ✏️ Modifier
                        </button>
                        <button
                          style={styles.btnDeleteSmall}
                          onClick={e => { e.stopPropagation(); setActionError(""); setDeleteConfirm(g); }}
                        >
                          🗑️
                        </button>
                      </div>
                    )}
                  </div>
                );
              })}

              {/* Carte + créer */}
              <div
                style={styles.groupCardAdd}
                onClick={() => navigate("/groupes/creer")}
              >
                <div style={{ fontSize: "32px", marginBottom: "8px" }}>+</div>
                <p style={{ color: "#185FA5", fontWeight: "500" }}>
                  Nouveau voyage
                </p>
              </div>
            </div>
          )}
        </div>

        {/* Liens rapides */}
        <div style={styles.quickLinks}>
          <Link to="/catalogue" style={styles.quickLink}>
            🌍 Explorer les destinations
          </Link>
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
  btnCreate: {
    background: "white",
    color: "#0C447C",
    border: "none",
    padding: "10px 20px",
    borderRadius: "8px",
    cursor: "pointer",
    fontWeight: "bold",
    fontSize: "14px",
  },
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
  empty: { color: "#73726c", fontSize: "14px" },
  emptyBox: { textAlign: "center", padding: "32px" },
  btnPrimary: {
    background: "#185FA5",
    color: "white",
    border: "none",
    padding: "10px 24px",
    borderRadius: "8px",
    cursor: "pointer",
    fontSize: "14px",
    fontWeight: "500",
  },
  groupGrid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
    gap: "16px",
  },
  groupCard: {
    background: "#F5F4F0",
    borderRadius: "10px",
    padding: "18px",
    cursor: "pointer",
    transition: "box-shadow 0.2s",
    border: "1px solid #E0DED6",
  },
  groupCardAdd: {
    background: "#F5F4F0",
    borderRadius: "10px",
    padding: "18px",
    cursor: "pointer",
    border: "2px dashed #D1CFC5",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    minHeight: "140px",
  },
  groupCardTop: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: "10px",
  },
  groupIcon: { fontSize: "24px" },
  badge: {
    fontSize: "11px",
    padding: "3px 8px",
    borderRadius: "12px",
    fontWeight: "600",
  },
  groupName: {
    fontSize: "16px",
    fontWeight: "bold",
    color: "#0C447C",
    marginBottom: "4px",
  },
  groupMeta: { fontSize: "12px", color: "#73726c", marginBottom: "4px" },
  groupBudget: { fontSize: "12px", color: "#444", marginBottom: "8px" },
  groupRole: { marginTop: "8px" },
  roleBadge: { fontSize: "11px", padding: "3px 8px", borderRadius: "12px" },
  quickLinks: { display: "flex", gap: "12px" },
  quickLink: {
    background: "white",
    color: "#185FA5",
    padding: "12px 20px",
    borderRadius: "8px",
    textDecoration: "none",
    fontWeight: "500",
    boxShadow: "0 2px 6px rgba(0,0,0,0.06)",
    fontSize: "14px",
  },
  cardActions: { display: "flex", gap: "6px", marginTop: "10px" },
  btnEdit: {
    flex: 1, padding: "6px 10px", borderRadius: "6px",
    border: "1px solid #D1CFC5", background: "white",
    color: "#0C447C", cursor: "pointer", fontSize: "12px", fontWeight: "500",
  },
  btnDeleteSmall: {
    padding: "6px 10px", borderRadius: "6px",
    border: "1px solid #F5C6C6", background: "#FFF5F5",
    color: "#A32D2D", cursor: "pointer", fontSize: "12px",
  },
  // Modales
  overlay: {
    position: "fixed", inset: 0, background: "rgba(0,0,0,0.4)",
    display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1000,
  },
  modal: {
    background: "white", borderRadius: "14px", padding: "28px 32px",
    width: "100%", maxWidth: "420px", boxShadow: "0 8px 32px rgba(0,0,0,0.18)",
  },
  modalTitle: { fontSize: "17px", fontWeight: "bold", color: "#0C447C", marginBottom: "18px" },
  modalLabel: { display: "block", fontSize: "13px", fontWeight: "600", color: "#2C2C2A", marginBottom: "6px", marginTop: "12px" },
  modalInput: {
    width: "100%", padding: "10px 13px", borderRadius: "8px",
    border: "1.5px solid #D1CFC5", fontSize: "14px",
    boxSizing: "border-box", outline: "none",
  },
  modalError: { color: "#A32D2D", fontSize: "13px", marginBottom: "8px" },
  modalActions: { display: "flex", gap: "10px", marginTop: "22px", justifyContent: "flex-end" },
  btnCancel: {
    padding: "9px 20px", borderRadius: "8px", border: "1px solid #D1CFC5",
    background: "white", color: "#444", cursor: "pointer", fontSize: "14px",
  },
  btnSave: {
    padding: "9px 20px", borderRadius: "8px", border: "none",
    background: "#185FA5", color: "white", cursor: "pointer", fontSize: "14px", fontWeight: "bold",
  },
  btnDelete: {
    padding: "9px 20px", borderRadius: "8px", border: "none",
    background: "#C0392B", color: "white", cursor: "pointer", fontSize: "14px", fontWeight: "bold",
  },
};
