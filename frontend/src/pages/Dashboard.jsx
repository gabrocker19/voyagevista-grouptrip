import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { useNavigate } from "react-router-dom";
import { groupService } from "../services/group.service";
import PageHeader from "../components/PageHeader";

const STATUT_META = {
  en_formation:        { bg: "#FFF8E6", color: "#854F0B", border: "#F5DFA0", label: "En formation", dot: "#F0A500" },
  vote_en_cours:       { bg: "#E6F1FB", color: "#185FA5", border: "#C5DDF0", label: "Vote en cours", dot: "#185FA5" },
  plan_valide:         { bg: "#EAF3DE", color: "#3B6D11", border: "#B8DDA4", label: "Plan validé", dot: "#42A85A" },
  reservation_confirmee:{ bg: "#EAF3DE", color: "#2E7D32", border: "#B8DDA4", label: "Confirmé ✓", dot: "#2E7D32" },
};

const DESTINATION_EMOJIS = ["🏖️","🏔️","🗼","🌅","🏝️","🌍","🎡","🌸","🏯","🗺️"];
function getDestEmoji(id) { return DESTINATION_EMOJIS[id % DESTINATION_EMOJIS.length]; }

export default function Dashboard() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [groupes, setGroupes] = useState([]);
  const [loading, setLoading] = useState(true);

  const [editModal, setEditModal]         = useState(null);
  const [editNom, setEditNom]             = useState("");
  const [editBudget, setEditBudget]       = useState("");
  const [editDateDepart, setEditDateDepart] = useState("");
  const [editDateRetour, setEditDateRetour] = useState("");
  const [deleteConfirm, setDeleteConfirm] = useState(null);
  const [actionError, setActionError]     = useState("");
  const [saving, setSaving]               = useState(false);

  useEffect(() => {
    groupService.getAll()
      .then(setGroupes)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const openEdit = (e, g) => {
    e.stopPropagation();
    setEditModal(g);
    setEditNom(g.nom);
    setEditBudget(g.budget_max || "");
    setEditDateDepart(g.date_depart || "");
    setEditDateRetour(g.date_retour || "");
    setActionError("");
  };

  const handleUpdate = async () => {
    if (!editNom.trim()) { setActionError("Le nom est requis."); return; }
    if (editDateDepart && editDateRetour && editDateRetour <= editDateDepart) {
      setActionError("La date de retour doit être après la date de départ."); return;
    }
    setSaving(true);
    try {
      const payload = {
        nom: editNom.trim(),
        budget_max: editBudget || null,
        date_depart: editDateDepart || null,
        date_retour: editDateRetour || null,
      };
      await groupService.update(editModal.id, payload);
      setGroupes(groupes.map(g => g.id === editModal.id ? { ...g, ...payload } : g));
      setEditModal(null);
    } catch (err) {
      setActionError(err.message);
    } finally {
      setSaving(false);
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

  // Stats
  const mesGroupes   = groupes.filter(g => g.mon_role === "organisateur");
  const autresGroupes= groupes.filter(g => g.mon_role !== "organisateur");
  const confirmes    = groupes.filter(g => g.statut === "reservation_confirmee").length;

  const editNuits = editDateDepart && editDateRetour
    ? Math.round((new Date(editDateRetour) - new Date(editDateDepart)) / 86400000)
    : null;

  return (
    <div style={s.page}>
      {/* ── Modale édition ── */}
      {editModal && (
        <div style={s.overlay} onClick={() => setEditModal(null)}>
          <div style={s.modal} onClick={e => e.stopPropagation()}>
            <div style={s.modalHeader}>
              <h3 style={s.modalTitle}>Modifier le voyage</h3>
              <button onClick={() => setEditModal(null)} style={s.modalClose}>✕</button>
            </div>
            {actionError && <div style={s.modalError}>⚠️ {actionError}</div>}

            <div style={s.mField}>
              <label style={s.mLabel}>Nom du voyage</label>
              <input
                style={s.mInput}
                value={editNom}
                onChange={e => setEditNom(e.target.value)}
                placeholder="Nom du voyage"
                autoFocus
              />
            </div>
            <div style={s.mField}>
              <label style={s.mLabel}>Budget max (€ / pers.)</label>
              <input
                style={s.mInput}
                type="number"
                value={editBudget}
                onChange={e => setEditBudget(e.target.value)}
                placeholder="Ex : 1 500"
              />
            </div>

            <div style={s.mField}>
              <label style={s.mLabel}>Dates du voyage</label>
              <div style={s.mDatesRow}>
                <input
                  style={s.mInputDate}
                  type="date"
                  value={editDateDepart}
                  onChange={e => { setEditDateDepart(e.target.value); setEditDateRetour(""); }}
                />
                <span style={s.mArrow}>→</span>
                <input
                  style={s.mInputDate}
                  type="date"
                  min={editDateDepart || undefined}
                  value={editDateRetour}
                  onChange={e => setEditDateRetour(e.target.value)}
                  disabled={!editDateDepart}
                />
              </div>
            </div>

            {editNuits !== null && editNuits > 0 && (
              <div style={s.mNights}>
                🌙 {editNuits} nuit{editNuits > 1 ? "s" : ""}
              </div>
            )}

            <div style={s.mActions}>
              <button style={s.mBtnCancel} onClick={() => setEditModal(null)}>Annuler</button>
              <button
                style={{ ...s.mBtnSave, opacity: saving ? 0.7 : 1 }}
                onClick={handleUpdate}
                disabled={saving}
              >
                {saving ? "Enregistrement..." : "Enregistrer"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── Modale suppression ── */}
      {deleteConfirm && (
        <div style={s.overlay} onClick={() => setDeleteConfirm(null)}>
          <div style={s.modal} onClick={e => e.stopPropagation()}>
            <div style={s.modalHeader}>
              <h3 style={{ ...s.modalTitle, color: "#A32D2D" }}>🗑️ Supprimer le voyage ?</h3>
              <button onClick={() => setDeleteConfirm(null)} style={s.modalClose}>✕</button>
            </div>
            {actionError && <div style={s.modalError}>{actionError}</div>}
            <p style={s.deleteMsg}>
              Êtes-vous sûr de vouloir supprimer <strong>"{deleteConfirm.nom}"</strong> ?
              <br />Cette action est <strong>irréversible</strong> et supprimera tous les votes associés.
            </p>
            <div style={s.mActions}>
              <button style={s.mBtnCancel} onClick={() => setDeleteConfirm(null)}>Annuler</button>
              <button style={s.mBtnDelete} onClick={handleDelete}>Supprimer définitivement</button>
            </div>
          </div>
        </div>
      )}

      <PageHeader
        title={`Bonjour, ${user?.nom || "voyageur"} 👋`}
        subtitle="Votre espace VoyageVista GroupTrip"
        right={
          <button onClick={() => navigate("/groupes/creer")} style={s.btnCreate}>
            + Nouveau GroupTrip
          </button>
        }
      />

      <div style={s.body}>
        {/* Statistiques rapides */}
        {!loading && groupes.length > 0 && (
          <div style={s.statsRow}>
            {[
              { icon: "🌍", value: groupes.length, label: "voyage" + (groupes.length > 1 ? "s" : "") },
              { icon: "👑", value: mesGroupes.length, label: "organisé" + (mesGroupes.length > 1 ? "s" : "") },
              { icon: "👤", value: autresGroupes.length, label: "en tant que membre" },
              { icon: "✅", value: confirmes, label: "confirmé" + (confirmes > 1 ? "s" : "") },
            ].map((st, i) => (
              <div key={i} style={s.statCard}>
                <span style={s.statIcon}>{st.icon}</span>
                <div style={s.statValue}>{st.value}</div>
                <div style={s.statLabel}>{st.label}</div>
              </div>
            ))}
          </div>
        )}

        {/* Section voyages */}
        <div style={s.section}>
          <div style={s.sectionHead}>
            <h2 style={s.sectionTitle}>🌍 Mes voyages</h2>
            {groupes.length > 0 && (
              <span style={s.sectionCount}>{groupes.length}</span>
            )}
          </div>

          {loading ? (
            <div style={s.loadingGrid}>
              {[1,2,3].map(i => <div key={i} style={s.skeleton} />)}
            </div>
          ) : groupes.length === 0 ? (
            <div style={s.emptyBox}>
              <div style={s.emptyIllus}>✈️</div>
              <h3 style={s.emptyTitle}>Aucun voyage pour l'instant</h3>
              <p style={s.emptyText}>
                Créez votre premier GroupTrip et invitez vos amis à planifier ensemble.
              </p>
              <button onClick={() => navigate("/groupes/creer")} style={s.btnEmpty}>
                Créer mon premier GroupTrip →
              </button>
            </div>
          ) : (
            <div style={s.grid}>
              {groupes.map(g => {
                const meta = STATUT_META[g.statut] || STATUT_META.en_formation;
                const isOrga = g.mon_role === "organisateur";
                const nbNuits = g.date_depart && g.date_retour
                  ? Math.round((new Date(g.date_retour) - new Date(g.date_depart)) / 86400000)
                  : null;

                return (
                  <div
                    key={g.id}
                    style={s.card}
                    onClick={() => navigate(`/groupes/${g.id}`)}
                  >
                    {/* En-tête colorée */}
                    <div style={{ ...s.cardTop, background: `linear-gradient(135deg, ${meta.bg} 0%, white 100%)`, borderBottom: `1px solid ${meta.border}` }}>
                      <div style={s.cardTopLeft}>
                        <div style={s.cardEmoji}>{getDestEmoji(g.id)}</div>
                        <div style={{ ...s.statusDot, background: meta.dot }} />
                      </div>
                      <span style={{ ...s.statusBadge, background: meta.bg, color: meta.color, border: `1px solid ${meta.border}` }}>
                        {meta.label}
                      </span>
                    </div>

                    {/* Corps */}
                    <div style={s.cardBody}>
                      <h3 style={s.cardName}>{g.nom}</h3>

                      <div style={s.cardMeta}>
                        <span style={s.cardMetaItem}>
                          {isOrga ? "👑" : "👤"} {isOrga ? "Organisateur" : `Par ${g.organisateur_nom}`}
                        </span>
                      </div>

                      <div style={s.cardInfos}>
                        {g.budget_max && (
                          <div style={s.cardInfo}>
                            <span style={s.cardInfoIcon}>💶</span>
                            <span>{parseInt(g.budget_max).toLocaleString("fr-FR")}€ / pers.</span>
                          </div>
                        )}
                        {g.date_depart && (
                          <div style={s.cardInfo}>
                            <span style={s.cardInfoIcon}>📅</span>
                            <span>
                              {new Date(g.date_depart).toLocaleDateString("fr-FR", { day: "numeric", month: "short" })}
                              {g.date_retour && (
                                <> → {new Date(g.date_retour).toLocaleDateString("fr-FR", { day: "numeric", month: "short", year: "numeric" })}</>
                              )}
                              {nbNuits && <span style={s.nightPill}>{nbNuits}n</span>}
                            </span>
                          </div>
                        )}
                      </div>
                    </div>

                    {/* Footer actions */}
                    {isOrga && (
                      <div style={s.cardFooter} onClick={e => e.stopPropagation()}>
                        <button style={s.btnEdit} onClick={e => openEdit(e, g)}>
                          ✏️ Modifier
                        </button>
                        <button
                          style={s.btnDel}
                          onClick={e => { e.stopPropagation(); setActionError(""); setDeleteConfirm(g); }}
                        >
                          🗑️
                        </button>
                      </div>
                    )}

                    <div style={s.cardArrow}>›</div>
                  </div>
                );
              })}

              {/* Carte ajouter */}
              <div style={s.addCard} onClick={() => navigate("/groupes/creer")}>
                <div style={s.addIcon}>+</div>
                <p style={s.addLabel}>Nouveau voyage</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

const s = {
  page: { fontFamily: "Arial, sans-serif", minHeight: "100vh", backgroundImage: "linear-gradient(rgba(245,244,240,0.52), rgba(245,244,240,0.58)), url('/voyagevista-grouptrip/frontend/dist/images/autre/gettyimages-1164878594-612x612.jpg')", backgroundSize: "cover", backgroundAttachment: "fixed", backgroundPosition: "center" },
  btnCreate: {
    background: "rgba(255,255,255,0.15)", color: "white",
    border: "1px solid rgba(255,255,255,0.35)", padding: "10px 20px",
    borderRadius: "10px", cursor: "pointer",
    fontWeight: "700", fontSize: "14px",
    backdropFilter: "blur(6px)",
  },
  body: { padding: "24px 32px 48px", maxWidth: "1100px", margin: "0 auto", display: "flex", flexDirection: "column", gap: "20px" },

  // Stats
  statsRow: { display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: "12px" },
  statCard: {
    background: "white", borderRadius: "12px",
    padding: "16px 20px", textAlign: "center",
    boxShadow: "0 2px 8px rgba(0,0,0,0.05)",
    display: "flex", flexDirection: "column", alignItems: "center", gap: "2px",
  },
  statIcon: { fontSize: "22px", marginBottom: "4px" },
  statValue: { fontSize: "24px", fontWeight: "800", color: "#0C447C" },
  statLabel: { fontSize: "11px", color: "#73726c", textTransform: "uppercase", letterSpacing: "0.3px" },

  // Section
  section: {
    background: "white", borderRadius: "16px",
    padding: "24px", boxShadow: "0 2px 8px rgba(0,0,0,0.05)",
  },
  sectionHead: { display: "flex", alignItems: "center", gap: "10px", marginBottom: "20px" },
  sectionTitle: { fontSize: "16px", fontWeight: "800", color: "#0C447C", margin: 0 },
  sectionCount: {
    background: "#E6F1FB", color: "#185FA5",
    borderRadius: "20px", padding: "2px 10px",
    fontSize: "13px", fontWeight: "700",
  },

  // Skeleton
  loadingGrid: { display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))", gap: "14px" },
  skeleton: { height: "200px", borderRadius: "14px", background: "linear-gradient(90deg, #F0EEE8 0%, #E8E6DE 50%, #F0EEE8 100%)", backgroundSize: "200% 100%", animation: "shimmer 1.5s infinite" },

  // Empty
  emptyBox: { textAlign: "center", padding: "40px 24px" },
  emptyIllus: { fontSize: "52px", marginBottom: "14px" },
  emptyTitle: { fontSize: "18px", fontWeight: "700", color: "#0C447C", marginBottom: "8px" },
  emptyText: { fontSize: "14px", color: "#73726c", maxWidth: "340px", margin: "0 auto 20px", lineHeight: 1.6 },
  btnEmpty: {
    background: "linear-gradient(135deg, #0C447C, #185FA5)", color: "white",
    border: "none", padding: "12px 24px",
    borderRadius: "10px", cursor: "pointer",
    fontSize: "14px", fontWeight: "700",
    boxShadow: "0 4px 12px rgba(12,68,124,0.2)",
  },

  // Grid cartes
  grid: { display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))", gap: "14px" },

  card: {
    borderRadius: "14px", border: "1px solid #E0DED6",
    overflow: "hidden", cursor: "pointer",
    transition: "transform 0.15s, box-shadow 0.15s",
    background: "white", position: "relative",
    boxShadow: "0 2px 6px rgba(0,0,0,0.05)",
    display: "flex", flexDirection: "column",
  },
  cardTop: {
    display: "flex", justifyContent: "space-between",
    alignItems: "center", padding: "14px 16px",
  },
  cardTopLeft: { display: "flex", alignItems: "center", gap: "8px" },
  cardEmoji: { fontSize: "28px" },
  statusDot: { width: 8, height: 8, borderRadius: "50%" },
  statusBadge: { fontSize: "11px", fontWeight: "700", padding: "3px 10px", borderRadius: "20px" },
  cardBody: { padding: "14px 16px 12px", flex: 1 },
  cardName: { fontSize: "16px", fontWeight: "800", color: "#0C447C", marginBottom: "6px", lineHeight: 1.3 },
  cardMeta: { marginBottom: "10px" },
  cardMetaItem: { fontSize: "12px", color: "#73726c" },
  cardInfos: { display: "flex", flexDirection: "column", gap: "4px" },
  cardInfo: { display: "flex", alignItems: "center", gap: "6px", fontSize: "12px", color: "#444" },
  cardInfoIcon: { fontSize: "13px" },
  nightPill: { background: "#E6F1FB", color: "#185FA5", borderRadius: "10px", padding: "1px 6px", fontSize: "10px", fontWeight: "700", marginLeft: "4px" },
  cardFooter: {
    display: "flex", gap: "6px",
    padding: "10px 16px",
    borderTop: "1px solid #F5F4F0",
    background: "#FAFAFA",
  },
  btnEdit: {
    flex: 1, padding: "7px 10px", borderRadius: "8px",
    border: "1px solid #D1CFC5", background: "white",
    color: "#0C447C", cursor: "pointer", fontSize: "12px", fontWeight: "600",
  },
  btnDel: {
    padding: "7px 10px", borderRadius: "8px",
    border: "1px solid #F5C6C6", background: "#FFF5F5",
    color: "#A32D2D", cursor: "pointer", fontSize: "12px",
  },
  cardArrow: { position: "absolute", top: "50%", right: "14px", transform: "translateY(-50%)", fontSize: "22px", color: "#D1CFC5", pointerEvents: "none" },

  addCard: {
    borderRadius: "14px", border: "2px dashed #D1CFC5",
    display: "flex", flexDirection: "column",
    alignItems: "center", justifyContent: "center",
    minHeight: "180px", cursor: "pointer",
    transition: "border-color 0.15s, background 0.15s",
    background: "#FAFAFA",
  },
  addIcon: { fontSize: "32px", color: "#B0AFA8", marginBottom: "8px" },
  addLabel: { color: "#185FA5", fontWeight: "700", fontSize: "14px" },

  // Modales
  overlay: {
    position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)",
    display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1000,
    backdropFilter: "blur(2px)",
  },
  modal: {
    background: "white", borderRadius: "16px",
    padding: "28px 32px", width: "100%",
    maxWidth: "440px", boxShadow: "0 12px 48px rgba(0,0,0,0.2)",
  },
  modalHeader: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "20px" },
  modalTitle: { fontSize: "17px", fontWeight: "800", color: "#0C447C", margin: 0 },
  modalClose: { background: "none", border: "none", fontSize: "18px", cursor: "pointer", color: "#73726c", padding: "0 4px" },
  modalError: { background: "#FCEBEB", color: "#A32D2D", padding: "10px 14px", borderRadius: "8px", marginBottom: "14px", fontSize: "13px" },

  mField: { marginBottom: "16px" },
  mLabel: { display: "block", fontSize: "12px", fontWeight: "700", color: "#444", marginBottom: "7px", textTransform: "uppercase", letterSpacing: "0.4px" },
  mInput: {
    width: "100%", padding: "11px 13px", borderRadius: "10px",
    border: "1.5px solid #E0DED6", fontSize: "14px",
    boxSizing: "border-box", outline: "none", background: "#FAFAFA",
  },
  mInputDate: {
    flex: 1, padding: "11px 12px", borderRadius: "10px",
    border: "1.5px solid #E0DED6", fontSize: "14px",
    boxSizing: "border-box", outline: "none", background: "#FAFAFA",
  },
  mDatesRow: { display: "flex", gap: "8px", alignItems: "center" },
  mArrow: { fontSize: "18px", color: "#C0BEB5", flexShrink: 0 },
  mNights: {
    background: "linear-gradient(135deg, #E6F1FB, #D4E8F5)",
    color: "#0C447C", padding: "9px 16px",
    borderRadius: "8px", fontSize: "13px",
    fontWeight: "700", textAlign: "center", marginBottom: "16px",
  },
  mActions: { display: "flex", gap: "10px", justifyContent: "flex-end", marginTop: "20px" },
  mBtnCancel: {
    padding: "10px 20px", borderRadius: "8px",
    border: "1px solid #D1CFC5", background: "white",
    color: "#444", cursor: "pointer", fontSize: "14px",
  },
  mBtnSave: {
    padding: "10px 22px", borderRadius: "8px", border: "none",
    background: "linear-gradient(135deg, #0C447C, #185FA5)",
    color: "white", cursor: "pointer",
    fontSize: "14px", fontWeight: "700",
  },
  mBtnDelete: {
    padding: "10px 20px", borderRadius: "8px", border: "none",
    background: "#C0392B", color: "white",
    cursor: "pointer", fontSize: "14px", fontWeight: "700",
  },
  deleteMsg: { fontSize: "14px", color: "#444", lineHeight: 1.6, marginBottom: "8px" },
};
