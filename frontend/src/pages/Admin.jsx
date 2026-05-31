import { useState, useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { api } from "../services/api";
import PageHeader from "../components/PageHeader";

const CATEGORIES   = ["plage", "montagne", "ville", "aventure", "culture"];
const TYPES_HEB    = ["hotel", "airbnb", "hostel", "villa", "resort"];
const TYPES_TRANS  = ["avion", "train", "bus", "bateau"];

export default function Admin() {
  const { user } = useAuth();
  const navigate  = useNavigate();
  const [onglet, setOnglet] = useState("destinations");

  const [destinations, setDestinations] = useState([]);
  const [hebergements, setHebergements] = useState([]);
  const [activites,    setActivites]    = useState([]);
  const [transports,   setTransports]   = useState([]);

  // Barres de recherche
  const [searchDest,  setSearchDest]  = useState("");
  const [searchHeb,   setSearchHeb]   = useState("");
  const [searchAct,   setSearchAct]   = useState("");
  const [searchTrans, setSearchTrans] = useState("");

  const [msg, setMsg] = useState("");
  const [err, setErr] = useState("");

  // Formulaires
  const [formDest,  setFormDest]  = useState({ nom:"", pays:"", categorie:"ville", description:"", prix_min:"" });
  const [formHeb,   setFormHeb]   = useState({ destination_id:"", nom:"", type:"hotel", prix_nuit:"", capacite:"10", description:"" });
  const [formAct,   setFormAct]   = useState({ destination_id:"", nom:"", description:"", prix:"", capacite_max:"20", duree_heures:"" });
  const [formTrans, setFormTrans] = useState({ compagnie:"", type:"avion", origine:"", destination:"", date_depart:"", date_arrivee:"", prix:"", places_dispo:"100" });

  useEffect(() => { if (user && user.role !== "admin") navigate("/dashboard"); }, [user]);
  useEffect(() => { loadAll(); }, []);

  const loadAll = () => {
    api.get("/api/destinations").then(setDestinations).catch(() => {});
    api.get("/api/hebergements").then(setHebergements).catch(() => {});
    api.get("/api/activites").then(setActivites).catch(() => {});
    api.get("/api/admin/transports").then(setTransports).catch(() => {});
  };

  const flash = (ok, texte) => {
    if (ok) { setMsg(texte); setErr(""); }
    else    { setErr(texte); setMsg(""); }
    setTimeout(() => { setMsg(""); setErr(""); }, 3000);
  };

  // ── Destinations ─────────────────────────────────────────────────────────────
  const handleCreateDest = async (e) => {
    e.preventDefault();
    try {
      await api.post("/api/admin/destinations", formDest);
      flash(true, "Destination créée !");
      setFormDest({ nom:"", pays:"", categorie:"ville", description:"", prix_min:"" });
      api.get("/api/destinations").then(setDestinations);
    } catch (er) { flash(false, er.message); }
  };

  const handleDeleteDest = async (id, nom) => {
    if (!confirm(`Supprimer "${nom}" ? Cela supprimera aussi ses hébergements et activités.`)) return;
    try {
      await api.delete(`/api/admin/destinations/${id}`);
      flash(true, `"${nom}" supprimée.`);
      loadAll();
    } catch (er) { flash(false, er.message); }
  };

  // ── Hébergements ─────────────────────────────────────────────────────────────
  const handleCreateHeb = async (e) => {
    e.preventDefault();
    try {
      await api.post("/api/admin/hebergements", formHeb);
      flash(true, "Hébergement créé !");
      setFormHeb({ destination_id:"", nom:"", type:"hotel", prix_nuit:"", capacite:"10", description:"" });
      api.get("/api/hebergements").then(setHebergements);
    } catch (er) { flash(false, er.message); }
  };

  const handleDeleteHeb = async (id, nom) => {
    if (!confirm(`Supprimer "${nom}" ?`)) return;
    try {
      await api.delete(`/api/admin/hebergements/${id}`);
      flash(true, `"${nom}" supprimé.`);
      api.get("/api/hebergements").then(setHebergements);
    } catch (er) { flash(false, er.message); }
  };

  // ── Activités ────────────────────────────────────────────────────────────────
  const handleCreateAct = async (e) => {
    e.preventDefault();
    try {
      await api.post("/api/admin/activites", formAct);
      flash(true, "Activité créée !");
      setFormAct({ destination_id:"", nom:"", description:"", prix:"", capacite_max:"20", duree_heures:"" });
      api.get("/api/activites").then(setActivites);
    } catch (er) { flash(false, er.message); }
  };

  const handleDeleteAct = async (id, nom) => {
    if (!confirm(`Supprimer "${nom}" ?`)) return;
    try {
      await api.delete(`/api/admin/activites/${id}`);
      flash(true, `"${nom}" supprimée.`);
      api.get("/api/activites").then(setActivites);
    } catch (er) { flash(false, er.message); }
  };

  // ── Transports ───────────────────────────────────────────────────────────────
  const handleCreateTrans = async (e) => {
    e.preventDefault();
    try {
      await api.post("/api/admin/transports", formTrans);
      flash(true, "Transport créé !");
      setFormTrans({ compagnie:"", type:"avion", origine:"", destination:"", date_depart:"", date_arrivee:"", prix:"", places_dispo:"100" });
      api.get("/api/admin/transports").then(setTransports);
    } catch (er) { flash(false, er.message); }
  };

  const handleDeleteTrans = async (id, nom) => {
    if (!confirm(`Supprimer le transport "${nom}" ?`)) return;
    try {
      await api.delete(`/api/admin/transports/${id}`);
      flash(true, `Transport supprimé.`);
      api.get("/api/admin/transports").then(setTransports);
    } catch (er) { flash(false, er.message); }
  };

  // ── Filtres recherche ────────────────────────────────────────────────────────
  const destName = (id) => destinations.find((d) => d.id == id)?.nom || `#${id}`;

  const q = (s) => s.toLowerCase();
  const destFiltered  = useMemo(() => destinations.filter(d =>
    !searchDest  || q(d.nom).includes(q(searchDest))  || q(d.pays).includes(q(searchDest))
  ), [destinations, searchDest]);

  const hebFiltered   = useMemo(() => hebergements.filter(h =>
    !searchHeb   || q(h.nom).includes(q(searchHeb))   || q(destName(h.destination_id)).includes(q(searchHeb))
  ), [hebergements, searchHeb, destinations]);

  const actFiltered   = useMemo(() => activites.filter(a =>
    !searchAct   || q(a.nom).includes(q(searchAct))   || q(destName(a.destination_id)).includes(q(searchAct))
  ), [activites, searchAct, destinations]);

  const transFiltered = useMemo(() => transports.filter(t =>
    !searchTrans || q(t.compagnie).includes(q(searchTrans)) || q(t.origine).includes(q(searchTrans)) || q(t.destination).includes(q(searchTrans))
  ), [transports, searchTrans]);

  return (
    <div style={styles.page}>
      <PageHeader
        title="⚙️ Administration — Catalogue"
        subtitle="Gestion des offres touristiques"
        backLabel="Tableau de bord"
        backTo="/dashboard"
      />

      {/* Onglets */}
      <div style={styles.tabs}>
        {[
          ["destinations", "🌍 Destinations"],
          ["hebergements", "🏨 Hébergements"],
          ["activites",    "🎯 Activités"],
          ["transports",   "✈️ Transports"],
        ].map(([key, label]) => (
          <button key={key} onClick={() => setOnglet(key)}
            style={onglet === key ? styles.tabActive : styles.tab}>
            {label}
          </button>
        ))}
      </div>

      <div style={styles.body}>
        {msg && <div style={styles.alertOk}>{msg}</div>}
        {err && <div style={styles.alertErr}>{err}</div>}

        {/* ── DESTINATIONS ── */}
        {onglet === "destinations" && (
          <div style={styles.cols}>
            <div style={styles.formCard}>
              <h2 style={styles.cardTitle}>Ajouter une destination</h2>
              <form onSubmit={handleCreateDest}>
                <Field label="Nom"          value={formDest.nom}         onChange={(v) => setFormDest({...formDest, nom:v})}         required />
                <Field label="Pays"         value={formDest.pays}        onChange={(v) => setFormDest({...formDest, pays:v})}        required />
                <SelectField label="Catégorie" value={formDest.categorie} onChange={(v) => setFormDest({...formDest, categorie:v})}  options={CATEGORIES} />
                <Field label="Description"  value={formDest.description} onChange={(v) => setFormDest({...formDest, description:v})} textarea />
                <Field label="Prix min (€)" value={formDest.prix_min}    onChange={(v) => setFormDest({...formDest, prix_min:v})}    type="number" />
                <button type="submit" style={styles.btnAdd}>+ Ajouter</button>
              </form>
            </div>
            <div style={styles.listCard}>
              <div style={styles.listHeader}>
                <h2 style={styles.cardTitle}>Destinations ({destFiltered.length}/{destinations.length})</h2>
                <SearchBar value={searchDest} onChange={setSearchDest} placeholder="Rechercher nom, pays…" />
              </div>
              <div style={styles.list}>
                {destFiltered.map((d) => (
                  <div key={d.id} style={styles.listRow}>
                    <div>
                      <div style={styles.listName}>{d.nom} <span style={styles.listSub}>— {d.pays}</span></div>
                      <div style={styles.listMeta}>{d.categorie} · {d.prix_min}€ min</div>
                    </div>
                    <button onClick={() => handleDeleteDest(d.id, d.nom)} style={styles.btnDel}>Supprimer</button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* ── HÉBERGEMENTS ── */}
        {onglet === "hebergements" && (
          <div style={styles.cols}>
            <div style={styles.formCard}>
              <h2 style={styles.cardTitle}>Ajouter un hébergement</h2>
              <form onSubmit={handleCreateHeb}>
                <SelectField label="Destination" value={formHeb.destination_id}
                  onChange={(v) => setFormHeb({...formHeb, destination_id:v})}
                  options={destinations.map((d) => ({ value:d.id, label:d.nom }))} required />
                <Field label="Nom"              value={formHeb.nom}         onChange={(v) => setFormHeb({...formHeb, nom:v})}         required />
                <SelectField label="Type"       value={formHeb.type}        onChange={(v) => setFormHeb({...formHeb, type:v})}        options={TYPES_HEB} />
                <Field label="Prix / nuit (€)"  value={formHeb.prix_nuit}   onChange={(v) => setFormHeb({...formHeb, prix_nuit:v})}   type="number" required />
                <Field label="Capacité (pers.)" value={formHeb.capacite}    onChange={(v) => setFormHeb({...formHeb, capacite:v})}    type="number" />
                <Field label="Description"      value={formHeb.description} onChange={(v) => setFormHeb({...formHeb, description:v})} textarea />
                <button type="submit" style={styles.btnAdd}>+ Ajouter</button>
              </form>
            </div>
            <div style={styles.listCard}>
              <div style={styles.listHeader}>
                <h2 style={styles.cardTitle}>Hébergements ({hebFiltered.length}/{hebergements.length})</h2>
                <SearchBar value={searchHeb} onChange={setSearchHeb} placeholder="Rechercher nom, destination…" />
              </div>
              <div style={styles.list}>
                {hebFiltered.map((h) => (
                  <div key={h.id} style={styles.listRow}>
                    <div>
                      <div style={styles.listName}>{h.nom} <span style={styles.listSub}>— {h.type}</span></div>
                      <div style={styles.listMeta}>{destName(h.destination_id)} · {h.prix_nuit}€/nuit</div>
                    </div>
                    <button onClick={() => handleDeleteHeb(h.id, h.nom)} style={styles.btnDel}>Supprimer</button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* ── ACTIVITÉS ── */}
        {onglet === "activites" && (
          <div style={styles.cols}>
            <div style={styles.formCard}>
              <h2 style={styles.cardTitle}>Ajouter une activité</h2>
              <form onSubmit={handleCreateAct}>
                <SelectField label="Destination" value={formAct.destination_id}
                  onChange={(v) => setFormAct({...formAct, destination_id:v})}
                  options={destinations.map((d) => ({ value:d.id, label:d.nom }))} required />
                <Field label="Nom"          value={formAct.nom}         onChange={(v) => setFormAct({...formAct, nom:v})}         required />
                <Field label="Description"  value={formAct.description} onChange={(v) => setFormAct({...formAct, description:v})} textarea />
                <Field label="Prix (€)"     value={formAct.prix}        onChange={(v) => setFormAct({...formAct, prix:v})}        type="number" required />
                <Field label="Durée (h)"    value={formAct.duree_heures} onChange={(v) => setFormAct({...formAct, duree_heures:v})} type="number" />
                <Field label="Capacité max" value={formAct.capacite_max} onChange={(v) => setFormAct({...formAct, capacite_max:v})} type="number" />
                <button type="submit" style={styles.btnAdd}>+ Ajouter</button>
              </form>
            </div>
            <div style={styles.listCard}>
              <div style={styles.listHeader}>
                <h2 style={styles.cardTitle}>Activités ({actFiltered.length}/{activites.length})</h2>
                <SearchBar value={searchAct} onChange={setSearchAct} placeholder="Rechercher nom, destination…" />
              </div>
              <div style={styles.list}>
                {actFiltered.map((a) => (
                  <div key={a.id} style={styles.listRow}>
                    <div>
                      <div style={styles.listName}>{a.nom}</div>
                      <div style={styles.listMeta}>{destName(a.destination_id)} · {a.prix}€ · {a.places_restantes}/{a.capacite_max} places</div>
                    </div>
                    <button onClick={() => handleDeleteAct(a.id, a.nom)} style={styles.btnDel}>Supprimer</button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* ── TRANSPORTS ── */}
        {onglet === "transports" && (
          <div style={styles.cols}>
            <div style={styles.formCard}>
              <h2 style={styles.cardTitle}>Ajouter un transport</h2>
              <form onSubmit={handleCreateTrans}>
                <Field label="Compagnie"       value={formTrans.compagnie}    onChange={(v) => setFormTrans({...formTrans, compagnie:v})}    required />
                <SelectField label="Type"      value={formTrans.type}         onChange={(v) => setFormTrans({...formTrans, type:v})}         options={TYPES_TRANS} />
                <Field label="Origine"         value={formTrans.origine}      onChange={(v) => setFormTrans({...formTrans, origine:v})}      required />
                <Field label="Destination"     value={formTrans.destination}  onChange={(v) => setFormTrans({...formTrans, destination:v})}  required />
                <Field label="Départ"          value={formTrans.date_depart}  onChange={(v) => setFormTrans({...formTrans, date_depart:v})}  type="datetime-local" />
                <Field label="Arrivée"         value={formTrans.date_arrivee} onChange={(v) => setFormTrans({...formTrans, date_arrivee:v})} type="datetime-local" />
                <Field label="Prix (€/pers.)"  value={formTrans.prix}         onChange={(v) => setFormTrans({...formTrans, prix:v})}         type="number" required />
                <Field label="Places dispo"    value={formTrans.places_dispo} onChange={(v) => setFormTrans({...formTrans, places_dispo:v})} type="number" />
                <button type="submit" style={styles.btnAdd}>+ Ajouter</button>
              </form>
            </div>
            <div style={styles.listCard}>
              <div style={styles.listHeader}>
                <h2 style={styles.cardTitle}>Transports ({transFiltered.length}/{transports.length})</h2>
                <SearchBar value={searchTrans} onChange={setSearchTrans} placeholder="Rechercher compagnie, ville…" />
              </div>
              <div style={styles.list}>
                {transFiltered.map((t) => (
                  <div key={t.id} style={styles.listRow}>
                    <div>
                      <div style={styles.listName}>
                        {TRANS_ICONS[t.type]} {t.compagnie}
                        <span style={styles.listSub}> — {t.type}</span>
                      </div>
                      <div style={styles.listMeta}>
                        {t.origine} → {t.destination} · {t.prix}€ · {t.places_dispo} places
                      </div>
                      <div style={styles.listMeta}>
                        🗓️ {new Date(t.date_depart).toLocaleDateString("fr-FR", { day:"2-digit", month:"short", year:"numeric", hour:"2-digit", minute:"2-digit" })}
                      </div>
                    </div>
                    <button onClick={() => handleDeleteTrans(t.id, `${t.compagnie} ${t.origine}→${t.destination}`)} style={styles.btnDel}>Supprimer</button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

const TRANS_ICONS = { avion:"✈️", train:"🚆", bus:"🚌", bateau:"⛴️" };

function SearchBar({ value, onChange, placeholder }) {
  return (
    <div style={{ position:"relative", marginBottom:"12px" }}>
      <span style={{ position:"absolute", left:"10px", top:"50%", transform:"translateY(-50%)", fontSize:"14px", color:"#73726c" }}>🔍</span>
      <input
        style={{ width:"100%", padding:"7px 10px 7px 32px", borderRadius:"8px", border:"1px solid #D1CFC5", fontSize:"13px", boxSizing:"border-box", background:"#FAFAF8" }}
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
      />
      {value && (
        <button
          onClick={() => onChange("")}
          style={{ position:"absolute", right:"8px", top:"50%", transform:"translateY(-50%)", background:"none", border:"none", cursor:"pointer", color:"#73726c", fontSize:"16px", lineHeight:1 }}
        >×</button>
      )}
    </div>
  );
}

function Field({ label, value, onChange, type = "text", required, textarea }) {
  return (
    <div style={{ marginBottom:"12px" }}>
      <label style={{ display:"block", fontSize:"12px", fontWeight:"600", color:"#2C2C2A", marginBottom:"4px" }}>{label}</label>
      {textarea ? (
        <textarea style={fStyles.input} value={value} onChange={(e) => onChange(e.target.value)} rows={2} />
      ) : (
        <input style={fStyles.input} type={type} value={value} onChange={(e) => onChange(e.target.value)} required={required} />
      )}
    </div>
  );
}

function SelectField({ label, value, onChange, options, required }) {
  return (
    <div style={{ marginBottom:"12px" }}>
      <label style={{ display:"block", fontSize:"12px", fontWeight:"600", color:"#2C2C2A", marginBottom:"4px" }}>{label}</label>
      <select style={fStyles.input} value={value} onChange={(e) => onChange(e.target.value)} required={required}>
        <option value="">— Choisir —</option>
        {options.map((o) =>
          typeof o === "string"
            ? <option key={o} value={o}>{o}</option>
            : <option key={o.value} value={o.value}>{o.label}</option>
        )}
      </select>
    </div>
  );
}

const fStyles = {
  input: {
    width:"100%", padding:"8px 10px", borderRadius:"6px",
    border:"1px solid #D1CFC5", fontSize:"13px", boxSizing:"border-box",
  },
};

const styles = {
  page:     { fontFamily:"Arial, sans-serif", minHeight:"100vh", background:"#F5F4F0" },
  tabs:     { background:"white", borderBottom:"1px solid #E0DED6", display:"flex", padding:"0 32px", gap:"4px" },
  tab:      { background:"none", border:"none", padding:"12px 18px", cursor:"pointer", fontSize:"14px", color:"#73726c", borderBottom:"3px solid transparent" },
  tabActive:{ background:"none", border:"none", padding:"12px 18px", cursor:"pointer", fontSize:"14px", color:"#0C447C", fontWeight:"bold", borderBottom:"3px solid #0C447C" },
  body:     { padding:"24px 32px" },
  alertOk:  { background:"#EAF3DE", color:"#3B6D11", padding:"10px 14px", borderRadius:"8px", marginBottom:"16px", fontSize:"14px" },
  alertErr: { background:"#FCEBEB", color:"#A32D2D", padding:"10px 14px", borderRadius:"8px", marginBottom:"16px", fontSize:"14px" },
  cols:     { display:"grid", gridTemplateColumns:"380px 1fr", gap:"20px", alignItems:"start" },
  formCard: { background:"white", borderRadius:"12px", padding:"20px 24px", boxShadow:"0 2px 6px rgba(0,0,0,0.06)" },
  listCard: { background:"white", borderRadius:"12px", padding:"20px 24px", boxShadow:"0 2px 6px rgba(0,0,0,0.06)" },
  listHeader:{ marginBottom:"4px" },
  cardTitle:{ fontSize:"15px", fontWeight:"bold", color:"#0C447C", marginBottom:"12px" },
  list:     { display:"flex", flexDirection:"column", gap:"8px", maxHeight:"520px", overflowY:"auto" },
  listRow:  { display:"flex", justifyContent:"space-between", alignItems:"center", padding:"10px 12px", background:"#FAFAF8", borderRadius:"8px", border:"1px solid #E0DED6", gap:"10px" },
  listName: { fontSize:"14px", fontWeight:"500", color:"#2C2C2A" },
  listSub:  { fontWeight:"normal", color:"#73726c" },
  listMeta: { fontSize:"12px", color:"#73726c", marginTop:"2px" },
  btnAdd:   { background:"#185FA5", color:"white", border:"none", padding:"10px 20px", borderRadius:"8px", cursor:"pointer", fontSize:"14px", fontWeight:"bold", width:"100%", marginTop:"4px" },
  btnDel:   { background:"#FCEBEB", color:"#A32D2D", border:"1px solid #F09595", padding:"5px 12px", borderRadius:"6px", cursor:"pointer", fontSize:"12px", whiteSpace:"nowrap", flexShrink:0 },
};
