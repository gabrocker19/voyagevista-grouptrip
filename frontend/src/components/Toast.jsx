import { useEffect, useState } from "react";

export default function Toast({ message, type = "success", duration = 3500, onClose }) {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    if (!message) return;
    setVisible(true);
    const hide = setTimeout(() => setVisible(false), duration - 400);
    const remove = setTimeout(() => onClose?.(), duration);
    return () => { clearTimeout(hide); clearTimeout(remove); };
  }, [message, duration]);

  if (!message) return null;

  const colors = {
    success: { bg: "#3B6D11", border: "#2D5209" },
    error:   { bg: "#A32D2D", border: "#7A1F1F" },
    info:    { bg: "#0C447C", border: "#083360" },
  };
  const c = colors[type] ?? colors.success;

  return (
    <>
      <style>{`
        @keyframes toastIn  { from { transform: translateY(24px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        @keyframes toastOut { from { opacity: 1; } to { opacity: 0; transform: translateY(8px); } }
      `}</style>
      <div style={{
        position: "fixed", bottom: "28px", right: "28px", zIndex: 9999,
        background: c.bg, color: "white",
        padding: "14px 20px", borderRadius: "10px",
        boxShadow: `0 4px 20px rgba(0,0,0,0.22), 0 0 0 1px ${c.border}`,
        fontSize: "14px", fontWeight: "500", maxWidth: "340px",
        display: "flex", alignItems: "center", gap: "10px",
        animation: visible ? "toastIn 0.3s ease" : "toastOut 0.35s ease forwards",
        lineHeight: "1.4",
      }}>
        <span style={{ fontSize: "18px" }}>
          {type === "success" ? "✓" : type === "error" ? "✕" : "ℹ"}
        </span>
        <span>{message}</span>
        <button
          onClick={() => { setVisible(false); setTimeout(() => onClose?.(), 350); }}
          style={{
            marginLeft: "auto", background: "none", border: "none",
            color: "rgba(255,255,255,0.7)", cursor: "pointer", fontSize: "16px",
            lineHeight: 1, padding: "0 0 0 8px",
          }}
        >×</button>
      </div>
    </>
  );
}
