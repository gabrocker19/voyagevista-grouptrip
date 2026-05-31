import { useState, useEffect, useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { catalogueService } from "../services/catalogue.service";
import { api } from "../services/api";
import { CAT_ICONS, getActivityIcon } from "../utils/icons";

const HEBERG_ICO = { hotel:"🏨", airbnb:"🏠", hostel:"🛏️", villa:"🏡", resort:"🌴" };
const TRANSP_ICO = { avion:"✈️", train:"🚆", bus:"🚌", bateau:"⛴️" };
const CAT_LABELS  = { plage:"🏖️ Plage", montagne:"⛰️ Montagne", ville:"🏙️ Ville", aventure:"🧗 Aventure", culture:"🎭 Culture" };
const CAT_COLORS  = { plage:"#0EA5E9", montagne:"#6366F1", ville:"#8B5CF6", aventure:"#F59E0B", culture:"#EC4899" };

const TYPES_HEB   = ["hotel","airbnb","hostel","villa","resort"];
const TYPES_TRANS = ["avion","train","bus","bateau"];

export default function DestinationDetail() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [dest,         setDest]         = useState(null);
  const [hebergements, setHebergements] = useState([]);
  const [transports,   setTransports]   = useState([]);
  const [activites,    setActivites]    = useState([]);
  const [loading,      setLoading]      = useState(true);
  const [tab,          setTab]          = useState("hebergements");
  const [descExpanded, setDescExpanded] = useState(false);

  // Filtres hébergements
  const [typeHeb,  setTypeHeb]  = useState("");
  const [triHeb,   setTriHeb]   = useState("prix_asc");
  const [capMin,   setCapMin]   = useState(0);

  // Filtres transports
  const [typeTrans, setTypeTrans] = useState("");
  const [triTrans,  setTriTrans]  = useState("prix_asc");

  // Filtres activités
  const [dureeMax, setDureeMax] = useState(0);
  const [triAct,   setTriAct]   = useState("prix_asc");

  useEffect(() => {
    setLoading(true);
    Promise.all([
      api.get(`/api/destinations/${id}`),
      catalogueService.hebergements({ destination_id: id }),
      catalogueService.activites({ destination_id: id }),
    ]).then(([d, hebs, acts]) => {
      setDest(d);
      setHebergements(hebs);
      setActivites(acts);
      // Transports filtrés par destination nom
      return catalogueService.transports({ destination: d.nom })
        .then(t => t.length ? t : catalogueService.transports({ destination: d.pays }));
    }).then(setTransports)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [id]);

  // --- Derived / filtered lists ---
  const hebFiltres = useMemo(() => {
    let list = [...hebergements];
    if (typeHeb) list = list.filter(h => h.type === typeHeb);
    if (capMin > 0) list = list.filter(h => h.capacite >= capMin);
    if (triHeb === "prix_asc")  list.sort((a,b) => a.prix_nuit - b.prix_nuit);
    if (triHeb === "prix_desc") list.sort((a,b) => b.prix_nuit - a.prix_nuit);
    if (triHeb === "cap_desc")  list.sort((a,b) => b.capacite  - a.capacite);
    return list;
  }, [hebergements, typeHeb, triHeb, capMin]);

  const transFiltres = useMemo(() => {
    let list = [...transports];
    if (typeTrans) list = list.filter(t => t.type === typeTrans);
    if (triTrans === "prix_asc")  list.sort((a,b) => a.prix - b.prix);
    if (triTrans === "prix_desc") list.sort((a,b) => b.prix - a.prix);
    if (triTrans === "date_asc")  list.sort((a,b) => new Date(a.date_depart) - new Date(b.date_depart));
    return list;
  }, [transports, typeTrans, triTrans]);

  const actFiltres = useMemo(() => {
    let list = [...activites];
    if (dureeMax > 0) list = list.filter(a => a.duree_heures <= dureeMax);
    if (triAct === "prix_asc")  list.sort((a,b) => a.prix - b.prix);
    if (triAct === "prix_desc") list.sort((a,b) => b.prix - a.prix);
    if (triAct === "dispo")     list.sort((a,b) => b.places_restantes - a.places_restantes);
    return list;
  }, [activites, dureeMax, triAct]);

  // Stats
  const prixMoyenHeb    = hebergements.length ? Math.round(hebergements.reduce((s,h) => s+Number(h.prix_nuit),0)/hebergements.length) : null;
  const prixMoyenTrans  = transports.length   ? Math.round(transports.reduce((s,t) => s+Number(t.prix),0)/transports.length) : null;
  const prixMoyenAct    = activites.length    ? Math.round(activites.reduce((s,a) => s+Number(a.prix),0)/activites.length) : null;

  if (loading) return (
    <div style={s.pageLoading}>
      <div style={s.spinner} />
      <p style={{ color:"#73726c", marginTop:"16px" }}>Chargement de la destination…</p>
    </div>
  );

  if (!dest) return (
    <div style={s.pageLoading}>
      <p style={{ color:"#A32D2D" }}>Destination introuvable.</p>
      <button onClick={() => navigate("/catalogue")} style={s.btnBack}>← Retour au catalogue</button>
    </div>
  );

  const catColor = CAT_COLORS[dest.categorie] || "#185FA5";
  const descShort = dest.description?.length > 180;

  const TABS = [
    { key:"hebergements", label:"🏨 Hébergements", count: hebergements.length, avg: prixMoyenHeb, unit:"/nuit" },
    { key:"transports",   label:"✈️ Transports",   count: transports.length,   avg: prixMoyenTrans, unit:"/pers." },
    { key:"activites",    label:"🎯 Activités",     count: activites.length,    avg: prixMoyenAct, unit:"/pers." },
    { key:"infos",        label:"ℹ️ Infos pratiques", count: null },
  ];

  return (
    <div style={s.page}>

      {/* ── HERO ── */}
      <div style={{
        ...s.hero,
        backgroundImage: dest.image_url ? `url(${dest.image_url})` : undefined,
        backgroundColor: dest.image_url ? undefined : "#E6F1FB",
      }}>
        <div style={s.heroOverlay} />
        <button onClick={() => navigate("/catalogue")} style={s.btnBackHero}>
          <span style={s.btnBackArrow}>←</span>
          Catalogue
        </button>
        <div style={s.heroContent}>
          <div style={s.heroBadge} data-cat={dest.categorie}>
            <span style={{ ...s.catBadge, background: catColor }}>{CAT_LABELS[dest.categorie] || dest.categorie}</span>
          </div>
          <h1 style={s.heroTitle}>{dest.nom}</h1>
          <p style={s.heroPays}>📍 {dest.pays}</p>

          {/* Stats bar */}
          <div style={s.heroStats}>
            <div style={s.heroStat}>
              <span style={s.heroStatVal}>{dest.prix_min}€</span>
              <span style={s.heroStatLbl}>à partir de</span>
            </div>
            <div style={s.heroStatSep} />
            {hebergements.length > 0 && (
              <>
                <div style={s.heroStat}>
                  <span style={s.heroStatVal}>{hebergements.length}</span>
                  <span style={s.heroStatLbl}>hébergements</span>
                </div>
                <div style={s.heroStatSep} />
              </>
            )}
            {transports.length > 0 && (
              <>
                <div style={s.heroStat}>
                  <span style={s.heroStatVal}>{transports.length}</span>
                  <span style={s.heroStatLbl}>trajets dispo</span>
                </div>
                <div style={s.heroStatSep} />
              </>
            )}
            {activites.length > 0 && (
              <div style={s.heroStat}>
                <span style={s.heroStatVal}>{activites.length}</span>
                <span style={s.heroStatLbl}>activités</span>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* ── DESCRIPTION ── */}
      {dest.description && (
        <div style={s.descSection}>
          <p style={s.descText}>
            {descShort && !descExpanded
              ? dest.description.slice(0, 180) + "…"
              : dest.description}
          </p>
          {descShort && (
            <button onClick={() => setDescExpanded(v => !v)} style={s.descToggle}>
              {descExpanded ? "Voir moins ↑" : "Voir plus ↓"}
            </button>
          )}
        </div>
      )}

      {/* ── ONGLETS STICKY ── */}
      <div style={s.tabWrap}>
        <div style={s.tabBar}>
          {TABS.map(t => (
            <button key={t.key} onClick={() => setTab(t.key)} style={tab === t.key ? s.tabActive : s.tab}>
              <span>{t.label}</span>
              {t.count !== null && (
                <span style={tab === t.key ? s.tabCountActive : s.tabCount}>{t.count}</span>
              )}
              {t.avg !== null && t.count > 0 && (
                <span style={s.tabAvg}>~{t.avg}€{t.unit}</span>
              )}
            </button>
          ))}
        </div>
      </div>

      <div style={s.body}>

        {/* ══ HÉBERGEMENTS ══ */}
        {tab === "hebergements" && (
          <>
            <div style={s.filterBar}>
              <div style={s.filterGroup}>
                <label style={s.filterLabel}>Type</label>
                <div style={s.chips}>
                  <button style={typeHeb==="" ? s.chipOn : s.chip} onClick={() => setTypeHeb("")}>Tous</button>
                  {TYPES_HEB.map(t => (
                    <button key={t} style={typeHeb===t ? s.chipOn : s.chip} onClick={() => setTypeHeb(t)}>
                      {HEBERG_ICO[t]} {t}
                    </button>
                  ))}
                </div>
              </div>
              <div style={s.filterGroup}>
                <label style={s.filterLabel}>Tri</label>
                <select style={s.select} value={triHeb} onChange={e => setTriHeb(e.target.value)}>
                  <option value="prix_asc">Prix ↑</option>
                  <option value="prix_desc">Prix ↓</option>
                  <option value="cap_desc">Capacité ↓</option>
                </select>
              </div>
              <div style={s.filterGroup}>
                <label style={s.filterLabel}>Capacité min.</label>
                <select style={s.select} value={capMin} onChange={e => setCapMin(Number(e.target.value))}>
                  <option value={0}>Toutes</option>
                  {[2,4,6,8,10,15,20].map(n => (
                    <option key={n} value={n}>{n}+ personnes</option>
                  ))}
                </select>
              </div>
            </div>

            <div style={s.resultsInfo}>
              {hebFiltres.length} hébergement{hebFiltres.length > 1 ? "s" : ""} trouvé{hebFiltres.length > 1 ? "s" : ""}
            </div>

            {hebFiltres.length === 0
              ? <EmptyState msg="Aucun hébergement ne correspond à vos filtres." />
              : <div style={s.gridHeb}>
                  {hebFiltres.map(h => (
                    <HebCard key={h.id} h={h} />
                  ))}
                </div>
            }
          </>
        )}

        {/* ══ TRANSPORTS ══ */}
        {tab === "transports" && (
          <>
            <div style={s.filterBar}>
              <div style={s.filterGroup}>
                <label style={s.filterLabel}>Moyen</label>
                <div style={s.chips}>
                  <button style={typeTrans==="" ? s.chipOn : s.chip} onClick={() => setTypeTrans("")}>Tous</button>
                  {TYPES_TRANS.map(t => (
                    <button key={t} style={typeTrans===t ? s.chipOn : s.chip} onClick={() => setTypeTrans(t)}>
                      {TRANSP_ICO[t]} {t}
                    </button>
                  ))}
                </div>
              </div>
              <div style={s.filterGroup}>
                <label style={s.filterLabel}>Tri</label>
                <select style={s.select} value={triTrans} onChange={e => setTriTrans(e.target.value)}>
                  <option value="prix_asc">Prix ↑</option>
                  <option value="prix_desc">Prix ↓</option>
                  <option value="date_asc">Départ ↑</option>
                </select>
              </div>
            </div>

            <div style={s.resultsInfo}>
              {transFiltres.length} trajet{transFiltres.length > 1 ? "s" : ""} disponible{transFiltres.length > 1 ? "s" : ""}
            </div>

            {transFiltres.length === 0
              ? <EmptyState msg="Aucun transport ne correspond à vos filtres." />
              : <div style={s.listWrap}>
                  {transFiltres.map(t => (
                    <TransCard key={t.id} t={t} />
                  ))}
                </div>
            }
          </>
        )}

        {/* ══ ACTIVITÉS ══ */}
        {tab === "activites" && (
          <>
            <div style={s.filterBar}>
              <div style={s.filterGroup}>
                <label style={s.filterLabel}>Durée max.</label>
                <div style={s.chips}>
                  <button style={dureeMax===0 ? s.chipOn : s.chip} onClick={() => setDureeMax(0)}>Toutes</button>
                  {[2, 4, 8].map(d => (
                    <button key={d} style={dureeMax===d ? s.chipOn : s.chip} onClick={() => setDureeMax(d)}>
                      ≤ {d}h
                    </button>
                  ))}
                </div>
              </div>
              <div style={s.filterGroup}>
                <label style={s.filterLabel}>Tri</label>
                <select style={s.select} value={triAct} onChange={e => setTriAct(e.target.value)}>
                  <option value="prix_asc">Prix ↑</option>
                  <option value="prix_desc">Prix ↓</option>
                  <option value="dispo">Disponibilité</option>
                </select>
              </div>
            </div>

            <div style={s.resultsInfo}>
              {actFiltres.length} activité{actFiltres.length > 1 ? "s" : ""} trouvée{actFiltres.length > 1 ? "s" : ""}
            </div>

            {actFiltres.length === 0
              ? <EmptyState msg="Aucune activité ne correspond à vos filtres." />
              : <div style={s.gridAct}>
                  {actFiltres.map(a => (
                    <ActCard key={a.id} a={a} />
                  ))}
                </div>
            }
          </>
        )}

        {/* ══ INFOS PRATIQUES ══ */}
        {tab === "infos" && (
          <InfosPratiques dest={dest} catColor={catColor} />
        )}
      </div>
    </div>
  );
}

/* ── Sub-components ── */

function HebCard({ h }) {
  const pct = h.capacite > 0 ? Math.min(100, Math.round((h.places_restantes ?? h.capacite) / h.capacite * 100)) : 100;
  return (
    <div style={sh.card}>
      <div style={sh.imgBox}>{HEBERG_ICO[h.type] || "🏨"}</div>
      <div style={sh.body}>
        <div style={sh.top}>
          <h3 style={sh.name}>{h.nom}</h3>
          <span style={sh.typeBadge}>{h.type}</span>
        </div>
        <p style={sh.desc}>{h.description}</p>
        <div style={sh.row}>
          <span style={sh.info}>👥 {h.capacite} pers. max</span>
        </div>
      </div>
      <div style={sh.right}>
        <div style={sh.price}>{h.prix_nuit}€</div>
        <div style={sh.priceSub}>/nuit</div>
      </div>
    </div>
  );
}

function TransCard({ t }) {
  return (
    <div style={st.card}>
      <div style={st.iconBox}>{TRANSP_ICO[t.type] || "🚀"}</div>
      <div style={st.body}>
        <div style={st.top}>
          <span style={st.compagnie}>{t.compagnie}</span>
          <span style={st.typeBadge}>{TRANSP_ICO[t.type]} {t.type}</span>
        </div>
        <div style={st.trajet}>
          <span style={st.ville}>{t.origine}</span>
          <span style={st.arrow}>→</span>
          <span style={st.ville}>{t.destination}</span>
        </div>
        <div style={st.meta}>
          🗓️ {new Date(t.date_depart).toLocaleDateString("fr-FR",{day:"2-digit",month:"short",year:"numeric",hour:"2-digit",minute:"2-digit"})}
          &nbsp;&nbsp;💺 {t.places_dispo} places
        </div>
      </div>
      <div style={st.right}>
        <div style={st.price}>{t.prix}€</div>
        <div style={st.priceSub}>/pers.</div>
      </div>
    </div>
  );
}

function ActCard({ a }) {
  const complet = a.places_restantes === 0;
  const pct = a.capacite_max > 0 ? Math.round((a.places_restantes / a.capacite_max) * 100) : 0;
  return (
    <div style={{ ...sa.card, opacity: complet ? 0.72 : 1 }}>
      <div style={sa.iconBox}>{getActivityIcon(a.nom)}</div>
      <div style={sa.body}>
        <div style={sa.top}>
          <h3 style={sa.name}>{a.nom}</h3>
          {complet
            ? <span style={sa.badgeFull}>Complet</span>
            : <span style={sa.badgeDispo}>{a.places_restantes} places</span>
          }
        </div>
        <p style={sa.desc}>{a.description}</p>
        <div style={sa.dispo}>
          <div style={sa.barBg}><div style={{ ...sa.barFill, width:`${pct}%`, background: complet ? "#E53E3E" : "#42A85A" }} /></div>
          <span style={sa.meta}>⏱️ {a.duree_heures}h</span>
        </div>
      </div>
      <div style={sa.right}>
        <div style={sa.price}>{a.prix}€</div>
        <div style={sa.priceSub}>/pers.</div>
      </div>
    </div>
  );
}

function InfosPratiques({ dest, catColor }) {
  const infos = getInfos(dest.categorie, dest.pays);
  const recit = getRecit(dest.nom, dest.pays, dest.categorie);
  return (
    <div style={si.wrap}>

      {/* Texte narratif */}
      <div style={si.recitCard}>
        <div style={{ ...si.recitAccent, background: catColor }} />
        <div style={si.recitBody}>
          <div style={si.recitLabel}>✦ À propos</div>
          <h2 style={si.recitTitle}>{dest.nom}</h2>
          {recit.map((para, i) => (
            <p key={i} style={si.recitPara}>{para}</p>
          ))}
        </div>
      </div>

      {/* Blocs pratiques */}
      <div style={si.sectionTitle}>Informations pratiques</div>
      <div style={si.grid}>
        {infos.map((bloc, i) => (
          <div key={i} style={si.card}>
            <div style={{ ...si.cardIcon, background: catColor + "18", color: catColor }}>{bloc.icon}</div>
            <div>
              <div style={si.cardTitle}>{bloc.titre}</div>
              <div style={si.cardText}>{bloc.texte}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function EmptyState({ msg }) {
  return (
    <div style={{ textAlign:"center", padding:"48px 24px", color:"#73726c", fontSize:"14px" }}>
      <div style={{ fontSize:"36px", marginBottom:"12px" }}>🔍</div>
      {msg}
    </div>
  );
}

function getRecit(nom, pays, categorie) {
  const recits = {
    plage: [
      `${nom}, nichée sur les côtes de ${pays}, est l'une de ces destinations qui s'impriment dans la mémoire bien après le retour. Le sable fin, les eaux turquoise et l'air iodé forment un tableau presque irréel au lever du soleil, quand les premiers rayons réchauffent doucement les plages encore désertes et que seuls les pêcheurs locaux animent le rivage.`,
      `Ce littoral a une histoire longue et romanesque. Des siècles durant, des navigateurs, des marchands et des conquistadors ont jeté l'ancre dans ces eaux, façonnant peu à peu une culture maritime riche, mêlant influences locales et apports du monde entier. Les vieux quartiers de pêcheurs témoignent encore de cet héritage, avec leurs barques colorées tirées sur le sable et leurs filets séchant au soleil.`,
      `La gastronomie est ici une institution. Les restaurants du bord de mer proposent des poissons grillés à la minute, des plateaux de fruits de mer et des spécialités locales préparées selon des recettes jalousement transmises de génération en génération. Les marchés du matin sont un spectacle à part entière : couleurs, odeurs et animation garanties dès l'aube.`,
      `Au-delà de la plage, ${nom} réserve bien des surprises. Les fonds marins, d'une richesse exceptionnelle, attirent plongeurs et snorkeleurs du monde entier. Les criques isolées, accessibles à pied ou en bateau, offrent des escapades loin des foules pour ceux qui savent les chercher. Le soir venu, les fronts de mer s'animent : restaurants en terrasse, musique live et marchés artisanaux créent une atmosphère chaleureuse et festive qui se prolonge tard dans la nuit.`,
      `${nom} est aussi une porte d'entrée vers un arrière-pays souvent ignoré des touristes pressés. Quelques kilomètres à l'intérieur des terres, des villages pittoresques, des oliveraies centenaires et des panoramas inattendus viennent compléter un tableau déjà généreux. Une destination complète, qui se livre à ceux qui prennent le temps de l'explorer au-delà de ses plages.`,
    ],
    montagne: [
      `${nom}, perchée dans les hauteurs de ${pays}, est un sanctuaire pour ceux qui cherchent à s'évader du bruit du monde. Les sommets enneigés, les forêts de pins centenaires et les vallées encaissées composent un paysage d'une pureté absolue, où le silence n'est troublé que par le vent dans les sapins ou le cri lointain d'un aigle royal.`,
      `Ces montagnes ont une âme ancienne. Les premières populations à s'y établir y ont développé, au fil des siècles, une culture particulière, forgée par la rudesse du climat et l'isolement des vallées. L'architecture traditionnelle — chalets en bois et pierre, toits à forte pente, greniers à foin — raconte mieux que n'importe quel livre la vie de ceux qui ont apprivoisé ces terres exigeantes.`,
      `La gastronomie de montagne est à l'image du paysage : généreuse, chaleureuse et sans chichis. Fromages affinés dans des caves creusées à même la roche, charcuteries fumées lentement, soupes roboratives et desserts dorés au four à bois — chaque repas est une invitation à s'asseoir, à prendre le temps et à savourer. Les tavernes locales, souvent tenues par des familles depuis plusieurs générations, sont les meilleures ambassadrices de ce patrimoine culinaire.`,
      `En hiver, les pistes de ski attirent les amateurs de glisse de toute l'Europe, mais les montagnes de ${nom} savent aussi se vivre autrement : raquettes, ski de fond, promenades dans la neige fraîche ou simples soirées au coin du feu dans un chalet. En été, les sentiers de randonnée révèlent des panoramas à couper le souffle, des lacs d'altitude aux eaux glacées et des alpages fleuris que broutent paisiblement les troupeaux.`,
      `${nom} se réinvente à chaque saison, et c'est peut-être là son plus grand secret. Ni purement hivernale ni exclusivement estivale, elle appartient à ceux qui savent apprécier ses multiples visages — la majesté des sommets enneigés comme la sérénité des prairies d'été, la fête des remontées mécaniques comme le silence absolu des crêtes en automne.`,
    ],
    ville: [
      `${nom} est l'une de ces villes qui ne ressemblent à aucune autre. Capitale culturelle, artistique ou économique de ${pays}, elle concentre en quelques arrondissements tout ce qui fait la richesse d'une civilisation : musées de renommée mondiale, architecture audacieuse côtoyant des bâtisses séculaires, scène gastronomique en perpétuelle ébullition et une vie nocturne qui refuse de s'endormir.`,
      `La ville a connu des heures glorieuses et des périodes sombres, des révolutions et des renaissances. Chaque époque a laissé ses traces dans la pierre, dans les noms des rues, dans les monuments qui jalonnent ses grandes avenues comme ses ruelles les plus étroites. Se promener dans ${nom}, c'est traverser les siècles en quelques pas, lire l'histoire d'un peuple dans ses facades et ses places publiques.`,
      `Ses quartiers racontent chacun une histoire différente. Ici, un ancien quartier industriel reconverti en hub créatif, avec galeries d'art contemporain, ateliers d'artistes et coffee shops branchés. Là, un centre historique classé où les pavés ont vu défiler rois, révolutionnaires et poètes. Plus loin, un quartier cosmopolite aux mille effluves, reflet de la richesse culturelle de ceux qui ont fait ${nom} au fil des vagues migratoires.`,
      `La scène gastronomique de ${nom} est à elle seule une raison de voyager. Des brasseries traditionnelles aux tables étoilées, en passant par les marchés couverts débordant de produits locaux et les street-food stalls que fréquentent les habitants du coin, chaque repas est une découverte. La ville est aussi une capitale du café, de la bière artisanale ou du vin, selon les traditions locales.`,
      `Se perdre dans ${nom} sans itinéraire fixe reste la meilleure façon de la découvrir. Chaque ruelle, chaque impasse réserve une surprise : une cour intérieure fleurie, un marché aux puces improvisé, une librairie d'occasion, un musicien de rue ou une boutique d'artisanat local. Cette ville se mérite — et récompense généreusement ceux qui prennent le temps de l'explorer au-delà des incontournables.`,
    ],
    aventure: [
      `${nom}, au cœur des terres sauvages de ${pays}, est une invitation à repousser ses limites et à retrouver quelque chose d'essentiel. Ici, la nature ne négocie pas : canyons vertigineux, rivières en furie, forêts impénétrables et sommets qui défient les nuages composent un décor grandeur nature pour les esprits qui ont besoin de se sentir vivants.`,
      `Cette région a longtemps été le domaine exclusif des peuples nomades et des explorateurs intrépides. Les récits de leurs traversées, conservés dans des carnets de route usés et des photographies jaunies, ont nourri des générations de rêveurs. Aujourd'hui, randonneurs, alpinistes, kayakistes et vététistes viennent à leur tour écrire leur propre histoire dans ces paysages que les siècles n'ont pas réussi à domestiquer.`,
      `La faune et la flore de ${nom} constituent un spectacle en soi. Des espèces endémiques, nichées dans des biotopes préservés loin des perturbations humaines, côtoient des paysages végétaux d'une diversité rare. Les guides naturalistes locaux, véritables encyclopédies vivantes de leur territoire, savent transformer une randonnée ordinaire en expédition scientifique passionnante.`,
      `La culture locale est à l'image du paysage : brute, authentique et sans artifice. Les villages perchés sur les hauteurs, où le temps semble s'être arrêté, accueillent les voyageurs avec une hospitalité sincère et sans calcul. Les repas partagés autour d'un feu de camp, les chants traditionnels qui résonnent dans les gorges au crépuscule, les objets artisanaux fabriqués selon des techniques ancestrales — tout cela forme un patrimoine immatériel d'une valeur inestimable.`,
      `Préparez-vous sérieusement avant de partir à la découverte de ${nom} : équipement adapté, forme physique au rendez-vous et respect absolu de la nature sont les conditions d'une expérience réussie. Les aventures les plus mémorables sont celles qui ont été menées avec la tête et le cœur. Et celles que l'on ramène de ${nom} ne s'oublient pas.`,
    ],
    culture: [
      `${nom} se lit comme un roman dont on ne veut pas tourner la dernière page. Chaque monument, chaque musée, chaque place publique est un chapitre de l'histoire de ${pays} et, plus largement, de l'histoire de l'humanité. Des civilisations y ont prospéré, des empires s'y sont construits et effondrés, des révolutions artistiques y ont changé le cours de l'art mondial — tout cela s'est joué ici, sur cette terre que les siècles ont rendue unique.`,
      `Le patrimoine architectural de ${nom} est époustouflant. Temples antiques et cathédrales gothiques voisinent avec des palais baroques et des chef-d'œuvres du modernisme. Chaque style porte l'empreinte de son époque, chaque pierre raconte une conquête, une dévotion ou une ambition. Se promener dans les rues de ${nom}, c'est traverser les millénaires en quelques pas.`,
      `Les musées de ${nom} comptent parmi les plus riches du monde. Peintures de maîtres, sculptures antiques, collections archéologiques et installations contemporaines cohabitent dans des espaces où l'on pourrait passer des journées entières sans jamais s'ennuyer. La scène artistique vivante — galeries, ateliers ouverts, biennales et festivals — prouve que ${nom} ne vit pas que de son passé.`,
      `La cuisine locale est elle-même un patrimoine. Les marchés débordent de produits frais que les cuisiniers transforment selon des recettes transmises de génération en génération, jalousement gardées comme des trésors de famille. Les restaurants populaires, loin du tourisme de masse, sont les meilleurs endroits pour goûter l'âme d'un peuple à travers ses saveurs.`,
      `Ce qui rend ${nom} véritablement inoubliable, c'est la densité de tout ce qu'elle offre. En quelques jours, on peut assister à un concert de musique classique dans une salle centenaire, visiter une exposition d'art contemporain dans un entrepôt reconverti, déjeuner dans un restaurant triplement étoilé et terminer la soirée dans une taverne populaire où les habitués chantent en chœur jusqu'à l'aube. Une destination totale, pour des voyageurs curieux de tout.`,
    ],
  };
  return recits[categorie] || [
    `${nom}, en ${pays}, est une destination qui sait surprendre et émouvoir à chaque détour. Entre paysages d'exception, culture locale vivante et accueil chaleureux des habitants, ce voyage promet de laisser des souvenirs que le temps ne saura pas effacer.`,
    `Chaque quartier, chaque rue, chaque marché de ${nom} recèle ses propres trésors. Patrimoine historique, gastronomie généreuse, artisanat local et atmosphère unique se combinent pour créer une expérience de voyage complète et inoubliable.`,
    `Que vous soyez en quête de détente, de découverte culturelle, de sensations fortes ou simplement d'un changement de décor, ${nom} saura répondre à vos attentes — et les dépasser. Une destination à explorer sans modération, au fil de ses envies et de ses humeurs.`,
  ];
}

function getInfos(categorie, pays) {
  return [
    {
      icon: "🌡️",
      titre: "Climat",
      texte: { plage:"Chaud et ensoleillé, 25–35 °C en été. Doux hors saison.", montagne:"Neige en hiver, frais en été (10–20 °C). Attention aux gelées nocturnes.", ville:"Tempéré, 4 saisons. Printemps et automne sont idéaux.", aventure:"Microclimats variables. Saison sèche recommandée pour les activités.", culture:"Méditerranéen ou continental. Printemps et automne parfaits." }[categorie] || "Varié selon les saisons, renseignez-vous avant le départ.",
    },
    {
      icon: "📅",
      titre: "Meilleure saison",
      texte: { plage:"Juin–septembre (hémisphère nord). Mai ou octobre pour éviter les foules.", montagne:"Déc.–mars pour le ski, juil.–août pour la randonnée. Sept. pour le calme.", ville:"Mai–juin et sept.–oct. Noël pour l'ambiance festive.", aventure:"Saison sèche locale. Évitez la mousson selon la région.", culture:"Mars–mai et sept.–nov. Évitez les pics touristiques estivaux." }[categorie] || "Varie selon vos activités. Vérifiez le calendrier local.",
    },
    {
      icon: "🗣️",
      titre: "Langue",
      texte: `Langue locale parlée en ${pays}. L'anglais est courant dans les zones touristiques. Quelques mots locaux sont toujours appréciés.`,
    },
    {
      icon: "💳",
      titre: "Monnaie",
      texte: `Vérifiez la monnaie locale et le taux de change. Carte acceptée en ville, prévoyez du cash ailleurs. Prévenez votre banque avant de partir.`,
    },
    {
      icon: "🛂",
      titre: "Visa",
      texte: `Les conditions d'entrée en ${pays} varient selon votre nationalité. Vérifiez la validité de votre passeport (6 mois min.) et les exigences de visa sur le site officiel de votre gouvernement.`,
    },
    {
      icon: "🏥",
      titre: "Santé",
      texte: `Assurance voyage recommandée. Consultez un médecin 4–6 semaines avant le départ pour les vaccins. Emportez une trousse de base et vérifiez la qualité de l'eau locale.`,
    },
  ];
}

/* ── Styles ── */

const s = {
  page:        { fontFamily:"'Inter', Arial, sans-serif", minHeight:"100vh", background:"#F5F4F0" },
  pageLoading: { minHeight:"100vh", display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center", background:"#F5F4F0" },
  spinner:     { width:"36px", height:"36px", border:"3px solid #E0DED6", borderTopColor:"#185FA5", borderRadius:"50%", animation:"spin 0.8s linear infinite" },
  btnBack:     { marginTop:"16px", padding:"8px 20px", borderRadius:"8px", border:"none", background:"#185FA5", color:"white", cursor:"pointer", fontSize:"13px" },

  btnBackHero: { position:"absolute", top:"20px", left:"24px", zIndex:2, display:"inline-flex", alignItems:"center", gap:"6px", padding:"7px 16px 7px 10px", borderRadius:"20px", border:"1px solid rgba(255,255,255,0.35)", background:"rgba(0,0,0,0.28)", backdropFilter:"blur(8px)", color:"white", cursor:"pointer", fontSize:"12px", fontWeight:"600" },
  btnBackArrow:{ display:"inline-flex", alignItems:"center", justifyContent:"center", width:"18px", height:"18px", borderRadius:"50%", background:"rgba(255,255,255,0.22)", fontSize:"11px", lineHeight:1 },
  hero:        { position:"relative", height:"360px", backgroundSize:"cover", backgroundPosition:"center", display:"flex", alignItems:"flex-end" },
  heroOverlay: { position:"absolute", inset:0, background:"linear-gradient(to top, rgba(0,0,0,0.75) 0%, rgba(0,0,0,0.15) 60%, transparent 100%)" },
  heroContent: { position:"relative", zIndex:1, width:"100%", padding:"28px 32px" },
  heroBadge:   { marginBottom:"10px", marginTop:"0" },
  catBadge:    { display:"inline-block", padding:"4px 14px", borderRadius:"20px", fontSize:"12px", fontWeight:"700", color:"white", letterSpacing:"0.3px" },
  heroTitle:   { fontSize:"36px", fontWeight:"800", color:"white", margin:"0 0 4px", textShadow:"0 2px 8px rgba(0,0,0,0.4)", lineHeight:1.15 },
  heroPays:    { fontSize:"14px", color:"rgba(255,255,255,0.82)", margin:"0 0 16px" },
  heroStats:   { display:"flex", alignItems:"center", gap:"0", background:"rgba(255,255,255,0.12)", backdropFilter:"blur(8px)", borderRadius:"12px", padding:"12px 20px", width:"fit-content", flexWrap:"wrap" },
  heroStat:    { display:"flex", flexDirection:"column", alignItems:"center", padding:"0 18px" },
  heroStatVal: { fontSize:"22px", fontWeight:"800", color:"white", lineHeight:1 },
  heroStatLbl: { fontSize:"10px", color:"rgba(255,255,255,0.7)", marginTop:"2px", textTransform:"uppercase", letterSpacing:"0.5px" },
  heroStatSep: { width:"1px", height:"32px", background:"rgba(255,255,255,0.25)" },

  descSection: { background:"white", padding:"20px 32px", borderBottom:"1px solid #E0DED6" },
  descText:    { fontSize:"14px", lineHeight:"1.7", color:"#444", margin:0 },
  descToggle:  { marginTop:"8px", background:"none", border:"none", color:"#185FA5", cursor:"pointer", fontSize:"13px", fontWeight:"600", padding:0 },

  tabWrap:     { position:"sticky", top:"0", zIndex:10, background:"white", borderBottom:"1px solid #E0DED6", boxShadow:"0 2px 8px rgba(0,0,0,0.06)" },
  tabBar:      { display:"flex", overflowX:"auto", padding:"0 24px" },
  tab:         { display:"flex", alignItems:"center", gap:"6px", padding:"14px 18px", border:"none", background:"none", cursor:"pointer", fontSize:"13px", color:"#73726c", borderBottom:"3px solid transparent", whiteSpace:"nowrap", transition:"color 0.15s" },
  tabActive:   { display:"flex", alignItems:"center", gap:"6px", padding:"14px 18px", border:"none", background:"none", cursor:"pointer", fontSize:"13px", color:"#185FA5", fontWeight:"700", borderBottom:"3px solid #185FA5", whiteSpace:"nowrap" },
  tabCount:    { background:"#F0F4F8", color:"#73726c", borderRadius:"20px", padding:"1px 7px", fontSize:"11px", fontWeight:"600" },
  tabCountActive:{ background:"#E6F1FB", color:"#185FA5", borderRadius:"20px", padding:"1px 7px", fontSize:"11px", fontWeight:"700" },
  tabAvg:      { background:"#F5F4F0", color:"#73726c", borderRadius:"20px", padding:"1px 8px", fontSize:"10px" },

  body:        { padding:"20px 24px 40px", display:"flex", flexDirection:"column", gap:"16px" },

  filterBar:   { background:"white", borderRadius:"12px", padding:"16px 20px", display:"flex", gap:"20px", flexWrap:"wrap", alignItems:"flex-end", boxShadow:"0 1px 4px rgba(0,0,0,0.05)" },
  filterGroup: { display:"flex", flexDirection:"column", gap:"6px" },
  filterLabel: { fontSize:"11px", fontWeight:"700", color:"#73726c", textTransform:"uppercase", letterSpacing:"0.4px" },
  chips:       { display:"flex", gap:"6px", flexWrap:"wrap" },
  chip:        { padding:"5px 12px", borderRadius:"20px", border:"1px solid #D1CFC5", background:"white", cursor:"pointer", fontSize:"12px", transition:"all 0.12s" },
  chipOn:      { padding:"5px 12px", borderRadius:"20px", border:"1px solid #185FA5", background:"#185FA5", color:"white", cursor:"pointer", fontSize:"12px" },
  select:      { padding:"7px 12px", borderRadius:"8px", border:"1px solid #D1CFC5", fontSize:"13px", background:"white", cursor:"pointer" },

  resultsInfo: { fontSize:"12px", color:"#73726c", fontStyle:"italic" },

  gridHeb:     { display:"grid", gridTemplateColumns:"repeat(auto-fill, minmax(300px, 1fr))", gap:"12px" },
  listWrap:    { display:"flex", flexDirection:"column", gap:"10px" },
  gridAct:     { display:"grid", gridTemplateColumns:"repeat(auto-fill, minmax(280px, 1fr))", gap:"12px" },
};

/* Hébergement card styles */
const sh = {
  card:     { background:"white", borderRadius:"12px", overflow:"hidden", display:"flex", boxShadow:"0 2px 8px rgba(0,0,0,0.07)", transition:"transform 0.15s, box-shadow 0.15s" },
  imgBox:   { width:"72px", flexShrink:0, background:"#E6F1FB", display:"flex", alignItems:"center", justifyContent:"center", fontSize:"30px" },
  body:     { flex:1, padding:"14px 12px", minWidth:0 },
  top:      { display:"flex", justifyContent:"space-between", alignItems:"flex-start", gap:"6px", marginBottom:"4px" },
  name:     { fontSize:"14px", fontWeight:"700", color:"#0C447C", margin:0 },
  typeBadge:{ background:"#E6F1FB", color:"#185FA5", padding:"2px 9px", borderRadius:"12px", fontSize:"10px", whiteSpace:"nowrap" },
  desc:     { fontSize:"12px", color:"#73726c", lineHeight:"1.4", marginBottom:"6px", display:"-webkit-box", WebkitLineClamp:2, WebkitBoxOrient:"vertical", overflow:"hidden" },
  row:      { display:"flex", gap:"8px", flexWrap:"wrap" },
  info:     { fontSize:"11px", color:"#444", background:"#F5F4F0", padding:"2px 8px", borderRadius:"8px" },
  right:    { padding:"14px 16px", textAlign:"right", flexShrink:0, display:"flex", flexDirection:"column", justifyContent:"center" },
  price:    { fontSize:"20px", fontWeight:"800", color:"#0C447C" },
  priceSub: { fontSize:"11px", color:"#73726c" },
};

/* Transport card styles */
const st = {
  card:     { background:"white", borderRadius:"12px", display:"flex", alignItems:"center", padding:"14px 16px", gap:"14px", boxShadow:"0 2px 8px rgba(0,0,0,0.07)" },
  iconBox:  { width:"48px", height:"48px", background:"#E6F1FB", borderRadius:"10px", display:"flex", alignItems:"center", justifyContent:"center", fontSize:"22px", flexShrink:0 },
  body:     { flex:1, minWidth:0 },
  top:      { display:"flex", alignItems:"center", gap:"8px", marginBottom:"4px" },
  compagnie:{ fontSize:"14px", fontWeight:"700", color:"#0C447C" },
  typeBadge:{ background:"#F5F4F0", color:"#73726c", padding:"2px 8px", borderRadius:"10px", fontSize:"10px" },
  trajet:   { display:"flex", alignItems:"center", gap:"8px", marginBottom:"4px" },
  ville:    { fontSize:"13px", fontWeight:"600", color:"#2C2C2A" },
  arrow:    { color:"#185FA5", fontWeight:"bold" },
  meta:     { fontSize:"12px", color:"#73726c" },
  right:    { textAlign:"right", flexShrink:0 },
  price:    { fontSize:"20px", fontWeight:"800", color:"#0C447C" },
  priceSub: { fontSize:"11px", color:"#73726c" },
};

/* Activité card styles */
const sa = {
  card:     { background:"white", borderRadius:"12px", display:"flex", boxShadow:"0 2px 8px rgba(0,0,0,0.07)" },
  iconBox:  { width:"60px", flexShrink:0, background:"#EAF3DE", display:"flex", alignItems:"center", justifyContent:"center", fontSize:"26px", borderRadius:"12px 0 0 12px" },
  body:     { flex:1, padding:"14px 12px", minWidth:0 },
  top:      { display:"flex", justifyContent:"space-between", alignItems:"flex-start", gap:"6px", marginBottom:"4px" },
  name:     { fontSize:"14px", fontWeight:"700", color:"#0C447C", margin:0 },
  badgeDispo:{ background:"#EAF3DE", color:"#3B6D11", padding:"2px 9px", borderRadius:"12px", fontSize:"10px", whiteSpace:"nowrap" },
  badgeFull: { background:"#FCEBEB", color:"#A32D2D", padding:"2px 9px", borderRadius:"12px", fontSize:"10px", whiteSpace:"nowrap" },
  desc:     { fontSize:"12px", color:"#73726c", lineHeight:"1.4", marginBottom:"8px", display:"-webkit-box", WebkitLineClamp:2, WebkitBoxOrient:"vertical", overflow:"hidden" },
  dispo:    { display:"flex", alignItems:"center", gap:"8px" },
  barBg:    { flex:1, height:"4px", background:"#E0DED6", borderRadius:"3px", overflow:"hidden" },
  barFill:  { height:"100%", borderRadius:"3px", transition:"width 0.3s" },
  meta:     { fontSize:"11px", color:"#73726c", whiteSpace:"nowrap" },
  right:    { padding:"14px 16px", textAlign:"right", flexShrink:0, display:"flex", flexDirection:"column", justifyContent:"center" },
  price:    { fontSize:"20px", fontWeight:"800", color:"#0C447C" },
  priceSub: { fontSize:"11px", color:"#73726c" },
};

/* Infos pratiques styles */
const si = {
  wrap:         { padding:"4px 0", display:"flex", flexDirection:"column", gap:"20px" },
  recitCard:    { background:"white", borderRadius:"16px", overflow:"hidden", boxShadow:"0 2px 10px rgba(0,0,0,0.08)", display:"flex" },
  recitAccent:  { width:"5px", flexShrink:0 },
  recitBody:    { padding:"28px 32px", flex:1 },
  recitLabel:   { fontSize:"11px", fontWeight:"700", letterSpacing:"1.5px", textTransform:"uppercase", color:"#73726c", marginBottom:"8px" },
  recitTitle:   { fontSize:"24px", fontWeight:"800", color:"#0C447C", margin:"0 0 20px" },
  recitPara:    { fontSize:"14px", lineHeight:"1.85", color:"#444", margin:"0 0 14px" },
  sectionTitle: { fontSize:"12px", fontWeight:"700", textTransform:"uppercase", letterSpacing:"1px", color:"#73726c" },
  grid:         { display:"grid", gridTemplateColumns:"repeat(auto-fill, minmax(300px, 1fr))", gap:"12px" },
  card:         { background:"white", borderRadius:"12px", padding:"18px 20px", display:"flex", gap:"14px", alignItems:"flex-start", boxShadow:"0 2px 8px rgba(0,0,0,0.06)" },
  cardIcon:     { width:"44px", height:"44px", borderRadius:"10px", display:"flex", alignItems:"center", justifyContent:"center", fontSize:"22px", flexShrink:0 },
  cardTitle:    { fontSize:"13px", fontWeight:"700", color:"#0C447C", marginBottom:"5px" },
  cardText:     { fontSize:"12px", color:"#73726c", lineHeight:"1.6" },
};
