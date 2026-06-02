import { EQUIPEMENTS_META, parseEquipements } from "../utils/equipements";

const TYPE_ICONS = { hotel:"🏨", airbnb:"🏠", hostel:"🛏️", villa:"🏡", resort:"🌴" };

export default function EquipementsModal({ heb, onClose }) {
  if (!heb) return null;
  const equips = parseEquipements(heb.equipements);

  return (
    <div style={s.overlay} onClick={onClose}>
      <div style={s.modal} onClick={e => e.stopPropagation()}>

        {/* Header */}
        <div style={s.header}>
          <div>
            <div style={s.headerType}>{TYPE_ICONS[heb.type] || "🏨"} {heb.type}</div>
            <h2 style={s.headerTitle}>{heb.nom}</h2>
          </div>
          <button onClick={onClose} style={s.btnClose}>✕</button>
        </div>

        {/* Description */}
        {heb.description && (
          <p style={s.description}>{heb.description}</p>
        )}

        {/* Infos rapides */}
        <div style={s.quickRow}>
          <div style={s.quickItem}>
            <span style={s.quickIcon}>👥</span>
            <span style={s.quickLabel}>Capacité</span>
            <span style={s.quickVal}>{heb.capacite} pers. max</span>
          </div>
          <div style={s.quickItem}>
            <span style={s.quickIcon}>{heb.animaux_acceptes ? "🐾" : "🚫"}</span>
            <span style={s.quickLabel}>Animaux</span>
            <span style={{ ...s.quickVal, color: heb.animaux_acceptes ? "#3B6D11" : "#A32D2D" }}>
              {heb.animaux_acceptes ? "Acceptés" : "Non acceptés"}
            </span>
          </div>
          <div style={s.quickItem}>
            <span style={s.quickIcon}>💶</span>
            <span style={s.quickLabel}>Tarif</span>
            <span style={s.quickVal}>{heb.prix_nuit}€/nuit</span>
          </div>
        </div>

        {/* Équipements */}
        {equips.length > 0 && (
          <>
            <div style={s.sectionTitle}>Équipements & services</div>
            <div style={s.equipsGrid}>
              {equips.map(e => {
                const m = EQUIPEMENTS_META[e] || { icon: "•", label: e };
                return (
                  <div key={e} style={s.equipItem}>
                    <span style={s.equipIcon}>{m.icon}</span>
                    <span style={s.equipLabel}>{m.label}</span>
                  </div>
                );
              })}
            </div>
          </>
        )}

        <button onClick={onClose} style={s.btnFermer}>Fermer</button>
      </div>
    </div>
  );
}

const s = {
  overlay: {
    position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)",
    display: "flex", alignItems: "center", justifyContent: "center",
    zIndex: 1000, padding: "24px",
  },
  modal: {
    background: "white", borderRadius: "16px", width: "100%", maxWidth: "520px",
    maxHeight: "85vh", overflowY: "auto",
    boxShadow: "0 20px 60px rgba(0,0,0,0.25)",
    display: "flex", flexDirection: "column", gap: "0",
  },
  header: {
    display: "flex", justifyContent: "space-between", alignItems: "flex-start",
    padding: "24px 24px 16px", borderBottom: "1px solid #F0EEE8",
  },
  headerType: { fontSize: "12px", color: "#73726c", marginBottom: "4px" },
  headerTitle: { fontSize: "20px", fontWeight: "800", color: "#0C447C", margin: 0 },
  btnClose: {
    background: "#F5F4F0", border: "none", borderRadius: "50%",
    width: "32px", height: "32px", cursor: "pointer",
    fontSize: "14px", color: "#73726c", flexShrink: 0,
    display: "flex", alignItems: "center", justifyContent: "center",
  },
  description: {
    fontSize: "13px", color: "#555", lineHeight: "1.6",
    padding: "16px 24px", margin: 0, borderBottom: "1px solid #F0EEE8",
  },
  quickRow: {
    display: "flex", gap: "0", padding: "16px 24px",
    borderBottom: "1px solid #F0EEE8",
  },
  quickItem: {
    flex: 1, display: "flex", flexDirection: "column",
    alignItems: "center", gap: "3px", textAlign: "center",
  },
  quickIcon: { fontSize: "20px" },
  quickLabel: { fontSize: "10px", color: "#73726c", textTransform: "uppercase", letterSpacing: "0.5px" },
  quickVal: { fontSize: "13px", fontWeight: "700", color: "#2C2C2A" },
  sectionTitle: {
    fontSize: "12px", fontWeight: "700", color: "#73726c",
    textTransform: "uppercase", letterSpacing: "0.8px",
    padding: "16px 24px 10px",
  },
  equipsGrid: {
    display: "grid", gridTemplateColumns: "1fr 1fr",
    gap: "6px", padding: "0 24px 16px",
  },
  equipItem: {
    display: "flex", alignItems: "center", gap: "10px",
    background: "#F8F7F4", borderRadius: "10px", padding: "10px 14px",
  },
  equipIcon: { fontSize: "18px", flexShrink: 0 },
  equipLabel: { fontSize: "13px", color: "#2C2C2A", fontWeight: "500" },
  btnFermer: {
    margin: "0 24px 24px", padding: "12px",
    background: "linear-gradient(135deg, #0C447C, #185FA5)",
    color: "white", border: "none", borderRadius: "10px",
    cursor: "pointer", fontSize: "14px", fontWeight: "700",
  },
};
