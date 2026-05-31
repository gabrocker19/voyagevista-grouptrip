-- ============================================================
--  VoyageVista — GroupTrip
--  Script complet : schéma + données (seed v2 + seed extra)
--  Équipe : Gabin Kerevel · Aurélien Kammerer · Brice Fargeat · Isiah Perelman
--  Projet Web dynamique 2026 — ING2
--
--  Ordre d'import : ce fichier suffit, tout est inclus.
-- ============================================================

SET NAMES utf8mb4;
SET foreign_key_checks = 0;

-- ============================================================
-- BASE DE DONNÉES
-- ============================================================
DROP DATABASE IF EXISTS voyagevista;
CREATE DATABASE voyagevista CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE voyagevista;

-- ============================================================
-- 1. UTILISATEURS
-- ============================================================
CREATE TABLE utilisateurs (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nom           VARCHAR(100)  NOT NULL,
    email         VARCHAR(150)  NOT NULL UNIQUE,
    mot_de_passe  VARCHAR(255)  NOT NULL,
    role          ENUM('membre', 'admin') DEFAULT 'membre',
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 2. DESTINATIONS
-- ============================================================
CREATE TABLE destinations (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nom           VARCHAR(150)  NOT NULL,
    pays          VARCHAR(100)  NOT NULL,
    categorie     ENUM('plage', 'montagne', 'ville', 'aventure', 'culture') NOT NULL,
    description   TEXT,
    prix_min      DECIMAL(10,2) DEFAULT 0,
    image_url     VARCHAR(255),
    icone         VARCHAR(10)   DEFAULT '🌍',
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 3. TRANSPORTS
-- ============================================================
CREATE TABLE transports (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    compagnie     VARCHAR(100)  NOT NULL,
    type          ENUM('avion', 'train', 'bus', 'bateau') NOT NULL,
    origine       VARCHAR(100)  NOT NULL,
    destination   VARCHAR(100)  NOT NULL,
    date_depart   DATETIME      NOT NULL,
    date_arrivee  DATETIME      NOT NULL,
    prix          DECIMAL(10,2) NOT NULL,
    places_dispo  INT           NOT NULL DEFAULT 100
);

-- ============================================================
-- 4. HEBERGEMENTS
-- ============================================================
CREATE TABLE hebergements (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    destination_id  INT          NOT NULL,
    nom             VARCHAR(150) NOT NULL,
    type            ENUM('hotel', 'airbnb', 'hostel', 'villa', 'resort') NOT NULL,
    prix_nuit       DECIMAL(10,2) NOT NULL,
    capacite        INT           NOT NULL,
    description     TEXT,
    image_url       VARCHAR(255),
    FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE CASCADE
);

-- ============================================================
-- 5. ACTIVITÉS
-- ============================================================
CREATE TABLE activites (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    destination_id  INT          NOT NULL,
    nom             VARCHAR(150) NOT NULL,
    description     TEXT,
    prix            DECIMAL(10,2) NOT NULL,
    capacite_max    INT           NOT NULL DEFAULT 20,
    places_restantes INT          NOT NULL DEFAULT 20,
    duree_heures    DECIMAL(4,1),
    FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE CASCADE
);

-- ============================================================
-- 6. GROUPES
-- ============================================================
CREATE TABLE groupes (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    nom              VARCHAR(150) NOT NULL,
    destination_id   INT,
    date_depart      DATE,
    date_retour      DATE,
    budget_max       DECIMAL(10,2),
    statut           ENUM('en_formation', 'vote_en_cours', 'plan_valide', 'reservation_confirmee') DEFAULT 'en_formation',
    organisateur_id  INT NOT NULL,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (organisateur_id) REFERENCES utilisateurs(id),
    FOREIGN KEY (destination_id)  REFERENCES destinations(id)
);

-- ============================================================
-- 7. MEMBRES DU GROUPE
-- ============================================================
CREATE TABLE membres_groupe (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id   INT NOT NULL,
    groupe_id        INT NOT NULL,
    role             ENUM('organisateur', 'membre') DEFAULT 'membre',
    statut           ENUM('en_attente', 'accepte', 'refuse') DEFAULT 'en_attente',
    joined_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_membre (utilisateur_id, groupe_id),
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (groupe_id)      REFERENCES groupes(id)      ON DELETE CASCADE
);

-- ============================================================
-- 8. VOTES
-- ============================================================
CREATE TABLE votes (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id   INT NOT NULL,
    groupe_id        INT NOT NULL,
    type             ENUM('destination', 'dates', 'hebergement', 'activite') NOT NULL,
    valeur           VARCHAR(255) NOT NULL,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_vote (utilisateur_id, groupe_id, type),
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (groupe_id)      REFERENCES groupes(id)      ON DELETE CASCADE
);

-- ============================================================
-- 9. ITINÉRAIRES
-- ============================================================
CREATE TABLE itineraires (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    groupe_id        INT NOT NULL UNIQUE,
    transport_id     INT,
    hebergement_id   INT,
    cout_total       DECIMAL(10,2) DEFAULT 0,
    statut           ENUM('brouillon', 'soumis', 'valide') DEFAULT 'brouillon',
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (groupe_id)      REFERENCES groupes(id)      ON DELETE CASCADE,
    FOREIGN KEY (transport_id)   REFERENCES transports(id),
    FOREIGN KEY (hebergement_id) REFERENCES hebergements(id)
);

-- ============================================================
-- 10. ACTIVITÉS DE L'ITINÉRAIRE (table pivot)
-- ============================================================
CREATE TABLE itineraire_activites (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    itineraire_id    INT NOT NULL,
    activite_id      INT NOT NULL,
    UNIQUE KEY unique_activite (itineraire_id, activite_id),
    FOREIGN KEY (itineraire_id) REFERENCES itineraires(id) ON DELETE CASCADE,
    FOREIGN KEY (activite_id)   REFERENCES activites(id)   ON DELETE CASCADE
);

-- ============================================================
-- 11. APPROBATIONS
-- ============================================================
CREATE TABLE approbations (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    itineraire_id    INT NOT NULL,
    utilisateur_id   INT NOT NULL,
    approuve         BOOLEAN DEFAULT FALSE,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_approbation (itineraire_id, utilisateur_id),
    FOREIGN KEY (itineraire_id)  REFERENCES itineraires(id)  ON DELETE CASCADE,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
);

-- ============================================================
-- 12. RÉSERVATIONS
-- ============================================================
CREATE TABLE reservations (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    itineraire_id    INT NOT NULL,
    utilisateur_id   INT NOT NULL,
    montant          DECIMAL(10,2) NOT NULL,
    statut_paiement  ENUM('en_attente', 'paye', 'annule') DEFAULT 'en_attente',
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (itineraire_id)  REFERENCES itineraires(id)  ON DELETE CASCADE,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
);

-- ============================================================
-- 13. DÉPENSES PARTAGÉES
-- ============================================================
CREATE TABLE depenses (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    groupe_id        INT NOT NULL,
    payeur_id        INT NOT NULL,
    description      VARCHAR(255) NOT NULL,
    montant          DECIMAL(10,2) NOT NULL,
    date_depense     DATE DEFAULT (CURRENT_DATE),
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (groupe_id) REFERENCES groupes(id)      ON DELETE CASCADE,
    FOREIGN KEY (payeur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
);

-- ============================================================
-- 14. NOTIFICATIONS
-- ============================================================
CREATE TABLE notifications (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id   INT NOT NULL,
    type             VARCHAR(50)  NOT NULL,
    message          TEXT         NOT NULL,
    lu               BOOLEAN DEFAULT FALSE,
    lien             VARCHAR(255) DEFAULT NULL,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
);

-- ============================================================
-- DONNÉES — UTILISATEURS
-- ============================================================

-- Admin
INSERT INTO utilisateurs (nom, email, mot_de_passe, role) VALUES
('Admin', 'admin@voyagevista.fr', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');
-- mot de passe : password

-- Utilisateurs de test
INSERT INTO utilisateurs (nom, email, mot_de_passe, role) VALUES
('Gabin Kerevel',     'gabin@test.fr',   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'membre'),
('Aurélien Kammerer', 'aurelien@test.fr','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'membre'),
('Brice Fargeat',     'brice@test.fr',   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'membre'),
('Isiah Perelman',    'isiah@test.fr',   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'membre');
-- mot de passe pour tous : password


-- ============================================================
-- DONNÉES — DESTINATIONS (65 au total, IDs 1-65)
-- ============================================================

-- Lot 1 : plage (nouvelles)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(7,'Maldives','Maldives','plage','Atolls de coraux turquoise, bungalows sur pilotis et eaux cristallines.',2200.00,'https://images.unsplash.com/photo-1573843981267-be1999ff37cd?w=800&q=80'),
(8,'Phuket','Thaïlande','plage','Baies secrètes, plages de sable blanc, cuisine de rue et vie nocturne animée.',650.00,'https://images.unsplash.com/photo-1589394815804-964ed0be2eb5?w=800&q=80'),
(9,'Cancún','Mexique','plage','Mer des Caraïbes turquoise, zone hôtelière animée et ruines mayas à proximité.',720.00,'https://images.unsplash.com/photo-1552074284-5e88ef1aef18?w=800&q=80'),
(10,'Seychelles','Seychelles','plage','Archipel préservé aux rochers de granit rose et biodiversité unique.',2500.00,'https://images.unsplash.com/photo-1573624337853-5e7d3e9e843e?w=800&q=80'),
(11,'Zanzibar','Tanzanie','plage','Île épicée aux plages de sable blanc et vieille ville historique.',890.00,'https://images.unsplash.com/photo-1586861203927-800a5acdcc4d?w=800&q=80');

-- Lot 2 : plage (suite)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(12,'Mykonos','Grèce','plage','Moulins à vent emblématiques, plages animées et gastronomie méditerranéenne.',950.00,'https://images.unsplash.com/photo-1601581987809-a874a81309c9?w=800&q=80'),
(13,'Ibiza','Espagne','plage','Île festive aux clubs légendaires, calanques cachées et marchés hippies.',680.00,'https://images.unsplash.com/photo-1503912882839-cf1b57f1c0a4?w=800&q=80'),
(14,'Bora Bora','Polynésie française','plage','Lagon turquoise mythique, monts volcaniques verdoyants et luxe discret.',3200.00,'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=80'),
(15,'Île Maurice','Maurice','plage','Plages de sable doux, lagons protégés par des récifs et culture métissée.',1100.00,'https://images.unsplash.com/photo-1504275107627-0c2ba7a43dba?w=800&q=80'),
(16,'Miami Beach','États-Unis','plage','Art déco pastel, South Beach animée, musées et gastronomie Floride-Caraïbes.',980.00,'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80');

-- Lot 3 : montagne
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(17,'Chamonix','France','montagne','Berceau de l\'alpinisme au pied du Mont-Blanc, ski hors-piste et randonnées.',890.00,'https://images.unsplash.com/photo-1551524163-a4fc34a25a3f?w=800&q=80'),
(18,'Queenstown','Nouvelle-Zélande','montagne','Capitale mondiale de l\'aventure : bungy, ski, jet-boat et fjords de Milford Sound.',1600.00,'https://images.unsplash.com/photo-1507699622108-4be3abd695ad?w=800&q=80'),
(19,'Zermatt','Suisse','montagne','Village sans voitures au pied du Cervin, ski de renommée mondiale.',1450.00,'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80'),
(20,'Dolomites','Italie','montagne','Aiguilles calcaires rose-orangées, via ferrata épiques et refuges alpins.',780.00,'https://images.unsplash.com/photo-1551524163-a4fc34a25a3f?w=800&q=80'),
(21,'Tromsø','Norvège','montagne','Cité arctique pour les aurores boréales, chiens de traîneau et baleines.',1300.00,'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&q=80'),
(22,'Aspen','États-Unis','montagne','Station de ski élégante du Colorado, gastronomie raffinée et festivals culturels.',1800.00,'https://images.unsplash.com/photo-1548777123-e216912df7d8?w=800&q=80');

-- Lot 4 : ville
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(23,'Barcelone','Espagne','ville','Gaudí, Ramblas, tapas, plage en ville et fête perpétuelle en Catalogne.',550.00,'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800&q=80'),
(24,'Amsterdam','Pays-Bas','ville','Canaux romantiques, musées world-class, vélos partout et maisons penchées.',600.00,'https://images.unsplash.com/photo-1534351590666-13e3e96b5017?w=800&q=80'),
(25,'Singapour','Singapour','ville','Cité-état ultramoderne, Gardens by the Bay et street food pluriculturel primé.',1250.00,'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=800&q=80'),
(26,'Prague','République tchèque','ville','Château médiéval dominant 100 clochers, bière artisanale et ambiance bohème.',380.00,'https://images.unsplash.com/photo-1541849546-216549ae216d?w=800&q=80'),
(27,'Dubaï','Émirats arabes unis','ville','Gratte-ciel records, souks dorés, désert à 30 min et luxe absolu partout.',1350.00,'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80');

-- Lot 5 : ville (suite)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(28,'New York','États-Unis','ville','La ville qui ne dort jamais : Central Park, Broadway et skyline légendaire.',1200.00,'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800&q=80'),
(29,'Bangkok','Thaïlande','ville','Temples bouddhistes dorés, tuk-tuks, marchés flottants et nuits électrisantes.',490.00,'https://images.unsplash.com/photo-1563492065599-3520f775eeed?w=800&q=80');

-- Lot 6 : culture
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(30,'Marrakech','Maroc','culture','Médina millénaire, souks labyrinthiques, riads colorés et cuisine épicée.',420.00,'https://images.unsplash.com/photo-1539020140153-e479b8c22e70?w=800&q=80'),
(31,'Rome','Italie','culture','Musée à ciel ouvert : Colisée, Vatican, fontaines baroques et pasta maison.',580.00,'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800&q=80'),
(32,'Istanbul','Turquie','culture','Carrefour de deux continents, mosquées ottomanes et croisière sur le Bosphore.',490.00,'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800&q=80'),
(33,'Kyoto','Japon','culture','Ancienne capitale impériale, jardins zen, geishas et temples de bambou.',980.00,'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80'),
(34,'Le Caire','Égypte','culture','Pyramides de Gizeh, musée égyptien et croisière inoubliable sur le Nil.',560.00,'https://images.unsplash.com/photo-1539768942893-daf525e5d1e5?w=800&q=80');

-- Lot 7 : aventure
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(35,'Reykjavik','Islande','aventure','Geysers, cascades mythiques, aurores boréales et paysages de feu et glace.',1100.00,'https://images.unsplash.com/photo-1474690870753-1b92efa1f2d8?w=800&q=80'),
(36,'Nairobi','Kenya','aventure','Porte du safari africain : Masaï Mara, lions et couchers de soleil sur la savane.',1400.00,'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800&q=80'),
(37,'San José','Costa Rica','aventure','Forêts tropicales, volcans actifs, surf sur deux océans et zip-line en canopée.',980.00,'https://images.unsplash.com/photo-1518259102261-b40117eabbc9?w=800&q=80'),
(38,'El Calafate','Argentine','aventure','Glacier Perito Moreno imposant, condors des Andes et trekking à Torres del Paine.',1250.00,'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&q=80');

-- VILLE (Europe proche — avion + train + bus depuis Paris)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(39,'Londres','Royaume-Uni','ville','Big Ben, Buckingham Palace, pubs centenaires et scène culturelle mondiale dans la capitale britannique.',350.00,'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&q=80'),
(40,'Berlin','Allemagne','ville','Murs de l\'histoire, street art omniprésent, clubs légendaires et gastronomie multiculturelle.',420.00,'https://images.unsplash.com/photo-1560969184-10fe8719e047?w=800&q=80'),
(41,'Vienne','Autriche','culture','Palais impériaux, cafés viennois centenaires, opéra mythique et valse sous les lustres de cristal.',520.00,'https://images.unsplash.com/photo-1516550893923-42d28e5677af?w=800&q=80'),
(42,'Madrid','Espagne','ville','Prado, Reina Sofía, tapas au marché San Miguel et ambiance festive jusqu\'à l\'aube.',480.00,'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=800&q=80'),
(43,'Bruxelles','Belgique','ville','Manneken Pis, Grand-Place baroque, bières trappistes et chocolats fondants dans la capitale de l\'Europe.',290.00,'https://images.unsplash.com/photo-1559113202-c916b8e44373?w=800&q=80'),
(44,'Copenhague','Danemark','ville','La Petite Sirène, Nyhavn coloré, gastronomie nordique et la ville la plus heureuse du monde.',680.00,'https://images.unsplash.com/photo-1513622470522-26c3c8a854bc?w=800&q=80');

INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(45,'Stockholm','Suède','ville','Capitale sur 14 îles, musée Vasa, design scandinave et aurores boréales en hiver.',720.00,'https://images.unsplash.com/photo-1509356843151-3e7d96241e11?w=800&q=80'),
(46,'Budapest','Hongrie','culture','Bains thermaux ottomans, Parlement néogothique sur le Danube et ruin bars uniques au monde.',380.00,'https://images.unsplash.com/photo-1551867633-194f125bddfa?w=800&q=80'),
(47,'Athènes','Grèce','culture','L\'Acropole surplombant 4000 ans d\'histoire, tavernes animées et musées exceptionnels.',420.00,'https://images.unsplash.com/photo-1603565816030-6b389eeb23cb?w=800&q=80'),
(48,'Florence','Italie','culture','Berceau de la Renaissance, David de Michel-Ange, Offices et les meilleurs bisteccas du monde.',550.00,'https://images.unsplash.com/photo-1543429258-60af90a01b7c?w=800&q=80'),
(49,'Porto','Portugal','ville','Azulejos bleus, caves de porto millésimées, ponts de Gustave Eiffel et fado authentique.',380.00,'https://images.unsplash.com/photo-1555881400-74d7acaacd8b?w=800&q=80'),
(50,'Lisbonne Nord (Sintra)','Portugal','culture','Palais de Sintra enchantés dans la forêt, falaises de Cabo da Roca et vignes de la côte d\'argent.',310.00,'https://images.unsplash.com/photo-1548707309-dcebeab9ea9b?w=800&q=80');

-- VILLE (monde — avion uniquement depuis Paris)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(51,'Séoul','Corée du Sud','ville','K-pop, palais Gyeongbokgung, cuisine de rue épicée et quartiers ultra-modernes comme Gangnam.',980.00,'https://images.unsplash.com/photo-1538485399081-7c8272b29579?w=800&q=80'),
(52,'Hong Kong','Chine','ville','Skyline vertigineux, dim sum légendaires, marchés nocturnes et Star Ferry entre Kowloon et l\'île.',1050.00,'https://images.unsplash.com/photo-1536599018102-9f803c140fc1?w=800&q=80'),
(53,'Kuala Lumpur','Malaisie','ville','Tours Petronas scintillantes, jungle tropicale à 20 min, street food multiculturel et shopping paradis.',620.00,'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=800&q=80'),
(54,'Hanoï','Vietnam','culture','Vieille ville aux 36 guildes, lac Hoan Kiem, pho au petit-déjeuner et baie d\'Along à portée de main.',540.00,'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800&q=80'),
(55,'Mumbai','Inde','culture','Gateway of India, Bollywood, quartier Dharavi et la plus grande concentration d\'art déco hors Miami.',680.00,'https://images.unsplash.com/photo-1529253355930-ddbe423a2ac7?w=800&q=80'),
(56,'Montréal','Canada','ville','Festivals en tout genre, vieux port historique, gastronomie franco-québécoise et hivers festifs.',750.00,'https://images.unsplash.com/photo-1519178614-68673b201f36?w=800&q=80');

INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(57,'Los Angeles','États-Unis','ville','Hollywood, plages de Santa Monica, gastronomie de fusion mondiale et couchers de soleil sur le Pacifique.',950.00,'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=800&q=80'),
(58,'Sydney','Australie','ville','Opéra sur la baie, Bondi Beach, barbecue du dimanche et Blue Mountains à une heure.',1200.00,'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800&q=80'),
(59,'Buenos Aires','Argentine','ville','Capitale du tango, biftecks de légende, architecture haussmannienne et vie nocturne jusqu\'au matin.',780.00,'https://images.unsplash.com/photo-1589909202802-8f4aadce1849?w=800&q=80'),
(60,'Rio de Janeiro','Brésil','aventure','Corcovado, Copacabana, carnaval explosif, caïpirinhas et forêt tropicale dans la ville.',820.00,'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?w=800&q=80');

-- PLAGE (avion uniquement depuis Paris)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(61,'Punta Cana','République dominicaine','plage','Palmiers sur 45 km de plage blanche, eaux turquoise et all-inclusive de rêve aux Caraïbes.',680.00,'https://images.unsplash.com/photo-1504615755583-2916b52192a3?w=800&q=80'),
(62,'Koh Samui','Thaïlande','plage','Cocotiers géants, Full Moon Party de Koh Phangan, snorkeling à Ang Thong et spa luxueux.',560.00,'https://images.unsplash.com/photo-1589394815804-964ed0be2eb5?w=800&q=80'),
(63,'Cap-Vert','Cap-Vert','plage','Archipel atlantique aux plages de sable doré, kitesurf à Sal, musique morna et culture créole.',720.00,'https://images.unsplash.com/photo-1586861203927-800a5acdcc4d?w=800&q=80');

-- AVENTURE (avion uniquement)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(64,'La Réunion','France','aventure','Volcan Piton de la Fournaise en activité, cirques de montagne, surf à Saint-Leu et canyoning mythique.',850.00,'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&q=80'),
(65,'Cape Town','Afrique du Sud','aventure','Table Mountain, Cape Point, plages de Camps Bay, vignobles de Stellenbosch et safaris proches.',1050.00,'https://images.unsplash.com/photo-1580060839134-75a5edca2e99?w=800&q=80');

-- ============================================================
-- IMAGES DES DESTINATIONS (fichiers locaux — frontend/public/images/destinations/)
-- ============================================================
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/7.jpg'  WHERE id = 7;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/8.jpg'  WHERE id = 8;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/9.jpg'  WHERE id = 9;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/10.jpg' WHERE id = 10;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/11.jpg' WHERE id = 11;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/12.jpg' WHERE id = 12;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/13.jpg' WHERE id = 13;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/14.jpg' WHERE id = 14;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/15.jpg' WHERE id = 15;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/16.jpg' WHERE id = 16;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/17.jpg' WHERE id = 17;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/18.jpg' WHERE id = 18;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/19.jpg' WHERE id = 19;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/20.jpg' WHERE id = 20;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/21.jpg' WHERE id = 21;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/22.jpg' WHERE id = 22;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/23.jpg' WHERE id = 23;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/24.jpg' WHERE id = 24;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/25.jpg' WHERE id = 25;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/26.jpg' WHERE id = 26;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/27.jpg' WHERE id = 27;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/28.jpg' WHERE id = 28;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/29.jpg' WHERE id = 29;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/30.jpg' WHERE id = 30;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/31.jpg' WHERE id = 31;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/32.jpg' WHERE id = 32;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/33.jpg' WHERE id = 33;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/34.jpg' WHERE id = 34;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/35.jpg' WHERE id = 35;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/36.jpg' WHERE id = 36;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/37.jpg' WHERE id = 37;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/38.jpg' WHERE id = 38;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/39.jpg' WHERE id = 39;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/40.jpg' WHERE id = 40;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/41.jpg' WHERE id = 41;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/42.jpg' WHERE id = 42;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/43.jpg' WHERE id = 43;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/44.jpg' WHERE id = 44;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/45.jpg' WHERE id = 45;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/46.jpg' WHERE id = 46;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/47.jpg' WHERE id = 47;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/48.jpg' WHERE id = 48;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/49.jpg' WHERE id = 49;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/50.jpg' WHERE id = 50;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/51.jpg' WHERE id = 51;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/52.jpg' WHERE id = 52;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/53.jpg' WHERE id = 53;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/54.jpg' WHERE id = 54;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/55.jpg' WHERE id = 55;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/56.jpg' WHERE id = 56;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/57.jpg' WHERE id = 57;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/58.jpg' WHERE id = 58;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/59.jpg' WHERE id = 59;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/60.jpg' WHERE id = 60;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/61.jpg' WHERE id = 61;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/62.jpg' WHERE id = 62;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/63.jpg' WHERE id = 63;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/64.jpg' WHERE id = 64;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/65.jpg' WHERE id = 65;

-- ============================================================
-- ICÔNES DES DESTINATIONS (depuis icons.js)
-- ============================================================
UPDATE destinations SET icone = '🏝️' WHERE id = 7;   -- Maldives
UPDATE destinations SET icone = '🏖️' WHERE id = 8;   -- Phuket
UPDATE destinations SET icone = '🌴' WHERE id = 9;   -- Cancún
UPDATE destinations SET icone = '🏖️' WHERE id = 10;  -- Seychelles
UPDATE destinations SET icone = '🐠' WHERE id = 11;  -- Zanzibar
UPDATE destinations SET icone = '⛵' WHERE id = 12;  -- Mykonos
UPDATE destinations SET icone = '🎶' WHERE id = 13;  -- Ibiza
UPDATE destinations SET icone = '🌺' WHERE id = 14;  -- Bora Bora
UPDATE destinations SET icone = '🌺' WHERE id = 15;  -- Île Maurice
UPDATE destinations SET icone = '🌊' WHERE id = 16;  -- Miami Beach
UPDATE destinations SET icone = '⛷️' WHERE id = 17;  -- Chamonix
UPDATE destinations SET icone = '🎿' WHERE id = 18;  -- Queenstown
UPDATE destinations SET icone = '🏔️' WHERE id = 19;  -- Zermatt
UPDATE destinations SET icone = '🏔️' WHERE id = 20;  -- Dolomites
UPDATE destinations SET icone = '🏔️' WHERE id = 21;  -- Tromsø
UPDATE destinations SET icone = '🏔️' WHERE id = 22;  -- Aspen
UPDATE destinations SET icone = '🏟️' WHERE id = 23;  -- Barcelone
UPDATE destinations SET icone = '🌷' WHERE id = 24;  -- Amsterdam
UPDATE destinations SET icone = '🌇' WHERE id = 25;  -- Singapour
UPDATE destinations SET icone = '🏰' WHERE id = 26;  -- Prague
UPDATE destinations SET icone = '🌆' WHERE id = 27;  -- Dubaï
UPDATE destinations SET icone = '🗽' WHERE id = 28;  -- New York
UPDATE destinations SET icone = '🛕' WHERE id = 29;  -- Bangkok
UPDATE destinations SET icone = '🕌' WHERE id = 30;  -- Marrakech
UPDATE destinations SET icone = '🏛️' WHERE id = 31;  -- Rome
UPDATE destinations SET icone = '🕌' WHERE id = 32;  -- Istanbul
UPDATE destinations SET icone = '🎋' WHERE id = 33;  -- Kyoto
UPDATE destinations SET icone = '🐪' WHERE id = 34;  -- Le Caire
UPDATE destinations SET icone = '🧗' WHERE id = 35;  -- Reykjavik
UPDATE destinations SET icone = '🦁' WHERE id = 36;  -- Nairobi
UPDATE destinations SET icone = '🧗' WHERE id = 37;  -- San José
UPDATE destinations SET icone = '🧗' WHERE id = 38;  -- El Calafate
UPDATE destinations SET icone = '🎡' WHERE id = 39;  -- Londres
UPDATE destinations SET icone = '🧱' WHERE id = 40;  -- Berlin
UPDATE destinations SET icone = '🎼' WHERE id = 41;  -- Vienne
UPDATE destinations SET icone = '💃' WHERE id = 42;  -- Madrid
UPDATE destinations SET icone = '🍫' WHERE id = 43;  -- Bruxelles
UPDATE destinations SET icone = '🧜' WHERE id = 44;  -- Copenhague
UPDATE destinations SET icone = '👑' WHERE id = 45;  -- Stockholm
UPDATE destinations SET icone = '🌉' WHERE id = 46;  -- Budapest
UPDATE destinations SET icone = '🏛️' WHERE id = 47;  -- Athènes
UPDATE destinations SET icone = '🎨' WHERE id = 48;  -- Florence
UPDATE destinations SET icone = '🍷' WHERE id = 49;  -- Porto
UPDATE destinations SET icone = '🏯' WHERE id = 50;  -- Lisbonne Nord (Sintra)
UPDATE destinations SET icone = '🎎' WHERE id = 51;  -- Séoul
UPDATE destinations SET icone = '🌃' WHERE id = 52;  -- Hong Kong
UPDATE destinations SET icone = '🏙️' WHERE id = 53;  -- Kuala Lumpur
UPDATE destinations SET icone = '🏮' WHERE id = 54;  -- Hanoï
UPDATE destinations SET icone = '🎬' WHERE id = 55;  -- Mumbai
UPDATE destinations SET icone = '🍁' WHERE id = 56;  -- Montréal
UPDATE destinations SET icone = '🌴' WHERE id = 57;  -- Los Angeles
UPDATE destinations SET icone = '🌉' WHERE id = 58;  -- Sydney
UPDATE destinations SET icone = '💃' WHERE id = 59;  -- Buenos Aires
UPDATE destinations SET icone = '🎭' WHERE id = 60;  -- Rio de Janeiro
UPDATE destinations SET icone = '🌴' WHERE id = 61;  -- Punta Cana
UPDATE destinations SET icone = '🥥' WHERE id = 62;  -- Koh Samui
UPDATE destinations SET icone = '🌊' WHERE id = 63;  -- Cap-Vert
UPDATE destinations SET icone = '🌋' WHERE id = 64;  -- La Réunion
UPDATE destinations SET icone = '🦭' WHERE id = 65;  -- Cape Town


-- ============================================================
-- DONNÉES — HÉBERGEMENTS
-- ============================================================

-- Hébergements de base (IDs 1-8, destinations 1-6)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(1, 1, 'The Kayon Resort',    'resort',  125.00, 2, 'Vue sur la jungle, piscine à débordement.', NULL),
(2, 1, 'Villa Umah Sunset',   'villa',   180.00, 4, 'Villa privée avec vue sur l\'océan.', NULL),
(3, 1, 'Sunshine Beach Hotel','hotel',    60.00, 2, 'Hôtel 3 étoiles à 200m de la plage.', NULL),
(4, 2, 'Shinjuku Grand Hotel','hotel',   110.00, 2, 'Idéalement situé dans le quartier Shinjuku.', NULL),
(5, 3, 'Alpine Lodge',        'hotel',    95.00, 2, 'Chalet avec vue sur les Alpes.', NULL),
(6, 4, 'LX Boutique Hotel',   'hotel',    85.00, 2, 'Boutique hôtel en centre-ville.', NULL),
(7, 5, 'Caldera Suites',      'hotel',   160.00, 2, 'Vue directe sur la caldeira.', NULL),
(8, 6, 'Casa Andina',         'hotel',    70.00, 2, 'Hôtel confortable en centre historique.', NULL);

-- HÉBERGEMENTS (nouveaux uniquement, IDs 18+)
-- ============================================================

-- Maldives (dest 7)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(18,7,'One & Only Reethi Rah','resort',1200.00,2,'Resort privé avec bungalow sur pilotis, plongée et spa de luxe absolu.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80'),
(19,7,'Coco Bodu Hithi','resort',680.00,4,'Villas sur pilotis avec piscine privée et accès direct au lagon turquoise.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(20,7,'Maafushivaru Resort','hotel',390.00,2,'Île-hôtel intime, coraux préservés et ambiance romantique garantie.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');

-- Phuket (dest 8)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(21,8,'Sri Panwa Resort','resort',280.00,6,'Resort sur promontoire avec vue 360° sur la mer d\'Andaman.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80'),
(22,8,'Villa Nalinnadda','villa',150.00,8,'Villa avec piscine privée dans la colline de Kata Noi.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(23,8,'Slumber Party Hostel','hostel',14.00,14,'Hostel festif sur Bangla Road avec piscine et soirées à thème.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Cancún (dest 9)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(24,9,'Grand Oasis Cancún','resort',220.00,4,'All-inclusive en bord de mer avec 14 restaurants et entertainment.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80'),
(25,9,'Hotel Krystal Cancún','hotel',110.00,2,'Hôtel 4 étoiles directement sur la plage de la zone hôtelière.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(26,9,'Nomads Hostel Cancún','hostel',18.00,10,'Hostel central avec terrasse animée et excursions Cenotes organisées.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Seychelles (dest 10)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(27,10,'Six Senses Zil Pasyon','resort',1500.00,2,'Resort sur île privée, bungalows dans la roche granitique et spa holistique.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80'),
(28,10,'Anse Soleil Beachcomber','hotel',220.00,4,'Hôtel boutique sur la plage d\'Anse Soleil, snorkeling inclus.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(29,10,'Beau Vallon Beach Villa','airbnb',180.00,8,'Grande villa avec jardin tropical sur la plage de Beau Vallon.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');

-- Zanzibar (dest 11)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(30,11,'Zuri Zanzibar Hotel','resort',260.00,2,'Eco-resort sur la côte nord avec cours de cuisine swahilie.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80'),
(31,11,'Kilindi Zanzibar','villa',380.00,4,'Pavillons privés ouverts sur la forêt et l\'océan Indien.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(32,11,'Jambo Brothers Hostel','hostel',12.00,16,'Hostel dans la Stone Town historique, proche du marché aux épices.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Mykonos (dest 12)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(33,12,'Cavo Tagoo Hotel','hotel',520.00,2,'Hôtel design iconique avec piscine à débordement infinie face à la mer.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(34,12,'Myconian Villa Collection','villa',350.00,8,'Complex de villas sur la colline d\'Elia avec vue sur la mer Égée.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(35,12,'Mykonos Backpackers','hostel',30.00,12,'Hostel bien situé à Mykonos Town avec accès rapide aux plages.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Ibiza (dest 13)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(36,13,'Hard Rock Hotel Ibiza','hotel',280.00,2,'Hôtel festif en bord de plage avec accès aux meilleurs clubs.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(37,13,'Can Lluc Boutique Finca','airbnb',180.00,12,'Finca traditionnelle avec oliviers centenaires et piscine en pierre.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(38,13,'Ibiza Rocks Hostel','hostel',25.00,10,'Hostel au cœur de San Antonio, proche des couchers du Café del Mar.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Bora Bora (dest 14)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(39,14,'The St. Regis Bora Bora','resort',1400.00,2,'Overwater bungalows de luxe avec piscine privée et vue sur le Mont Otemanu.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80'),
(40,14,'Intercontinental Thalasso','resort',680.00,4,'Resort aux bungalows sur pilotis avec accès snorkeling direct.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(41,14,'Pension Chez Nono','airbnb',90.00,6,'Pension familiale authentique avec kayaks inclus et petit-déjeuner maison.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');

-- Île Maurice (dest 15)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(42,15,'Constance Belle Mare Plage','resort',480.00,2,'Resort 5 étoiles sur la plus belle plage de l\'île avec golf et thalasso.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80'),
(43,15,'Heritage Le Telfair','hotel',260.00,4,'Hôtel colonial dans une vaste propriété sucrière avec plage privée.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(44,15,'Chalets Bord de Mer','airbnb',70.00,8,'Petits chalets familiaux directement sur la plage dans le sud de l\'île.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');

-- Miami Beach (dest 16)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(45,16,'Faena Hotel Miami Beach','hotel',420.00,2,'Hôtel design luxueux sur Collins Avenue avec plage privée et restaurant étoilé.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(46,16,'SoBe Hostel & Bar','hostel',28.00,10,'Hostel sur Ocean Drive avec piscine et accès à la vie nocturne.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80'),
(47,16,'Collins Park Airbnb','airbnb',95.00,6,'Appartement art-déco rénové à deux pas de la mer et des musées.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');

-- Chamonix (dest 17)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(48,17,'Hameau Albert 1er','hotel',280.00,2,'Hôtel gastronomique 5 étoiles avec vue sur le massif du Mont-Blanc.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(49,17,'Chalet Les Drus','airbnb',140.00,8,'Chalet savoyard authentique avec bois de chauffage, hammam et skis aux pieds.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(50,17,'Vagabond Hostel Chamonix','hostel',25.00,12,'Hostel convivial dans le centre-ville, vue sur le Mont-Blanc.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Queenstown (dest 18)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(51,18,'Eichardt Private Hotel','hotel',480.00,2,'Maison d\'hôtes de luxe sur les rives du lac Wakatipu.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(52,18,'Lakefront Villa NZ','villa',220.00,10,'Villa familiale avec accès lac, kayaks et barbecue face aux Remarkables.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(53,18,'Nomads Queenstown','hostel',22.00,14,'Hostel 5 étoiles avec sauna, bar rooftop et organisation d\'activités d\'aventure.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Zermatt (dest 19)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(54,19,'Mont Cervin Palace','hotel',420.00,2,'Palace historique au pied du Cervin, spa de 2000m² et cuisine valaisanne.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(55,19,'Chalet Theodul','airbnb',180.00,8,'Chalet en bois de mélèze traditionnel avec vue directe sur le Cervin.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(56,19,'Zermatt Youth Hostel','hostel',28.00,10,'Hostel avec vue montagne et accès direct aux pistes.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Dolomites (dest 20)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(57,20,'Rosa Alpina Hotel & Spa','hotel',320.00,2,'Hôtel 5 étoiles dans le Val Badia avec restaurant Michelin et piscine panoramique.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(58,20,'Rifugio Tre Cime','airbnb',65.00,6,'Refuge alpin authentique avec vue unique sur les Drei Zinnen.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(59,20,'Cortina Hostel Dolomiti','hostel',20.00,12,'Hostel dans la station de Cortina d\'Ampezzo, proche des pistes.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Tromsø (dest 21)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(60,21,'Clarion Hotel The Edge','hotel',210.00,2,'Hôtel design au bord du fjord avec terrasse vitrée pour les aurores.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(61,21,'Arctic Panorama Lodge','villa',280.00,4,'Chalet avec paroi vitrée face à la montagne pour voir les aurores du lit.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(62,21,'Tromsø Camping & Hostel','hostel',18.00,12,'Hostel convivial avec minibus aurora tour chaque soir.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Aspen (dest 22)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(63,22,'The Little Nell Aspen','hotel',850.00,2,'Seul hôtel 5 étoiles avec accès direct aux remontées mécaniques d\'Aspen.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(64,22,'Snowmass Ski Chalet','airbnb',300.00,10,'Chalet avec sauna, salle de jeux et navette ski inclus.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(65,22,'Aspen Mountain Lodge','hostel',55.00,8,'Hébergement économique pour skieurs avec casiers et séchoir.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Barcelone (dest 23)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(66,23,'Hotel Arts Barcelona','hotel',380.00,2,'Tour de 44 étages sur le front de mer avec spa et vue panoramique.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(67,23,'Appartement Gracia','airbnb',80.00,6,'Appartement moderne dans le quartier bohème de Gràcia avec terrasse.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(68,23,'Casa Gracia Hostel','hostel',22.00,12,'Hostel design dans une demeure moderniste de l\'Eixample, rooftop animé.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Amsterdam (dest 24)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(69,24,'Pulitzer Amsterdam','hotel',320.00,2,'Hôtel dans 25 maisons de canal restaurées du XVIIe siècle en plein Jordaan.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(70,24,'Houseboat Canal Jordaan','airbnb',130.00,4,'Péniche habitable amarrée sur le canal Prinsengracht, expérience unique.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(71,24,'ClinkNOORD Hostel','hostel',20.00,14,'Hostel dans une ancienne usine de gaz avec restaurant et terrasse sur l\'IJ.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Singapour (dest 25)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(72,25,'Marina Bay Sands','hotel',420.00,2,'Hôtel iconique avec piscine à débordement au sommet et casino intégré.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(73,25,'Capella Singapore','resort',550.00,2,'Resort de luxe sur l\'île de Sentosa, au cœur de la jungle tropicale.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(74,25,'The Pod @ Beach Road','hostel',25.00,8,'Hostel design avec pods individuels fermés et WiFi haut débit.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Prague (dest 26)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(75,26,'Four Seasons Prague','hotel',350.00,2,'Hôtel face au Pont Charles avec vue directe sur le Château de Prague.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(76,26,'Appartement Mala Strana','airbnb',65.00,6,'Appartement historique dans le quartier de Malá Strana, poutres apparentes.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(77,26,'Sophies Hostel Prague','hostel',14.00,10,'Hostel primé dans le quartier de Zizkov avec bar local et concerts live.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Dubaï (dest 27)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(78,27,'Burj Al Arab Jumeirah','hotel',1500.00,2,'L\'hôtel le plus iconique du monde en forme de voile, service butler 24h/24.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(79,27,'Atlantis The Palm','resort',380.00,4,'Resort géant sur l\'archipel The Palm avec parc aquatique et aquarium.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(80,27,'Rove Downtown Dubai','hotel',80.00,2,'Hôtel lifestyle abordable à deux pas du Burj Khalifa et du Dubai Mall.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');

-- New York (dest 28)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(81,28,'The Plaza Hotel','hotel',650.00,2,'Palace légendaire sur Central Park, symbole du New York de Fitzgerald.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(82,28,'Loft Brooklyn Heights','airbnb',120.00,6,'Loft industriel chic avec vue sur Manhattan depuis Brooklyn.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(83,28,'HI NYC Hostel','hostel',35.00,12,'Hostel bien situé à Upper West Side, proche du Museum of Natural History.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Bangkok (dest 29)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(84,29,'Mandarin Oriental Bangkok','hotel',380.00,2,'Palace légendaire sur le fleuve Chao Phraya, fondé en 1876.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(85,29,'Airbnb Sukhumvit','airbnb',45.00,4,'Appartement moderne dans le quartier branché de Sukhumvit.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(86,29,'Lub d Bangkok Silom','hostel',12.00,14,'Hostel design avec piscine dans le quartier de Silom.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Marrakech (dest 30)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(87,30,'La Mamounia','hotel',600.00,2,'Palace mythique dans un jardin d\'oliviers centenaires, Art Déco légendaire.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(88,30,'Riad Dar Si Said','airbnb',110.00,8,'Riad traditionnel avec patio, fontaine, hammam privé et petit-déjeuner marocain.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(89,30,'Equity Point Hostel','hostel',10.00,16,'Hostel dans la médina avec rooftop, cours de cuisine et soirées berbères.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Rome (dest 31)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(90,31,'Hotel de Russie','hotel',550.00,2,'Hôtel emblématique entre la Piazza del Popolo et le Pincio, jardin secret.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(91,31,'Trastevere Apartment','airbnb',75.00,6,'Appartement authentique dans le quartier de Trastevere avec terrasse.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(92,31,'The Yellow Hostel','hostel',18.00,10,'Hostel festif proche du Termini avec bar et restaurant populaires.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Istanbul (dest 32)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(93,32,'Four Seasons Sultanahmet','hotel',450.00,2,'Hôtel dans une ancienne prison ottomane entre Sainte-Sophie et la Marmara.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(94,32,'Appartement Balat','airbnb',50.00,6,'Maison grecque rénovée dans le quartier coloré de Balat, près du Bosphore.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(95,32,'Big Apple Hostel Istanbul','hostel',12.00,14,'Hostel bien situé à Sultanahmet avec terrasse vue sur la Mosquée Bleue.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Kyoto (dest 33)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(96,33,'Tawaraya Ryokan','hotel',600.00,2,'Le ryokan le plus célèbre du Japon, fondé en 1712, expérience absolument unique.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(97,33,'Machiya Townhouse Gion','airbnb',120.00,6,'Maison de ville traditionnelle entièrement rénovée dans le quartier de Gion.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(98,33,'Kyoto Hostel Wabisabi','hostel',22.00,12,'Hostel dans un kyo-machiya restauré, cours de cérémonie du thé inclus.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Le Caire (dest 34)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(99,34,'Marriott Mena House','hotel',220.00,2,'Hôtel historique à Gizeh avec vue directe sur la Grande Pyramide depuis la piscine.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(100,34,'Appartement Zamalek','airbnb',40.00,6,'Appartement dans l\'île chic de Zamalek sur le Nil, quartier galeries et cafés.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(101,34,'Cairo Downtown Hostel','hostel',8.00,16,'Hostel dans le centre historique, toit terrasse avec vue sur les minarets.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Reykjavik (dest 35)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(102,35,'Ion Adventure Hotel','hotel',320.00,2,'Hôtel design au bord d\'un lac volcanique avec salle aurora viewing.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(103,35,'Cabin on the Lake','airbnb',180.00,6,'Cabane sur la berge du lac Thingvallavatn, à 40 min de Reykjavik.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(104,35,'Loft Hostel Reykjavik','hostel',28.00,12,'Hostel animé avec bar panoramique et excursions aurores quotidiennes.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Nairobi (dest 36)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(105,36,'Giraffe Manor','hotel',650.00,2,'Manoir unique où les girafes Rothschild passent leur tête au petit-déjeuner.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(106,36,'Angama Mara Tented Camp','resort',1200.00,4,'Camp de luxe en tentes sur le rebord du Rift, vue directe sur la Masaï Mara.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(107,36,'Wildebeest Eco Camp','hostel',15.00,16,'Éco-hostel dans un jardin tropical à Nairobi, organisation de safaris budget.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Costa Rica (dest 37)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(108,37,'Nayara Springs Resort','resort',480.00,2,'Villas avec piscine privée en forêt tropicale face au volcan Arenal.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(109,37,'Casa Corcovado Lodge','hotel',150.00,4,'Lodge écologique sur la péninsule d\'Osa, à la lisière du parc Corcovado.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(110,37,'Selina San Jose','hostel',20.00,12,'Hostel-coliving branché avec piscine, co-working et excursions nature.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- El Calafate (dest 38)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(111,38,'Explora El Calafate','resort',980.00,4,'Lodge d\'exploration avec guides experts et treks guidés vers Fitz Roy.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(112,38,'Hosteria Helsingfors','hotel',230.00,2,'Ferme-hôtel sur les rives du lac Viedma avec vue sur le Perito Moreno.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(113,38,'America del Sur Hostel','hostel',14.00,16,'Hostel chaleureux à El Calafate avec salle à manger chaleureuse et bibliothèque.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- HÉBERGEMENTS (IDs 114-188)
-- ============================================================

-- Londres (dest 39)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(114,39,'The Savoy','hotel',650.00,2,'Palace légendaire sur la Tamise, Art Déco et gastronomie Gordon Ramsay.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(115,39,'Notting Hill Garden Flat','airbnb',95.00,4,'Appartement Victorian dans le quartier de Portobello Road et ses marchés.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(116,39,'Generator London','hostel',22.00,12,'Hostel design à Kings Cross, à deux pas de la gare Saint-Pancras.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Berlin (dest 40)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(117,40,'Hotel Adlon Kempinski','hotel',480.00,2,'Le palace historique de Berlin face à la Porte de Brandebourg.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(118,40,'Prenzlauer Berg Loft','airbnb',75.00,6,'Loft industriel dans le quartier branché de Prenzlauer Berg.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(119,40,'Circus Hostel Berlin','hostel',18.00,12,'Hostel primé près de Rosenthaler Platz, parfait pour explorer le Mitte.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Vienne (dest 41)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(120,41,'Hotel Sacher Wien','hotel',550.00,2,'L\'hôtel mythique de la Sachertorte, en face de l\'Opéra impérial.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(121,41,'Altbau Wohnung Innere Stadt','airbnb',90.00,4,'Appartement dans un immeuble Belle Époque du 1er arrondissement.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(122,41,'Wombat\'s City Hostel','hostel',20.00,10,'Hostel réputé dans le quartier de la Mariahilfer Strasse.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Madrid (dest 42)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(123,42,'Hotel Ritz Madrid','hotel',520.00,2,'Palace centenaire face au Prado avec jardin d\'hiver et spa de luxe.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(124,42,'Appartement Malasaña','airbnb',65.00,6,'Appartement lumineux dans le quartier bohème de Malasaña.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(125,42,'Cat\'s Hostel Madrid','hostel',16.00,12,'Hostel dans un palais du XVIIIe siècle avec cour andalouse et piscine.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Bruxelles (dest 43)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(126,43,'Hotel Amigo','hotel',380.00,2,'Hôtel 5 étoiles dans le cœur historique, à deux pas de la Grand-Place.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(127,43,'Ixelles Art Deco Apartment','airbnb',70.00,4,'Appartement Art Déco dans le quartier animé d\'Ixelles.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(128,43,'2GO4 Quality Hostel','hostel',18.00,12,'Hostel réputé dans le Pentagone historique de Bruxelles.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Copenhague (dest 44)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(129,44,'Hotel d\'Angleterre','hotel',520.00,2,'Grand hôtel historique face au théâtre royal sur Kongens Nytorv.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(130,44,'Nørrebro Design Apartment','airbnb',90.00,4,'Appartement scandinave minimaliste dans le quartier multiculturel de Nørrebro.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(131,44,'Steel House Copenhagen','hostel',28.00,14,'Hostel design avec piscine intérieure et rooftop dans le centre-ville.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Stockholm (dest 45)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(132,45,'Grand Hotel Stockholm','hotel',580.00,2,'Palace historique en face du Palais Royal sur les rives du lac Mälaren.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(133,45,'Södermalm Studio','airbnb',85.00,3,'Studio moderne dans le quartier branché de Södermalm.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(134,45,'City Backpackers Inn','hostel',22.00,10,'Hostel convivial dans Gamla Stan (la vieille ville), idéal pour explorer à pied.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Budapest (dest 46)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(135,46,'Four Seasons Gresham Palace','hotel',480.00,2,'Art Nouveau somptueux au bout du Pont des Chaînes sur le Danube.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(136,46,'Jewish Quarter Flat','airbnb',55.00,4,'Appartement dans le quartier juif historique, proche des ruin bars.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(137,46,'Maverick City Lodge','hostel',12.00,14,'Hostel bien situé à Pest, organisation de soirées ruin bars chaque soir.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Athènes (dest 47)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(138,47,'Hotel Grande Bretagne','hotel',450.00,2,'Palace historique face à la place Syntagma avec vue sur le Parthénon.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(139,47,'Monastiraki Rooftop Flat','airbnb',65.00,4,'Appartement avec terrasse et vue directe sur l\'Acropole depuis Monastiraki.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(140,47,'Athens Backpackers','hostel',16.00,12,'Hostel avec rooftop mythique vue Acropole dans le quartier de Makrigianni.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Florence (dest 48)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(141,48,'Portrait Firenze','hotel',580.00,2,'Boutique hôtel de luxe sur le Ponte Vecchio avec vue sur l\'Arno.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(142,48,'Oltrarno Farmhouse','airbnb',80.00,6,'Appartement toscan dans le quartier authentique d\'Oltrarno.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(143,48,'Plus Florence Hostel','hostel',20.00,10,'Hostel avec piscine et restaurant dans une villa à 5 min de la gare.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Porto (dest 49)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(144,49,'The Yeatman Hotel','hotel',350.00,2,'Hôtel oenotouristique à Vila Nova de Gaia avec cave Graham\'s et piscine vue Douro.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(145,49,'Ribeira Townhouse','airbnb',75.00,6,'Maison de ville à façade d\'azulejos dans le quartier historique de Ribeira.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(146,49,'Gallery Hostel Porto','hostel',18.00,10,'Hostel design récompensé dans le quartier de Bonfim, galerie d\'art incluse.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Sintra (dest 50)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(147,50,'Tivoli Palácio de Seteais','hotel',280.00,2,'Palace du XVIIIe siècle dans un jardin avec vue sur les collines de Sintra.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(148,50,'Casa da Ramila','airbnb',90.00,8,'Quinta traditionnelle dans la forêt de Sintra avec jardin et piscine.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(149,50,'Sintra Hostel','hostel',15.00,10,'Hostel convivial dans le village, excursions palais incluses.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Séoul (dest 51)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(150,51,'The Shilla Seoul','hotel',380.00,2,'Palace coréen sur colline avec spa et vue panoramique sur la ville.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(151,51,'Hanok Guesthouse Bukchon','airbnb',85.00,4,'Maison traditionnelle coréenne restaurée dans le village de Bukchon.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(152,51,'Korea Guesthouse','hostel',18.00,10,'Hostel cosy à Hongdae avec accès libre aux cours de K-pop.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Hong Kong (dest 52)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(153,52,'The Peninsula Hong Kong','hotel',650.00,2,'Le palace le plus légendaire d\'Asie, face à la skyline de Hong Kong Island.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(154,52,'Sheung Wan Artist Flat','airbnb',95.00,4,'Appartement design dans le quartier des galeries d\'art de Sheung Wan.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(155,52,'Yesinn Hostel HK','hostel',28.00,8,'Hostel boutique à Mong Kok au cœur du Kowloon historique.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Kuala Lumpur (dest 53)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(156,53,'Mandarin Oriental KL','hotel',280.00,2,'Hôtel de luxe aux pieds des tours Petronas avec spa et piscine à débordement.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(157,53,'KLCC Studio Apartment','airbnb',45.00,4,'Studio moderne avec vue sur les tours Petronas illuminées la nuit.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(158,53,'Bed & Dreams Hostel KL','hostel',10.00,12,'Hostel central dans Chinatown, à deux pas de Petaling Street.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Hanoï (dest 54)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(159,54,'Sofitel Legend Metropole','hotel',320.00,2,'Palace colonial français de 1901, symbole de l\'élégance indochinoise.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(160,54,'Old Quarter Tube House','airbnb',35.00,4,'Maison tube typique dans la vieille ville aux 36 guildes.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(161,54,'Hanoi Backpackers Hostel','hostel',8.00,14,'Hostel légendaire du backpacker trail, organisation excursions Ha Long.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Mumbai (dest 55)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(162,55,'Taj Mahal Palace Mumbai','hotel',480.00,2,'Palace iconique face au Gateway of India, symbole de Mumbai depuis 1903.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(163,55,'Bandra Sea-view Flat','airbnb',55.00,4,'Appartement dans le quartier branché de Bandra avec vue sur la mer d\'Arabie.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(164,55,'Zostel Mumbai','hostel',12.00,14,'Hostel design en terrasse dans le quartier bohème de Colaba.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Montréal (dest 56)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(165,56,'Le Mount Stephen','hotel',380.00,2,'Hotel de luxe dans une banque néoclassique du XIXe siècle au cœur du Golden Square Mile.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(166,56,'Plateau Mont-Royal Loft','airbnb',80.00,6,'Loft dans le quartier francophone le plus vivant de Montréal.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(167,56,'HI Montréal Hostel','hostel',25.00,12,'Hostel officiel bien situé dans le centre-ville, accès métro immédiat.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Los Angeles (dest 57)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(168,57,'Chateau Marmont','hotel',550.00,2,'Hôtel légendaire perché sur Sunset Boulevard, repaire des stars depuis 1929.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(169,57,'Venice Beach Bungalow','airbnb',120.00,6,'Bungalow à 2 pas du boardwalk de Venice Beach, vélos inclus.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(170,57,'HI Los Angeles Hostel','hostel',32.00,10,'Hostel officiel à Santa Monica, à 5 min de la plage et du pier.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Sydney (dest 58)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(171,58,'Park Hyatt Sydney','hotel',580.00,2,'Hôtel de luxe avec vue directe sur l\'Opéra et le Harbour Bridge depuis la piscine.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(172,58,'Bondi Beach House','airbnb',130.00,6,'Maison de plage à deux rues de Bondi Beach avec barbecue.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(173,58,'Sydney Harbour YHA','hostel',35.00,12,'Hostel primé dans The Rocks avec vue imprenable sur le Harbour Bridge.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Buenos Aires (dest 59)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(174,59,'Alvear Palace Hotel','hotel',320.00,2,'Palace Belle Époque de Recoleta, le plus luxueux d\'Amérique du Sud.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(175,59,'Palermo Soho Loft','airbnb',50.00,6,'Loft design dans le quartier tendance de Palermo Soho.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(176,59,'Milhouse Hostel Avenue','hostel',12.00,16,'Hostel légendaire du backpacker trail en Amérique du Sud, toit terrasse.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Rio de Janeiro (dest 60)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(177,60,'Belmond Copacabana Palace','hotel',650.00,2,'Palace mythique sur le front de mer de Copacabana, piscine à débordement.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(178,60,'Santa Teresa Colonial House','airbnb',70.00,6,'Villa coloniale dans le quartier bohème de Santa Teresa avec vue panoramique.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(179,60,'El Misti Hostel Ipanema','hostel',15.00,14,'Hostel sur la plage d\'Ipanema, ambiance festive et soirées cariocas.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Punta Cana (dest 61)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(180,61,'Hard Rock Hotel Punta Cana','resort',280.00,4,'All-inclusive musicalement thématisé avec 13 piscines et plage privée.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80'),
(181,61,'Barcelo Bavaro Palace','resort',180.00,4,'Resort 5 étoiles tout compris sur la plus belle plage de la Caraïbe.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(182,61,'Dreaming Punta Cana Hostel','hostel',18.00,10,'Hostel convivial en retrait de la plage avec excursions Isla Saona.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Koh Samui (dest 62)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(183,62,'Four Seasons Koh Samui','resort',680.00,2,'Villas sur falaise avec piscine à débordement sur la mer de Chine méridionale.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80'),
(184,62,'Chaweng Beach Villa','villa',120.00,8,'Villa privée à Chaweng Beach, la plage la plus animée de Koh Samui.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80'),
(185,62,'Samui Backpacker Hostel','hostel',12.00,14,'Hostel sur Lamai Beach avec scooters à louer et soirées locales.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Cap-Vert (dest 63)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(186,63,'Riu Palace Boavista','resort',220.00,4,'Resort sur la plage Santa Monica, l\'une des plus belles plages d\'Afrique.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80'),
(187,63,'Casa Familiar Sal Rei','airbnb',45.00,6,'Maison créole authentique dans la capitale de Boa Vista.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(188,63,'Tortuga Beach Hostel','hostel',14.00,12,'Hostel sur la plage des tortues, organisation de kitesurf et snorkeling.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- La Réunion (dest 64)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(189,64,'Le Saint-Alexis Hôtel & Spa','hotel',220.00,2,'Hôtel de charme avec piscine à débordement et vue sur le lagon de l\'Ermitage.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(190,64,'Gîte Cilaos en Cirque','airbnb',55.00,6,'Gîte de montagne dans le cirque volcanique de Cilaos, randonnées à pied de porte.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(191,64,'Auberge du Volcan','hostel',18.00,10,'Auberge de jeunesse au plus près du Piton de la Fournaise, guides locaux.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Cape Town (dest 65)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(192,65,'The Silo Hotel','hotel',750.00,2,'Hôtel dans un ancien silo à grains avec vue sur Table Mountain et le port.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'),
(193,65,'Bo-Kaap Heritage House','airbnb',85.00,6,'Maison malaise colorée dans le quartier historique de Bo-Kaap.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80'),
(194,65,'Once in Cape Town Hostel','hostel',16.00,12,'Hostel design dans De Waterkant, organisation de safaris et excursions Cap.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');


-- ============================================================
-- DONNÉES — ACTIVITÉS
-- ============================================================

-- Activités de base (IDs 1-10, destinations 1-5)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(1, 1, 'Snorkeling Blue Lagoon',  NULL, 45.00, 15, 15, 3.0),
(2, 1, 'Temple Tanah Lot',        NULL, 35.00, 30, 30, 2.0),
(3, 1, 'Cours de surf à Kuta',    NULL, 60.00, 10,  0, 3.0),
(4, 1, 'Randonnée rizières',      NULL, 40.00, 12, 12, 4.0),
(5, 2, 'Visite du Mont Fuji',     NULL, 80.00, 20, 20, 8.0),
(6, 2, 'Quartier d\'Akihabara',   NULL, 25.00, 50, 50, 3.0),
(7, 3, 'Parachutisme',            NULL,180.00,  8,  8, 2.0),
(8, 3, 'Canyoning',               NULL, 90.00, 10, 10, 4.0),
(9, 4, 'Tram 28 + Alfama',        NULL, 20.00, 40, 40, 3.0),
(10,5, 'Coucher de soleil Oia',   NULL, 30.00, 25, 25, 2.0);

-- ACTIVITÉS (nouvelles uniquement, IDs 28+)
-- ============================================================

-- Maldives (dest 7)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(28,7,'Plongée sur le récif','Plongée guidée dans les récifs coralliens préservés avec tortues et raies mantas.',90.00,8,7,3.0),
(29,7,'Croisière en dhow au coucher de soleil','Croisière en boutre traditionnel maldivien avec dîner fruits de mer.',110.00,12,10,3.0),
(30,7,'Observation des bioluminescences','Nage nocturne dans le lagon illuminé par le plancton bioluminescent.',60.00,10,8,2.0),
(31,7,'Cours de surf et bodyboard','Initiation aux sports de glisse dans un lagon protégé avec moniteur.',55.00,12,11,3.0);

-- Phuket (dest 8)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(32,8,'Tour de la baie de Phang Nga','Excursion en kayak dans les falaises calcaires de la baie de James Bond.',75.00,20,17,8.0),
(33,8,'Cours de muay thai','Entraînement d\'initiation à la boxe thaïlandaise avec un champion local.',40.00,12,9,2.0),
(34,8,'Snorkeling aux îles Phi Phi','Journée en bateau rapide aux îles Phi Phi avec plongée en apnée.',55.00,25,21,7.0),
(35,8,'Cours de cuisine thaie','Leçon de cuisine avec 5 recettes typiques et visite du marché flottant.',50.00,10,8,5.0);

-- Cancún (dest 9)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(36,9,'Plongée dans un Cenote','Exploration sous-marine de ces puits sacrés mayas aux eaux turquoise.',80.00,10,7,4.0),
(37,9,'Visite de Chichen Itza','Excursion guidée vers la pyramide maya classée parmi les 7 merveilles du monde.',95.00,25,19,10.0),
(38,9,'Snorkeling à l\'île Mujeres','Traversée en ferry et snorkeling sur la barrière de corail en mer des Caraïbes.',60.00,20,15,6.0),
(39,9,'Wakeboard et sports nautiques','Session 2h de sports nautiques : wakeboard, ski nautique, banana boat.',65.00,15,12,2.0);

-- Seychelles (dest 10)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(40,10,'Randonnée Vallée de Mai','Trek dans la réserve de biosphère où pousse le Coco de Mer mythique.',50.00,12,10,4.0),
(41,10,'Plongée à l\'île de Curieuse','Plongée avec les tortues géantes et barracudas dans les eaux protégées.',85.00,8,6,3.0),
(42,10,'Pêche en haute mer','Pêche au gros en mer Indienne : thon, marlin et dorade coryphène.',180.00,6,5,8.0),
(43,10,'Kayak de mer entre les îlots','Exploration en kayak des criques secrètes entre Mahé et Praslin.',45.00,16,14,4.0);

-- Zanzibar (dest 11)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(44,11,'Tour des épices de Zanzibar','Balade olfactive dans une plantation d\'épices tropicales avec dégustation.',25.00,20,18,3.0),
(45,11,'Visite de Stone Town','Découverte de l\'architecture swahili-arabe et de la maison de Freddie Mercury.',30.00,25,22,4.0),
(46,11,'Nage avec les dauphins','Sortie en bateau pour nager avec les dauphins sauvages au large.',55.00,12,9,4.0),
(47,11,'Safari Blue Snorkeling','Journée en boutre à voile avec pêche, snorkeling et festin de fruits de mer.',70.00,20,16,8.0);

-- Mykonos (dest 12)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(48,12,'Party boat sunset cruise','Croisière festive au coucher du soleil avec DJ, open bar et baignade.',85.00,30,25,4.0),
(49,12,'Windsurf et kitesurf','Cours de windsurf ou kitesurf sur l\'une des meilleures plages de Méditerranée.',70.00,8,6,3.0),
(50,12,'Visite de Délos en bateau','Excursion sur l\'île mythologique de Délos, berceau des dieux Apollon et Artémis.',45.00,20,16,5.0),
(51,12,'Yoga au lever du soleil','Session de yoga au lever du soleil sur un rocher face à la mer Égée.',30.00,12,11,1.5);

-- Ibiza (dest 13)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(52,13,'Excursion en quad','Tour en quad entre les collines, vignes et criques secrètes d\'Ibiza.',90.00,10,7,4.0),
(53,13,'Coucher de soleil Café del Mar','Soirée mythique avec accès réservé à la terrasse du Café del Mar.',40.00,25,20,3.0),
(54,13,'Plongée à Ses Salines','Plongée dans le parc naturel protégé de Ses Salines avec posidonie.',65.00,8,6,3.0),
(55,13,'Yoga et méditation Es Vedra','Retraite yoga d\'une journée face au rocher magique d\'Es Vedra.',55.00,15,13,6.0);

-- Bora Bora (dest 14)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(56,14,'Jet ski autour de l\'île','Tour complet de Bora Bora en jet ski avec snorkeling dans le lagon.',130.00,10,7,3.0),
(57,14,'Plongée avec les requins','Plongée sécurisée avec les requins à pointe noire et raies du lagon.',95.00,8,6,3.0),
(58,14,'Excursion 4x4 Mont Pahia','Ascension en 4x4 du Mont Pahia pour une vue panoramique à 360°.',75.00,12,10,4.0),
(59,14,'Pique-nique sur motu privé','Transfert en hors-bord vers un motu désert avec pique-nique gastronomique.',150.00,8,7,5.0);

-- Île Maurice (dest 15)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(60,15,'Plongée à l\'île aux Cerfs','Plongée dans le lagon protégé avec poissons multicolores.',70.00,10,8,3.0),
(61,15,'Trek à la montagne du Pouce','Randonnée jusqu\'au sommet du Pouce (812m) avec vue sur Port-Louis.',40.00,15,13,5.0),
(62,15,'Visite distillerie de rhum','Tour de la distillerie Chamarel avec dégustation de 6 rhums arrangés.',45.00,20,17,3.0),
(63,15,'Observation des baleines','Sortie en bateau pour observer les dauphins et baleines au large de Tamarin.',80.00,15,12,4.0);

-- Miami Beach (dest 16)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(64,16,'Tour Art Deco South Beach','Visite guidée à pied des chefs-d\'œuvre Art Déco de la Ocean Drive.',30.00,20,18,2.0),
(65,16,'Excursion dans les Everglades','Tour en airboat dans la jungle aquatique des Everglades avec alligators.',65.00,20,16,5.0),
(66,16,'Stand-up paddle Biscayne Bay','Session SUP dans la baie de Biscayne avec vue sur Miami et les mangroves.',45.00,12,10,2.0),
(67,16,'Brunch rooftop Wynwood','Brunch gastronomique sur un rooftop dans le quartier street art de Wynwood.',55.00,20,17,2.0);

-- Chamonix (dest 17)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(68,17,'Aiguille du Midi','Montée à 3842m avec vue sur le Mont-Blanc et la Vallée Blanche.',60.00,40,35,4.0),
(69,17,'Randonnée Mer de Glace','Trek jusqu\'au plus grand glacier de France avec visite de la grotte de glace.',35.00,20,18,5.0),
(70,17,'Ski hors-piste Vallée Blanche','Session de ski hors-piste avec guide UIAGM en vallée Blanche.',180.00,6,4,6.0),
(71,17,'Parapente biplace','Vol en parapente biplace depuis le Brévent avec vue sur le Mont-Blanc.',145.00,4,3,1.5);

-- Queenstown (dest 18)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(72,18,'Bungy Kawarau Bridge','Le premier bungy commercial du monde au-dessus de la gorge de Kawarau.',165.00,20,14,2.0),
(73,18,'Jet-boat Shotover River','Course en jet-boat à grande vitesse dans les gorges du Shotover.',90.00,12,9,1.0),
(74,18,'Excursion à Milford Sound','Croisière majestueuse dans le fjord classé au patrimoine mondial.',185.00,25,19,12.0),
(75,18,'Ski à Coronet Peak','Journée de ski ou snowboard sur le domaine emblématique de Queenstown.',120.00,30,24,8.0);

-- Zermatt (dest 19)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(76,19,'Ski Klein Matterhorn','Ski sur le plus haut domaine skiable d\'Europe avec vue sur 38 sommets de 4000m.',95.00,30,25,7.0),
(77,19,'Randonnée Haute Route','Étape guidée de la célèbre Haute Route entre Chamonix et Zermatt.',150.00,8,5,8.0),
(78,19,'Photo du Cervin au lever du soleil','Session guidée de photographie de montagne au lever du soleil.',70.00,6,4,3.0),
(79,19,'Visite musée Matterhorn','Découverte de l\'histoire de la conquête du Cervin et des premières ascensions.',15.00,30,28,1.5);

-- Dolomites (dest 20)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(80,20,'Via Ferrata Lagazuoi','Via ferrata légendaire avec vue sur les Cinq Doigts et le Fanes.',65.00,8,6,6.0),
(81,20,'Tour des Drei Zinnen en VTT','Tour cyclo-montagne autour des trois sommets emblématiques des Dolomites.',55.00,10,7,5.0),
(82,20,'Randonnée Alpe di Siusi','Trek dans le plus grand alpage d\'Europe avec vue sur le Schlern.',20.00,25,22,4.0),
(83,20,'Cours de cuisine ladine','Initiation à la cuisine traditionnelle ladine avec polenta et canederli.',60.00,10,9,4.0);

-- Tromsø (dest 21)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(84,21,'Tour aurores boréales','Expédition nocturne en minibus pour chasser les aurores boréales.',95.00,12,10,5.0),
(85,21,'Randonnée en raquettes','Trek en raquettes dans la toundra enneigée avec guide Sami.',70.00,10,8,4.0),
(86,21,'Safari en chiens de traineau','Promenade en traîneau tiré par des huskies dans la neige arctique.',160.00,12,10,3.0),
(87,21,'Plongée sous la glace','Plongée dans les fjords arctiques gelés avec combinaison étanche.',180.00,6,4,3.0);

-- Aspen (dest 22)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(88,22,'Ski sur Aspen Mountain','Journée de ski avec moniteur sur les pistes légendaires d\'Aspen Mountain.',130.00,20,16,7.0),
(89,22,'Motoneige dans Snowmass','Session de motoneige dans les montagnes enneigées autour d\'Aspen.',110.00,10,8,3.0),
(90,22,'Randonnée Maroon Bells','Randonnée autour des lacs de Maroon Bells, vue considérée la plus belle d\'Amérique.',30.00,20,17,5.0),
(91,22,'Dégustation de vins du Colorado','Visite d\'un vignoble altitude et dégustation de vins locaux dans la cave.',65.00,16,14,3.0);

-- Barcelone (dest 23)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(92,23,'Visite guidée Sagrada Familia','Visite complète avec guide expert de l\'œuvre-vie de Gaudí.',35.00,20,17,2.5),
(93,23,'Tour de nuit des tapas','Déambulation gastronomique dans 5 bars à tapas du Born et de la Barceloneta.',55.00,16,13,3.0),
(94,23,'Cours de flamenco','Initiation au flamenco en studio avec danseuse professionnelle.',40.00,12,10,1.5),
(95,23,'Excursion à Montserrat','Excursion en train de crémaillère à l\'abbaye perchée de Montserrat.',45.00,25,21,6.0);

-- Amsterdam (dest 24)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(96,24,'Tour en vélo des canaux','Découverte des quartiers d\'Amsterdam à vélo avec guide local.',25.00,15,12,3.0),
(97,24,'Visite du Rijksmuseum','Visite guidée des chefs-d\'œuvre de Rembrandt et Vermeer.',30.00,20,17,2.5),
(98,24,'Tour des brasseries artisanales','Dégustation dans 3 brasseries artisanales amsterdamoises.',55.00,16,13,3.0),
(99,24,'Croisière nocturne illuminée','Croisière dans les canaux illuminés avec open bar.',65.00,25,20,2.0);

-- Singapour (dest 25)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(100,25,'Gardens by the Bay nocturne','Spectacle son et lumière dans les Supertrees de Gardens by the Bay.',20.00,50,45,2.0),
(101,25,'Tour gastronomique Hawker Centre','Dégustation guidée dans 3 hawker centres emblématiques.',50.00,12,10,3.0),
(102,25,'Excursion à Sentosa','Journée à Universal Studios Singapore et sur les plages de Sentosa.',80.00,20,16,8.0),
(103,25,'Night Safari','Visite du célèbre Night Safari avec animaux nocturnes et spectacle.',45.00,25,21,3.0);

-- Prague (dest 26)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(104,26,'Tour du Château de Prague','Visite complète du plus grand château médiéval du monde avec guide.',25.00,20,18,3.0),
(105,26,'Dégustation cave à bière','Session dans une pivnice traditionnelle avec 6 bières artisanales tchèques.',30.00,16,14,2.0),
(106,26,'Tour en bateau sur la Vltava','Croisière panoramique sur la rivière Vltava au coucher du soleil.',35.00,25,21,2.0),
(107,26,'Marchés de la Vieille Ville','Immersion dans la vie locale lors des marchés saisonniers emblématiques.',15.00,30,27,2.0);

-- Dubaï (dest 27)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(108,27,'Safari dans le désert','Excursion en 4x4 dans les dunes rouges avec dîner bédouin et show.',95.00,20,16,6.0),
(109,27,'Observation depuis le Burj Khalifa','Accès au pont d\'observation At The Top (124e étage) avec vue 360°.',50.00,40,35,2.0),
(110,27,'Ski à Ski Dubai','Session de ski indoor dans la plus grande piste couverte du Moyen-Orient.',80.00,20,17,2.0),
(111,27,'Croisière en dhow sur Dubai Creek','Dîner croisière sur le Creek dans un boutre traditionnel illuminé.',70.00,25,20,2.5);

-- New York (dest 28)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(112,28,'Tour en hélicoptère de Manhattan','Vol panoramique de 15 min autour des gratte-ciels de Manhattan.',180.00,6,4,0.5),
(113,28,'Broadway Musical','Spectacle sur Broadway avec les meilleures places en catégorie Orchestra.',150.00,10,7,3.0),
(114,28,'Tour gastronomique Greenwich Village','Dégustation dans les meilleurs restaurants du plus beau quartier de NY.',70.00,12,9,3.0),
(115,28,'Kayak sur l\'Hudson River','Session de kayak avec vue sur le World Trade Center depuis l\'eau.',45.00,15,12,2.0);

-- Bangkok (dest 29)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(116,29,'Tour des temples en tuk-tuk','Visite de Wat Pho, Wat Arun et Grand Palais en tuk-tuk avec guide.',35.00,20,16,5.0),
(117,29,'Cours de cuisine thaie au marché','Marché flottant suivi d\'un cours de cuisine traditionnelle.',60.00,12,10,6.0),
(118,29,'Excursion à Ayutthaya','Journée aux ruines de l\'ancienne capitale du Siam classée UNESCO.',55.00,20,16,8.0),
(119,29,'Massage thai traditionnel','Séance de 2h de massage thaï traditionnel dans un salon authentique.',25.00,10,8,2.0);

-- Marrakech (dest 30)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(120,30,'Balade dans les souks','Tour guidé dans les souks labyrinthiques et visite des tanneries de Chouara.',30.00,15,13,4.0),
(121,30,'Excursion désert d\'Agafay','Dîner gastronomique sous les étoiles dans le désert de pierres de l\'Agafay.',95.00,20,16,6.0),
(122,30,'Hammam traditionnel','Séance complète de hammam marocain dans un établissement historique.',35.00,12,10,2.0),
(123,30,'Cours de cuisine marocaine','Préparation d\'un tajine et de pastilla avec une cuisinière locale.',50.00,8,6,4.0);

-- Rome (dest 31)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(124,31,'Visite guidée du Colisée','Accès coupe-file au Colisée, à l\'arène souterraine et au Forum romain.',45.00,20,16,3.0),
(125,31,'Tour Vatican Chapelle Sixtine','Visite guidée exclusive des Musées du Vatican et de la Chapelle Sixtine.',55.00,20,15,3.0),
(126,31,'Atelier de cuisine romaine','Cours de fabrication de pasta fraîche, tiramisu et carbonara.',65.00,10,8,3.0),
(127,31,'Tour de la Roma Segreta','Découverte des coins cachés et fontaines secrètes de la Rome antique.',30.00,15,12,2.5);

-- Istanbul (dest 32)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(128,32,'Sainte-Sophie et Mosquée Bleue','Visite guidée des deux icônes de l\'Empire byzantin et ottoman.',35.00,20,17,3.0),
(129,32,'Tour en bateau sur le Bosphore','Croisière dans le détroit mythique entre Europe et Asie.',40.00,25,21,2.0),
(130,32,'Dégustation au Grand Bazar','Tour gastronomique dans le plus vieux marché couvert du monde.',45.00,12,10,2.5),
(131,32,'Hammam ottoman Cagaloglu','Bain turc dans le hammam historique du XVIIIe siècle.',55.00,20,17,2.0);

-- Kyoto (dest 33)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(132,33,'Cérémonie du thé à Gion','Cérémonie du thé authentique dans un ochaya historique du quartier des geishas.',45.00,8,6,2.0),
(133,33,'Randonnée Fushimi Inari','Ascension aux milliers de torii vermillon du sanctuaire Fushimi Inari.',15.00,20,18,3.0),
(134,33,'Tour en rickshaw Arashiyama','Promenade en rickshaw dans la forêt de bambous d\'Arashiyama.',55.00,6,4,2.0),
(135,33,'Cours d\'ikebana','Atelier d\'initiation à l\'art floral japonais avec maître certifié.',60.00,8,7,2.5);

-- Le Caire (dest 34)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(136,34,'Pyramides à dos de chameau','Tour des pyramides de Gizeh et du Sphinx à dos de chameau avec guide.',60.00,20,15,4.0),
(137,34,'Croisière sur le Nil','Dîner croisière sur le Nil avec spectacle de danse orientale.',55.00,25,20,3.0),
(138,34,'Musée égyptien et momies royales','Visite guidée du plus grand musée d\'antiquités égyptiennes du monde.',35.00,20,17,3.0),
(139,34,'Balade Khan El-Khalili','Tour guidé dans le souk médiéval du Caire avec dégustation de café turc.',25.00,15,13,2.0);

-- Reykjavik (dest 35)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(140,35,'Bain dans le Blue Lagoon','Séance dans les eaux géothermales bleu laiteux du Blue Lagoon avec soin.',80.00,30,25,3.0),
(141,35,'Tour du Cercle d\'Or','Excursion vers Thingvellir, les geysers de Geysir et la cascade de Gullfoss.',95.00,25,21,10.0),
(142,35,'Observation des baleines','Sortie en mer à la rencontre des baleines à bosse et des marsouins.',70.00,20,16,3.0),
(143,35,'Randonnée sur glacier','Trek guidé sur le glacier Solheimajokull avec crampons.',120.00,10,8,4.0);

-- Nairobi (dest 36)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(144,36,'Safari 2 jours Masai Mara','Safari privé de 2 jours dans la Masaï Mara avec nuit en camp de luxe.',450.00,8,5,48.0),
(145,36,'Centre des éléphants orphelins','Rencontre avec les éléphants orphelins du David Sheldrick Wildlife Trust.',25.00,30,26,2.0),
(146,36,'Tour du village Masai','Immersion dans une boma Masaï avec danses traditionnelles et artisanat.',40.00,20,16,3.0),
(147,36,'Randonnée Ngong Hills','Trek dans les collines Ngong avec vue sur la vallée du Rift et Nairobi.',35.00,15,12,5.0);

-- Costa Rica (dest 37)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(148,37,'Canopy et Zip-line Arenal','Vol de tyrolienne à travers la canopée tropicale du parc Arenal.',55.00,15,12,3.0),
(149,37,'Rafting sur le Rio Pacuare','Descente en eaux vives de classe III-IV dans l\'un des plus beaux fleuves du monde.',85.00,12,10,5.0),
(150,37,'Observation des tortues marines','Nuit sur la plage de Tortuguero pour observer les tortues géantes pondre.',70.00,10,7,4.0),
(151,37,'Sources chaudes Arenal','Soirée dans les sources thermales naturelles au pied du volcan actif.',40.00,25,21,3.0);

-- El Calafate (dest 38)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(152,38,'Marche sur le Perito Moreno','Trek avec crampons sur le glacier bleu le plus actif du monde.',130.00,12,9,5.0),
(153,38,'Navigation devant le glacier','Croisière pour admirer les chutes de glace depuis l\'eau.',60.00,25,20,2.0),
(154,38,'Trek à Torres del Paine','Journée de randonnée vers les tours de granit iconiques de Patagonie.',90.00,8,6,8.0),
(155,38,'Observation condors des Andes','Sortie ornithologique pour observer les condors en vol dans les Andes.',45.00,12,10,4.0);

-- ACTIVITÉS (IDs 156-283)
-- ============================================================

-- Londres (dest 39)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(156,39,'Visite de la Tour de Londres','Tour guidé de la Tour royale avec joyaux de la couronne et gardes Beefeaters.',28.00,20,17,3.0),
(157,39,'Croisière sur la Tamise','Bateau entre Westminster et Greenwich avec vue sur Tower Bridge et le Parlement.',18.00,50,44,2.0),
(158,39,'Comédie musicale West End','Spectacle dans l\'un des théâtres mythiques de Shaftesbury Avenue (Lion King, Hamilton).',75.00,10,7,3.0),
(159,39,'Tour des pubs victoriens de Soho','Dégustation de ales et bitters dans 4 pubs victoriens authentiques avec guide local.',35.00,15,12,3.0);

-- Berlin (dest 40)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(160,40,'Tour du Mur de Berlin','Visite guidée du Checkpoint Charlie, East Side Gallery et mémorial.',15.00,25,22,3.0),
(161,40,'Visite de l\'île aux Musées','Journée dans les 5 musées de l\'île avec Pergamon Altar et buste de Néfertiti.',18.00,20,17,5.0),
(162,40,'Soirée club berlinois','Entrée guidée dans les clubs électroniques légendaires de Mitte et Friedrichshain.',25.00,12,9,5.0),
(163,40,'Street Food Tour Kreuzberg','Dégustation multiculturelle dans le quartier turc et alternatif de Kreuzberg.',40.00,15,12,3.0);

-- Vienne (dest 41)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(164,41,'Opéra de Vienne','Soirée à l\'Opéra impérial avec visite des coulisses en matinée.',95.00,8,6,4.0),
(165,41,'Visite du Palais de Schönbrunn','Tour du palais impérial des Habsbourg et de ses jardins à la française.',18.00,25,21,3.0),
(166,41,'Café viennois et Sachertorte','Tour des cafés historiques : Café Central, Demel, Landtmann avec dégustation.',35.00,15,13,2.5),
(167,41,'Valse au Musikverein','Soirée concert dans la salle dorée du Musikverein, la plus belle salle de concert du monde.',55.00,20,16,3.0);

-- Madrid (dest 42)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(168,42,'Visite guidée du Prado','Tour des chefs-d\'œuvre de Velázquez, Goya et Bosch avec accès coupe-file.',22.00,20,17,2.5),
(169,42,'Tour de nuit des tapas','Dégustation dans 5 bars à tapas de La Latina et Chueca avec guide madrilène.',55.00,14,11,3.0),
(170,42,'Spectacle de flamenco','Show flamenco authentique dans un tablao historique avec dîner inclus.',65.00,20,16,2.5),
(171,42,'Excursion à Tolède','Journée dans la cité impériale médiévale classée UNESCO à 70 km de Madrid.',45.00,25,20,8.0);

-- Bruxelles (dest 43)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(172,43,'Tour des brasseries belges','Dégustation de 6 bières trappistes dans 3 établissements historiques.',45.00,15,12,3.0),
(173,43,'Visite de la Grand-Place et Manneken Pis','Tour guidé du cœur baroque de Bruxelles classé UNESCO.',12.00,25,22,2.0),
(174,43,'Musée Magritte et Art Nouveau','Visite du musée Magritte et balade dans les maisons Art Nouveau de Horta.',18.00,20,17,3.0),
(175,43,'Atelier chocolat belge','Fabrication de pralines avec un maître chocolatier bruxellois.',40.00,10,8,2.0);

-- Copenhague (dest 44)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(176,44,'Tour à vélo de Nyhavn et des canaux','Exploration de la ville à vélo comme les Danois avec guide local.',25.00,15,13,3.0),
(177,44,'Visite du Palais de Christiansborg','Tour du Palais royal où siège le Parlement danois avec vue panoramique.',16.00,20,18,2.5),
(178,44,'Parc Tivoli nocturne','Soirée dans le plus ancien parc d\'attractions du monde avec manèges et concerts.',18.00,30,25,3.0),
(179,44,'Dîner gastronomique nouvelle cuisine nordique','Repas dans un restaurant étoilé spécialisé New Nordic Cuisine.',150.00,8,5,3.0);

-- Stockholm (dest 45)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(180,45,'Musée Vasa','Visite du seul navire de guerre du XVIIe siècle intact au monde.',16.00,25,22,2.0),
(181,45,'Excursion en kayak dans l\'archipel','Paddle dans les 30 000 îles de l\'archipel de Stockholm.',65.00,10,8,5.0),
(182,45,'Tour de Gamla Stan (vieille ville)','Visite guidée de la plus belle vieille ville scandinave avec café et kanelbulle.',20.00,20,17,2.5),
(183,45,'Sauna traditionnel suédois','Séance de sauna puis plongeon dans les eaux de la Baltique.',35.00,8,7,2.0);

-- Budapest (dest 46)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(184,46,'Bains thermaux Széchenyi','Séance dans les plus grands bains thermaux d\'Europe, ambiance unique.',20.00,30,25,3.0),
(185,46,'Croisière nocturne sur le Danube','Bateau illuminé entre Buda et Pest avec vue sur le Parlement scintillant.',18.00,40,35,2.0),
(186,46,'Tour des ruin bars','Visite guidée des bars dans les ruines : Szimpla Kert et ses compères.',25.00,20,16,4.0),
(187,46,'Visite du Parlement hongrois','Tour du 3e plus grand parlement du monde avec la Couronne de Saint-Étienne.',20.00,20,17,2.0);

-- Athènes (dest 47)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(188,47,'Visite de l\'Acropole et du Parthénon','Tour guidé du site archéologique le plus visité de Grèce avec musée.',20.00,20,16,3.0),
(189,47,'Tour gastronomique d\'Athènes','Dégustation de mezze, souvlaki et vins grecs dans le marché Monastiraki.',50.00,12,10,3.0),
(190,47,'Excursion à Delphes','Journée au oracle de Delphes et au musée archéologique dans les montagnes.',65.00,20,17,10.0),
(191,47,'Cours de cuisine grecque','Préparation de moussaka, spanakopita et baklava avec chef local.',55.00,10,8,3.0);

-- Florence (dest 48)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(192,48,'Visite des Offices avec accès coupe-file','Tour guidé de la plus grande collection de Renaissance au monde.',35.00,15,12,2.5),
(193,48,'Cours de cuisine toscane','Marché San Lorenzo + préparation ribollita, bistecca et tiramisu.',75.00,10,8,5.0),
(194,48,'Excursion dans le Chianti','Tour vinicole dans les vignes du Chianti Classico avec dégustation.',85.00,12,10,7.0),
(195,48,'Montée au Dôme de Brunelleschi','Ascension des 463 marches pour une vue 360° sur Florence et la Toscane.',18.00,20,16,2.0);

-- Porto (dest 49)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(196,49,'Tour des caves de porto','Visite et dégustation dans 3 caves historiques de Vila Nova de Gaia.',45.00,15,12,3.0),
(197,49,'Croisière sur le Douro','Bateau des 6 ponts sur le fleuve Douro avec vue sur Ribeira.',18.00,30,26,2.0),
(198,49,'Tour azulejos et Librairie Lello','Découverte du street art en carreaux et de la plus belle librairie du monde.',20.00,20,17,2.5),
(199,49,'Excursion aux vignobles du Douro','Journée dans la vallée classée UNESCO avec déjeuner en quinta.',90.00,12,9,9.0);

-- Sintra (dest 50)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(200,50,'Visite du Palácio da Pena','Tour du château romantique multicolore perché dans la forêt royale.',14.00,25,22,2.5),
(201,50,'Randonnée Cabo da Roca','Marche jusqu\'au point le plus occidental de l\'Europe continentale.',10.00,20,18,4.0),
(202,50,'Palácio de Queluz (Versailles portugais)','Visite du palais baroque des rois du Portugal et ses jardins à la française.',12.00,20,18,2.0),
(203,50,'Tour en tuk-tuk des palais','Circuit en tuk-tuk entre les 5 palais de Sintra avec guide local.',30.00,8,6,3.0);

-- Séoul (dest 51)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(204,51,'Visite du Palais Gyeongbokgung','Tour du plus grand palais Joseon avec relève de la garde en costume traditionnel.',3.00,30,26,2.0),
(205,51,'Cours de K-pop et K-beauty','Cours de danse K-pop + atelier maquillage coréen dans un studio de Gangnam.',60.00,12,9,3.0),
(206,51,'Tour gastronomique de Gwangjang','Dégustation de street food au marché de nuit le plus ancien de Séoul.',35.00,15,12,2.5),
(207,51,'Excursion à la zone démilitarisée','Tour de la DMZ et du tunnel nord-coréen avec guide militaire accrédité.',55.00,20,16,7.0);

-- Hong Kong (dest 52)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(208,52,'Tramway du Peak Victoria','Montée au sommet de l\'île pour la vue la plus spectaculaire sur la skyline.',8.00,40,36,2.0),
(209,52,'Tour des marchés de nuit Kowloon','Marchés de Temple Street et Mong Kok avec guide local connaisseur.',30.00,15,12,3.0),
(210,52,'Croisière Star Ferry + Symphony of Lights','Traversée iconique du port + spectacle son et lumière sur 44 gratte-ciels.',15.00,30,26,2.0),
(211,52,'Dim sum au palace restaurant','Brunch dim sum dans un restaurant de chef étoilé avec plus de 60 sortes.',45.00,10,8,2.0);

-- Kuala Lumpur (dest 53)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(212,53,'Tour des tours Petronas','Accès au sky bridge (41e étage) et observation deck (86e étage) des tours jumelles.',25.00,30,26,2.0),
(213,53,'Caves de Batu et temples hindous','Excursion aux grottes sacrées de Batu avec singes et temple doré.',12.00,25,21,3.0),
(214,53,'Tour gastronomique Jalan Alor','Dégustation de street food malaisien, indien et chinois dans la rue des saveurs.',30.00,15,12,2.5),
(215,53,'Excursion Cameron Highlands','Journée dans les plantations de thé des hautes terres malaisiennes.',55.00,15,12,9.0);

-- Hanoï (dest 54)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(216,54,'Excursion baie d\'Along en jonque','2 jours en jonque dans la baie classée UNESCO avec kayak et grotte.',150.00,12,9,48.0),
(217,54,'Tour de la vieille ville à vélo','Exploration des 36 guildes de Hanoï à vélo avec guide et déjeuner.',25.00,15,12,4.0),
(218,54,'Cours de cuisine vietnamienne','Marché + préparation de pho, banh mi et nem cuon avec chef local.',35.00,10,8,4.0),
(219,54,'Spectacle de marionnettes sur l\'eau','Art traditionnel vietnamien du Thang Long au lac Hoan Kiem.',10.00,30,27,1.0);

-- Mumbai (dest 55)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(220,55,'Tour de Dharavi (plus grand bidonville d\'Asie)','Visite sociale accompagnée dans ce quartier d\'entrepreneurs incroyables.',20.00,12,10,3.0),
(221,55,'Dîner croisière Mumbai Harbour','Repas sur un bateau devant le Gateway of India et le Taj Palace illuminés.',55.00,20,16,2.5),
(222,55,'Cours de cuisine indienne','Préparation de curry, samosa, chapati et chai masala avec cuisine traditionnelle.',40.00,10,8,4.0),
(223,55,'Visite du quartier Art Déco de Marine Drive','Tour architectural de la plus grande concentration Art Déco hors Miami.',15.00,20,17,2.5);

-- Montréal (dest 56)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(224,56,'Tour du Vieux-Montréal','Visite guidée du quartier colonial français avec guide francophone.',20.00,20,17,2.5),
(225,56,'Festival de Jazz ou Juste pour Rire','Accès aux concerts et spectacles du festival le plus important au monde.',0.00,100,90,4.0),
(226,56,'Randonnée Mont-Royal','Montée au sommet du mont qui domine Montréal avec vue panoramique.',0.00,30,27,2.0),
(227,56,'Poutine et gastronomie québécoise','Tour culinaire : poutine, tourtière, sirop d\'érable et fromages fins locaux.',45.00,15,12,3.0);

-- Los Angeles (dest 57)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(228,57,'Visite de Hollywood et Universal Studios','Journée à Universal Studios avec accès backstage et attractions blockbusters.',120.00,20,16,9.0),
(229,57,'Tour des maisons de stars à Beverly Hills','Balade en bus décapotable devant les villas des célébrités.',45.00,30,26,2.0),
(230,57,'Surf à Venice Beach','Cours de surf avec moniteur certifié sur la plage de Venice.',65.00,8,6,2.0),
(231,57,'Road trip Malibu et coucher de soleil','Balade en convertible le long de Pacific Coast Highway jusqu\'à Malibu.',85.00,4,3,4.0);

-- Sydney (dest 58)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(232,58,'BridgeClimb Harbour Bridge','Ascension guidée du Harbour Bridge avec vue 360° sur la baie de Sydney.',185.00,10,7,3.5),
(233,58,'Visite de l\'Opéra de Sydney','Tour des coulisses de l\'Opéra et concert dans la salle de concert.',45.00,20,17,2.0),
(234,58,'Excursion Blue Mountains','Journée dans les montagnes bleues avec les Trois Sœurs et forêt eucalyptus.',75.00,20,16,9.0),
(235,58,'Surf à Bondi Beach','Cours de surf sur la plage la plus célèbre d\'Australie.',60.00,10,8,2.0);

-- Buenos Aires (dest 59)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(236,59,'Cours de tango avec milonga','Cours en couple + soirée milonga dans un salon traditionnel de San Telmo.',45.00,15,12,4.0),
(237,59,'Tour des boulangeries et empanadas','Dégustation de la gastronomie argentine de rue dans le quartier de Palermo.',30.00,15,12,2.5),
(238,59,'Visite du stade Bombonera (Boca Juniors)','Tour du stade mythique du club le plus passionné du monde.',25.00,20,17,2.0),
(239,59,'Excursion à l\'Estancia','Journée dans un ranch argentin avec asado, cheval et folklore gaucho.',90.00,15,12,9.0);

-- Rio de Janeiro (dest 60)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(240,60,'Téléphérique du Pain de Sucre','Montée en téléphérique au sommet du Pão de Açúcar pour la vue mythique.',25.00,30,25,2.0),
(241,60,'Corcovado et Christ Rédempteur','Ascension au Christ Rédempteur en train à crémaillère dans la forêt tropicale.',35.00,25,20,3.0),
(242,60,'Cours de samba à l\'école de samba','Cours de samba avec les danseuses du Carnaval dans une vraie escola.',40.00,15,12,2.0),
(243,60,'Surf et Beach Volley à Ipanema','Cours de surf ou session de beach-volley sur la plage d\'Ipanema avec pro.',55.00,10,8,2.0);

-- Punta Cana (dest 61)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(244,61,'Excursion Isla Saona','Journée en catamaran vers l\'île paradisiaque de Saona avec buffet et open bar.',75.00,25,20,8.0),
(245,61,'Plongée à l\'espace de plongée 7 Mares','Plongée dans les eaux claires des Caraïbes avec tortues et raies.',70.00,10,8,3.0),
(246,61,'Buggy dans la forêt dominicaine','Excursion en buggy 4x4 dans la nature, cascade et village typique.',65.00,12,10,4.0),
(247,61,'Kitesurfing à Cabarete','Cours de kitesurf sur la plage de Cabarete, capitale mondiale du kite.',85.00,8,6,3.0);

-- Koh Samui (dest 62)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(248,62,'Excursion Ang Thong National Park','Journée en bateau dans le parc marin de 42 îles avec kayak et snorkeling.',65.00,20,16,8.0),
(249,62,'Full Moon Party Koh Phangan','Transport + entrée + open bar pour la fête mensuelle légendaire sur la plage.',40.00,25,20,8.0),
(250,62,'Cours de muay thai à Chaweng','Session d\'entraînement avec boxeurs professionnels thaïlandais.',30.00,10,8,2.0),
(251,62,'Spa et massage traditionnel thaï','Journée spa avec massage thaï 2h, soin du visage et bain aux fleurs.',55.00,8,7,5.0);

-- Cap-Vert (dest 63)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(252,63,'Kitesurf à Santa Maria','Cours ou session de kitesurf dans les vents parfaits de Sal, paradis des kiteurs.',75.00,8,6,3.0),
(253,63,'Excursion à pied autour du volcan Pico do Fogo','Randonnée autour du volcan actif de l\'île de Fogo avec guide.',45.00,10,8,7.0),
(254,63,'Snorkeling et découverte marine','Sortie en bateau pour observer les tortues marines et fonds coralliens préservés.',40.00,15,12,3.0),
(255,63,'Soirée musique morna','Concert de musique créole morna dans un bar authentique de Mindelo (São Vicente).',15.00,25,21,3.0);

-- La Réunion (dest 64)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(256,64,'Randonnée au Piton de la Fournaise','Trek guidé jusqu\'au bord du volcan actif, l\'un des plus actifs au monde.',35.00,10,7,7.0),
(257,64,'Canyoning dans le cirque de Cilaos','Descente de cascades et toboggans naturels dans le cirque volcanique.',75.00,8,6,5.0),
(258,64,'Surf à Saint-Leu','Session de surf sur l\'un des meilleurs spots de l\'océan Indien.',40.00,10,8,2.0),
(259,64,'Vol en ULM au-dessus des cirques','Survol des cirques et du littoral réunionnais en ultra-léger motorisé.',95.00,2,2,1.5);

-- Cape Town (dest 65)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(260,65,'Téléphérique Table Mountain','Montée au sommet de la montagne emblématique avec vue sur l\'océan et la ville.',25.00,30,26,2.0),
(261,65,'Safari en journée Réserve de Kapama','Safari dans une réserve proche avec lions, éléphants et girafes.',150.00,8,6,8.0),
(262,65,'Tour du Cap et Cape Point','Excursion au bout de l\'Afrique avec rencontre des pingouins à Boulders Beach.',65.00,20,16,8.0),
(263,65,'Dégustation dans les vignobles de Stellenbosch','Visite de 3 domaines viticoles avec accord mets et vins en plein air.',80.00,15,12,6.0);


-- ============================================================
-- DONNÉES — TRANSPORTS
-- ============================================================

-- Transports de base (IDs 1-6)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(1,'Air France',    'avion', 'Paris CDG', 'Bali DPS',   '2026-06-14 11:30:00', '2026-06-15 05:45:00', 789.00, 50),
(2,'Qatar Airways', 'avion', 'Paris CDG', 'Bali DPS',   '2026-06-14 15:20:00', '2026-06-15 09:00:00', 672.00, 40),
(3,'Air France',    'avion', 'Bali DPS',  'Paris CDG',  '2026-06-28 23:55:00', '2026-06-29 14:30:00', 789.00, 50),
(4,'Eurostar',      'train', 'Paris',     'Londres',    '2026-07-01 08:00:00', '2026-07-01 10:00:00', 120.00, 80),
(5,'Air France',    'avion', 'Paris CDG', 'Tokyo HND',  '2026-08-01 10:00:00', '2026-08-02 08:00:00',1100.00, 30),
(6,'TAP Portugal',  'avion', 'Paris CDG', 'Lisbonne',   '2026-09-15 07:30:00', '2026-09-15 09:45:00', 180.00, 60);

-- TRANSPORTS (nouveaux uniquement, IDs 7+)
-- ============================================================

-- Avion : Paris → destinations plage
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(7,'Emirates','avion','Paris CDG','Malé MLE','2026-07-10 21:30:00','2026-07-11 15:45:00',1350.00,250),
(8,'Air Maldives','avion','Paris CDG','Malé MLE','2026-08-15 23:00:00','2026-08-16 17:00:00',1190.00,200),
(9,'Thai Airways','avion','Paris CDG','Phuket HKT','2026-07-12 22:00:00','2026-07-13 16:30:00',720.00,300),
(10,'Emirates','avion','Paris CDG','Phuket HKT','2026-08-05 08:30:00','2026-08-06 03:20:00',680.00,280),
(11,'Air France','avion','Paris CDG','Cancún CUN','2026-07-18 10:00:00','2026-07-18 14:45:00',650.00,240);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(12,'Iberia','avion','Paris CDG','Cancún CUN','2026-08-10 12:30:00','2026-08-10 17:15:00',590.00,220),
(13,'Air Seychelles','avion','Paris CDG','Mahé SEZ','2026-07-22 22:45:00','2026-07-23 11:20:00',980.00,180),
(14,'Emirates','avion','Paris CDG','Mahé SEZ','2026-08-12 20:00:00','2026-08-13 09:00:00',1050.00,200),
(15,'Ethiopian Air','avion','Paris CDG','Zanzibar ZNZ','2026-07-25 11:00:00','2026-07-26 01:30:00',620.00,240),
(16,'Kenya Airways','avion','Paris CDG','Zanzibar ZNZ','2026-08-20 09:00:00','2026-08-20 23:45:00',580.00,220);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(17,'Aegean Airlines','avion','Paris CDG','Mykonos JMK','2026-06-20 07:30:00','2026-06-20 11:15:00',220.00,180),
(18,'Air France','avion','Paris CDG','Mykonos JMK','2026-07-28 14:00:00','2026-07-28 17:50:00',280.00,200),
(19,'Vueling','avion','Paris ORY','Ibiza IBZ','2026-06-25 06:45:00','2026-06-25 09:15:00',110.00,180),
(20,'easyJet','avion','Paris CDG','Ibiza IBZ','2026-07-04 11:00:00','2026-07-04 13:35:00',95.00,180),
(21,'Air Tahiti Nui','avion','Paris CDG','Bora Bora BOB','2026-08-01 10:00:00','2026-08-02 07:30:00',1800.00,240);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(22,'Air Mauritius','avion','Paris CDG','Île Maurice MRU','2026-07-30 22:00:00','2026-07-31 11:30:00',750.00,280),
(23,'Air France','avion','Paris CDG','Île Maurice MRU','2026-08-25 21:00:00','2026-08-26 10:00:00',820.00,250),
(24,'Air France','avion','Paris CDG','Miami MIA','2026-07-08 10:30:00','2026-07-08 14:00:00',480.00,300),
(25,'American Airlines','avion','Paris CDG','Miami MIA','2026-08-18 09:00:00','2026-08-18 12:30:00',420.00,280),
(26,'Aegean Airlines','avion','Paris CDG','Santorini JTR','2026-06-15 06:00:00','2026-06-15 10:30:00',195.00,180);

-- Avion : Paris → destinations montagne/ville/culture/aventure
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(27,'Air France','avion','Paris CDG','Santorini JTR','2026-07-20 08:00:00','2026-07-20 12:00:00',245.00,200),
(28,'Vueling','avion','Paris ORY','Barcelone BCN','2026-07-01 07:00:00','2026-07-01 08:45:00',80.00,180),
(29,'Air France','avion','Paris CDG','Barcelone BCN','2026-08-05 18:00:00','2026-08-05 20:00:00',120.00,200),
(30,'KLM','avion','Paris CDG','Amsterdam AMS','2026-07-05 08:00:00','2026-07-05 09:30:00',110.00,180),
(31,'Singapore Airlines','avion','Paris CDG','Singapour SIN','2026-07-15 23:30:00','2026-07-16 18:15:00',880.00,280);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(32,'Air France','avion','Paris CDG','Singapour SIN','2026-08-10 22:00:00','2026-08-11 16:45:00',920.00,250),
(33,'Czech Airlines','avion','Paris CDG','Prague PRG','2026-06-10 07:00:00','2026-06-10 09:05:00',95.00,180),
(34,'easyJet','avion','Paris CDG','Prague PRG','2026-07-22 10:30:00','2026-07-22 12:40:00',75.00,180),
(35,'Emirates','avion','Paris CDG','Dubaï DXB','2026-07-10 14:00:00','2026-07-10 23:00:00',420.00,300),
(36,'Air France','avion','Paris CDG','Dubaï DXB','2026-08-01 08:30:00','2026-08-01 17:45:00',380.00,280);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(37,'Air France','avion','Paris CDG','New York JFK','2026-07-12 11:00:00','2026-07-12 13:30:00',520.00,300),
(38,'Delta Airlines','avion','Paris CDG','New York JFK','2026-08-15 14:00:00','2026-08-15 16:20:00',480.00,280),
(39,'Thai Airways','avion','Paris CDG','Bangkok BKK','2026-07-05 23:00:00','2026-07-06 16:30:00',610.00,300),
(40,'Air France','avion','Paris CDG','Bangkok BKK','2026-08-20 22:30:00','2026-08-21 15:45:00',650.00,260),
(41,'Royal Air Maroc','avion','Paris CDG','Marrakech RAK','2026-07-03 08:00:00','2026-07-03 10:15:00',95.00,200);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(42,'Transavia','avion','Paris ORY','Marrakech RAK','2026-08-14 06:30:00','2026-08-14 08:45:00',80.00,180),
(43,'ITA Airways','avion','Paris CDG','Rome FCO','2026-07-08 07:00:00','2026-07-08 09:15:00',90.00,180),
(44,'Vueling','avion','Paris ORY','Rome FCO','2026-08-22 14:00:00','2026-08-22 16:20:00',75.00,180),
(45,'Turkish Airlines','avion','Paris CDG','Istanbul IST','2026-07-10 07:30:00','2026-07-10 11:30:00',190.00,280),
(46,'Pegasus','avion','Paris CDG','Istanbul SAW','2026-08-05 11:00:00','2026-08-05 15:10:00',145.00,220);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(47,'Japan Airlines','avion','Paris CDG','Osaka KIX','2026-07-15 10:30:00','2026-07-16 07:00:00',1050.00,250),
(48,'ANA','avion','Paris CDG','Osaka KIX','2026-08-10 21:00:00','2026-08-11 17:30:00',1120.00,240),
(49,'EgyptAir','avion','Paris CDG','Le Caire CAI','2026-07-20 10:00:00','2026-07-20 15:00:00',280.00,220),
(50,'Air France','avion','Paris CDG','Le Caire CAI','2026-08-12 13:00:00','2026-08-12 18:15:00',320.00,200),
(51,'Icelandair','avion','Paris CDG','Reykjavik KEF','2026-07-18 07:00:00','2026-07-18 09:30:00',290.00,180);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(52,'easyJet','avion','Paris CDG','Reykjavik KEF','2026-08-08 06:30:00','2026-08-08 09:05:00',220.00,180),
(53,'Kenya Airways','avion','Paris CDG','Nairobi NBO','2026-07-14 23:45:00','2026-07-15 09:30:00',680.00,250),
(54,'Ethiopian Air','avion','Paris CDG','Nairobi NBO','2026-08-20 10:00:00','2026-08-21 00:15:00',610.00,240),
(55,'Iberia','avion','Paris CDG','San José SJO','2026-07-22 10:30:00','2026-07-22 18:00:00',720.00,220),
(56,'Air France','avion','Paris CDG','Buenos Aires EZE','2026-08-05 11:00:00','2026-08-05 22:30:00',950.00,250);

-- Train
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(57,'SNCF','train','Paris Gare de Lyon','Saint-Gervais (Chamonix)','2026-07-01 07:20:00','2026-07-01 10:35:00',55.00,400),
(58,'SNCF','train','Paris Gare de Lyon','Saint-Gervais (Chamonix)','2026-08-15 08:10:00','2026-08-15 11:25:00',65.00,400),
(59,'Thalys','train','Paris Gare du Nord','Amsterdam Centraal','2026-07-10 09:19:00','2026-07-10 12:43:00',85.00,300),
(60,'Eurostar','train','Paris Gare du Nord','Amsterdam Centraal','2026-08-01 10:31:00','2026-08-01 13:52:00',95.00,300),
(61,'SNCF Renfe','train','Paris Gare de Lyon','Barcelone Sants','2026-07-05 06:25:00','2026-07-05 12:00:00',80.00,350);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(62,'SNCF Renfe','train','Paris Gare de Lyon','Barcelone Sants','2026-08-20 08:13:00','2026-08-20 13:47:00',95.00,350),
(63,'DB SNCF','train','Paris Est','Prague hl.n.','2026-07-18 07:08:00','2026-07-18 19:00:00',120.00,250),
(64,'Trenitalia','train','Paris Gare de Lyon','Rome Termini','2026-08-02 07:30:00','2026-08-02 19:15:00',130.00,300),
(65,'CP Portugal','train','Lisbonne Santa Apolonia','Porto Campanha','2026-07-08 10:00:00','2026-07-08 13:00:00',28.00,250),
(66,'SBB','train','Interlaken Ost','Zermatt','2026-07-20 09:15:00','2026-07-20 12:48:00',62.00,200);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(67,'JR West','train','Osaka','Kyoto','2026-07-16 08:00:00','2026-07-16 08:14:00',14.00,500);

-- Bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(68,'Flixbus','bus','Paris Bercy','Bruxelles Midi','2026-07-02 07:00:00','2026-07-02 10:30:00',15.00,55),
(69,'ALSA','bus','Lisbonne Sete Rios','Séville','2026-07-10 08:30:00','2026-07-10 15:00:00',25.00,50),
(70,'Peru Hop','bus','Cusco','Puno','2026-07-22 08:00:00','2026-07-22 16:00:00',35.00,45),
(71,'InterCity NZ','bus','Queenstown','Te Anau','2026-08-10 08:00:00','2026-08-10 11:30:00',28.00,50),
(72,'Nakhon Chai Air','bus','Bangkok Morchit','Chiang Mai','2026-07-15 21:00:00','2026-07-16 07:00:00',18.00,42);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(73,'CTM Maroc','bus','Marrakech','Essaouira','2026-07-20 09:00:00','2026-07-20 12:30:00',12.00,45),
(74,'Metro Turizm','bus','Istanbul Esenler','Göreme Cappadoce','2026-07-12 19:00:00','2026-07-13 06:00:00',22.00,45);

-- Bateau
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(75,'Hellenic Seaways','bateau','Athènes Pirée','Santorin','2026-07-15 07:30:00','2026-07-15 17:00:00',65.00,400),
(76,'SeaJets','bateau','Athènes Pirée','Santorin','2026-08-05 08:00:00','2026-08-05 13:30:00',90.00,200),
(77,'Balearia','bateau','Barcelone','Ibiza','2026-06-30 23:30:00','2026-07-01 09:00:00',55.00,600),
(78,'Trasmediterranea','bateau','Barcelone','Ibiza','2026-07-20 20:00:00','2026-07-21 05:30:00',50.00,500),
(79,'Aranui Cruises','bateau','Papeete Tahiti','Bora Bora','2026-08-10 10:00:00','2026-08-10 16:30:00',55.00,200);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(80,'DFDS Seaways','bateau','Amsterdam IJmuiden','Newcastle','2026-07-25 17:00:00','2026-07-26 09:00:00',120.00,500),
(81,'Island Aviation','bateau','Malé Airport','Atoll Baa','2026-07-12 14:00:00','2026-07-12 15:30:00',80.00,20),
(82,'Jadrolinija','bateau','Venise','Split','2026-08-01 16:00:00','2026-08-02 08:00:00',85.00,300);

-- TRANSPORTS DEPUIS PARIS (cohérents par destination)
-- ============================================================

-- ============================================================
-- EUROPÉENS PROCHES : avion + train + bus depuis Paris
-- ============================================================

-- Londres (dest 39) — Eurostar déjà en ID=3 dans schema.sql
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(84,'Eurostar','train','Paris Gare du Nord','London St Pancras','2026-07-08 09:01:00','2026-07-08 10:28:00',79.00,300),
(85,'Eurostar','train','Paris Gare du Nord','London St Pancras','2026-08-12 11:31:00','2026-08-12 12:58:00',95.00,300),
(86,'Air France','avion','Paris CDG','London Heathrow LHR','2026-07-15 07:00:00','2026-07-15 08:15:00',85.00,180),
(87,'easyJet','avion','Paris CDG','London Gatwick LGW','2026-08-20 06:30:00','2026-08-20 07:45:00',65.00,180),
(88,'Flixbus','bus','Paris Bercy Seine','London Victoria','2026-07-10 07:00:00','2026-07-10 13:30:00',25.00,55);

-- Berlin (dest 40) — avion + train (Nightjet) + bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(89,'Air France','avion','Paris CDG','Berlin BER','2026-07-05 07:30:00','2026-07-05 09:20:00',95.00,180),
(90,'easyJet','avion','Paris CDG','Berlin BER','2026-08-10 06:00:00','2026-08-10 07:55:00',75.00,180),
(91,'DB Nightjet','train','Paris Est','Berlin Hbf','2026-07-20 22:17:00','2026-07-21 08:02:00',89.00,150),
(92,'Flixbus','bus','Paris Bercy Seine','Berlin ZOB','2026-07-15 08:00:00','2026-07-16 04:30:00',35.00,55);

-- Vienne (dest 41) — avion + train (Nightjet)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(93,'Air France','avion','Paris CDG','Vienne VIE','2026-07-08 08:00:00','2026-07-08 10:00:00',110.00,180),
(94,'Austrian Airlines','avion','Paris CDG','Vienne VIE','2026-08-15 07:00:00','2026-08-15 09:05:00',95.00,180),
(95,'DB Nightjet','train','Paris Est','Wien Hbf','2026-07-22 22:25:00','2026-07-23 09:00:00',99.00,150),
(96,'Flixbus','bus','Paris Bercy Seine','Wien Erdberg','2026-07-18 07:30:00','2026-07-19 05:00:00',45.00,55);

-- Madrid (dest 42) — avion + train TGV/Renfe + bus nuit
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(97,'Air France','avion','Paris CDG','Madrid MAD','2026-07-01 07:30:00','2026-07-01 09:30:00',90.00,180),
(98,'Iberia','avion','Paris CDG','Madrid MAD','2026-08-05 08:00:00','2026-08-05 10:00:00',75.00,180),
(99,'SNCF Renfe','train','Paris Montparnasse','Madrid Chamartin','2026-07-10 09:30:00','2026-07-10 16:02:00',120.00,300),
(100,'Flixbus','bus','Paris Bercy Seine','Madrid Sur','2026-07-20 19:00:00','2026-07-21 14:00:00',49.00,55);

-- Bruxelles (dest 43) — avion + Thalys + bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(101,'Thalys','train','Paris Gare du Nord','Bruxelles Midi','2026-07-05 09:25:00','2026-07-05 10:55:00',45.00,300),
(102,'Thalys','train','Paris Gare du Nord','Bruxelles Midi','2026-08-12 12:55:00','2026-08-12 14:25:00',55.00,300),
(103,'Brussels Airlines','avion','Paris CDG','Bruxelles BRU','2026-07-15 07:30:00','2026-07-15 08:35:00',70.00,150),
(104,'Flixbus','bus','Paris Gallieni','Bruxelles Nord','2026-07-08 08:00:00','2026-07-08 11:30:00',12.00,55);

-- Copenhague (dest 44) — avion uniquement (train trop long)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(105,'Air France','avion','Paris CDG','Copenhague CPH','2026-07-10 07:30:00','2026-07-10 10:15:00',140.00,180),
(106,'SAS','avion','Paris CDG','Copenhague CPH','2026-08-20 08:00:00','2026-08-20 10:45:00',120.00,180);

-- Stockholm (dest 45) — avion + bus très long
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(107,'Air France','avion','Paris CDG','Stockholm ARN','2026-07-12 08:30:00','2026-07-12 11:50:00',160.00,180),
(108,'SAS','avion','Paris CDG','Stockholm ARN','2026-08-18 07:00:00','2026-08-18 10:20:00',140.00,180);

-- Budapest (dest 46) — avion + train (Nightjet) + bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(109,'Air France','avion','Paris CDG','Budapest BUD','2026-07-08 08:00:00','2026-07-08 10:15:00',105.00,180),
(110,'Wizz Air','avion','Paris ORY','Budapest BUD','2026-08-10 06:30:00','2026-08-10 08:45:00',65.00,180),
(111,'DB Nightjet','train','Paris Est','Budapest Keleti','2026-07-20 21:33:00','2026-07-21 09:40:00',109.00,150),
(112,'Flixbus','bus','Paris Bercy Seine','Budapest Nepliget','2026-07-15 08:00:00','2026-07-16 07:30:00',55.00,55);

-- Athènes (dest 47) — avion uniquement depuis Paris
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(113,'Air France','avion','Paris CDG','Athènes ATH','2026-07-10 08:30:00','2026-07-10 12:30:00',145.00,180),
(114,'Aegean Airlines','avion','Paris CDG','Athènes ATH','2026-08-15 09:00:00','2026-08-15 13:05:00',120.00,180);

-- Florence (dest 48) — avion + train (TGV Paris-Florence)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(115,'Vueling','avion','Paris ORY','Florence FLR','2026-07-05 07:00:00','2026-07-05 09:15:00',85.00,180),
(116,'Air France','avion','Paris CDG','Pise PSA','2026-08-10 08:30:00','2026-08-10 10:45:00',95.00,180),
(117,'Trenitalia','train','Paris Gare de Lyon','Florence SMN','2026-07-15 07:15:00','2026-07-15 14:50:00',110.00,300),
(118,'Flixbus','bus','Paris Bercy Seine','Florence SITA','2026-07-20 07:00:00','2026-07-20 20:00:00',45.00,55);

-- Porto (dest 49) — avion + bus nuit (pas de train direct Paris-Porto)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(119,'TAP Portugal','avion','Paris CDG','Porto OPO','2026-07-08 07:30:00','2026-07-08 09:40:00',95.00,180),
(120,'Ryanair','avion','Paris Beauvais','Porto OPO','2026-08-12 06:30:00','2026-08-12 08:45:00',55.00,180),
(121,'Flixbus','bus','Paris Bercy Seine','Porto Campo 24 Agosto','2026-07-20 09:00:00','2026-07-21 09:00:00',49.00,55);

-- Sintra (dest 50) — via Lisbonne (avion + bus depuis Lisbonne)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(122,'TAP Portugal','avion','Paris CDG','Lisbonne LIS','2026-07-10 07:00:00','2026-07-10 09:15:00',90.00,180),
(123,'easyJet','avion','Paris CDG','Lisbonne LIS','2026-08-05 06:30:00','2026-08-05 08:45:00',75.00,180);

-- ============================================================
-- INTERNATIONAUX LOINTAINS : avion uniquement depuis Paris
-- ============================================================

-- Séoul (dest 51)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(124,'Korean Air','avion','Paris CDG','Séoul ICN','2026-07-10 13:30:00','2026-07-11 08:10:00',850.00,300),
(125,'Air France','avion','Paris CDG','Séoul ICN','2026-08-15 10:00:00','2026-08-16 05:40:00',920.00,280);

-- Hong Kong (dest 52)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(126,'Cathay Pacific','avion','Paris CDG','Hong Kong HKG','2026-07-12 22:00:00','2026-07-13 17:30:00',780.00,300),
(127,'Air France','avion','Paris CDG','Hong Kong HKG','2026-08-10 21:30:00','2026-08-11 17:00:00',850.00,280);

-- Kuala Lumpur (dest 53)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(128,'Malaysia Airlines','avion','Paris CDG','Kuala Lumpur KUL','2026-07-15 21:00:00','2026-07-16 16:00:00',720.00,300),
(129,'Qatar Airways','avion','Paris CDG','Kuala Lumpur KUL','2026-08-20 23:00:00','2026-08-21 18:30:00',680.00,280);

-- Hanoï (dest 54)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(130,'Vietnam Airlines','avion','Paris CDG','Hanoï HAN','2026-07-08 22:30:00','2026-07-09 15:30:00',680.00,280),
(131,'Air France','avion','Paris CDG','Hanoï HAN','2026-08-12 21:00:00','2026-08-13 14:00:00',750.00,280);

-- Mumbai (dest 55)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(132,'Air India','avion','Paris CDG','Mumbai BOM','2026-07-10 21:30:00','2026-07-11 09:00:00',580.00,300),
(133,'Air France','avion','Paris CDG','Mumbai BOM','2026-08-15 22:00:00','2026-08-16 09:30:00',620.00,280);

-- Montréal (dest 56)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(134,'Air Transat','avion','Paris CDG','Montréal YUL','2026-07-05 11:00:00','2026-07-05 13:00:00',420.00,300),
(135,'Air France','avion','Paris CDG','Montréal YUL','2026-08-10 10:30:00','2026-08-10 12:30:00',480.00,280);

-- Los Angeles (dest 57)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(136,'Air France','avion','Paris CDG','Los Angeles LAX','2026-07-12 10:00:00','2026-07-12 13:30:00',580.00,300),
(137,'Delta Airlines','avion','Paris CDG','Los Angeles LAX','2026-08-18 11:00:00','2026-08-18 14:20:00',520.00,280);

-- Sydney (dest 58)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(138,'Qantas','avion','Paris CDG','Sydney SYD','2026-07-15 22:00:00','2026-07-17 07:00:00',1350.00,300),
(139,'Air France','avion','Paris CDG','Sydney SYD','2026-08-20 21:30:00','2026-08-22 06:30:00',1450.00,280);

-- Buenos Aires (dest 59)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(140,'Air France','avion','Paris CDG','Buenos Aires EZE','2026-07-10 11:00:00','2026-07-10 22:30:00',880.00,300),
(141,'Aerolíneas Argentinas','avion','Paris CDG','Buenos Aires EZE','2026-08-05 12:00:00','2026-08-05 23:30:00',820.00,280);

-- Rio de Janeiro (dest 60)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(142,'Air France','avion','Paris CDG','Rio de Janeiro GIG','2026-07-08 10:30:00','2026-07-08 20:00:00',820.00,300),
(143,'Latam Airlines','avion','Paris CDG','Rio de Janeiro GIG','2026-08-12 11:00:00','2026-08-12 20:30:00',780.00,280);

-- Punta Cana (dest 61)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(144,'Corsair','avion','Paris ORY','Punta Cana PUJ','2026-07-05 10:00:00','2026-07-05 14:30:00',580.00,300),
(145,'Air France','avion','Paris CDG','Punta Cana PUJ','2026-08-10 09:30:00','2026-08-10 14:00:00',650.00,280);

-- Koh Samui (dest 62) — via Bangkok
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(146,'Bangkok Airways','avion','Paris CDG','Koh Samui USM','2026-07-10 22:00:00','2026-07-11 19:00:00',780.00,200),
(147,'Thai Airways','avion','Paris CDG','Koh Samui USM','2026-08-15 21:00:00','2026-08-16 18:00:00',720.00,200);

-- Cap-Vert (dest 63)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(148,'TACV / Cabo Verde Airlines','avion','Paris CDG','Sal SID','2026-07-12 22:00:00','2026-07-13 02:00:00',420.00,200),
(149,'Transavia','avion','Paris ORY','Sal SID','2026-08-08 21:30:00','2026-08-09 01:30:00',380.00,180);

-- La Réunion (dest 64)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(150,'Air France','avion','Paris CDG','Saint-Denis RUN','2026-07-15 22:30:00','2026-07-16 11:30:00',580.00,280),
(151,'Corsair','avion','Paris ORY','Saint-Denis RUN','2026-08-20 21:00:00','2026-08-21 10:00:00',520.00,250);

-- Cape Town (dest 65)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(152,'Air France','avion','Paris CDG','Cape Town CPT','2026-07-10 22:00:00','2026-07-11 11:00:00',850.00,280),
(153,'South African Airways','avion','Paris CDG','Cape Town CPT','2026-08-15 20:00:00','2026-08-16 09:00:00',780.00,280);

-- ============================================================
-- TRANSPORTS MANQUANTS POUR DESTINATIONS EXISTANTES
-- (Lisbonne bus, Barcelone ferry, etc.)
-- ============================================================

-- Lisbonne (dest 4) — ajout bus Flixbus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(154,'Flixbus','bus','Paris Bercy Seine','Lisbonne Sete Rios','2026-07-08 08:00:00','2026-07-09 08:00:00',45.00,55),
(155,'ALSA','bus','Paris Bercy Seine','Lisbonne Oriente','2026-08-15 09:00:00','2026-08-16 09:00:00',55.00,55);

-- Chamonix (dest 17) — ajout bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(156,'Flixbus','bus','Paris Bercy Seine','Chamonix gare routière','2026-07-05 07:30:00','2026-07-05 13:00:00',25.00,55),
(157,'Ouibus','bus','Paris Bercy Seine','Chamonix gare routière','2026-08-10 08:00:00','2026-08-10 13:30:00',22.00,55);

-- Interlaken (dest 3) — ajout bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(158,'Flixbus','bus','Paris Bercy Seine','Interlaken gare','2026-07-10 07:00:00','2026-07-10 15:00:00',35.00,55),
(159,'Flixbus','bus','Paris Bercy Seine','Interlaken gare','2026-08-20 07:00:00','2026-08-20 15:00:00',40.00,55);

-- Mykonos (dest 12) — ferry depuis Athènes (Paris→ATH en avion puis ferry)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(160,'SeaJets','bateau','Athènes Pirée','Mykonos JMK','2026-07-11 07:30:00','2026-07-11 09:30:00',45.00,200),
(161,'Hellenic Seaways','bateau','Athènes Pirée','Mykonos JMK','2026-08-16 08:00:00','2026-08-16 12:30:00',35.00,400);


SET foreign_key_checks = 1;
