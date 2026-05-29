import { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { voteService } from "../services/vote.service";
import { groupService } from "../services/group.service";
import { api } from "../services/api";
import { useAuth } from "../context/AuthContext";

export default function Vote() {
  const { id } = useParams();
  const { user } = useAuth();
  const [groupe, setGroupe] = useState(null);
  const [destinations, setDestinations] = useState([]);
  const [resultats, setResultats] = useState([]);
  const [monVote, setMonVote] = useState(null);
  const [totalMembres, setTotalMembres] = useState(0);
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(true);

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

  const handleVote = async (dest_id) => {
    try {
      await voteService.voter({
        groupe_id: id,
        type: "destination",
        valeur: String(dest_id),
      });
      setMonVote(String(dest_id));
      setMessage("Vote enregistré !");
      // Recharger les résultats
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

  if (loading) return <div style={styles.loading}>Chargement...</div>;

  const isOrganisateur = groupe?.organisateur_id === user?.id;

  return (
    <div style={styles.page}>
      <div style={styles.header}>
        <h1 style={styles.title}>🗳️ Vote — Destination</h1>
        <p style={styles.sub}>{groupe?.nom}</p>
      </div>

      <div style={styles.body}>
        {message && <div style={styles.success}>{message}</div>}

        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>
            Votez pour votre destination
            <span style={styles.counter}>
              {" "}
              {resultats.reduce((a, r) => a + parseInt(r.nb_votes), 0)} /{" "}
              {totalMembres} votes
            </span>
          </h2>

          <div style={styles.destGrid}>
            {destinations.map((d) => {
              const resultat = resultats.find((r) => r.valeur === String(d.id));
              const nbVotes = resultat ? parseInt(resultat.nb_votes) : 0;
              const votants = resultat ? resultat.votants : "";
              const pct =
                totalMembres > 0
                  ? Math.round((nbVotes / totalMembres) * 100)
                  : 0;
              const isMyVote = monVote === String(d.id);

              return (
                <div
                  key={d.id}
                  style={{
                    ...styles.destCard,
                    border: isMyVote
                      ? "2px solid #185FA5"
                      : "1px solid #E0DED6",
                  }}
                >
                  <div style={styles.destIcon}>
                    {d.categorie === "plage"
                      ? "🏖️"
                      : d.categorie === "montagne"
                        ? "🏔️"
                        : d.categorie === "ville"
                          ? "🏙️"
                          : d.categorie === "aventure"
                            ? "🧗"
                            : "🏛️"}
                  </div>
                  <div style={styles.destInfo}>
                    <div style={styles.destName}>{d.nom}</div>
                    <div style={styles.destPays}>📍 {d.pays}</div>
                    <div style={styles.destPrice}>
                      À partir de {d.prix_min}€
                    </div>

                    {/* Barre de vote */}
                    <div style={styles.voteBarBg}>
                      <div
                        style={{ ...styles.voteBarFill, width: `${pct}%` }}
                      ></div>
                    </div>
                    <div style={styles.voteInfo}>
                      <span>
                        {nbVotes} vote{nbVotes > 1 ? "s" : ""} ({pct}%)
                      </span>
                      {votants && <span style={styles.votants}>{votants}</span>}
                    </div>
                  </div>

                  <div style={styles.destActions}>
                    <button
                      onClick={() => handleVote(d.id)}
                      style={{
                        ...styles.btnVote,
                        background: isMyVote ? "#185FA5" : "white",
                        color: isMyVote ? "white" : "#185FA5",
                      }}
                    >
                      {isMyVote ? "✓ Voté" : "Voter"}
                    </button>

                    {isOrganisateur && nbVotes > 0 && (
                      <button
                        onClick={() => handleValider(String(d.id))}
                        style={styles.btnValider}
                      >
                        Valider
                      </button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Info organisateur */}
        {isOrganisateur && (
          <div style={styles.infoBox}>
            👑 En tant qu'organisateur, vous pouvez valider le choix final après
            le vote. Cliquez sur <strong>"Valider"</strong> sur la destination
            choisie.
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
  header: { background: "#0C447C", color: "white", padding: "32px" },
  title: { fontSize: "26px", fontWeight: "bold", marginBottom: "6px" },
  sub: { opacity: 0.8, fontSize: "14px" },
  body: {
    padding: "24px 32px",
    display: "flex",
    flexDirection: "column",
    gap: "20px",
  },
  success: {
    background: "#EAF3DE",
    color: "#3B6D11",
    padding: "12px 16px",
    borderRadius: "8px",
    fontSize: "14px",
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
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },
  counter: { fontSize: "13px", fontWeight: "normal", color: "#73726c" },
  destGrid: { display: "flex", flexDirection: "column", gap: "12px" },
  destCard: {
    display: "flex",
    alignItems: "center",
    gap: "16px",
    padding: "14px",
    borderRadius: "10px",
    background: "#FAFAF8",
  },
  destIcon: { fontSize: "32px", flexShrink: 0 },
  destInfo: { flex: 1 },
  destName: {
    fontSize: "15px",
    fontWeight: "bold",
    color: "#0C447C",
    marginBottom: "2px",
  },
  destPays: { fontSize: "12px", color: "#73726c", marginBottom: "2px" },
  destPrice: { fontSize: "12px", color: "#185FA5", marginBottom: "6px" },
  voteBarBg: {
    height: "6px",
    background: "#E0DED6",
    borderRadius: "3px",
    overflow: "hidden",
    marginBottom: "4px",
  },
  voteBarFill: {
    height: "100%",
    background: "#185FA5",
    borderRadius: "3px",
    transition: "width 0.3s",
  },
  voteInfo: {
    display: "flex",
    justifyContent: "space-between",
    fontSize: "11px",
    color: "#73726c",
  },
  votants: { color: "#185FA5" },
  destActions: {
    display: "flex",
    flexDirection: "column",
    gap: "6px",
    flexShrink: 0,
  },
  btnVote: {
    padding: "7px 16px",
    borderRadius: "6px",
    cursor: "pointer",
    border: "1px solid #185FA5",
    fontSize: "13px",
    fontWeight: "500",
    whiteSpace: "nowrap",
  },
  btnValider: {
    padding: "7px 16px",
    borderRadius: "6px",
    cursor: "pointer",
    border: "none",
    background: "#EAF3DE",
    color: "#3B6D11",
    fontSize: "13px",
    fontWeight: "500",
    whiteSpace: "nowrap",
  },
  infoBox: {
    background: "#E6F1FB",
    color: "#0C447C",
    padding: "14px 18px",
    borderRadius: "8px",
    fontSize: "13px",
    lineHeight: "1.5",
  },
};
