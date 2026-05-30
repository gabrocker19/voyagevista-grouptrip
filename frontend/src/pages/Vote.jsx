import { useState, useEffect, useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { voteService } from "../services/vote.service";
import { groupService } from "../services/group.service";
import { api } from "../services/api";
import { useAuth } from "../context/AuthContext";
import { CAT_ICONS, getDestIcon } from "../utils/icons";

const CATEGORIES = ["plage", "montagne", "ville", "aventure", "culture"];

export default function Vote() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();

  const [groupe, setGroupe] = useState(null);
  const [destinations, setDestinations] = useState([]);
  const [resultats, setResultats] = useState([]);
  const [monVote, setMonVote] = useState(null);
  const [totalMembres, setTotalMembres] = useState(0);
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(true);

  const [search, setSearch] = useState("");
  const [catFiltre, setCatFiltre] = useState("");

  useEffect(() => {
    Promise.all([
      groupService.getOne(id),
      api.get("/api/destinations"),
      voteService.resultats(id, "destination"),
    ])
      .then(([g, dests, res]) => {
        setGroupe(g);
        setDestinations(dests);
        setResultats(res.resultats);
        setMonVote(res.mon_vote);
        setTotalMembres(res.total_membres);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [id]);

  const destsFiltrees = useMemo(() => {
    return destinations.filter((d) => {
      const matchSearch =
        !search ||
        d.nom.toLowerCase().includes(search.toLowerCase()) ||
        d.pays.toLowerCase().includes(search.toLowerCase());
      const matchCat = !catFiltre || d.categorie === catFiltre;
      return matchSearch && matchCat;
    });
  }, [destinations, search, catFiltre]);

  const handleVote = async (dest_id) => {
    try {
      await voteService.voter({
        groupe_id: id,
        type: "destination",
        valeur: String(dest_id),
      });
      setMonVote(String(dest_id));
      setMessage("Vote enregistré !");
      const res = await voteService.resultats(id, "destination");
      setResultats(res.resultats);
      setTotalMembres(res.total_membres);
    } catch (err) {
      setMessage(err.message);
    }
  };

  const handleValider = async (valeur) => {
    try {
      await voteService.valider({ groupe_id: id, type: "destination", valeur });
      setMessage("Destination validée pour le groupe !");
      groupService.getOne(id).then(setGroupe);
    } catch (err) {
      setMessage(err.message);
    }
  };

  if (loading) return <div style={s.loading}>Chargement...</div>;

  const isOrganisateur = groupe?.organisateur_id === user?.id;
  const totalVotes = resultats.reduce((a, r) => a + parseInt(r.nb_votes), 0);

  return (
    <div style={s.page}>
      {/* Header */}
      <div style={s.header}>
        <button onClick={() => navigate(`/groupes/${id}`)} style={s.btnBack}>
          ← Retour au groupe
        </button>
        <h1 style={s.title}>🗳️ Vote — Destination</h1>
        <p style={s.sub}>{groupe?.nom}</p>
        <div style={s.voteCount}>
          {totalVotes} / {totalMembres} vote{totalMembres > 1 ? "s" : ""}
        </div>
      </div>

      {/* Filtres */}
      <div style={s.filtersBar}>
        <input
          type="text"
          placeholder="🔍 Rechercher une destination ou un pays..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={s.searchInput}
        />
        <div style={s.catButtons}>
          <button
            style={catFiltre === "" ? s.catActive : s.cat}
            onClick={() => setCatFiltre("")}
          >
            Toutes ({destinations.length})
          </button>
          {CATEGORIES.map((c) => {
            const count = destinations.filter((d) => d.categorie === c).length;
            return (
              <button
                key={c}
                style={catFiltre === c ? s.catActive : s.cat}
                onClick={() => setCatFiltre(c)}
              >
                {CAT_ICONS[c]} {c.charAt(0).toUpperCase() + c.slice(1)} ({count})
              </button>
            );
          })}
        </div>
      </div>

      {/* Message feedback */}
      {message && <div style={s.toast}>{message}</div>}

      {/* Mon vote actuel */}
      {monVote && (
        <div style={s.monVoteBanner}>
          ✓ Vous avez voté pour{" "}
          <strong>
            {destinations.find((d) => String(d.id) === monVote)?.nom}
          </strong>
        </div>
      )}

      {/* Grille destinations */}
      <div style={s.body}>
        {destsFiltrees.length === 0 ? (
          <p style={s.empty}>Aucune destination ne correspond à votre recherche.</p>
        ) : (
          <div style={s.grid}>
            {destsFiltrees.map((d) => {
              const resultat = resultats.find((r) => r.valeur === String(d.id));
              const nbVotes = resultat ? parseInt(resultat.nb_votes) : 0;
              const votants = resultat ? resultat.votants : "";
              const pct = totalMembres > 0 ? Math.round((nbVotes / totalMembres) * 100) : 0;
              const isMyVote = monVote === String(d.id);

              return (
                <div
                  key={d.id}
                  style={{
                    ...s.card,
                    border: isMyVote ? "2px solid #185FA5" : "1px solid #E0DED6",
                    boxShadow: isMyVote
                      ? "0 0 0 3px rgba(24,95,165,0.15)"
                      : "0 2px 8px rgba(0,0,0,0.07)",
                  }}
                >
                  {/* Image / icône */}
                  <div style={{ ...s.cardImg, background: "#E6F1FB" }}>
                    <span style={s.cardEmoji}>{getDestIcon(d)}</span>
                    <span style={s.badge}>{d.categorie}</span>
                    {isMyVote && <span style={s.myVoteBadge}>✓ Mon vote</span>}
                  </div>

                  {/* Infos */}
                  <div style={s.cardBody}>
                    <div style={s.cardTitle}>{d.nom}</div>
                    <div style={s.cardPays}>📍 {d.pays}</div>
                    <div style={s.cardDesc}>{d.description}</div>
                    <div style={s.cardPrice}>À partir de {d.prix_min}€</div>

                    {/* Barre de vote */}
                    <div style={s.voteBarBg}>
                      <div style={{ ...s.voteBarFill, width: `${pct}%` }} />
                    </div>
                    <div style={s.voteStats}>
                      <span>{nbVotes} vote{nbVotes > 1 ? "s" : ""} ({pct}%)</span>
                      {votants && <span style={s.votants}>{votants}</span>}
                    </div>

                    {/* Actions */}
                    <div style={s.cardActions}>
                      <button
                        onClick={() => handleVote(d.id)}
                        style={{
                          ...s.btnVote,
                          background: isMyVote ? "#185FA5" : "white",
                          color: isMyVote ? "white" : "#185FA5",
                        }}
                      >
                        {isMyVote ? "✓ Voté" : "Voter pour cette destination"}
                      </button>
                      {isOrganisateur && nbVotes > 0 && (
                        <button
                          onClick={() => handleValider(String(d.id))}
                          style={s.btnValider}
                        >
                          👑 Valider
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {isOrganisateur && (
        <div style={s.infoBox}>
          👑 En tant qu'organisateur, cliquez sur <strong>"Valider"</strong>{" "}
          sur la destination qui a remporté le vote pour la confirmer.
        </div>
      )}
    </div>
  );
}

const s = {
  page: { fontFamily: "Arial, sans-serif", minHeight: "100vh", background: "#F5F4F0" },
  loading: { textAlign: "center", padding: "60px", color: "#73726c" },
  btnBack: {
    background: "none", border: "none", color: "rgba(255,255,255,0.8)",
    cursor: "pointer", fontSize: "13px", padding: "0", marginBottom: "8px", display: "block",
  },
  header: { background: "#0C447C", color: "white", padding: "28px 32px" },
  title: { fontSize: "24px", fontWeight: "bold", marginBottom: "4px" },
  sub: { opacity: 0.8, fontSize: "14px", marginBottom: "6px" },
  voteCount: {
    display: "inline-block", background: "rgba(255,255,255,0.15)",
    padding: "4px 12px", borderRadius: "20px", fontSize: "13px",
  },
  filtersBar: {
    background: "white", padding: "16px 24px",
    boxShadow: "0 2px 4px rgba(0,0,0,0.06)", position: "sticky", top: 0, zIndex: 10,
  },
  searchInput: {
    width: "100%", padding: "10px 14px", borderRadius: "8px",
    fontSize: "14px", border: "1px solid #D1CFC5",
    marginBottom: "10px", boxSizing: "border-box",
  },
  catButtons: { display: "flex", gap: "8px", flexWrap: "wrap" },
  cat: {
    padding: "6px 14px", borderRadius: "20px", border: "1px solid #D1CFC5",
    background: "white", cursor: "pointer", fontSize: "12px",
  },
  catActive: {
    padding: "6px 14px", borderRadius: "20px", border: "1px solid #185FA5",
    background: "#185FA5", color: "white", cursor: "pointer", fontSize: "12px",
  },
  toast: {
    margin: "12px 24px 0", background: "#EAF3DE", color: "#3B6D11",
    padding: "10px 16px", borderRadius: "8px", fontSize: "13px",
  },
  monVoteBanner: {
    margin: "10px 24px 0", background: "#E6F1FB", color: "#0C447C",
    padding: "10px 16px", borderRadius: "8px", fontSize: "13px",
  },
  body: { padding: "20px 24px 32px" },
  empty: { textAlign: "center", padding: "40px", color: "#73726c" },
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fill, minmax(300px, 1fr))",
    gap: "16px",
  },
  card: {
    background: "white", borderRadius: "12px", overflow: "hidden",
    transition: "transform 0.15s",
  },
  cardImg: {
    height: "150px", backgroundSize: "cover", backgroundPosition: "center",
    position: "relative", display: "flex", alignItems: "center", justifyContent: "center",
  },
  cardEmoji: { fontSize: "56px" },
  badge: {
    position: "absolute", top: "10px", left: "10px",
    background: "rgba(0,0,0,0.5)", color: "white",
    padding: "3px 10px", borderRadius: "12px", fontSize: "11px",
  },
  myVoteBadge: {
    position: "absolute", top: "10px", right: "10px",
    background: "#185FA5", color: "white",
    padding: "3px 10px", borderRadius: "12px", fontSize: "11px", fontWeight: "bold",
  },
  cardBody: { padding: "14px 16px" },
  cardTitle: { fontSize: "16px", fontWeight: "bold", color: "#0C447C", marginBottom: "2px" },
  cardPays: { fontSize: "12px", color: "#73726c", marginBottom: "4px" },
  cardDesc: {
    fontSize: "12px", color: "#555", lineHeight: "1.4",
    marginBottom: "6px",
    display: "-webkit-box", WebkitLineClamp: 2,
    WebkitBoxOrient: "vertical", overflow: "hidden",
  },
  cardPrice: { fontSize: "13px", fontWeight: "bold", color: "#185FA5", marginBottom: "8px" },
  voteBarBg: {
    height: "5px", background: "#E0DED6", borderRadius: "3px",
    overflow: "hidden", marginBottom: "4px",
  },
  voteBarFill: { height: "100%", background: "#185FA5", borderRadius: "3px", transition: "width 0.3s" },
  voteStats: {
    display: "flex", justifyContent: "space-between",
    fontSize: "11px", color: "#73726c", marginBottom: "10px",
  },
  votants: { color: "#185FA5" },
  cardActions: { display: "flex", gap: "8px", flexWrap: "wrap" },
  btnVote: {
    flex: 1, padding: "8px 12px", borderRadius: "6px",
    border: "1px solid #185FA5", cursor: "pointer",
    fontSize: "13px", fontWeight: "500",
  },
  btnValider: {
    padding: "8px 12px", borderRadius: "6px", border: "none",
    background: "#EAF3DE", color: "#3B6D11", cursor: "pointer",
    fontSize: "13px", fontWeight: "500",
  },
  infoBox: {
    margin: "0 24px 24px", background: "#E6F1FB", color: "#0C447C",
    padding: "14px 18px", borderRadius: "8px", fontSize: "13px", lineHeight: "1.5",
  },
};
