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
    type             ENUM('destination', 'dates', 'transport', 'hebergement', 'activite') NOT NULL,
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
('Gabin Kerevel',     'gabin@test.fr',   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'membre');
INSERT INTO utilisateurs (nom, email, mot_de_passe, role) VALUES
('Aurélien Kammerer', 'aurelien@test.fr','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'membre');
INSERT INTO utilisateurs (nom, email, mot_de_passe, role) VALUES
('Brice Fargeat',     'brice@test.fr',   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'membre');
INSERT INTO utilisateurs (nom, email, mot_de_passe, role) VALUES
('Isiah Perelman',    'isiah@test.fr',   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'membre');
-- mot de passe pour tous : password


-- ============================================================
-- DONNÉES — DESTINATIONS (59 au total, IDs 1-59)
-- ============================================================

-- Lot 1 : plage (nouvelles)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(1,'Maldives','Maldives','plage','Atolls de coraux turquoise, bungalows sur pilotis et eaux cristallines.',2200.00,'https://images.unsplash.com/photo-1573843981267-be1999ff37cd?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(2,'Phuket','Thaïlande','plage','Baies secrètes, plages de sable blanc, cuisine de rue et vie nocturne animée.',650.00,'https://images.unsplash.com/photo-1589394815804-964ed0be2eb5?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(3,'Cancún','Mexique','plage','Mer des Caraïbes turquoise, zone hôtelière animée et ruines mayas à proximité.',720.00,'https://images.unsplash.com/photo-1552074284-5e88ef1aef18?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(4,'Seychelles','Seychelles','plage','Archipel préservé aux rochers de granit rose et biodiversité unique.',2500.00,'https://images.unsplash.com/photo-1573624337853-5e7d3e9e843e?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(5,'Zanzibar','Tanzanie','plage','Île épicée aux plages de sable blanc et vieille ville historique.',890.00,'https://images.unsplash.com/photo-1586861203927-800a5acdcc4d?w=800&q=80');

-- Lot 2 : plage (suite)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(6,'Mykonos','Grèce','plage','Moulins à vent emblématiques, plages animées et gastronomie méditerranéenne.',950.00,'https://images.unsplash.com/photo-1601581987809-a874a81309c9?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(7,'Ibiza','Espagne','plage','Île festive aux clubs légendaires, calanques cachées et marchés hippies.',680.00,'https://images.unsplash.com/photo-1503912882839-cf1b57f1c0a4?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(8,'Bora Bora','Polynésie française','plage','Lagon turquoise mythique, monts volcaniques verdoyants et luxe discret.',3200.00,'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(9,'Île Maurice','Maurice','plage','Plages de sable doux, lagons protégés par des récifs et culture métissée.',1100.00,'https://images.unsplash.com/photo-1504275107627-0c2ba7a43dba?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(10,'Miami Beach','États-Unis','plage','Art déco pastel, South Beach animée, musées et gastronomie Floride-Caraïbes.',980.00,'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80');

-- Lot 3 : montagne
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(11,'Chamonix','France','montagne','Berceau de l\'alpinisme au pied du Mont-Blanc, ski hors-piste et randonnées.',890.00,'https://images.unsplash.com/photo-1551524163-a4fc34a25a3f?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(12,'Queenstown','Nouvelle-Zélande','montagne','Capitale mondiale de l\'aventure : bungy, ski, jet-boat et fjords de Milford Sound.',1600.00,'https://images.unsplash.com/photo-1507699622108-4be3abd695ad?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(13,'Zermatt','Suisse','montagne','Village sans voitures au pied du Cervin, ski de renommée mondiale.',1450.00,'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(14,'Dolomites','Italie','montagne','Aiguilles calcaires rose-orangées, via ferrata épiques et refuges alpins.',780.00,'https://images.unsplash.com/photo-1551524163-a4fc34a25a3f?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(15,'Tromsø','Norvège','montagne','Cité arctique pour les aurores boréales, chiens de traîneau et baleines.',1300.00,'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(16,'Aspen','États-Unis','montagne','Station de ski élégante du Colorado, gastronomie raffinée et festivals culturels.',1800.00,'https://images.unsplash.com/photo-1548777123-e216912df7d8?w=800&q=80');

-- Lot 4 : ville
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(17,'Barcelone','Espagne','ville','Gaudí, Ramblas, tapas, plage en ville et fête perpétuelle en Catalogne.',550.00,'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(18,'Amsterdam','Pays-Bas','ville','Canaux romantiques, musées world-class, vélos partout et maisons penchées.',600.00,'https://images.unsplash.com/photo-1534351590666-13e3e96b5017?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(19,'Singapour','Singapour','ville','Cité-état ultramoderne, Gardens by the Bay et street food pluriculturel primé.',1250.00,'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(20,'Prague','République tchèque','ville','Château médiéval dominant 100 clochers, bière artisanale et ambiance bohème.',380.00,'https://images.unsplash.com/photo-1541849546-216549ae216d?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(21,'Dubaï','Émirats arabes unis','ville','Gratte-ciel records, souks dorés, désert à 30 min et luxe absolu partout.',1350.00,'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80');

-- Lot 5 : ville (suite)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(22,'New York','États-Unis','ville','La ville qui ne dort jamais : Central Park, Broadway et skyline légendaire.',1200.00,'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(23,'Bangkok','Thaïlande','ville','Temples bouddhistes dorés, tuk-tuks, marchés flottants et nuits électrisantes.',490.00,'https://images.unsplash.com/photo-1563492065599-3520f775eeed?w=800&q=80');

-- Lot 6 : culture
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(24,'Marrakech','Maroc','culture','Médina millénaire, souks labyrinthiques, riads colorés et cuisine épicée.',420.00,'https://images.unsplash.com/photo-1539020140153-e479b8c22e70?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(25,'Rome','Italie','culture','Musée à ciel ouvert : Colisée, Vatican, fontaines baroques et pasta maison.',580.00,'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(26,'Istanbul','Turquie','culture','Carrefour de deux continents, mosquées ottomanes et croisière sur le Bosphore.',490.00,'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(27,'Kyoto','Japon','culture','Ancienne capitale impériale, jardins zen, geishas et temples de bambou.',980.00,'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(28,'Le Caire','Égypte','culture','Pyramides de Gizeh, musée égyptien et croisière inoubliable sur le Nil.',560.00,'https://images.unsplash.com/photo-1539768942893-daf525e5d1e5?w=800&q=80');

-- Lot 7 : aventure
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(29,'Reykjavik','Islande','aventure','Geysers, cascades mythiques, aurores boréales et paysages de feu et glace.',1100.00,'https://images.unsplash.com/photo-1474690870753-1b92efa1f2d8?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(30,'Nairobi','Kenya','aventure','Porte du safari africain : Masaï Mara, lions et couchers de soleil sur la savane.',1400.00,'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(31,'San José','Costa Rica','aventure','Forêts tropicales, volcans actifs, surf sur deux océans et zip-line en canopée.',980.00,'https://images.unsplash.com/photo-1518259102261-b40117eabbc9?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(32,'El Calafate','Argentine','aventure','Glacier Perito Moreno imposant, condors des Andes et trekking à Torres del Paine.',1250.00,'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&q=80');

-- VILLE (Europe proche — avion + train + bus depuis Paris)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(33,'Londres','Royaume-Uni','ville','Big Ben, Buckingham Palace, pubs centenaires et scène culturelle mondiale dans la capitale britannique.',350.00,'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(34,'Berlin','Allemagne','ville','Murs de l\'histoire, street art omniprésent, clubs légendaires et gastronomie multiculturelle.',420.00,'https://images.unsplash.com/photo-1560969184-10fe8719e047?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(35,'Vienne','Autriche','culture','Palais impériaux, cafés viennois centenaires, opéra mythique et valse sous les lustres de cristal.',520.00,'https://images.unsplash.com/photo-1516550893923-42d28e5677af?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(36,'Madrid','Espagne','ville','Prado, Reina Sofía, tapas au marché San Miguel et ambiance festive jusqu\'à l\'aube.',480.00,'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(37,'Bruxelles','Belgique','ville','Manneken Pis, Grand-Place baroque, bières trappistes et chocolats fondants dans la capitale de l\'Europe.',290.00,'https://images.unsplash.com/photo-1559113202-c916b8e44373?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(38,'Copenhague','Danemark','ville','La Petite Sirène, Nyhavn coloré, gastronomie nordique et la ville la plus heureuse du monde.',680.00,'https://images.unsplash.com/photo-1513622470522-26c3c8a854bc?w=800&q=80');

INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(39,'Stockholm','Suède','ville','Capitale sur 14 îles, musée Vasa, design scandinave et aurores boréales en hiver.',720.00,'https://images.unsplash.com/photo-1509356843151-3e7d96241e11?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(40,'Budapest','Hongrie','culture','Bains thermaux ottomans, Parlement néogothique sur le Danube et ruin bars uniques au monde.',380.00,'https://images.unsplash.com/photo-1551867633-194f125bddfa?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(41,'Athènes','Grèce','culture','L\'Acropole surplombant 4000 ans d\'histoire, tavernes animées et musées exceptionnels.',420.00,'https://images.unsplash.com/photo-1603565816030-6b389eeb23cb?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(42,'Florence','Italie','culture','Berceau de la Renaissance, David de Michel-Ange, Offices et les meilleurs bisteccas du monde.',550.00,'https://images.unsplash.com/photo-1543429258-60af90a01b7c?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(43,'Porto','Portugal','ville','Azulejos bleus, caves de porto millésimées, ponts de Gustave Eiffel et fado authentique.',380.00,'https://images.unsplash.com/photo-1555881400-74d7acaacd8b?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(44,'Lisbonne Nord (Sintra)','Portugal','culture','Palais de Sintra enchantés dans la forêt, falaises de Cabo da Roca et vignes de la côte d\'argent.',310.00,'https://images.unsplash.com/photo-1548707309-dcebeab9ea9b?w=800&q=80');

-- VILLE (monde — avion uniquement depuis Paris)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(45,'Séoul','Corée du Sud','ville','K-pop, palais Gyeongbokgung, cuisine de rue épicée et quartiers ultra-modernes comme Gangnam.',980.00,'https://images.unsplash.com/photo-1538485399081-7c8272b29579?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(46,'Hong Kong','Chine','ville','Skyline vertigineux, dim sum légendaires, marchés nocturnes et Star Ferry entre Kowloon et l\'île.',1050.00,'https://images.unsplash.com/photo-1536599018102-9f803c140fc1?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(47,'Kuala Lumpur','Malaisie','ville','Tours Petronas scintillantes, jungle tropicale à 20 min, street food multiculturel et shopping paradis.',620.00,'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(48,'Hanoï','Vietnam','culture','Vieille ville aux 36 guildes, lac Hoan Kiem, pho au petit-déjeuner et baie d\'Along à portée de main.',540.00,'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(49,'Mumbai','Inde','culture','Gateway of India, Bollywood, quartier Dharavi et la plus grande concentration d\'art déco hors Miami.',680.00,'https://images.unsplash.com/photo-1529253355930-ddbe423a2ac7?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(50,'Montréal','Canada','ville','Festivals en tout genre, vieux port historique, gastronomie franco-québécoise et hivers festifs.',750.00,'https://images.unsplash.com/photo-1519178614-68673b201f36?w=800&q=80');

INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(51,'Los Angeles','États-Unis','ville','Hollywood, plages de Santa Monica, gastronomie de fusion mondiale et couchers de soleil sur le Pacifique.',950.00,'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(52,'Sydney','Australie','ville','Opéra sur la baie, Bondi Beach, barbecue du dimanche et Blue Mountains à une heure.',1200.00,'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(53,'Buenos Aires','Argentine','ville','Capitale du tango, biftecks de légende, architecture haussmannienne et vie nocturne jusqu\'au matin.',780.00,'https://images.unsplash.com/photo-1589909202802-8f4aadce1849?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(54,'Rio de Janeiro','Brésil','aventure','Corcovado, Copacabana, carnaval explosif, caïpirinhas et forêt tropicale dans la ville.',820.00,'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?w=800&q=80');

-- PLAGE (avion uniquement depuis Paris)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(55,'Punta Cana','République dominicaine','plage','Palmiers sur 45 km de plage blanche, eaux turquoise et all-inclusive de rêve aux Caraïbes.',680.00,'https://images.unsplash.com/photo-1504615755583-2916b52192a3?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(56,'Koh Samui','Thaïlande','plage','Cocotiers géants, Full Moon Party de Koh Phangan, snorkeling à Ang Thong et spa luxueux.',560.00,'https://images.unsplash.com/photo-1589394815804-964ed0be2eb5?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(57,'Cap-Vert','Cap-Vert','plage','Archipel atlantique aux plages de sable doré, kitesurf à Sal, musique morna et culture créole.',720.00,'https://images.unsplash.com/photo-1586861203927-800a5acdcc4d?w=800&q=80');

-- AVENTURE (avion uniquement)
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(58,'La Réunion','France','aventure','Volcan Piton de la Fournaise en activité, cirques de montagne, surf à Saint-Leu et canyoning mythique.',850.00,'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&q=80');
INSERT IGNORE INTO destinations (id,nom,pays,categorie,description,prix_min,image_url) VALUES
(59,'Cape Town','Afrique du Sud','aventure','Table Mountain, Cape Point, plages de Camps Bay, vignobles de Stellenbosch et safaris proches.',1050.00,'https://images.unsplash.com/photo-1580060839134-75a5edca2e99?w=800&q=80');

-- ============================================================
-- IMAGES DES DESTINATIONS (fichiers locaux — frontend/public/images/destinations/)
-- ============================================================
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/1.jpg'  WHERE id = 1;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/2.jpg'  WHERE id = 2;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/3.jpg'  WHERE id = 3;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/4.jpg' WHERE id = 4;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/5.jpg' WHERE id = 5;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/6.jpg' WHERE id = 6;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/7.jpg' WHERE id = 7;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/8.jpg' WHERE id = 8;
UPDATE destinations SET image_url = '/voyagevista-grouptrip/frontend/dist/images/destinations/9.jpg' WHERE id = 9;
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

-- ============================================================
-- ICÔNES DES DESTINATIONS (depuis icons.js)
-- ============================================================
UPDATE destinations SET icone = '🏝️' WHERE id = 1;   -- Maldives
UPDATE destinations SET icone = '🏖️' WHERE id = 2;   -- Phuket
UPDATE destinations SET icone = '🌴' WHERE id = 3;   -- Cancún
UPDATE destinations SET icone = '🏖️' WHERE id = 4;  -- Seychelles
UPDATE destinations SET icone = '🐠' WHERE id = 5;  -- Zanzibar
UPDATE destinations SET icone = '⛵' WHERE id = 6;  -- Mykonos
UPDATE destinations SET icone = '🎶' WHERE id = 7;  -- Ibiza
UPDATE destinations SET icone = '🌺' WHERE id = 8;  -- Bora Bora
UPDATE destinations SET icone = '🌺' WHERE id = 9;  -- Île Maurice
UPDATE destinations SET icone = '🌊' WHERE id = 10;  -- Miami Beach
UPDATE destinations SET icone = '⛷️' WHERE id = 11;  -- Chamonix
UPDATE destinations SET icone = '🎿' WHERE id = 12;  -- Queenstown
UPDATE destinations SET icone = '🏔️' WHERE id = 13;  -- Zermatt
UPDATE destinations SET icone = '🏔️' WHERE id = 14;  -- Dolomites
UPDATE destinations SET icone = '🏔️' WHERE id = 15;  -- Tromsø
UPDATE destinations SET icone = '🏔️' WHERE id = 16;  -- Aspen
UPDATE destinations SET icone = '🏟️' WHERE id = 17;  -- Barcelone
UPDATE destinations SET icone = '🌷' WHERE id = 18;  -- Amsterdam
UPDATE destinations SET icone = '🌇' WHERE id = 19;  -- Singapour
UPDATE destinations SET icone = '🏰' WHERE id = 20;  -- Prague
UPDATE destinations SET icone = '🌆' WHERE id = 21;  -- Dubaï
UPDATE destinations SET icone = '🗽' WHERE id = 22;  -- New York
UPDATE destinations SET icone = '🛕' WHERE id = 23;  -- Bangkok
UPDATE destinations SET icone = '🕌' WHERE id = 24;  -- Marrakech
UPDATE destinations SET icone = '🏛️' WHERE id = 25;  -- Rome
UPDATE destinations SET icone = '🕌' WHERE id = 26;  -- Istanbul
UPDATE destinations SET icone = '🎋' WHERE id = 27;  -- Kyoto
UPDATE destinations SET icone = '🐪' WHERE id = 28;  -- Le Caire
UPDATE destinations SET icone = '🧗' WHERE id = 29;  -- Reykjavik
UPDATE destinations SET icone = '🦁' WHERE id = 30;  -- Nairobi
UPDATE destinations SET icone = '🧗' WHERE id = 31;  -- San José
UPDATE destinations SET icone = '🧗' WHERE id = 32;  -- El Calafate
UPDATE destinations SET icone = '🎡' WHERE id = 33;  -- Londres
UPDATE destinations SET icone = '🧱' WHERE id = 34;  -- Berlin
UPDATE destinations SET icone = '🎼' WHERE id = 35;  -- Vienne
UPDATE destinations SET icone = '💃' WHERE id = 36;  -- Madrid
UPDATE destinations SET icone = '🍫' WHERE id = 37;  -- Bruxelles
UPDATE destinations SET icone = '🧜' WHERE id = 38;  -- Copenhague
UPDATE destinations SET icone = '👑' WHERE id = 39;  -- Stockholm
UPDATE destinations SET icone = '🌉' WHERE id = 40;  -- Budapest
UPDATE destinations SET icone = '🏛️' WHERE id = 41;  -- Athènes
UPDATE destinations SET icone = '🎨' WHERE id = 42;  -- Florence
UPDATE destinations SET icone = '🍷' WHERE id = 43;  -- Porto
UPDATE destinations SET icone = '🏯' WHERE id = 44;  -- Lisbonne Nord (Sintra)
UPDATE destinations SET icone = '🎎' WHERE id = 45;  -- Séoul
UPDATE destinations SET icone = '🌃' WHERE id = 46;  -- Hong Kong
UPDATE destinations SET icone = '🏙️' WHERE id = 47;  -- Kuala Lumpur
UPDATE destinations SET icone = '🏮' WHERE id = 48;  -- Hanoï
UPDATE destinations SET icone = '🎬' WHERE id = 49;  -- Mumbai
UPDATE destinations SET icone = '🍁' WHERE id = 50;  -- Montréal
UPDATE destinations SET icone = '🌴' WHERE id = 51;  -- Los Angeles
UPDATE destinations SET icone = '🌉' WHERE id = 52;  -- Sydney
UPDATE destinations SET icone = '💃' WHERE id = 53;  -- Buenos Aires
UPDATE destinations SET icone = '🎭' WHERE id = 54;  -- Rio de Janeiro
UPDATE destinations SET icone = '🌴' WHERE id = 55;  -- Punta Cana
UPDATE destinations SET icone = '🥥' WHERE id = 56;  -- Koh Samui
UPDATE destinations SET icone = '🌊' WHERE id = 57;  -- Cap-Vert
UPDATE destinations SET icone = '🌋' WHERE id = 58;  -- La Réunion
UPDATE destinations SET icone = '🦭' WHERE id = 59;  -- Cape Town


-- ============================================================
-- DONNÉES — HÉBERGEMENTS
-- ============================================================

-- Hébergements de base (IDs 1-8, destinations 1-6)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(1, 1, 'The Kayon Resort',    'resort',  125.00, 2, 'Vue sur la jungle, piscine à débordement.', NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(2, 1, 'Villa Umah Sunset',   'villa',   180.00, 4, 'Villa privée avec vue sur l\'océan.', NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(3, 1, 'Sunshine Beach Hotel','hotel',    60.00, 2, 'Hôtel 3 étoiles à 200m de la plage.', NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(4, 2, 'Shinjuku Grand Hotel','hotel',   110.00, 2, 'Idéalement situé dans le quartier Shinjuku.', NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(5, 3, 'Alpine Lodge',        'hotel',    95.00, 2, 'Chalet avec vue sur les Alpes.', NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(6, 4, 'LX Boutique Hotel',   'hotel',    85.00, 2, 'Boutique hôtel en centre-ville.', NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(7, 5, 'Caldera Suites',      'hotel',   160.00, 2, 'Vue directe sur la caldeira.', NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(8, 6, 'Casa Andina',         'hotel',    70.00, 2, 'Hôtel confortable en centre historique.', NULL);

-- HÉBERGEMENTS (nouveaux uniquement, IDs 18+)
-- ============================================================

-- Maldives (dest 1)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(18,1,'One & Only Reethi Rah','resort',1200.00,2,'Resort privé avec bungalow sur pilotis, plongée et spa de luxe absolu.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(19,1,'Coco Bodu Hithi','resort',680.00,4,'Villas sur pilotis avec piscine privée et accès direct au lagon turquoise.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(20,1,'Maafushivaru Resort','hotel',390.00,2,'Île-hôtel intime, coraux préservés et ambiance romantique garantie.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');

-- Phuket (dest 2)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(21,2,'Sri Panwa Resort','resort',280.00,6,'Resort sur promontoire avec vue 360° sur la mer d\'Andaman.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(22,2,'Villa Nalinnadda','villa',150.00,8,'Villa avec piscine privée dans la colline de Kata Noi.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(23,2,'Slumber Party Hostel','hostel',14.00,14,'Hostel festif sur Bangla Road avec piscine et soirées à thème.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Cancún (dest 3)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(24,3,'Grand Oasis Cancún','resort',220.00,4,'All-inclusive en bord de mer avec 14 restaurants et entertainment.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(25,3,'Hotel Krystal Cancún','hotel',110.00,2,'Hôtel 4 étoiles directement sur la plage de la zone hôtelière.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(26,3,'Nomads Hostel Cancún','hostel',18.00,10,'Hostel central avec terrasse animée et excursions Cenotes organisées.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Seychelles (dest 4)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(27,4,'Six Senses Zil Pasyon','resort',1500.00,2,'Resort sur île privée, bungalows dans la roche granitique et spa holistique.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(28,4,'Anse Soleil Beachcomber','hotel',220.00,4,'Hôtel boutique sur la plage d\'Anse Soleil, snorkeling inclus.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(29,4,'Beau Vallon Beach Villa','airbnb',180.00,8,'Grande villa avec jardin tropical sur la plage de Beau Vallon.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');

-- Zanzibar (dest 5)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(30,5,'Zuri Zanzibar Hotel','resort',260.00,2,'Eco-resort sur la côte nord avec cours de cuisine swahilie.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(31,5,'Kilindi Zanzibar','villa',380.00,4,'Pavillons privés ouverts sur la forêt et l\'océan Indien.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(32,5,'Jambo Brothers Hostel','hostel',12.00,16,'Hostel dans la Stone Town historique, proche du marché aux épices.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Mykonos (dest 6)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(33,6,'Cavo Tagoo Hotel','hotel',520.00,2,'Hôtel design iconique avec piscine à débordement infinie face à la mer.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(34,6,'Myconian Villa Collection','villa',350.00,8,'Complex de villas sur la colline d\'Elia avec vue sur la mer Égée.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(35,6,'Mykonos Backpackers','hostel',30.00,12,'Hostel bien situé à Mykonos Town avec accès rapide aux plages.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Ibiza (dest 7)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(36,7,'Hard Rock Hotel Ibiza','hotel',280.00,2,'Hôtel festif en bord de plage avec accès aux meilleurs clubs.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(37,7,'Can Lluc Boutique Finca','airbnb',180.00,12,'Finca traditionnelle avec oliviers centenaires et piscine en pierre.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(38,7,'Ibiza Rocks Hostel','hostel',25.00,10,'Hostel au cœur de San Antonio, proche des couchers du Café del Mar.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Bora Bora (dest 8)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(39,8,'The St. Regis Bora Bora','resort',1400.00,2,'Overwater bungalows de luxe avec piscine privée et vue sur le Mont Otemanu.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(40,8,'Intercontinental Thalasso','resort',680.00,4,'Resort aux bungalows sur pilotis avec accès snorkeling direct.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(41,8,'Pension Chez Nono','airbnb',90.00,6,'Pension familiale authentique avec kayaks inclus et petit-déjeuner maison.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');

-- Île Maurice (dest 9)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(42,9,'Constance Belle Mare Plage','resort',480.00,2,'Resort 5 étoiles sur la plus belle plage de l\'île avec golf et thalasso.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(43,9,'Heritage Le Telfair','hotel',260.00,4,'Hôtel colonial dans une vaste propriété sucrière avec plage privée.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(44,9,'Chalets Bord de Mer','airbnb',70.00,8,'Petits chalets familiaux directement sur la plage dans le sud de l\'île.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');

-- Miami Beach (dest 10)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(45,10,'Faena Hotel Miami Beach','hotel',420.00,2,'Hôtel design luxueux sur Collins Avenue avec plage privée et restaurant étoilé.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(46,10,'SoBe Hostel & Bar','hostel',28.00,10,'Hostel sur Ocean Drive avec piscine et accès à la vie nocturne.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(47,10,'Collins Park Airbnb','airbnb',95.00,6,'Appartement art-déco rénové à deux pas de la mer et des musées.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');

-- Chamonix (dest 11)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(48,11,'Hameau Albert 1er','hotel',280.00,2,'Hôtel gastronomique 5 étoiles avec vue sur le massif du Mont-Blanc.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(49,11,'Chalet Les Drus','airbnb',140.00,8,'Chalet savoyard authentique avec bois de chauffage, hammam et skis aux pieds.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(50,11,'Vagabond Hostel Chamonix','hostel',25.00,12,'Hostel convivial dans le centre-ville, vue sur le Mont-Blanc.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Queenstown (dest 12)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(51,12,'Eichardt Private Hotel','hotel',480.00,2,'Maison d\'hôtes de luxe sur les rives du lac Wakatipu.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(52,12,'Lakefront Villa NZ','villa',220.00,10,'Villa familiale avec accès lac, kayaks et barbecue face aux Remarkables.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(53,12,'Nomads Queenstown','hostel',22.00,14,'Hostel 5 étoiles avec sauna, bar rooftop et organisation d\'activités d\'aventure.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Zermatt (dest 13)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(54,13,'Mont Cervin Palace','hotel',420.00,2,'Palace historique au pied du Cervin, spa de 2000m² et cuisine valaisanne.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(55,13,'Chalet Theodul','airbnb',180.00,8,'Chalet en bois de mélèze traditionnel avec vue directe sur le Cervin.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(56,13,'Zermatt Youth Hostel','hostel',28.00,10,'Hostel avec vue montagne et accès direct aux pistes.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Dolomites (dest 14)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(57,14,'Rosa Alpina Hotel & Spa','hotel',320.00,2,'Hôtel 5 étoiles dans le Val Badia avec restaurant Michelin et piscine panoramique.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(58,14,'Rifugio Tre Cime','airbnb',65.00,6,'Refuge alpin authentique avec vue unique sur les Drei Zinnen.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(59,14,'Cortina Hostel Dolomiti','hostel',20.00,12,'Hostel dans la station de Cortina d\'Ampezzo, proche des pistes.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Tromsø (dest 15)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(60,15,'Clarion Hotel The Edge','hotel',210.00,2,'Hôtel design au bord du fjord avec terrasse vitrée pour les aurores.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(61,15,'Arctic Panorama Lodge','villa',280.00,4,'Chalet avec paroi vitrée face à la montagne pour voir les aurores du lit.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(62,15,'Tromsø Camping & Hostel','hostel',18.00,12,'Hostel convivial avec minibus aurora tour chaque soir.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Aspen (dest 16)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(63,16,'The Little Nell Aspen','hotel',850.00,2,'Seul hôtel 5 étoiles avec accès direct aux remontées mécaniques d\'Aspen.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(64,16,'Snowmass Ski Chalet','airbnb',300.00,10,'Chalet avec sauna, salle de jeux et navette ski inclus.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(65,16,'Aspen Mountain Lodge','hostel',55.00,8,'Hébergement économique pour skieurs avec casiers et séchoir.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Barcelone (dest 17)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(66,17,'Hotel Arts Barcelona','hotel',380.00,2,'Tour de 44 étages sur le front de mer avec spa et vue panoramique.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(67,17,'Appartement Gracia','airbnb',80.00,6,'Appartement moderne dans le quartier bohème de Gràcia avec terrasse.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(68,17,'Casa Gracia Hostel','hostel',22.00,12,'Hostel design dans une demeure moderniste de l\'Eixample, rooftop animé.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Amsterdam (dest 18)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(69,18,'Pulitzer Amsterdam','hotel',320.00,2,'Hôtel dans 25 maisons de canal restaurées du XVIIe siècle en plein Jordaan.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(70,18,'Houseboat Canal Jordaan','airbnb',130.00,4,'Péniche habitable amarrée sur le canal Prinsengracht, expérience unique.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(71,18,'ClinkNOORD Hostel','hostel',20.00,14,'Hostel dans une ancienne usine de gaz avec restaurant et terrasse sur l\'IJ.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Singapour (dest 19)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(72,19,'Marina Bay Sands','hotel',420.00,2,'Hôtel iconique avec piscine à débordement au sommet et casino intégré.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(73,19,'Capella Singapore','resort',550.00,2,'Resort de luxe sur l\'île de Sentosa, au cœur de la jungle tropicale.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(74,19,'The Pod @ Beach Road','hostel',25.00,8,'Hostel design avec pods individuels fermés et WiFi haut débit.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Prague (dest 20)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(75,20,'Four Seasons Prague','hotel',350.00,2,'Hôtel face au Pont Charles avec vue directe sur le Château de Prague.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(76,20,'Appartement Mala Strana','airbnb',65.00,6,'Appartement historique dans le quartier de Malá Strana, poutres apparentes.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(77,20,'Sophies Hostel Prague','hostel',14.00,10,'Hostel primé dans le quartier de Zizkov avec bar local et concerts live.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Dubaï (dest 21)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(78,21,'Burj Al Arab Jumeirah','hotel',1500.00,2,'L\'hôtel le plus iconique du monde en forme de voile, service butler 24h/24.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(79,21,'Atlantis The Palm','resort',380.00,4,'Resort géant sur l\'archipel The Palm avec parc aquatique et aquarium.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(80,21,'Rove Downtown Dubai','hotel',80.00,2,'Hôtel lifestyle abordable à deux pas du Burj Khalifa et du Dubai Mall.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');

-- New York (dest 22)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(81,22,'The Plaza Hotel','hotel',650.00,2,'Palace légendaire sur Central Park, symbole du New York de Fitzgerald.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(82,22,'Loft Brooklyn Heights','airbnb',120.00,6,'Loft industriel chic avec vue sur Manhattan depuis Brooklyn.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(83,22,'HI NYC Hostel','hostel',35.00,12,'Hostel bien situé à Upper West Side, proche du Museum of Natural History.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Bangkok (dest 23)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(84,23,'Mandarin Oriental Bangkok','hotel',380.00,2,'Palace légendaire sur le fleuve Chao Phraya, fondé en 1876.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(85,23,'Airbnb Sukhumvit','airbnb',45.00,4,'Appartement moderne dans le quartier branché de Sukhumvit.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(86,23,'Lub d Bangkok Silom','hostel',12.00,14,'Hostel design avec piscine dans le quartier de Silom.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Marrakech (dest 24)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(87,24,'La Mamounia','hotel',600.00,2,'Palace mythique dans un jardin d\'oliviers centenaires, Art Déco légendaire.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(88,24,'Riad Dar Si Said','airbnb',110.00,8,'Riad traditionnel avec patio, fontaine, hammam privé et petit-déjeuner marocain.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(89,24,'Equity Point Hostel','hostel',10.00,16,'Hostel dans la médina avec rooftop, cours de cuisine et soirées berbères.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Rome (dest 25)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(90,25,'Hotel de Russie','hotel',550.00,2,'Hôtel emblématique entre la Piazza del Popolo et le Pincio, jardin secret.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(91,25,'Trastevere Apartment','airbnb',75.00,6,'Appartement authentique dans le quartier de Trastevere avec terrasse.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(92,25,'The Yellow Hostel','hostel',18.00,10,'Hostel festif proche du Termini avec bar et restaurant populaires.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Istanbul (dest 26)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(93,26,'Four Seasons Sultanahmet','hotel',450.00,2,'Hôtel dans une ancienne prison ottomane entre Sainte-Sophie et la Marmara.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(94,26,'Appartement Balat','airbnb',50.00,6,'Maison grecque rénovée dans le quartier coloré de Balat, près du Bosphore.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(95,26,'Big Apple Hostel Istanbul','hostel',12.00,14,'Hostel bien situé à Sultanahmet avec terrasse vue sur la Mosquée Bleue.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Kyoto (dest 27)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(96,27,'Tawaraya Ryokan','hotel',600.00,2,'Le ryokan le plus célèbre du Japon, fondé en 1712, expérience absolument unique.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(97,27,'Machiya Townhouse Gion','airbnb',120.00,6,'Maison de ville traditionnelle entièrement rénovée dans le quartier de Gion.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(98,27,'Kyoto Hostel Wabisabi','hostel',22.00,12,'Hostel dans un kyo-machiya restauré, cours de cérémonie du thé inclus.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Le Caire (dest 28)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(99,28,'Marriott Mena House','hotel',220.00,2,'Hôtel historique à Gizeh avec vue directe sur la Grande Pyramide depuis la piscine.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(100,28,'Appartement Zamalek','airbnb',40.00,6,'Appartement dans l\'île chic de Zamalek sur le Nil, quartier galeries et cafés.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(101,28,'Cairo Downtown Hostel','hostel',8.00,16,'Hostel dans le centre historique, toit terrasse avec vue sur les minarets.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Reykjavik (dest 29)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(102,29,'Ion Adventure Hotel','hotel',320.00,2,'Hôtel design au bord d\'un lac volcanique avec salle aurora viewing.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(103,29,'Cabin on the Lake','airbnb',180.00,6,'Cabane sur la berge du lac Thingvallavatn, à 40 min de Reykjavik.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(104,29,'Loft Hostel Reykjavik','hostel',28.00,12,'Hostel animé avec bar panoramique et excursions aurores quotidiennes.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Nairobi (dest 30)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(105,30,'Giraffe Manor','hotel',650.00,2,'Manoir unique où les girafes Rothschild passent leur tête au petit-déjeuner.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(106,30,'Angama Mara Tented Camp','resort',1200.00,4,'Camp de luxe en tentes sur le rebord du Rift, vue directe sur la Masaï Mara.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(107,30,'Wildebeest Eco Camp','hostel',15.00,16,'Éco-hostel dans un jardin tropical à Nairobi, organisation de safaris budget.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Costa Rica (dest 31)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(108,31,'Nayara Springs Resort','resort',480.00,2,'Villas avec piscine privée en forêt tropicale face au volcan Arenal.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(109,31,'Casa Corcovado Lodge','hotel',150.00,4,'Lodge écologique sur la péninsule d\'Osa, à la lisière du parc Corcovado.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(110,31,'Selina San Jose','hostel',20.00,12,'Hostel-coliving branché avec piscine, co-working et excursions nature.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- El Calafate (dest 32)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(111,32,'Explora El Calafate','resort',980.00,4,'Lodge d\'exploration avec guides experts et treks guidés vers Fitz Roy.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(112,32,'Hosteria Helsingfors','hotel',230.00,2,'Ferme-hôtel sur les rives du lac Viedma avec vue sur le Perito Moreno.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(113,32,'America del Sur Hostel','hostel',14.00,16,'Hostel chaleureux à El Calafate avec salle à manger chaleureuse et bibliothèque.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- HÉBERGEMENTS (IDs 114-188)
-- ============================================================

-- Londres (dest 33)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(114,33,'The Savoy','hotel',650.00,2,'Palace légendaire sur la Tamise, Art Déco et gastronomie Gordon Ramsay.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(115,33,'Notting Hill Garden Flat','airbnb',95.00,4,'Appartement Victorian dans le quartier de Portobello Road et ses marchés.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(116,33,'Generator London','hostel',22.00,12,'Hostel design à Kings Cross, à deux pas de la gare Saint-Pancras.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Berlin (dest 34)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(117,34,'Hotel Adlon Kempinski','hotel',480.00,2,'Le palace historique de Berlin face à la Porte de Brandebourg.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(118,34,'Prenzlauer Berg Loft','airbnb',75.00,6,'Loft industriel dans le quartier branché de Prenzlauer Berg.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(119,34,'Circus Hostel Berlin','hostel',18.00,12,'Hostel primé près de Rosenthaler Platz, parfait pour explorer le Mitte.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Vienne (dest 35)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(120,35,'Hotel Sacher Wien','hotel',550.00,2,'L\'hôtel mythique de la Sachertorte, en face de l\'Opéra impérial.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(121,35,'Altbau Wohnung Innere Stadt','airbnb',90.00,4,'Appartement dans un immeuble Belle Époque du 1er arrondissement.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(122,41,'Wombat\'s City Hostel','hostel',20.00,10,'Hostel réputé dans le quartier de la Mariahilfer Strasse.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Madrid (dest 36)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(123,36,'Hotel Ritz Madrid','hotel',520.00,2,'Palace centenaire face au Prado avec jardin d\'hiver et spa de luxe.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(124,36,'Appartement Malasaña','airbnb',65.00,6,'Appartement lumineux dans le quartier bohème de Malasaña.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(125,42,'Cat\'s Hostel Madrid','hostel',16.00,12,'Hostel dans un palais du XVIIIe siècle avec cour andalouse et piscine.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Bruxelles (dest 37)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(126,37,'Hotel Amigo','hotel',380.00,2,'Hôtel 5 étoiles dans le cœur historique, à deux pas de la Grand-Place.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(127,37,'Ixelles Art Deco Apartment','airbnb',70.00,4,'Appartement Art Déco dans le quartier animé d\'Ixelles.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(128,37,'2GO4 Quality Hostel','hostel',18.00,12,'Hostel réputé dans le Pentagone historique de Bruxelles.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Copenhague (dest 38)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(129,44,'Hotel d\'Angleterre','hotel',520.00,2,'Grand hôtel historique face au théâtre royal sur Kongens Nytorv.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(130,38,'Nørrebro Design Apartment','airbnb',90.00,4,'Appartement scandinave minimaliste dans le quartier multiculturel de Nørrebro.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(131,38,'Steel House Copenhagen','hostel',28.00,14,'Hostel design avec piscine intérieure et rooftop dans le centre-ville.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Stockholm (dest 39)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(132,39,'Grand Hotel Stockholm','hotel',580.00,2,'Palace historique en face du Palais Royal sur les rives du lac Mälaren.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(133,39,'Södermalm Studio','airbnb',85.00,3,'Studio moderne dans le quartier branché de Södermalm.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(134,39,'City Backpackers Inn','hostel',22.00,10,'Hostel convivial dans Gamla Stan (la vieille ville), idéal pour explorer à pied.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Budapest (dest 40)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(135,40,'Four Seasons Gresham Palace','hotel',480.00,2,'Art Nouveau somptueux au bout du Pont des Chaînes sur le Danube.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(136,40,'Jewish Quarter Flat','airbnb',55.00,4,'Appartement dans le quartier juif historique, proche des ruin bars.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(137,40,'Maverick City Lodge','hostel',12.00,14,'Hostel bien situé à Pest, organisation de soirées ruin bars chaque soir.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Athènes (dest 41)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(138,41,'Hotel Grande Bretagne','hotel',450.00,2,'Palace historique face à la place Syntagma avec vue sur le Parthénon.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(139,41,'Monastiraki Rooftop Flat','airbnb',65.00,4,'Appartement avec terrasse et vue directe sur l\'Acropole depuis Monastiraki.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(140,41,'Athens Backpackers','hostel',16.00,12,'Hostel avec rooftop mythique vue Acropole dans le quartier de Makrigianni.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Florence (dest 42)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(141,42,'Portrait Firenze','hotel',580.00,2,'Boutique hôtel de luxe sur le Ponte Vecchio avec vue sur l\'Arno.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(142,42,'Oltrarno Farmhouse','airbnb',80.00,6,'Appartement toscan dans le quartier authentique d\'Oltrarno.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(143,42,'Plus Florence Hostel','hostel',20.00,10,'Hostel avec piscine et restaurant dans une villa à 5 min de la gare.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Porto (dest 43)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(144,43,'The Yeatman Hotel','hotel',350.00,2,'Hôtel oenotouristique à Vila Nova de Gaia avec cave Graham\'s et piscine vue Douro.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(145,43,'Ribeira Townhouse','airbnb',75.00,6,'Maison de ville à façade d\'azulejos dans le quartier historique de Ribeira.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(146,43,'Gallery Hostel Porto','hostel',18.00,10,'Hostel design récompensé dans le quartier de Bonfim, galerie d\'art incluse.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Sintra (dest 44)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(147,44,'Tivoli Palácio de Seteais','hotel',280.00,2,'Palace du XVIIIe siècle dans un jardin avec vue sur les collines de Sintra.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(148,44,'Casa da Ramila','airbnb',90.00,8,'Quinta traditionnelle dans la forêt de Sintra avec jardin et piscine.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(149,44,'Sintra Hostel','hostel',15.00,10,'Hostel convivial dans le village, excursions palais incluses.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Séoul (dest 45)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(150,45,'The Shilla Seoul','hotel',380.00,2,'Palace coréen sur colline avec spa et vue panoramique sur la ville.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(151,45,'Hanok Guesthouse Bukchon','airbnb',85.00,4,'Maison traditionnelle coréenne restaurée dans le village de Bukchon.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(152,45,'Korea Guesthouse','hostel',18.00,10,'Hostel cosy à Hongdae avec accès libre aux cours de K-pop.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Hong Kong (dest 46)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(153,46,'The Peninsula Hong Kong','hotel',650.00,2,'Le palace le plus légendaire d\'Asie, face à la skyline de Hong Kong Island.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(154,46,'Sheung Wan Artist Flat','airbnb',95.00,4,'Appartement design dans le quartier des galeries d\'art de Sheung Wan.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(155,46,'Yesinn Hostel HK','hostel',28.00,8,'Hostel boutique à Mong Kok au cœur du Kowloon historique.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Kuala Lumpur (dest 47)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(156,47,'Mandarin Oriental KL','hotel',280.00,2,'Hôtel de luxe aux pieds des tours Petronas avec spa et piscine à débordement.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(157,47,'KLCC Studio Apartment','airbnb',45.00,4,'Studio moderne avec vue sur les tours Petronas illuminées la nuit.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(158,47,'Bed & Dreams Hostel KL','hostel',10.00,12,'Hostel central dans Chinatown, à deux pas de Petaling Street.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Hanoï (dest 48)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(159,48,'Sofitel Legend Metropole','hotel',320.00,2,'Palace colonial français de 1901, symbole de l\'élégance indochinoise.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(160,48,'Old Quarter Tube House','airbnb',35.00,4,'Maison tube typique dans la vieille ville aux 36 guildes.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(161,48,'Hanoi Backpackers Hostel','hostel',8.00,14,'Hostel légendaire du backpacker trail, organisation excursions Ha Long.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Mumbai (dest 49)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(162,49,'Taj Mahal Palace Mumbai','hotel',480.00,2,'Palace iconique face au Gateway of India, symbole de Mumbai depuis 1903.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(163,49,'Bandra Sea-view Flat','airbnb',55.00,4,'Appartement dans le quartier branché de Bandra avec vue sur la mer d\'Arabie.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(164,49,'Zostel Mumbai','hostel',12.00,14,'Hostel design en terrasse dans le quartier bohème de Colaba.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Montréal (dest 50)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(165,50,'Le Mount Stephen','hotel',380.00,2,'Hotel de luxe dans une banque néoclassique du XIXe siècle au cœur du Golden Square Mile.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(166,50,'Plateau Mont-Royal Loft','airbnb',80.00,6,'Loft dans le quartier francophone le plus vivant de Montréal.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(167,50,'HI Montréal Hostel','hostel',25.00,12,'Hostel officiel bien situé dans le centre-ville, accès métro immédiat.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Los Angeles (dest 51)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(168,51,'Chateau Marmont','hotel',550.00,2,'Hôtel légendaire perché sur Sunset Boulevard, repaire des stars depuis 1929.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(169,51,'Venice Beach Bungalow','airbnb',120.00,6,'Bungalow à 2 pas du boardwalk de Venice Beach, vélos inclus.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(170,51,'HI Los Angeles Hostel','hostel',32.00,10,'Hostel officiel à Santa Monica, à 5 min de la plage et du pier.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Sydney (dest 52)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(171,52,'Park Hyatt Sydney','hotel',580.00,2,'Hôtel de luxe avec vue directe sur l\'Opéra et le Harbour Bridge depuis la piscine.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(172,52,'Bondi Beach House','airbnb',130.00,6,'Maison de plage à deux rues de Bondi Beach avec barbecue.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(173,52,'Sydney Harbour YHA','hostel',35.00,12,'Hostel primé dans The Rocks avec vue imprenable sur le Harbour Bridge.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Buenos Aires (dest 53)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(174,53,'Alvear Palace Hotel','hotel',320.00,2,'Palace Belle Époque de Recoleta, le plus luxueux d\'Amérique du Sud.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(175,53,'Palermo Soho Loft','airbnb',50.00,6,'Loft design dans le quartier tendance de Palermo Soho.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(176,53,'Milhouse Hostel Avenue','hostel',12.00,16,'Hostel légendaire du backpacker trail en Amérique du Sud, toit terrasse.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Rio de Janeiro (dest 54)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(177,54,'Belmond Copacabana Palace','hotel',650.00,2,'Palace mythique sur le front de mer de Copacabana, piscine à débordement.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(178,54,'Santa Teresa Colonial House','airbnb',70.00,6,'Villa coloniale dans le quartier bohème de Santa Teresa avec vue panoramique.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(179,54,'El Misti Hostel Ipanema','hostel',15.00,14,'Hostel sur la plage d\'Ipanema, ambiance festive et soirées cariocas.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Punta Cana (dest 55)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(180,55,'Hard Rock Hotel Punta Cana','resort',280.00,4,'All-inclusive musicalement thématisé avec 13 piscines et plage privée.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(181,55,'Barcelo Bavaro Palace','resort',180.00,4,'Resort 5 étoiles tout compris sur la plus belle plage de la Caraïbe.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(182,55,'Dreaming Punta Cana Hostel','hostel',18.00,10,'Hostel convivial en retrait de la plage avec excursions Isla Saona.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Koh Samui (dest 56)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(183,56,'Four Seasons Koh Samui','resort',680.00,2,'Villas sur falaise avec piscine à débordement sur la mer de Chine méridionale.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(184,56,'Chaweng Beach Villa','villa',120.00,8,'Villa privée à Chaweng Beach, la plage la plus animée de Koh Samui.','https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(185,56,'Samui Backpacker Hostel','hostel',12.00,14,'Hostel sur Lamai Beach avec scooters à louer et soirées locales.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Cap-Vert (dest 57)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(186,57,'Riu Palace Boavista','resort',220.00,4,'Resort sur la plage Santa Monica, l\'une des plus belles plages d\'Afrique.','https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(187,57,'Casa Familiar Sal Rei','airbnb',45.00,6,'Maison créole authentique dans la capitale de Boa Vista.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(188,57,'Tortuga Beach Hostel','hostel',14.00,12,'Hostel sur la plage des tortues, organisation de kitesurf et snorkeling.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- La Réunion (dest 58)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(189,58,'Le Saint-Alexis Hôtel & Spa','hotel',220.00,2,'Hôtel de charme avec piscine à débordement et vue sur le lagon de l\'Ermitage.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(190,58,'Gîte Cilaos en Cirque','airbnb',55.00,6,'Gîte de montagne dans le cirque volcanique de Cilaos, randonnées à pied de porte.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(191,58,'Auberge du Volcan','hostel',18.00,10,'Auberge de jeunesse au plus près du Piton de la Fournaise, guides locaux.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

-- Cape Town (dest 59)
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(192,59,'The Silo Hotel','hotel',750.00,2,'Hôtel dans un ancien silo à grains avec vue sur Table Mountain et le port.','https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(193,59,'Bo-Kaap Heritage House','airbnb',85.00,6,'Maison malaise colorée dans le quartier historique de Bo-Kaap.','https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80');
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(194,59,'Once in Cape Town Hostel','hostel',16.00,12,'Hostel design dans De Waterkant, organisation de safaris et excursions Cap.','https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80');

INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(196,1,'Ocean Grand Hôtel','hotel',84.00,2,'Hôtel chaleureux à quelques minutes des plages des Maldives, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(197,1,'Casa Paradis Maldives','villa',114.00,6,'Villa privée avec piscine et terrasse aux Maldives, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(198,1,'Loft Laguna Maldives','airbnb',144.00,4,'Appartement lumineux aux Maldives, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(199,1,'Maldives Beach Resort','resort',174.00,2,'Resort tout confort en bord de mer aux Maldives : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(200,1,'Maldives Backpackers','hostel',204.00,12,'Auberge de jeunesse conviviale aux Maldives, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(201,2,'Hôtel Sunset Phuket','hotel',88.00,2,'Hôtel chaleureux à quelques minutes des plages de Phuket, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(202,2,'Villa Phuket','villa',118.00,6,'Villa privée avec piscine et terrasse à Phuket, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(203,2,'Studio Azur','airbnb',148.00,4,'Appartement lumineux à Phuket, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(204,2,'Ocean Resort Phuket','resort',178.00,2,'Resort tout confort en bord de mer à Phuket : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(205,2,'Auberge Phuket','hostel',208.00,12,'Auberge de jeunesse conviviale à Phuket, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(206,3,'Hôtel Cancún Centre','hotel',92.00,2,'Hôtel chaleureux à quelques minutes des plages de Cancún, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(207,3,'Villa Palm','villa',122.00,6,'Villa privée avec piscine et terrasse à Cancún, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(208,3,'Appartement Cancún','airbnb',152.00,4,'Appartement lumineux à Cancún, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(209,3,'Sunset Spa Resort','resort',182.00,2,'Resort tout confort en bord de mer à Cancún : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(210,3,'Coral Hostel Cancún','hostel',212.00,12,'Auberge de jeunesse conviviale à Cancún, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(211,4,'Azur Grand Hôtel','hotel',96.00,2,'Hôtel chaleureux à quelques minutes des plages des Seychelles, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(212,4,'Casa Ocean Seychelles','villa',126.00,6,'Villa privée avec piscine et terrasse aux Seychelles, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(213,4,'Loft Paradis Seychelles','airbnb',156.00,4,'Appartement lumineux aux Seychelles, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(214,4,'Seychelles Beach Resort','resort',186.00,2,'Resort tout confort en bord de mer aux Seychelles : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(215,4,'Seychelles Backpackers','hostel',216.00,12,'Auberge de jeunesse conviviale aux Seychelles, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(216,5,'Hôtel Lagon Zanzibar','hotel',100.00,2,'Hôtel chaleureux à quelques minutes des plages de Zanzibar, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(217,5,'Villa Zanzibar','villa',130.00,6,'Villa privée avec piscine et terrasse à Zanzibar, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(218,5,'Studio Coral','airbnb',160.00,4,'Appartement lumineux à Zanzibar, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(219,5,'Azur Resort Zanzibar','resort',190.00,2,'Resort tout confort en bord de mer à Zanzibar : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(220,5,'Auberge Zanzibar','hostel',220.00,12,'Auberge de jeunesse conviviale à Zanzibar, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(221,6,'Hôtel Mykonos Centre','hotel',104.00,2,'Hôtel chaleureux à quelques minutes des plages de Mykonos, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(222,6,'Villa Laguna','villa',134.00,6,'Villa privée avec piscine et terrasse à Mykonos, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(223,6,'Appartement Mykonos','airbnb',164.00,4,'Appartement lumineux à Mykonos, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(224,6,'Lagon Spa Resort','resort',194.00,2,'Resort tout confort en bord de mer à Mykonos : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(225,6,'Sunset Hostel Mykonos','hostel',224.00,12,'Auberge de jeunesse conviviale à Mykonos, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(226,7,'Coral Grand Hôtel','hotel',108.00,2,'Hôtel chaleureux à quelques minutes des plages de Ibiza, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(227,7,'Casa Azur Ibiza','villa',138.00,6,'Villa privée avec piscine et terrasse à Ibiza, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(228,7,'Loft Ocean Ibiza','airbnb',168.00,4,'Appartement lumineux à Ibiza, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(229,7,'Ibiza Beach Resort','resort',198.00,2,'Resort tout confort en bord de mer à Ibiza : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(230,7,'Ibiza Backpackers','hostel',228.00,12,'Auberge de jeunesse conviviale à Ibiza, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(231,8,'Hôtel Palm Bora Bora','hotel',112.00,2,'Hôtel chaleureux à quelques minutes des plages de Bora Bora, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(232,8,'Villa Bora Bora','villa',142.00,6,'Villa privée avec piscine et terrasse à Bora Bora, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(233,8,'Studio Sunset','airbnb',172.00,4,'Appartement lumineux à Bora Bora, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(234,8,'Coral Resort Bora Bora','resort',202.00,2,'Resort tout confort en bord de mer à Bora Bora : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(235,8,'Auberge Bora Bora','hostel',232.00,12,'Auberge de jeunesse conviviale à Bora Bora, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(236,9,'Hôtel Île Maurice Centre','hotel',116.00,2,'Hôtel chaleureux à quelques minutes des plages de l\'île Maurice, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(237,9,'Villa Paradis','villa',146.00,6,'Villa privée avec piscine et terrasse à l\'île Maurice, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(238,9,'Appartement Île Maurice','airbnb',176.00,4,'Appartement lumineux à l\'île Maurice, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(239,9,'Palm Spa Resort','resort',206.00,2,'Resort tout confort en bord de mer à l\'île Maurice : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(240,9,'Lagon Hostel Île Maurice','hostel',236.00,12,'Auberge de jeunesse conviviale à l\'île Maurice, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(241,10,'Sunset Grand Hôtel','hotel',120.00,2,'Hôtel chaleureux à quelques minutes des plages de Miami Beach, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(242,10,'Casa Coral Miami Beach','villa',150.00,6,'Villa privée avec piscine et terrasse à Miami Beach, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(243,10,'Loft Azur Miami Beach','airbnb',180.00,4,'Appartement lumineux à Miami Beach, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(244,10,'Miami Beach Resort & Spa','resort',210.00,2,'Resort tout confort en bord de mer à Miami Beach : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(245,10,'Miami Beach Backpackers','hostel',240.00,12,'Auberge de jeunesse conviviale à Miami Beach, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(246,11,'Hôtel Summit Chamonix','hotel',124.00,2,'Hôtel confortable au cœur des montagnes de Chamonix, idéal après une journée de randonnée ou de ski.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(247,11,'Villa Chamonix','villa',154.00,6,'Villa spacieuse avec vue sur les sommets de Chamonix, cheminée et grand séjour convivial.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(248,11,'Studio Panorama','airbnb',184.00,4,'Appartement cosy à Chamonix, parfait pour un séjour au grand air, skis aux pieds.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(249,11,'Cime Lodge Chamonix','resort',214.00,2,'Lodge de montagne à Chamonix avec spa et sauna, accès direct aux pistes et aux sentiers.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(250,11,'Auberge Chamonix','hostel',244.00,12,'Auberge chaleureuse à Chamonix, dortoirs confortables et espace commun avec vue sur les montagnes.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(251,12,'Hôtel Queenstown Centre','hotel',128.00,2,'Hôtel confortable au cœur des montagnes de Queenstown, idéal après une journée de randonnée ou de ski.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(252,12,'Villa Alpin','villa',158.00,6,'Villa spacieuse avec vue sur les sommets de Queenstown, cheminée et grand séjour convivial.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(253,12,'Appartement Queenstown','airbnb',188.00,4,'Appartement cosy à Queenstown, parfait pour un séjour au grand air, skis aux pieds.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(254,12,'Edelweiss Spa Lodge','resort',218.00,2,'Lodge de montagne à Queenstown avec spa et sauna, accès direct aux pistes et aux sentiers.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(255,12,'Panorama Hostel Queenstown','hostel',248.00,12,'Auberge chaleureuse à Queenstown, dortoirs confortables et espace commun avec vue sur les montagnes.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(256,13,'Cime Grand Hôtel','hotel',132.00,2,'Hôtel confortable au cœur des montagnes de Zermatt, idéal après une journée de randonnée ou de ski.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(257,13,'Casa Glacier Zermatt','villa',162.00,6,'Villa spacieuse avec vue sur les sommets de Zermatt, cheminée et grand séjour convivial.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(258,13,'Loft Sommet Zermatt','airbnb',192.00,4,'Appartement cosy à Zermatt, parfait pour un séjour au grand air, skis aux pieds.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(259,13,'Zermatt Mountain Resort','resort',222.00,2,'Lodge de montagne à Zermatt avec spa et sauna, accès direct aux pistes et aux sentiers.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(260,13,'Zermatt Backpackers','hostel',252.00,12,'Auberge chaleureuse à Zermatt, dortoirs confortables et espace commun avec vue sur les montagnes.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(261,14,'Hôtel Edelweiss Dolomites','hotel',136.00,2,'Hôtel confortable au cœur des montagnes des Dolomites, idéal après une journée de randonnée ou de ski.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(262,14,'Villa Dolomites','villa',166.00,6,'Villa spacieuse avec vue sur les sommets des Dolomites, cheminée et grand séjour convivial.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(263,14,'Studio Cime','airbnb',196.00,4,'Appartement cosy dans les Dolomites, parfait pour un séjour au grand air, skis aux pieds.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(264,14,'Glacier Lodge Dolomites','resort',226.00,2,'Lodge de montagne dans les Dolomites avec spa et sauna, accès direct aux pistes et aux sentiers.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(265,14,'Auberge Dolomites','hostel',256.00,12,'Auberge chaleureuse dans les Dolomites, dortoirs confortables et espace commun avec vue sur les montagnes.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(266,15,'Hôtel Tromsø Centre','hotel',140.00,2,'Hôtel confortable au cœur des montagnes de Tromsø, idéal après une journée de randonnée ou de ski.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(267,15,'Villa Summit','villa',170.00,6,'Villa spacieuse avec vue sur les sommets de Tromsø, cheminée et grand séjour convivial.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(268,15,'Appartement Tromsø','airbnb',200.00,4,'Appartement cosy à Tromsø, parfait pour un séjour au grand air, skis aux pieds.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(269,15,'Panorama Spa Lodge','resort',230.00,2,'Lodge de montagne à Tromsø avec spa et sauna, accès direct aux pistes et aux sentiers.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(270,15,'Cime Hostel Tromsø','hostel',260.00,12,'Auberge chaleureuse à Tromsø, dortoirs confortables et espace commun avec vue sur les montagnes.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(271,16,'Glacier Grand Hôtel','hotel',144.00,2,'Hôtel confortable au cœur des montagnes de Aspen, idéal après une journée de randonnée ou de ski.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(272,16,'Casa Sommet Aspen','villa',174.00,6,'Villa spacieuse avec vue sur les sommets de Aspen, cheminée et grand séjour convivial.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(273,16,'Loft Alpin Aspen','airbnb',204.00,4,'Appartement cosy à Aspen, parfait pour un séjour au grand air, skis aux pieds.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(274,16,'Aspen Mountain Resort','resort',234.00,2,'Lodge de montagne à Aspen avec spa et sauna, accès direct aux pistes et aux sentiers.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(275,16,'Aspen Backpackers','hostel',264.00,12,'Auberge chaleureuse à Aspen, dortoirs confortables et espace commun avec vue sur les montagnes.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(276,17,'Hôtel Central Barcelone','hotel',148.00,2,'Hôtel moderne en plein centre de Barcelone, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(277,17,'Villa Barcelone','villa',178.00,6,'Villa élégante dans un quartier résidentiel calme de Barcelone, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(278,17,'Studio Plaza','airbnb',208.00,4,'Appartement bien situé en centre-ville de Barcelone, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(279,17,'Métropole Resort Barcelone','resort',238.00,2,'Resort urbain à Barcelone avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(280,17,'Auberge Barcelone','hostel',268.00,12,'Auberge animée en plein cœur de Barcelone, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(281,18,'Hôtel Amsterdam Centre','hotel',152.00,2,'Hôtel moderne en plein centre de Amsterdam, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(282,18,'Villa Central','villa',182.00,6,'Villa élégante dans un quartier résidentiel calme de Amsterdam, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(283,18,'Appartement Amsterdam','airbnb',212.00,4,'Appartement bien situé en centre-ville de Amsterdam, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(284,18,'Plaza Spa Resort','resort',242.00,2,'Resort urbain à Amsterdam avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(285,18,'Métropole Hostel Amsterdam','hostel',272.00,12,'Auberge animée en plein cœur de Amsterdam, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(286,19,'Downtown Grand Hôtel','hotel',156.00,2,'Hôtel moderne en plein centre de Singapour, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(287,19,'Casa Rivoli Singapour','villa',186.00,6,'Villa élégante dans un quartier résidentiel calme de Singapour, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(288,19,'Loft Central Singapour','airbnb',216.00,4,'Appartement bien situé en centre-ville de Singapour, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(289,19,'Singapour Resort & Spa','resort',246.00,2,'Resort urbain à Singapour avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(290,19,'Singapour Backpackers','hostel',276.00,12,'Auberge animée en plein cœur de Singapour, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(291,20,'Hôtel Métropole Prague','hotel',160.00,2,'Hôtel moderne en plein centre de Prague, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(292,20,'Villa Prague','villa',190.00,6,'Villa élégante dans un quartier résidentiel calme de Prague, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(293,20,'Studio Rivoli','airbnb',220.00,4,'Appartement bien situé en centre-ville de Prague, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(294,20,'Central Resort Prague','resort',250.00,2,'Resort urbain à Prague avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(295,20,'Auberge Prague','hostel',280.00,12,'Auberge animée en plein cœur de Prague, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(296,21,'Hôtel Dubaï Centre','hotel',164.00,2,'Hôtel moderne en plein centre de Dubaï, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(297,21,'Villa Métropole','villa',194.00,6,'Villa élégante dans un quartier résidentiel calme de Dubaï, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(298,21,'Appartement Dubaï','airbnb',224.00,4,'Appartement bien situé en centre-ville de Dubaï, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(299,21,'Rivoli Spa Resort','resort',254.00,2,'Resort urbain à Dubaï avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(300,21,'Central Hostel Dubaï','hostel',284.00,12,'Auberge animée en plein cœur de Dubaï, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(301,22,'Urban Grand Hôtel','hotel',168.00,2,'Hôtel moderne en plein centre de New York, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(302,22,'Casa Plaza New York','villa',198.00,6,'Villa élégante dans un quartier résidentiel calme de New York, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(303,22,'Loft Métropole New York','airbnb',228.00,4,'Appartement bien situé en centre-ville de New York, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(304,22,'New York Resort & Spa','resort',258.00,2,'Resort urbain à New York avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(305,22,'New York Backpackers','hostel',288.00,12,'Auberge animée en plein cœur de New York, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(306,23,'Hôtel Central Bangkok','hotel',172.00,2,'Hôtel moderne en plein centre de Bangkok, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(307,23,'Villa Bangkok','villa',202.00,6,'Villa élégante dans un quartier résidentiel calme de Bangkok, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(308,23,'Studio Plaza','airbnb',232.00,4,'Appartement bien situé en centre-ville de Bangkok, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(309,23,'Métropole Resort Bangkok','resort',262.00,2,'Resort urbain à Bangkok avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(310,23,'Auberge Bangkok','hostel',292.00,12,'Auberge animée en plein cœur de Bangkok, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(311,24,'Hôtel Marrakech Centre','hotel',176.00,2,'Hôtel de charme proche des sites historiques de Marrakech, alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(312,24,'Villa Héritage','villa',206.00,6,'Villa de caractère à Marrakech, décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(313,24,'Appartement Marrakech','airbnb',236.00,4,'Appartement de charme dans la vieille ville de Marrakech, à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(314,24,'Royal Spa Resort','resort',266.00,2,'Resort raffiné proche des trésors culturels de Marrakech, entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(315,24,'Médina Hostel Marrakech','hostel',296.00,12,'Auberge accueillante près du centre historique de Marrakech, idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(316,25,'Antico Grand Hôtel','hotel',180.00,2,'Hôtel de charme proche des sites historiques de Rome, alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(317,25,'Casa Palacio Rome','villa',210.00,6,'Villa de caractère à Rome, décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(318,25,'Loft Héritage Rome','airbnb',240.00,4,'Appartement de charme dans la vieille ville de Rome, à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(319,25,'Rome Resort & Spa','resort',270.00,2,'Resort raffiné proche des trésors culturels de Rome, entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(320,25,'Rome Backpackers','hostel',300.00,12,'Auberge accueillante près du centre historique de Rome, idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(321,26,'Hôtel Médina Istanbul','hotel',184.00,2,'Hôtel de charme proche des sites historiques de Istanbul, alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(322,26,'Villa Istanbul','villa',214.00,6,'Villa de caractère à Istanbul, décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(323,26,'Studio Palacio','airbnb',244.00,4,'Appartement de charme dans la vieille ville de Istanbul, à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(324,26,'Héritage Resort Istanbul','resort',274.00,2,'Resort raffiné proche des trésors culturels de Istanbul, entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(325,26,'Auberge Istanbul','hostel',304.00,12,'Auberge accueillante près du centre historique de Istanbul, idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(326,27,'Hôtel Kyoto Centre','hotel',188.00,2,'Hôtel de charme proche des sites historiques de Kyoto, alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(327,27,'Villa Médina','villa',218.00,6,'Villa de caractère à Kyoto, décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(328,27,'Appartement Kyoto','airbnb',248.00,4,'Appartement de charme dans la vieille ville de Kyoto, à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(329,27,'Palacio Spa Resort','resort',278.00,2,'Resort raffiné proche des trésors culturels de Kyoto, entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(330,27,'Héritage Hostel Kyoto','hostel',308.00,12,'Auberge accueillante près du centre historique de Kyoto, idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(331,28,'Patrimoine Grand Hôtel','hotel',192.00,2,'Hôtel de charme proche des sites historiques du Caire, alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(332,28,'Casa Royal Le Caire','villa',222.00,6,'Villa de caractère au Caire, décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(333,28,'Loft Médina Le Caire','airbnb',252.00,4,'Appartement de charme dans la vieille ville du Caire, à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(334,28,'Le Caire Resort & Spa','resort',282.00,2,'Resort raffiné proche des trésors culturels du Caire, entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(335,28,'Le Caire Backpackers','hostel',312.00,12,'Auberge accueillante près du centre historique du Caire, idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(336,29,'Hôtel Explorer Reykjavik','hotel',196.00,2,'Hôtel pratique pour rayonner autour de Reykjavik et partir à l\'aventure dès le matin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(337,29,'Villa Reykjavik','villa',226.00,6,'Villa au cœur de la nature, près de Reykjavik, point de départ idéal pour vos excursions.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(338,29,'Studio Nomad','airbnb',256.00,4,'Appartement fonctionnel à Reykjavik, base confortable entre deux aventures.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(339,29,'Trek Resort Reykjavik','resort',286.00,2,'Resort nature à Reykjavik, confort moderne au plus près des grands espaces.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(340,29,'Auberge Reykjavik','hostel',316.00,12,'Auberge backpacker à Reykjavik, ambiance routarde et bons conseils pour explorer les environs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(341,30,'Hôtel Nairobi Centre','hotel',200.00,2,'Hôtel pratique pour rayonner autour de Nairobi et partir à l\'aventure dès le matin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(342,30,'Villa Explorer','villa',230.00,6,'Villa au cœur de la nature, près de Nairobi, point de départ idéal pour vos excursions.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(343,30,'Appartement Nairobi','airbnb',260.00,4,'Appartement fonctionnel à Nairobi, base confortable entre deux aventures.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(344,30,'Nomad Spa Resort','resort',290.00,2,'Resort nature à Nairobi, confort moderne au plus près des grands espaces.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(345,30,'Trek Hostel Nairobi','hostel',320.00,12,'Auberge backpacker à Nairobi, ambiance routarde et bons conseils pour explorer les environs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(346,31,'Wild Grand Hôtel','hotel',204.00,2,'Hôtel pratique pour rayonner autour de San José et partir à l\'aventure dès le matin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(347,31,'Casa Horizon San José','villa',234.00,6,'Villa au cœur de la nature, près de San José, point de départ idéal pour vos excursions.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(348,31,'Loft Explorer San José','airbnb',264.00,4,'Appartement fonctionnel à San José, base confortable entre deux aventures.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(349,31,'San José Resort & Spa','resort',294.00,2,'Resort nature à San José, confort moderne au plus près des grands espaces.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(350,31,'San José Backpackers','hostel',324.00,12,'Auberge backpacker à San José, ambiance routarde et bons conseils pour explorer les environs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(351,32,'Hôtel Trek El Calafate','hotel',208.00,2,'Hôtel pratique pour rayonner autour de El Calafate et partir à l\'aventure dès le matin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(352,32,'Villa El Calafate','villa',238.00,6,'Villa au cœur de la nature, près de El Calafate, point de départ idéal pour vos excursions.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(353,32,'Studio Horizon','airbnb',268.00,4,'Appartement fonctionnel à El Calafate, base confortable entre deux aventures.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(354,32,'Explorer Resort El Calafate','resort',298.00,2,'Resort nature à El Calafate, confort moderne au plus près des grands espaces.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(355,32,'Auberge El Calafate','hostel',328.00,12,'Auberge backpacker à El Calafate, ambiance routarde et bons conseils pour explorer les environs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(356,33,'Hôtel Londres Centre','hotel',212.00,2,'Hôtel moderne en plein centre de Londres, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(357,33,'Villa Métropole','villa',242.00,6,'Villa élégante dans un quartier résidentiel calme de Londres, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(358,33,'Appartement Londres','airbnb',272.00,4,'Appartement bien situé en centre-ville de Londres, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(359,33,'Rivoli Spa Resort','resort',302.00,2,'Resort urbain à Londres avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(360,33,'Central Hostel Londres','hostel',332.00,12,'Auberge animée en plein cœur de Londres, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(361,34,'Urban Grand Hôtel','hotel',216.00,2,'Hôtel moderne en plein centre de Berlin, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(362,34,'Casa Plaza Berlin','villa',246.00,6,'Villa élégante dans un quartier résidentiel calme de Berlin, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(363,34,'Loft Métropole Berlin','airbnb',276.00,4,'Appartement bien situé en centre-ville de Berlin, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(364,34,'Berlin Resort & Spa','resort',306.00,2,'Resort urbain à Berlin avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(365,34,'Berlin Backpackers','hostel',336.00,12,'Auberge animée en plein cœur de Berlin, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(366,35,'Hôtel Héritage Vienne','hotel',220.00,2,'Hôtel de charme proche des sites historiques de Vienne, alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(367,35,'Villa Vienne','villa',250.00,6,'Villa de caractère à Vienne, décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(368,35,'Studio Royal','airbnb',280.00,4,'Appartement de charme dans la vieille ville de Vienne, à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(369,35,'Médina Resort Vienne','resort',310.00,2,'Resort raffiné proche des trésors culturels de Vienne, entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(370,35,'Auberge Vienne','hostel',340.00,12,'Auberge accueillante près du centre historique de Vienne, idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(371,36,'Hôtel Madrid Centre','hotel',224.00,2,'Hôtel moderne en plein centre de Madrid, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(372,36,'Villa Central','villa',254.00,6,'Villa élégante dans un quartier résidentiel calme de Madrid, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(373,36,'Appartement Madrid','airbnb',284.00,4,'Appartement bien situé en centre-ville de Madrid, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(374,36,'Plaza Spa Resort','resort',314.00,2,'Resort urbain à Madrid avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(375,36,'Métropole Hostel Madrid','hostel',344.00,12,'Auberge animée en plein cœur de Madrid, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(376,37,'Downtown Grand Hôtel','hotel',228.00,2,'Hôtel moderne en plein centre de Bruxelles, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(377,37,'Casa Rivoli Bruxelles','villa',258.00,6,'Villa élégante dans un quartier résidentiel calme de Bruxelles, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(378,37,'Loft Central Bruxelles','airbnb',288.00,4,'Appartement bien situé en centre-ville de Bruxelles, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(379,37,'Bruxelles Resort & Spa','resort',318.00,2,'Resort urbain à Bruxelles avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(380,37,'Bruxelles Backpackers','hostel',348.00,12,'Auberge animée en plein cœur de Bruxelles, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(381,38,'Hôtel Métropole Copenhague','hotel',232.00,2,'Hôtel moderne en plein centre de Copenhague, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(382,38,'Villa Copenhague','villa',262.00,6,'Villa élégante dans un quartier résidentiel calme de Copenhague, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(383,38,'Studio Rivoli','airbnb',292.00,4,'Appartement bien situé en centre-ville de Copenhague, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(384,38,'Central Resort Copenhague','resort',322.00,2,'Resort urbain à Copenhague avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(385,38,'Auberge Copenhague','hostel',352.00,12,'Auberge animée en plein cœur de Copenhague, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(386,39,'Hôtel Stockholm Centre','hotel',236.00,2,'Hôtel moderne en plein centre de Stockholm, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(387,39,'Villa Métropole','villa',266.00,6,'Villa élégante dans un quartier résidentiel calme de Stockholm, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(388,39,'Appartement Stockholm','airbnb',296.00,4,'Appartement bien situé en centre-ville de Stockholm, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(389,39,'Rivoli Spa Resort','resort',326.00,2,'Resort urbain à Stockholm avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(390,39,'Central Hostel Stockholm','hostel',356.00,12,'Auberge animée en plein cœur de Stockholm, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(391,40,'Patrimoine Grand Hôtel','hotel',240.00,2,'Hôtel de charme proche des sites historiques de Budapest, alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(392,40,'Casa Royal Budapest','villa',270.00,6,'Villa de caractère à Budapest, décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(393,40,'Loft Médina Budapest','airbnb',300.00,4,'Appartement de charme dans la vieille ville de Budapest, à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(394,40,'Budapest Resort & Spa','resort',330.00,2,'Resort raffiné proche des trésors culturels de Budapest, entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(395,40,'Budapest Backpackers','hostel',360.00,12,'Auberge accueillante près du centre historique de Budapest, idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(396,41,'Hôtel Héritage Athènes','hotel',244.00,2,'Hôtel de charme proche des sites historiques de Athènes, alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(397,41,'Villa Athènes','villa',274.00,6,'Villa de caractère à Athènes, décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(398,41,'Studio Royal','airbnb',304.00,4,'Appartement de charme dans la vieille ville de Athènes, à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(399,41,'Médina Resort Athènes','resort',334.00,2,'Resort raffiné proche des trésors culturels de Athènes, entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(400,41,'Auberge Athènes','hostel',364.00,12,'Auberge accueillante près du centre historique de Athènes, idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(401,42,'Hôtel Florence Centre','hotel',248.00,2,'Hôtel de charme proche des sites historiques de Florence, alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(402,42,'Villa Héritage','villa',278.00,6,'Villa de caractère à Florence, décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(403,42,'Appartement Florence','airbnb',308.00,4,'Appartement de charme dans la vieille ville de Florence, à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(404,42,'Royal Spa Resort','resort',338.00,2,'Resort raffiné proche des trésors culturels de Florence, entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(405,42,'Médina Hostel Florence','hostel',368.00,12,'Auberge accueillante près du centre historique de Florence, idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(406,43,'Downtown Grand Hôtel','hotel',252.00,2,'Hôtel moderne en plein centre de Porto, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(407,43,'Casa Rivoli Porto','villa',282.00,6,'Villa élégante dans un quartier résidentiel calme de Porto, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(408,43,'Loft Central Porto','airbnb',312.00,4,'Appartement bien situé en centre-ville de Porto, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(409,43,'Porto Resort & Spa','resort',342.00,2,'Resort urbain à Porto avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(410,43,'Porto Backpackers','hostel',372.00,12,'Auberge animée en plein cœur de Porto, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(411,44,'Hôtel Médina Lisbonne Nord (Sintra)','hotel',256.00,2,'Hôtel de charme proche des sites historiques de Lisbonne Nord (Sintra), alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(412,44,'Villa Lisbonne Nord (Sintra)','villa',286.00,6,'Villa de caractère à Lisbonne Nord (Sintra), décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(413,44,'Studio Palacio','airbnb',316.00,4,'Appartement de charme dans la vieille ville de Lisbonne Nord (Sintra), à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(414,44,'Héritage Resort Lisbonne Nord (Sintra)','resort',346.00,2,'Resort raffiné proche des trésors culturels de Lisbonne Nord (Sintra), entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(415,44,'Auberge Lisbonne Nord (Sintra)','hostel',376.00,12,'Auberge accueillante près du centre historique de Lisbonne Nord (Sintra), idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(416,45,'Hôtel Séoul Centre','hotel',260.00,2,'Hôtel moderne en plein centre de Séoul, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(417,45,'Villa Métropole','villa',290.00,6,'Villa élégante dans un quartier résidentiel calme de Séoul, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(418,45,'Appartement Séoul','airbnb',320.00,4,'Appartement bien situé en centre-ville de Séoul, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(419,45,'Rivoli Spa Resort','resort',350.00,2,'Resort urbain à Séoul avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(420,45,'Central Hostel Séoul','hostel',380.00,12,'Auberge animée en plein cœur de Séoul, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(421,46,'Urban Grand Hôtel','hotel',264.00,2,'Hôtel moderne en plein centre de Hong Kong, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(422,46,'Casa Plaza Hong Kong','villa',294.00,6,'Villa élégante dans un quartier résidentiel calme de Hong Kong, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(423,46,'Loft Métropole Hong Kong','airbnb',324.00,4,'Appartement bien situé en centre-ville de Hong Kong, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(424,46,'Hong Kong Resort & Spa','resort',354.00,2,'Resort urbain à Hong Kong avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(425,46,'Hong Kong Backpackers','hostel',384.00,12,'Auberge animée en plein cœur de Hong Kong, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(426,47,'Hôtel Central Kuala Lumpur','hotel',268.00,2,'Hôtel moderne en plein centre de Kuala Lumpur, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(427,47,'Villa Kuala Lumpur','villa',298.00,6,'Villa élégante dans un quartier résidentiel calme de Kuala Lumpur, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(428,47,'Studio Plaza','airbnb',328.00,4,'Appartement bien situé en centre-ville de Kuala Lumpur, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(429,47,'Métropole Resort Kuala Lumpur','resort',358.00,2,'Resort urbain à Kuala Lumpur avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(430,47,'Auberge Kuala Lumpur','hostel',388.00,12,'Auberge animée en plein cœur de Kuala Lumpur, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(431,48,'Hôtel Hanoï Centre','hotel',272.00,2,'Hôtel de charme proche des sites historiques de Hanoï, alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(432,48,'Villa Héritage','villa',302.00,6,'Villa de caractère à Hanoï, décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(433,48,'Appartement Hanoï','airbnb',332.00,4,'Appartement de charme dans la vieille ville de Hanoï, à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(434,48,'Royal Spa Resort','resort',362.00,2,'Resort raffiné proche des trésors culturels de Hanoï, entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(435,48,'Médina Hostel Hanoï','hostel',392.00,12,'Auberge accueillante près du centre historique de Hanoï, idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(436,49,'Antico Grand Hôtel','hotel',276.00,2,'Hôtel de charme proche des sites historiques de Mumbai, alliant confort et authenticité.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(437,49,'Casa Palacio Mumbai','villa',306.00,6,'Villa de caractère à Mumbai, décor traditionnel et patio ombragé pour se ressourcer.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(438,49,'Loft Héritage Mumbai','airbnb',336.00,4,'Appartement de charme dans la vieille ville de Mumbai, à deux pas des monuments.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(439,49,'Mumbai Resort & Spa','resort',366.00,2,'Resort raffiné proche des trésors culturels de Mumbai, entre détente et découverte.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(440,49,'Mumbai Backpackers','hostel',396.00,12,'Auberge accueillante près du centre historique de Mumbai, idéale pour rencontrer d\'autres voyageurs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(441,50,'Hôtel Métropole Montréal','hotel',280.00,2,'Hôtel moderne en plein centre de Montréal, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(442,50,'Villa Montréal','villa',310.00,6,'Villa élégante dans un quartier résidentiel calme de Montréal, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(443,50,'Studio Rivoli','airbnb',340.00,4,'Appartement bien situé en centre-ville de Montréal, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(444,50,'Central Resort Montréal','resort',370.00,2,'Resort urbain à Montréal avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(445,50,'Auberge Montréal','hostel',400.00,12,'Auberge animée en plein cœur de Montréal, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(446,51,'Hôtel Los Angeles Centre','hotel',284.00,2,'Hôtel moderne en plein centre de Los Angeles, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(447,51,'Villa Métropole','villa',314.00,6,'Villa élégante dans un quartier résidentiel calme de Los Angeles, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(448,51,'Appartement Los Angeles','airbnb',344.00,4,'Appartement bien situé en centre-ville de Los Angeles, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(449,51,'Rivoli Spa Resort','resort',374.00,2,'Resort urbain à Los Angeles avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(450,51,'Central Hostel Los Angeles','hostel',404.00,12,'Auberge animée en plein cœur de Los Angeles, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(451,52,'Urban Grand Hôtel','hotel',288.00,2,'Hôtel moderne en plein centre de Sydney, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(452,52,'Casa Plaza Sydney','villa',318.00,6,'Villa élégante dans un quartier résidentiel calme de Sydney, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(453,52,'Loft Métropole Sydney','airbnb',348.00,4,'Appartement bien situé en centre-ville de Sydney, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(454,52,'Sydney Resort & Spa','resort',378.00,2,'Resort urbain à Sydney avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(455,52,'Sydney Backpackers','hostel',408.00,12,'Auberge animée en plein cœur de Sydney, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(456,53,'Hôtel Central Buenos Aires','hotel',292.00,2,'Hôtel moderne en plein centre de Buenos Aires, à deux pas des principaux sites et des transports.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(457,53,'Villa Buenos Aires','villa',322.00,6,'Villa élégante dans un quartier résidentiel calme de Buenos Aires, à proximité du centre.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(458,53,'Studio Plaza','airbnb',352.00,4,'Appartement bien situé en centre-ville de Buenos Aires, idéal pour découvrir la ville à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(459,53,'Métropole Resort Buenos Aires','resort',382.00,2,'Resort urbain à Buenos Aires avec spa, rooftop et prestations haut de gamme.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(460,53,'Auberge Buenos Aires','hostel',412.00,12,'Auberge animée en plein cœur de Buenos Aires, parfaite pour les voyageurs au budget malin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(461,54,'Hôtel Rio de Janeiro Centre','hotel',296.00,2,'Hôtel pratique pour rayonner autour de Rio de Janeiro et partir à l\'aventure dès le matin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(462,54,'Villa Explorer','villa',326.00,6,'Villa au cœur de la nature, près de Rio de Janeiro, point de départ idéal pour vos excursions.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(463,54,'Appartement Rio de Janeiro','airbnb',356.00,4,'Appartement fonctionnel à Rio de Janeiro, base confortable entre deux aventures.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(464,54,'Nomad Spa Resort','resort',386.00,2,'Resort nature à Rio de Janeiro, confort moderne au plus près des grands espaces.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(465,54,'Trek Hostel Rio de Janeiro','hostel',416.00,12,'Auberge backpacker à Rio de Janeiro, ambiance routarde et bons conseils pour explorer les environs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(466,55,'Coral Grand Hôtel','hotel',300.00,2,'Hôtel chaleureux à quelques minutes des plages de Punta Cana, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(467,55,'Casa Azur Punta Cana','villa',330.00,6,'Villa privée avec piscine et terrasse à Punta Cana, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(468,55,'Loft Ocean Punta Cana','airbnb',360.00,4,'Appartement lumineux à Punta Cana, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(469,55,'Punta Cana Beach Resort','resort',390.00,2,'Resort tout confort en bord de mer à Punta Cana : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(470,55,'Punta Cana Backpackers','hostel',420.00,12,'Auberge de jeunesse conviviale à Punta Cana, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(471,56,'Hôtel Palm Koh Samui','hotel',304.00,2,'Hôtel chaleureux à quelques minutes des plages de Koh Samui, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(472,56,'Villa Koh Samui','villa',334.00,6,'Villa privée avec piscine et terrasse à Koh Samui, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(473,56,'Studio Sunset','airbnb',364.00,4,'Appartement lumineux à Koh Samui, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(474,56,'Coral Resort Koh Samui','resort',394.00,2,'Resort tout confort en bord de mer à Koh Samui : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(475,56,'Auberge Koh Samui','hostel',424.00,12,'Auberge de jeunesse conviviale à Koh Samui, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(476,57,'Hôtel Cap-Vert Centre','hotel',308.00,2,'Hôtel chaleureux à quelques minutes des plages du Cap-Vert, avec piscine extérieure et petit-déjeuner inclus.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(477,57,'Villa Paradis','villa',338.00,6,'Villa privée avec piscine et terrasse au Cap-Vert, parfaite pour des vacances en famille au bord de l\'eau.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(478,57,'Appartement Cap-Vert','airbnb',368.00,4,'Appartement lumineux au Cap-Vert, balcon avec vue mer et plage accessible à pied.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(479,57,'Palm Spa Resort','resort',398.00,2,'Resort tout confort en bord de mer au Cap-Vert : piscines, spa et activités nautiques.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(480,57,'Lagon Hostel Cap-Vert','hostel',428.00,12,'Auberge de jeunesse conviviale au Cap-Vert, ambiance détendue et plage toute proche.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(481,58,'Safari Grand Hôtel','hotel',312.00,2,'Hôtel pratique pour rayonner autour de La Réunion et partir à l\'aventure dès le matin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(482,58,'Casa Nomad La Réunion','villa',342.00,6,'Villa au cœur de la nature, près de La Réunion, point de départ idéal pour vos excursions.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(483,58,'Loft Trek La Réunion','airbnb',372.00,4,'Appartement fonctionnel à La Réunion, base confortable entre deux aventures.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(484,58,'La Réunion Resort & Spa','resort',402.00,2,'Resort nature à La Réunion, confort moderne au plus près des grands espaces.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(485,58,'La Réunion Backpackers','hostel',432.00,12,'Auberge backpacker à La Réunion, ambiance routarde et bons conseils pour explorer les environs.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(486,59,'Hôtel Explorer Cape Town','hotel',316.00,2,'Hôtel pratique pour rayonner autour de Cape Town et partir à l\'aventure dès le matin.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(487,59,'Villa Cape Town','villa',346.00,6,'Villa au cœur de la nature, près de Cape Town, point de départ idéal pour vos excursions.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(488,59,'Studio Nomad','airbnb',376.00,4,'Appartement fonctionnel à Cape Town, base confortable entre deux aventures.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(489,59,'Trek Resort Cape Town','resort',406.00,2,'Resort nature à Cape Town, confort moderne au plus près des grands espaces.',NULL);
INSERT IGNORE INTO hebergements (id,destination_id,nom,type,prix_nuit,capacite,description,image_url) VALUES
(490,59,'Auberge Cape Town','hostel',436.00,12,'Auberge backpacker à Cape Town, ambiance routarde et bons conseils pour explorer les environs.',NULL);

-- ============================================================
-- DONNÉES — ACTIVITÉS
-- ============================================================

-- Activités de base (IDs 1-10, destinations 1-5)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(1, 1, 'Snorkeling Blue Lagoon',  NULL, 45.00, 15, 15, 3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(2, 1, 'Temple Tanah Lot',        NULL, 35.00, 30, 30, 2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(3, 1, 'Cours de surf à Kuta',    NULL, 60.00, 10,  0, 3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(4, 1, 'Randonnée rizières',      NULL, 40.00, 12, 12, 4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(5, 2, 'Visite du Mont Fuji',     NULL, 80.00, 20, 20, 8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(6, 2, 'Quartier d\'Akihabara',   NULL, 25.00, 50, 50, 3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(7, 3, 'Parachutisme',            NULL,180.00,  8,  8, 2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(8, 3, 'Canyoning',               NULL, 90.00, 10, 10, 4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(9, 4, 'Tram 28 + Alfama',        NULL, 20.00, 40, 40, 3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(10,5, 'Coucher de soleil Oia',   NULL, 30.00, 25, 25, 2.0);

-- ACTIVITÉS (nouvelles uniquement, IDs 28+)
-- ============================================================

-- Maldives (dest 1)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(28,1,'Plongée sur le récif','Plongée guidée dans les récifs coralliens préservés avec tortues et raies mantas.',90.00,8,7,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(29,1,'Croisière en dhow au coucher de soleil','Croisière en boutre traditionnel maldivien avec dîner fruits de mer.',110.00,12,10,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(30,1,'Observation des bioluminescences','Nage nocturne dans le lagon illuminé par le plancton bioluminescent.',60.00,10,8,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(31,1,'Cours de surf et bodyboard','Initiation aux sports de glisse dans un lagon protégé avec moniteur.',55.00,12,11,3.0);

-- Phuket (dest 2)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(32,2,'Tour de la baie de Phang Nga','Excursion en kayak dans les falaises calcaires de la baie de James Bond.',75.00,20,17,8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(33,2,'Cours de muay thai','Entraînement d\'initiation à la boxe thaïlandaise avec un champion local.',40.00,12,9,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(34,2,'Snorkeling aux îles Phi Phi','Journée en bateau rapide aux îles Phi Phi avec plongée en apnée.',55.00,25,21,7.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(35,2,'Cours de cuisine thaie','Leçon de cuisine avec 5 recettes typiques et visite du marché flottant.',50.00,10,8,5.0);

-- Cancún (dest 3)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(36,3,'Plongée dans un Cenote','Exploration sous-marine de ces puits sacrés mayas aux eaux turquoise.',80.00,10,7,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(37,3,'Visite de Chichen Itza','Excursion guidée vers la pyramide maya classée parmi les 7 merveilles du monde.',95.00,25,19,10.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(38,9,'Snorkeling à l\'île Mujeres','Traversée en ferry et snorkeling sur la barrière de corail en mer des Caraïbes.',60.00,20,15,6.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(39,3,'Wakeboard et sports nautiques','Session 2h de sports nautiques : wakeboard, ski nautique, banana boat.',65.00,15,12,2.0);

-- Seychelles (dest 4)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(40,4,'Randonnée Vallée de Mai','Trek dans la réserve de biosphère où pousse le Coco de Mer mythique.',50.00,12,10,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(41,10,'Plongée à l\'île de Curieuse','Plongée avec les tortues géantes et barracudas dans les eaux protégées.',85.00,8,6,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(42,4,'Pêche en haute mer','Pêche au gros en mer Indienne : thon, marlin et dorade coryphène.',180.00,6,5,8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(43,4,'Kayak de mer entre les îlots','Exploration en kayak des criques secrètes entre Mahé et Praslin.',45.00,16,14,4.0);

-- Zanzibar (dest 5)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(44,5,'Tour des épices de Zanzibar','Balade olfactive dans une plantation d\'épices tropicales avec dégustation.',25.00,20,18,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(45,5,'Visite de Stone Town','Découverte de l\'architecture swahili-arabe et de la maison de Freddie Mercury.',30.00,25,22,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(46,5,'Nage avec les dauphins','Sortie en bateau pour nager avec les dauphins sauvages au large.',55.00,12,9,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(47,5,'Safari Blue Snorkeling','Journée en boutre à voile avec pêche, snorkeling et festin de fruits de mer.',70.00,20,16,8.0);

-- Mykonos (dest 6)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(48,6,'Party boat sunset cruise','Croisière festive au coucher du soleil avec DJ, open bar et baignade.',85.00,30,25,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(49,6,'Windsurf et kitesurf','Cours de windsurf ou kitesurf sur l\'une des meilleures plages de Méditerranée.',70.00,8,6,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(50,6,'Visite de Délos en bateau','Excursion sur l\'île mythologique de Délos, berceau des dieux Apollon et Artémis.',45.00,20,16,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(51,6,'Yoga au lever du soleil','Session de yoga au lever du soleil sur un rocher face à la mer Égée.',30.00,12,11,1.5);

-- Ibiza (dest 7)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(52,7,'Excursion en quad','Tour en quad entre les collines, vignes et criques secrètes d\'Ibiza.',90.00,10,7,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(53,7,'Coucher de soleil Café del Mar','Soirée mythique avec accès réservé à la terrasse du Café del Mar.',40.00,25,20,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(54,7,'Plongée à Ses Salines','Plongée dans le parc naturel protégé de Ses Salines avec posidonie.',65.00,8,6,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(55,7,'Yoga et méditation Es Vedra','Retraite yoga d\'une journée face au rocher magique d\'Es Vedra.',55.00,15,13,6.0);

-- Bora Bora (dest 8)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(56,14,'Jet ski autour de l\'île','Tour complet de Bora Bora en jet ski avec snorkeling dans le lagon.',130.00,10,7,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(57,8,'Plongée avec les requins','Plongée sécurisée avec les requins à pointe noire et raies du lagon.',95.00,8,6,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(58,8,'Excursion 4x4 Mont Pahia','Ascension en 4x4 du Mont Pahia pour une vue panoramique à 360°.',75.00,12,10,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(59,8,'Pique-nique sur motu privé','Transfert en hors-bord vers un motu désert avec pique-nique gastronomique.',150.00,8,7,5.0);

-- Île Maurice (dest 9)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(60,15,'Plongée à l\'île aux Cerfs','Plongée dans le lagon protégé avec poissons multicolores.',70.00,10,8,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(61,9,'Trek à la montagne du Pouce','Randonnée jusqu\'au sommet du Pouce (812m) avec vue sur Port-Louis.',40.00,15,13,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(62,9,'Visite distillerie de rhum','Tour de la distillerie Chamarel avec dégustation de 6 rhums arrangés.',45.00,20,17,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(63,9,'Observation des baleines','Sortie en bateau pour observer les dauphins et baleines au large de Tamarin.',80.00,15,12,4.0);

-- Miami Beach (dest 10)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(64,10,'Tour Art Deco South Beach','Visite guidée à pied des chefs-d\'œuvre Art Déco de la Ocean Drive.',30.00,20,18,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(65,10,'Excursion dans les Everglades','Tour en airboat dans la jungle aquatique des Everglades avec alligators.',65.00,20,16,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(66,10,'Stand-up paddle Biscayne Bay','Session SUP dans la baie de Biscayne avec vue sur Miami et les mangroves.',45.00,12,10,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(67,10,'Brunch rooftop Wynwood','Brunch gastronomique sur un rooftop dans le quartier street art de Wynwood.',55.00,20,17,2.0);

-- Chamonix (dest 11)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(68,11,'Aiguille du Midi','Montée à 3842m avec vue sur le Mont-Blanc et la Vallée Blanche.',60.00,40,35,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(69,11,'Randonnée Mer de Glace','Trek jusqu\'au plus grand glacier de France avec visite de la grotte de glace.',35.00,20,18,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(70,11,'Ski hors-piste Vallée Blanche','Session de ski hors-piste avec guide UIAGM en vallée Blanche.',180.00,6,4,6.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(71,11,'Parapente biplace','Vol en parapente biplace depuis le Brévent avec vue sur le Mont-Blanc.',145.00,4,3,1.5);

-- Queenstown (dest 12)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(72,12,'Bungy Kawarau Bridge','Le premier bungy commercial du monde au-dessus de la gorge de Kawarau.',165.00,20,14,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(73,12,'Jet-boat Shotover River','Course en jet-boat à grande vitesse dans les gorges du Shotover.',90.00,12,9,1.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(74,12,'Excursion à Milford Sound','Croisière majestueuse dans le fjord classé au patrimoine mondial.',185.00,25,19,12.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(75,12,'Ski à Coronet Peak','Journée de ski ou snowboard sur le domaine emblématique de Queenstown.',120.00,30,24,8.0);

-- Zermatt (dest 13)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(76,13,'Ski Klein Matterhorn','Ski sur le plus haut domaine skiable d\'Europe avec vue sur 38 sommets de 4000m.',95.00,30,25,7.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(77,13,'Randonnée Haute Route','Étape guidée de la célèbre Haute Route entre Chamonix et Zermatt.',150.00,8,5,8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(78,13,'Photo du Cervin au lever du soleil','Session guidée de photographie de montagne au lever du soleil.',70.00,6,4,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(79,13,'Visite musée Matterhorn','Découverte de l\'histoire de la conquête du Cervin et des premières ascensions.',15.00,30,28,1.5);

-- Dolomites (dest 14)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(80,14,'Via Ferrata Lagazuoi','Via ferrata légendaire avec vue sur les Cinq Doigts et le Fanes.',65.00,8,6,6.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(81,14,'Tour des Drei Zinnen en VTT','Tour cyclo-montagne autour des trois sommets emblématiques des Dolomites.',55.00,10,7,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(82,14,'Randonnée Alpe di Siusi','Trek dans le plus grand alpage d\'Europe avec vue sur le Schlern.',20.00,25,22,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(83,14,'Cours de cuisine ladine','Initiation à la cuisine traditionnelle ladine avec polenta et canederli.',60.00,10,9,4.0);

-- Tromsø (dest 15)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(84,15,'Tour aurores boréales','Expédition nocturne en minibus pour chasser les aurores boréales.',95.00,12,10,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(85,15,'Randonnée en raquettes','Trek en raquettes dans la toundra enneigée avec guide Sami.',70.00,10,8,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(86,15,'Safari en chiens de traineau','Promenade en traîneau tiré par des huskies dans la neige arctique.',160.00,12,10,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(87,15,'Plongée sous la glace','Plongée dans les fjords arctiques gelés avec combinaison étanche.',180.00,6,4,3.0);

-- Aspen (dest 16)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(88,16,'Ski sur Aspen Mountain','Journée de ski avec moniteur sur les pistes légendaires d\'Aspen Mountain.',130.00,20,16,7.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(89,16,'Motoneige dans Snowmass','Session de motoneige dans les montagnes enneigées autour d\'Aspen.',110.00,10,8,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(90,16,'Randonnée Maroon Bells','Randonnée autour des lacs de Maroon Bells, vue considérée la plus belle d\'Amérique.',30.00,20,17,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(91,16,'Dégustation de vins du Colorado','Visite d\'un vignoble altitude et dégustation de vins locaux dans la cave.',65.00,16,14,3.0);

-- Barcelone (dest 17)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(92,17,'Visite guidée Sagrada Familia','Visite complète avec guide expert de l\'œuvre-vie de Gaudí.',35.00,20,17,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(93,17,'Tour de nuit des tapas','Déambulation gastronomique dans 5 bars à tapas du Born et de la Barceloneta.',55.00,16,13,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(94,17,'Cours de flamenco','Initiation au flamenco en studio avec danseuse professionnelle.',40.00,12,10,1.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(95,17,'Excursion à Montserrat','Excursion en train de crémaillère à l\'abbaye perchée de Montserrat.',45.00,25,21,6.0);

-- Amsterdam (dest 18)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(96,18,'Tour en vélo des canaux','Découverte des quartiers d\'Amsterdam à vélo avec guide local.',25.00,15,12,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(97,18,'Visite du Rijksmuseum','Visite guidée des chefs-d\'œuvre de Rembrandt et Vermeer.',30.00,20,17,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(98,18,'Tour des brasseries artisanales','Dégustation dans 3 brasseries artisanales amsterdamoises.',55.00,16,13,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(99,18,'Croisière nocturne illuminée','Croisière dans les canaux illuminés avec open bar.',65.00,25,20,2.0);

-- Singapour (dest 19)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(100,19,'Gardens by the Bay nocturne','Spectacle son et lumière dans les Supertrees de Gardens by the Bay.',20.00,50,45,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(101,19,'Tour gastronomique Hawker Centre','Dégustation guidée dans 3 hawker centres emblématiques.',50.00,12,10,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(102,19,'Excursion à Sentosa','Journée à Universal Studios Singapore et sur les plages de Sentosa.',80.00,20,16,8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(103,19,'Night Safari','Visite du célèbre Night Safari avec animaux nocturnes et spectacle.',45.00,25,21,3.0);

-- Prague (dest 20)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(104,20,'Tour du Château de Prague','Visite complète du plus grand château médiéval du monde avec guide.',25.00,20,18,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(105,20,'Dégustation cave à bière','Session dans une pivnice traditionnelle avec 6 bières artisanales tchèques.',30.00,16,14,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(106,20,'Tour en bateau sur la Vltava','Croisière panoramique sur la rivière Vltava au coucher du soleil.',35.00,25,21,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(107,20,'Marchés de la Vieille Ville','Immersion dans la vie locale lors des marchés saisonniers emblématiques.',15.00,30,27,2.0);

-- Dubaï (dest 21)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(108,21,'Safari dans le désert','Excursion en 4x4 dans les dunes rouges avec dîner bédouin et show.',95.00,20,16,6.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(109,21,'Observation depuis le Burj Khalifa','Accès au pont d\'observation At The Top (124e étage) avec vue 360°.',50.00,40,35,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(110,21,'Ski à Ski Dubai','Session de ski indoor dans la plus grande piste couverte du Moyen-Orient.',80.00,20,17,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(111,21,'Croisière en dhow sur Dubai Creek','Dîner croisière sur le Creek dans un boutre traditionnel illuminé.',70.00,25,20,2.5);

-- New York (dest 22)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(112,22,'Tour en hélicoptère de Manhattan','Vol panoramique de 15 min autour des gratte-ciels de Manhattan.',180.00,6,4,0.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(113,22,'Broadway Musical','Spectacle sur Broadway avec les meilleures places en catégorie Orchestra.',150.00,10,7,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(114,22,'Tour gastronomique Greenwich Village','Dégustation dans les meilleurs restaurants du plus beau quartier de NY.',70.00,12,9,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(115,28,'Kayak sur l\'Hudson River','Session de kayak avec vue sur le World Trade Center depuis l\'eau.',45.00,15,12,2.0);

-- Bangkok (dest 23)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(116,23,'Tour des temples en tuk-tuk','Visite de Wat Pho, Wat Arun et Grand Palais en tuk-tuk avec guide.',35.00,20,16,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(117,23,'Cours de cuisine thaie au marché','Marché flottant suivi d\'un cours de cuisine traditionnelle.',60.00,12,10,6.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(118,23,'Excursion à Ayutthaya','Journée aux ruines de l\'ancienne capitale du Siam classée UNESCO.',55.00,20,16,8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(119,23,'Massage thai traditionnel','Séance de 2h de massage thaï traditionnel dans un salon authentique.',25.00,10,8,2.0);

-- Marrakech (dest 24)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(120,24,'Balade dans les souks','Tour guidé dans les souks labyrinthiques et visite des tanneries de Chouara.',30.00,15,13,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(121,30,'Excursion désert d\'Agafay','Dîner gastronomique sous les étoiles dans le désert de pierres de l\'Agafay.',95.00,20,16,6.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(122,24,'Hammam traditionnel','Séance complète de hammam marocain dans un établissement historique.',35.00,12,10,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(123,24,'Cours de cuisine marocaine','Préparation d\'un tajine et de pastilla avec une cuisinière locale.',50.00,8,6,4.0);

-- Rome (dest 25)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(124,25,'Visite guidée du Colisée','Accès coupe-file au Colisée, à l\'arène souterraine et au Forum romain.',45.00,20,16,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(125,25,'Tour Vatican Chapelle Sixtine','Visite guidée exclusive des Musées du Vatican et de la Chapelle Sixtine.',55.00,20,15,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(126,25,'Atelier de cuisine romaine','Cours de fabrication de pasta fraîche, tiramisu et carbonara.',65.00,10,8,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(127,25,'Tour de la Roma Segreta','Découverte des coins cachés et fontaines secrètes de la Rome antique.',30.00,15,12,2.5);

-- Istanbul (dest 26)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(128,26,'Sainte-Sophie et Mosquée Bleue','Visite guidée des deux icônes de l\'Empire byzantin et ottoman.',35.00,20,17,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(129,26,'Tour en bateau sur le Bosphore','Croisière dans le détroit mythique entre Europe et Asie.',40.00,25,21,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(130,26,'Dégustation au Grand Bazar','Tour gastronomique dans le plus vieux marché couvert du monde.',45.00,12,10,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(131,26,'Hammam ottoman Cagaloglu','Bain turc dans le hammam historique du XVIIIe siècle.',55.00,20,17,2.0);

-- Kyoto (dest 27)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(132,27,'Cérémonie du thé à Gion','Cérémonie du thé authentique dans un ochaya historique du quartier des geishas.',45.00,8,6,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(133,27,'Randonnée Fushimi Inari','Ascension aux milliers de torii vermillon du sanctuaire Fushimi Inari.',15.00,20,18,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(134,27,'Tour en rickshaw Arashiyama','Promenade en rickshaw dans la forêt de bambous d\'Arashiyama.',55.00,6,4,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(135,33,'Cours d\'ikebana','Atelier d\'initiation à l\'art floral japonais avec maître certifié.',60.00,8,7,2.5);

-- Le Caire (dest 28)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(136,28,'Pyramides à dos de chameau','Tour des pyramides de Gizeh et du Sphinx à dos de chameau avec guide.',60.00,20,15,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(137,28,'Croisière sur le Nil','Dîner croisière sur le Nil avec spectacle de danse orientale.',55.00,25,20,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(138,28,'Musée égyptien et momies royales','Visite guidée du plus grand musée d\'antiquités égyptiennes du monde.',35.00,20,17,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(139,28,'Balade Khan El-Khalili','Tour guidé dans le souk médiéval du Caire avec dégustation de café turc.',25.00,15,13,2.0);

-- Reykjavik (dest 29)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(140,29,'Bain dans le Blue Lagoon','Séance dans les eaux géothermales bleu laiteux du Blue Lagoon avec soin.',80.00,30,25,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(141,35,'Tour du Cercle d\'Or','Excursion vers Thingvellir, les geysers de Geysir et la cascade de Gullfoss.',95.00,25,21,10.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(142,29,'Observation des baleines','Sortie en mer à la rencontre des baleines à bosse et des marsouins.',70.00,20,16,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(143,29,'Randonnée sur glacier','Trek guidé sur le glacier Solheimajokull avec crampons.',120.00,10,8,4.0);

-- Nairobi (dest 30)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(144,30,'Safari 2 jours Masai Mara','Safari privé de 2 jours dans la Masaï Mara avec nuit en camp de luxe.',450.00,8,5,48.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(145,30,'Centre des éléphants orphelins','Rencontre avec les éléphants orphelins du David Sheldrick Wildlife Trust.',25.00,30,26,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(146,30,'Tour du village Masai','Immersion dans une boma Masaï avec danses traditionnelles et artisanat.',40.00,20,16,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(147,30,'Randonnée Ngong Hills','Trek dans les collines Ngong avec vue sur la vallée du Rift et Nairobi.',35.00,15,12,5.0);

-- Costa Rica (dest 31)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(148,31,'Canopy et Zip-line Arenal','Vol de tyrolienne à travers la canopée tropicale du parc Arenal.',55.00,15,12,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(149,31,'Rafting sur le Rio Pacuare','Descente en eaux vives de classe III-IV dans l\'un des plus beaux fleuves du monde.',85.00,12,10,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(150,31,'Observation des tortues marines','Nuit sur la plage de Tortuguero pour observer les tortues géantes pondre.',70.00,10,7,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(151,31,'Sources chaudes Arenal','Soirée dans les sources thermales naturelles au pied du volcan actif.',40.00,25,21,3.0);

-- El Calafate (dest 32)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(152,32,'Marche sur le Perito Moreno','Trek avec crampons sur le glacier bleu le plus actif du monde.',130.00,12,9,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(153,32,'Navigation devant le glacier','Croisière pour admirer les chutes de glace depuis l\'eau.',60.00,25,20,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(154,32,'Trek à Torres del Paine','Journée de randonnée vers les tours de granit iconiques de Patagonie.',90.00,8,6,8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(155,32,'Observation condors des Andes','Sortie ornithologique pour observer les condors en vol dans les Andes.',45.00,12,10,4.0);

-- ACTIVITÉS (IDs 156-283)
-- ============================================================

-- Londres (dest 33)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(156,33,'Visite de la Tour de Londres','Tour guidé de la Tour royale avec joyaux de la couronne et gardes Beefeaters.',28.00,20,17,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(157,33,'Croisière sur la Tamise','Bateau entre Westminster et Greenwich avec vue sur Tower Bridge et le Parlement.',18.00,50,44,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(158,33,'Comédie musicale West End','Spectacle dans l\'un des théâtres mythiques de Shaftesbury Avenue (Lion King, Hamilton).',75.00,10,7,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(159,33,'Tour des pubs victoriens de Soho','Dégustation de ales et bitters dans 4 pubs victoriens authentiques avec guide local.',35.00,15,12,3.0);

-- Berlin (dest 34)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(160,34,'Tour du Mur de Berlin','Visite guidée du Checkpoint Charlie, East Side Gallery et mémorial.',15.00,25,22,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(161,40,'Visite de l\'île aux Musées','Journée dans les 5 musées de l\'île avec Pergamon Altar et buste de Néfertiti.',18.00,20,17,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(162,34,'Soirée club berlinois','Entrée guidée dans les clubs électroniques légendaires de Mitte et Friedrichshain.',25.00,12,9,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(163,34,'Street Food Tour Kreuzberg','Dégustation multiculturelle dans le quartier turc et alternatif de Kreuzberg.',40.00,15,12,3.0);

-- Vienne (dest 35)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(164,35,'Opéra de Vienne','Soirée à l\'Opéra impérial avec visite des coulisses en matinée.',95.00,8,6,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(165,35,'Visite du Palais de Schönbrunn','Tour du palais impérial des Habsbourg et de ses jardins à la française.',18.00,25,21,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(166,35,'Café viennois et Sachertorte','Tour des cafés historiques : Café Central, Demel, Landtmann avec dégustation.',35.00,15,13,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(167,35,'Valse au Musikverein','Soirée concert dans la salle dorée du Musikverein, la plus belle salle de concert du monde.',55.00,20,16,3.0);

-- Madrid (dest 36)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(168,36,'Visite guidée du Prado','Tour des chefs-d\'œuvre de Velázquez, Goya et Bosch avec accès coupe-file.',22.00,20,17,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(169,36,'Tour de nuit des tapas','Dégustation dans 5 bars à tapas de La Latina et Chueca avec guide madrilène.',55.00,14,11,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(170,36,'Spectacle de flamenco','Show flamenco authentique dans un tablao historique avec dîner inclus.',65.00,20,16,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(171,36,'Excursion à Tolède','Journée dans la cité impériale médiévale classée UNESCO à 70 km de Madrid.',45.00,25,20,8.0);

-- Bruxelles (dest 37)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(172,37,'Tour des brasseries belges','Dégustation de 6 bières trappistes dans 3 établissements historiques.',45.00,15,12,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(173,37,'Visite de la Grand-Place et Manneken Pis','Tour guidé du cœur baroque de Bruxelles classé UNESCO.',12.00,25,22,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(174,37,'Musée Magritte et Art Nouveau','Visite du musée Magritte et balade dans les maisons Art Nouveau de Horta.',18.00,20,17,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(175,37,'Atelier chocolat belge','Fabrication de pralines avec un maître chocolatier bruxellois.',40.00,10,8,2.0);

-- Copenhague (dest 38)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(176,38,'Tour à vélo de Nyhavn et des canaux','Exploration de la ville à vélo comme les Danois avec guide local.',25.00,15,13,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(177,38,'Visite du Palais de Christiansborg','Tour du Palais royal où siège le Parlement danois avec vue panoramique.',16.00,20,18,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(178,38,'Parc Tivoli nocturne','Soirée dans le plus ancien parc d\'attractions du monde avec manèges et concerts.',18.00,30,25,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(179,38,'Dîner gastronomique nouvelle cuisine nordique','Repas dans un restaurant étoilé spécialisé New Nordic Cuisine.',150.00,8,5,3.0);

-- Stockholm (dest 39)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(180,39,'Musée Vasa','Visite du seul navire de guerre du XVIIe siècle intact au monde.',16.00,25,22,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(181,45,'Excursion en kayak dans l\'archipel','Paddle dans les 30 000 îles de l\'archipel de Stockholm.',65.00,10,8,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(182,39,'Tour de Gamla Stan (vieille ville)','Visite guidée de la plus belle vieille ville scandinave avec café et kanelbulle.',20.00,20,17,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(183,39,'Sauna traditionnel suédois','Séance de sauna puis plongeon dans les eaux de la Baltique.',35.00,8,7,2.0);

-- Budapest (dest 40)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(184,40,'Bains thermaux Széchenyi','Séance dans les plus grands bains thermaux d\'Europe, ambiance unique.',20.00,30,25,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(185,40,'Croisière nocturne sur le Danube','Bateau illuminé entre Buda et Pest avec vue sur le Parlement scintillant.',18.00,40,35,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(186,40,'Tour des ruin bars','Visite guidée des bars dans les ruines : Szimpla Kert et ses compères.',25.00,20,16,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(187,40,'Visite du Parlement hongrois','Tour du 3e plus grand parlement du monde avec la Couronne de Saint-Étienne.',20.00,20,17,2.0);

-- Athènes (dest 41)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(188,47,'Visite de l\'Acropole et du Parthénon','Tour guidé du site archéologique le plus visité de Grèce avec musée.',20.00,20,16,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(189,47,'Tour gastronomique d\'Athènes','Dégustation de mezze, souvlaki et vins grecs dans le marché Monastiraki.',50.00,12,10,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(190,41,'Excursion à Delphes','Journée au oracle de Delphes et au musée archéologique dans les montagnes.',65.00,20,17,10.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(191,41,'Cours de cuisine grecque','Préparation de moussaka, spanakopita et baklava avec chef local.',55.00,10,8,3.0);

-- Florence (dest 42)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(192,42,'Visite des Offices avec accès coupe-file','Tour guidé de la plus grande collection de Renaissance au monde.',35.00,15,12,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(193,42,'Cours de cuisine toscane','Marché San Lorenzo + préparation ribollita, bistecca et tiramisu.',75.00,10,8,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(194,42,'Excursion dans le Chianti','Tour vinicole dans les vignes du Chianti Classico avec dégustation.',85.00,12,10,7.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(195,42,'Montée au Dôme de Brunelleschi','Ascension des 463 marches pour une vue 360° sur Florence et la Toscane.',18.00,20,16,2.0);

-- Porto (dest 43)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(196,43,'Tour des caves de porto','Visite et dégustation dans 3 caves historiques de Vila Nova de Gaia.',45.00,15,12,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(197,43,'Croisière sur le Douro','Bateau des 6 ponts sur le fleuve Douro avec vue sur Ribeira.',18.00,30,26,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(198,43,'Tour azulejos et Librairie Lello','Découverte du street art en carreaux et de la plus belle librairie du monde.',20.00,20,17,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(199,43,'Excursion aux vignobles du Douro','Journée dans la vallée classée UNESCO avec déjeuner en quinta.',90.00,12,9,9.0);

-- Sintra (dest 44)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(200,44,'Visite du Palácio da Pena','Tour du château romantique multicolore perché dans la forêt royale.',14.00,25,22,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(201,44,'Randonnée Cabo da Roca','Marche jusqu\'au point le plus occidental de l\'Europe continentale.',10.00,20,18,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(202,44,'Palácio de Queluz (Versailles portugais)','Visite du palais baroque des rois du Portugal et ses jardins à la française.',12.00,20,18,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(203,44,'Tour en tuk-tuk des palais','Circuit en tuk-tuk entre les 5 palais de Sintra avec guide local.',30.00,8,6,3.0);

-- Séoul (dest 45)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(204,45,'Visite du Palais Gyeongbokgung','Tour du plus grand palais Joseon avec relève de la garde en costume traditionnel.',3.00,30,26,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(205,45,'Cours de K-pop et K-beauty','Cours de danse K-pop + atelier maquillage coréen dans un studio de Gangnam.',60.00,12,9,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(206,45,'Tour gastronomique de Gwangjang','Dégustation de street food au marché de nuit le plus ancien de Séoul.',35.00,15,12,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(207,45,'Excursion à la zone démilitarisée','Tour de la DMZ et du tunnel nord-coréen avec guide militaire accrédité.',55.00,20,16,7.0);

-- Hong Kong (dest 46)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(208,46,'Tramway du Peak Victoria','Montée au sommet de l\'île pour la vue la plus spectaculaire sur la skyline.',8.00,40,36,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(209,46,'Tour des marchés de nuit Kowloon','Marchés de Temple Street et Mong Kok avec guide local connaisseur.',30.00,15,12,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(210,46,'Croisière Star Ferry + Symphony of Lights','Traversée iconique du port + spectacle son et lumière sur 44 gratte-ciels.',15.00,30,26,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(211,46,'Dim sum au palace restaurant','Brunch dim sum dans un restaurant de chef étoilé avec plus de 60 sortes.',45.00,10,8,2.0);

-- Kuala Lumpur (dest 47)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(212,47,'Tour des tours Petronas','Accès au sky bridge (41e étage) et observation deck (86e étage) des tours jumelles.',25.00,30,26,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(213,47,'Caves de Batu et temples hindous','Excursion aux grottes sacrées de Batu avec singes et temple doré.',12.00,25,21,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(214,47,'Tour gastronomique Jalan Alor','Dégustation de street food malaisien, indien et chinois dans la rue des saveurs.',30.00,15,12,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(215,47,'Excursion Cameron Highlands','Journée dans les plantations de thé des hautes terres malaisiennes.',55.00,15,12,9.0);

-- Hanoï (dest 48)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(216,54,'Excursion baie d\'Along en jonque','2 jours en jonque dans la baie classée UNESCO avec kayak et grotte.',150.00,12,9,48.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(217,48,'Tour de la vieille ville à vélo','Exploration des 36 guildes de Hanoï à vélo avec guide et déjeuner.',25.00,15,12,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(218,48,'Cours de cuisine vietnamienne','Marché + préparation de pho, banh mi et nem cuon avec chef local.',35.00,10,8,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(219,54,'Spectacle de marionnettes sur l\'eau','Art traditionnel vietnamien du Thang Long au lac Hoan Kiem.',10.00,30,27,1.0);

-- Mumbai (dest 49)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(220,55,'Tour de Dharavi (plus grand bidonville d\'Asie)','Visite sociale accompagnée dans ce quartier d\'entrepreneurs incroyables.',20.00,12,10,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(221,49,'Dîner croisière Mumbai Harbour','Repas sur un bateau devant le Gateway of India et le Taj Palace illuminés.',55.00,20,16,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(222,49,'Cours de cuisine indienne','Préparation de curry, samosa, chapati et chai masala avec cuisine traditionnelle.',40.00,10,8,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(223,49,'Visite du quartier Art Déco de Marine Drive','Tour architectural de la plus grande concentration Art Déco hors Miami.',15.00,20,17,2.5);

-- Montréal (dest 50)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(224,50,'Tour du Vieux-Montréal','Visite guidée du quartier colonial français avec guide francophone.',20.00,20,17,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(225,50,'Festival de Jazz ou Juste pour Rire','Accès aux concerts et spectacles du festival le plus important au monde.',0.00,100,90,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(226,50,'Randonnée Mont-Royal','Montée au sommet du mont qui domine Montréal avec vue panoramique.',0.00,30,27,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(227,50,'Poutine et gastronomie québécoise','Tour culinaire : poutine, tourtière, sirop d\'érable et fromages fins locaux.',45.00,15,12,3.0);

-- Los Angeles (dest 51)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(228,51,'Visite de Hollywood et Universal Studios','Journée à Universal Studios avec accès backstage et attractions blockbusters.',120.00,20,16,9.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(229,51,'Tour des maisons de stars à Beverly Hills','Balade en bus décapotable devant les villas des célébrités.',45.00,30,26,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(230,51,'Surf à Venice Beach','Cours de surf avec moniteur certifié sur la plage de Venice.',65.00,8,6,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(231,51,'Road trip Malibu et coucher de soleil','Balade en convertible le long de Pacific Coast Highway jusqu\'à Malibu.',85.00,4,3,4.0);

-- Sydney (dest 52)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(232,52,'BridgeClimb Harbour Bridge','Ascension guidée du Harbour Bridge avec vue 360° sur la baie de Sydney.',185.00,10,7,3.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(233,58,'Visite de l\'Opéra de Sydney','Tour des coulisses de l\'Opéra et concert dans la salle de concert.',45.00,20,17,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(234,52,'Excursion Blue Mountains','Journée dans les montagnes bleues avec les Trois Sœurs et forêt eucalyptus.',75.00,20,16,9.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(235,52,'Surf à Bondi Beach','Cours de surf sur la plage la plus célèbre d\'Australie.',60.00,10,8,2.0);

-- Buenos Aires (dest 53)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(236,53,'Cours de tango avec milonga','Cours en couple + soirée milonga dans un salon traditionnel de San Telmo.',45.00,15,12,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(237,53,'Tour des boulangeries et empanadas','Dégustation de la gastronomie argentine de rue dans le quartier de Palermo.',30.00,15,12,2.5);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(238,53,'Visite du stade Bombonera (Boca Juniors)','Tour du stade mythique du club le plus passionné du monde.',25.00,20,17,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(239,59,'Excursion à l\'Estancia','Journée dans un ranch argentin avec asado, cheval et folklore gaucho.',90.00,15,12,9.0);

-- Rio de Janeiro (dest 54)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(240,54,'Téléphérique du Pain de Sucre','Montée en téléphérique au sommet du Pão de Açúcar pour la vue mythique.',25.00,30,25,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(241,54,'Corcovado et Christ Rédempteur','Ascension au Christ Rédempteur en train à crémaillère dans la forêt tropicale.',35.00,25,20,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(242,60,'Cours de samba à l\'école de samba','Cours de samba avec les danseuses du Carnaval dans une vraie escola.',40.00,15,12,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(243,54,'Surf et Beach Volley à Ipanema','Cours de surf ou session de beach-volley sur la plage d\'Ipanema avec pro.',55.00,10,8,2.0);

-- Punta Cana (dest 55)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(244,55,'Excursion Isla Saona','Journée en catamaran vers l\'île paradisiaque de Saona avec buffet et open bar.',75.00,25,20,8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(245,61,'Plongée à l\'espace de plongée 7 Mares','Plongée dans les eaux claires des Caraïbes avec tortues et raies.',70.00,10,8,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(246,55,'Buggy dans la forêt dominicaine','Excursion en buggy 4x4 dans la nature, cascade et village typique.',65.00,12,10,4.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(247,55,'Kitesurfing à Cabarete','Cours de kitesurf sur la plage de Cabarete, capitale mondiale du kite.',85.00,8,6,3.0);

-- Koh Samui (dest 56)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(248,56,'Excursion Ang Thong National Park','Journée en bateau dans le parc marin de 42 îles avec kayak et snorkeling.',65.00,20,16,8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(249,56,'Full Moon Party Koh Phangan','Transport + entrée + open bar pour la fête mensuelle légendaire sur la plage.',40.00,25,20,8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(250,56,'Cours de muay thai à Chaweng','Session d\'entraînement avec boxeurs professionnels thaïlandais.',30.00,10,8,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(251,56,'Spa et massage traditionnel thaï','Journée spa avec massage thaï 2h, soin du visage et bain aux fleurs.',55.00,8,7,5.0);

-- Cap-Vert (dest 57)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(252,57,'Kitesurf à Santa Maria','Cours ou session de kitesurf dans les vents parfaits de Sal, paradis des kiteurs.',75.00,8,6,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(253,57,'Excursion à pied autour du volcan Pico do Fogo','Randonnée autour du volcan actif de l\'île de Fogo avec guide.',45.00,10,8,7.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(254,57,'Snorkeling et découverte marine','Sortie en bateau pour observer les tortues marines et fonds coralliens préservés.',40.00,15,12,3.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(255,57,'Soirée musique morna','Concert de musique créole morna dans un bar authentique de Mindelo (São Vicente).',15.00,25,21,3.0);

-- La Réunion (dest 58)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(256,58,'Randonnée au Piton de la Fournaise','Trek guidé jusqu\'au bord du volcan actif, l\'un des plus actifs au monde.',35.00,10,7,7.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(257,58,'Canyoning dans le cirque de Cilaos','Descente de cascades et toboggans naturels dans le cirque volcanique.',75.00,8,6,5.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(258,58,'Surf à Saint-Leu','Session de surf sur l\'un des meilleurs spots de l\'océan Indien.',40.00,10,8,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(259,58,'Vol en ULM au-dessus des cirques','Survol des cirques et du littoral réunionnais en ultra-léger motorisé.',95.00,2,2,1.5);

-- Cape Town (dest 59)
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(260,59,'Téléphérique Table Mountain','Montée au sommet de la montagne emblématique avec vue sur l\'océan et la ville.',25.00,30,26,2.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(261,59,'Safari en journée Réserve de Kapama','Safari dans une réserve proche avec lions, éléphants et girafes.',150.00,8,6,8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(262,59,'Tour du Cap et Cape Point','Excursion au bout de l\'Afrique avec rencontre des pingouins à Boulders Beach.',65.00,20,16,8.0);
INSERT IGNORE INTO activites (id,destination_id,nom,description,prix,capacite_max,places_restantes,duree_heures) VALUES
(263,59,'Dégustation dans les vignobles de Stellenbosch','Visite de 3 domaines viticoles avec accord mets et vins en plein air.',80.00,15,12,6.0);


-- ============================================================
-- DONNÉES — TRANSPORTS
-- ============================================================

-- Transports de base (IDs 1-6)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(1,'Air France','avion','Paris CDG','Bali DPS','2026-06-14 11:30:00','2026-06-27 11:30:00',789.00,50);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(2,'Qatar Airways','avion','Paris CDG','Bali DPS','2026-06-14 15:20:00','2026-06-28 15:20:00',672.00,40);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(4,'Eurostar','train','Paris','Londres','2026-07-01 08:00:00','2026-07-09 08:00:00',120.00,80);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(5,'Air France','avion','Paris CDG','Tokyo HND','2026-08-01 10:00:00','2026-08-15 10:00:00',1100.00,30);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(6,'TAP Portugal','avion','Paris CDG','Lisbonne','2026-09-15 07:30:00','2026-09-22 07:30:00',180.00,60);

-- TRANSPORTS (nouveaux uniquement, IDs 7+)
-- ============================================================

-- Avion : Paris → destinations plage
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(7,'Emirates','avion','Paris CDG','Malé MLE','2026-07-10 21:30:00','2026-07-23 21:30:00',1350.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(8,'Air Maldives','avion','Paris CDG','Malé MLE','2026-08-15 23:00:00','2026-08-29 23:00:00',1190.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(9,'Thai Airways','avion','Paris CDG','Phuket HKT','2026-07-12 22:00:00','2026-07-24 22:00:00',720.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(10,'Emirates','avion','Paris CDG','Phuket HKT','2026-08-05 08:30:00','2026-08-18 08:30:00',680.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(11,'Air France','avion','Paris CDG','Cancún CUN','2026-07-18 10:00:00','2026-08-01 10:00:00',650.00,240);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(12,'Iberia','avion','Paris CDG','Cancún CUN','2026-08-10 12:30:00','2026-08-22 12:30:00',590.00,220);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(13,'Air Seychelles','avion','Paris CDG','Mahé SEZ','2026-07-22 22:45:00','2026-08-04 22:45:00',980.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(14,'Emirates','avion','Paris CDG','Mahé SEZ','2026-08-12 20:00:00','2026-08-26 20:00:00',1050.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(15,'Ethiopian Air','avion','Paris CDG','Zanzibar ZNZ','2026-07-25 11:00:00','2026-08-06 11:00:00',620.00,240);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(16,'Kenya Airways','avion','Paris CDG','Zanzibar ZNZ','2026-08-20 09:00:00','2026-08-29 09:00:00',580.00,220);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(17,'Aegean Airlines','avion','Paris CDG','Mykonos JMK','2026-06-20 07:30:00','2026-06-30 07:30:00',220.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(18,'Air France','avion','Paris CDG','Mykonos JMK','2026-07-28 14:00:00','2026-08-08 14:00:00',280.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(19,'Vueling','avion','Paris ORY','Ibiza IBZ','2026-06-25 06:45:00','2026-07-03 06:45:00',110.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(20,'easyJet','avion','Paris CDG','Ibiza IBZ','2026-07-04 11:00:00','2026-07-13 11:00:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(21,'Air Tahiti Nui','avion','Paris CDG','Bora Bora BOB','2026-08-01 10:00:00','2026-08-13 10:00:00',1800.00,240);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(22,'Air Mauritius','avion','Paris CDG','Île Maurice MRU','2026-07-30 22:00:00','2026-08-12 22:00:00',750.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(23,'Air France','avion','Paris CDG','Île Maurice MRU','2026-08-25 21:00:00','2026-09-08 21:00:00',820.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(24,'Air France','avion','Paris CDG','Miami MIA','2026-07-08 10:30:00','2026-07-20 10:30:00',480.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(25,'American Airlines','avion','Paris CDG','Miami MIA','2026-08-18 09:00:00','2026-08-31 09:00:00',420.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(26,'Aegean Airlines','avion','Paris CDG','Santorini JTR','2026-06-15 06:00:00','2026-06-26 06:00:00',195.00,180);

-- Avion : Paris → destinations montagne/ville/culture/aventure
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(27,'Air France','avion','Paris CDG','Santorini JTR','2026-07-20 08:00:00','2026-08-01 08:00:00',245.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(28,'Vueling','avion','Paris ORY','Barcelone BCN','2026-07-01 07:00:00','2026-07-09 07:00:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(29,'Air France','avion','Paris CDG','Barcelone BCN','2026-08-05 18:00:00','2026-08-14 18:00:00',120.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(30,'KLM','avion','Paris CDG','Amsterdam AMS','2026-07-05 08:00:00','2026-07-12 08:00:00',110.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(31,'Singapore Airlines','avion','Paris CDG','Singapour SIN','2026-07-15 23:30:00','2026-07-28 23:30:00',880.00,280);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(32,'Air France','avion','Paris CDG','Singapour SIN','2026-08-10 22:00:00','2026-08-24 22:00:00',920.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(33,'Czech Airlines','avion','Paris CDG','Prague PRG','2026-06-10 07:00:00','2026-06-17 07:00:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(34,'easyJet','avion','Paris CDG','Prague PRG','2026-07-22 10:30:00','2026-07-30 10:30:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(35,'Emirates','avion','Paris CDG','Dubaï DXB','2026-07-10 14:00:00','2026-07-22 14:00:00',420.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(36,'Air France','avion','Paris CDG','Dubaï DXB','2026-08-01 08:30:00','2026-08-10 08:30:00',380.00,280);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(37,'Air France','avion','Paris CDG','New York JFK','2026-07-12 11:00:00','2026-07-22 11:00:00',520.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(38,'Delta Airlines','avion','Paris CDG','New York JFK','2026-08-15 14:00:00','2026-08-26 14:00:00',480.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(39,'Thai Airways','avion','Paris CDG','Bangkok BKK','2026-07-05 23:00:00','2026-07-17 23:00:00',610.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(40,'Air France','avion','Paris CDG','Bangkok BKK','2026-08-20 22:30:00','2026-09-02 22:30:00',650.00,260);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(41,'Royal Air Maroc','avion','Paris CDG','Marrakech RAK','2026-07-03 08:00:00','2026-07-13 08:00:00',95.00,200);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(42,'Transavia','avion','Paris ORY','Marrakech RAK','2026-08-14 06:30:00','2026-08-25 06:30:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(43,'ITA Airways','avion','Paris CDG','Rome FCO','2026-07-08 07:00:00','2026-07-16 07:00:00',90.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(44,'Vueling','avion','Paris ORY','Rome FCO','2026-08-22 14:00:00','2026-08-31 14:00:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(45,'Turkish Airlines','avion','Paris CDG','Istanbul IST','2026-07-10 07:30:00','2026-07-20 07:30:00',190.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(46,'Pegasus','avion','Paris CDG','Istanbul SAW','2026-08-05 11:00:00','2026-08-16 11:00:00',145.00,220);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(47,'Japan Airlines','avion','Paris CDG','Osaka KIX','2026-07-15 10:30:00','2026-07-29 10:30:00',1050.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(48,'ANA','avion','Paris CDG','Osaka KIX','2026-08-10 21:00:00','2026-08-22 21:00:00',1120.00,240);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(49,'EgyptAir','avion','Paris CDG','Le Caire CAI','2026-07-20 10:00:00','2026-07-30 10:00:00',280.00,220);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(50,'Air France','avion','Paris CDG','Le Caire CAI','2026-08-12 13:00:00','2026-08-23 13:00:00',320.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(51,'Icelandair','avion','Paris CDG','Reykjavik KEF','2026-07-18 07:00:00','2026-07-30 07:00:00',290.00,180);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(52,'easyJet','avion','Paris CDG','Reykjavik KEF','2026-08-08 06:30:00','2026-08-17 06:30:00',220.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(53,'Kenya Airways','avion','Paris CDG','Nairobi NBO','2026-07-14 23:45:00','2026-07-24 23:45:00',680.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(54,'Ethiopian Air','avion','Paris CDG','Nairobi NBO','2026-08-20 10:00:00','2026-08-31 10:00:00',610.00,240);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(55,'Iberia','avion','Paris CDG','San José SJO','2026-07-22 10:30:00','2026-08-04 10:30:00',720.00,220);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(56,'Air France','avion','Paris CDG','Buenos Aires EZE','2026-08-05 11:00:00','2026-08-19 11:00:00',950.00,250);

-- Train
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(57,'SNCF','train','Paris Gare de Lyon','Saint-Gervais (Chamonix)','2026-07-01 07:20:00','2026-07-08 07:20:00',55.00,400);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(58,'SNCF','train','Paris Gare de Lyon','Saint-Gervais (Chamonix)','2026-08-15 08:10:00','2026-08-23 08:10:00',65.00,400);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(59,'Thalys','train','Paris Gare du Nord','Amsterdam Centraal','2026-07-10 09:19:00','2026-07-19 09:19:00',85.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(60,'Eurostar','train','Paris Gare du Nord','Amsterdam Centraal','2026-08-01 10:31:00','2026-08-08 10:31:00',95.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(61,'SNCF Renfe','train','Paris Gare de Lyon','Barcelone Sants','2026-07-05 06:25:00','2026-07-13 06:25:00',80.00,350);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(62,'SNCF Renfe','train','Paris Gare de Lyon','Barcelone Sants','2026-08-20 08:13:00','2026-08-29 08:13:00',95.00,350);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(63,'DB SNCF','train','Paris Est','Prague hl.n.','2026-07-18 07:08:00','2026-07-25 07:08:00',120.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(64,'Trenitalia','train','Paris Gare de Lyon','Rome Termini','2026-08-02 07:30:00','2026-08-10 07:30:00',130.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(65,'CP Portugal','train','Paris Gare de Lyon','Porto Campanha','2026-07-08 10:00:00','2026-07-17 10:00:00',28.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(66,'SBB','train','Paris Gare de Lyon','Zermatt','2026-07-20 09:15:00','2026-07-27 09:15:00',62.00,200);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(67,'JR West','train','Paris Gare de Lyon','Kyoto','2026-07-16 08:00:00','2026-07-24 08:00:00',14.00,500);

-- Bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(68,'Flixbus','bus','Paris Bercy','Bruxelles Midi','2026-07-02 07:00:00','2026-07-11 07:00:00',15.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(69,'ALSA','bus','Paris Bercy Seine','Séville','2026-07-10 08:30:00','2026-07-17 08:30:00',25.00,50);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(70,'Peru Hop','bus','Paris Bercy Seine','Puno','2026-07-22 08:00:00','2026-07-30 08:00:00',35.00,45);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(71,'InterCity NZ','bus','Paris Bercy Seine','Te Anau','2026-08-10 08:00:00','2026-08-19 08:00:00',28.00,50);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(72,'Nakhon Chai Air','bus','Paris Bercy Seine','Chiang Mai','2026-07-15 21:00:00','2026-07-22 21:00:00',18.00,42);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(73,'CTM Maroc','bus','Paris Bercy Seine','Essaouira','2026-07-20 09:00:00','2026-07-28 09:00:00',12.00,45);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(74,'Metro Turizm','bus','Paris Bercy Seine','Göreme Cappadoce','2026-07-12 19:00:00','2026-07-21 19:00:00',22.00,45);

-- Bateau
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(75,'Hellenic Seaways','bateau','Paris Port de Grenelle','Santorin','2026-07-15 07:30:00','2026-07-22 07:30:00',65.00,400);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(76,'SeaJets','bateau','Paris Port de Grenelle','Santorin','2026-08-05 08:00:00','2026-08-13 08:00:00',90.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(77,'Balearia','bateau','Paris Port de Grenelle','Ibiza','2026-06-30 23:30:00','2026-07-09 23:30:00',55.00,600);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(78,'Trasmediterranea','bateau','Paris Port de Grenelle','Ibiza','2026-07-20 20:00:00','2026-07-27 20:00:00',50.00,500);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(79,'Aranui Cruises','bateau','Paris Port de Grenelle','Bora Bora','2026-08-10 10:00:00','2026-08-18 10:00:00',55.00,200);

INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(80,'DFDS Seaways','bateau','Paris Port de Grenelle','Newcastle','2026-07-25 17:00:00','2026-08-03 17:00:00',120.00,500);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(81,'Island Aviation','bateau','Paris Port de Grenelle','Atoll Baa','2026-07-12 14:00:00','2026-07-19 14:00:00',80.00,20);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(82,'Jadrolinija','bateau','Paris Port de Grenelle','Split','2026-08-01 16:00:00','2026-08-09 16:00:00',85.00,300);

-- TRANSPORTS DEPUIS PARIS (cohérents par destination)
-- ============================================================

-- ============================================================
-- EUROPÉENS PROCHES : avion + train + bus depuis Paris
-- ============================================================

-- Londres (dest 33) — Eurostar déjà en ID=3 dans schema.sql
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(84,'Eurostar','train','Paris Gare du Nord','London St Pancras','2026-07-08 09:01:00','2026-07-15 09:01:00',79.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(85,'Eurostar','train','Paris Gare du Nord','London St Pancras','2026-08-12 11:31:00','2026-08-20 11:31:00',95.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(86,'Air France','avion','Paris CDG','London Heathrow LHR','2026-07-15 07:00:00','2026-07-24 07:00:00',85.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(87,'easyJet','avion','Paris CDG','London Gatwick LGW','2026-08-20 06:30:00','2026-08-27 06:30:00',65.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(88,'Flixbus','bus','Paris Bercy Seine','London Victoria','2026-07-10 07:00:00','2026-07-18 07:00:00',25.00,55);

-- Berlin (dest 34) — avion + train (Nightjet) + bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(89,'Air France','avion','Paris CDG','Berlin BER','2026-07-05 07:30:00','2026-07-14 07:30:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(90,'easyJet','avion','Paris CDG','Berlin BER','2026-08-10 06:00:00','2026-08-17 06:00:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(91,'DB Nightjet','train','Paris Est','Berlin Hbf','2026-07-20 22:17:00','2026-07-28 22:17:00',89.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(92,'Flixbus','bus','Paris Bercy Seine','Berlin ZOB','2026-07-15 08:00:00','2026-07-24 08:00:00',35.00,55);

-- Vienne (dest 35) — avion + train (Nightjet)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(93,'Air France','avion','Paris CDG','Vienne VIE','2026-07-08 08:00:00','2026-07-15 08:00:00',110.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(94,'Austrian Airlines','avion','Paris CDG','Vienne VIE','2026-08-15 07:00:00','2026-08-23 07:00:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(95,'DB Nightjet','train','Paris Est','Wien Hbf','2026-07-22 22:25:00','2026-07-31 22:25:00',99.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(96,'Flixbus','bus','Paris Bercy Seine','Wien Erdberg','2026-07-18 07:30:00','2026-07-25 07:30:00',45.00,55);

-- Madrid (dest 36) — avion + train TGV/Renfe + bus nuit
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(97,'Air France','avion','Paris CDG','Madrid MAD','2026-07-01 07:30:00','2026-07-09 07:30:00',90.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(98,'Iberia','avion','Paris CDG','Madrid MAD','2026-08-05 08:00:00','2026-08-14 08:00:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(99,'SNCF Renfe','train','Paris Montparnasse','Madrid Chamartin','2026-07-10 09:30:00','2026-07-17 09:30:00',120.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(100,'Flixbus','bus','Paris Bercy Seine','Madrid Sur','2026-07-20 19:00:00','2026-07-28 19:00:00',49.00,55);

-- Bruxelles (dest 37) — avion + Thalys + bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(101,'Thalys','train','Paris Gare du Nord','Bruxelles Midi','2026-07-05 09:25:00','2026-07-14 09:25:00',45.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(102,'Thalys','train','Paris Gare du Nord','Bruxelles Midi','2026-08-12 12:55:00','2026-08-19 12:55:00',55.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(103,'Brussels Airlines','avion','Paris CDG','Bruxelles BRU','2026-07-15 07:30:00','2026-07-23 07:30:00',70.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(104,'Flixbus','bus','Paris Gallieni','Bruxelles Nord','2026-07-08 08:00:00','2026-07-17 08:00:00',12.00,55);

-- Copenhague (dest 38) — avion uniquement (train trop long)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(105,'Air France','avion','Paris CDG','Copenhague CPH','2026-07-10 07:30:00','2026-07-17 07:30:00',140.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(106,'SAS','avion','Paris CDG','Copenhague CPH','2026-08-20 08:00:00','2026-08-28 08:00:00',120.00,180);

-- Stockholm (dest 39) — avion + bus très long
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(107,'Air France','avion','Paris CDG','Stockholm ARN','2026-07-12 08:30:00','2026-07-21 08:30:00',160.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(108,'SAS','avion','Paris CDG','Stockholm ARN','2026-08-18 07:00:00','2026-08-25 07:00:00',140.00,180);

-- Budapest (dest 40) — avion + train (Nightjet) + bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(109,'Air France','avion','Paris CDG','Budapest BUD','2026-07-08 08:00:00','2026-07-16 08:00:00',105.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(110,'Wizz Air','avion','Paris ORY','Budapest BUD','2026-08-10 06:30:00','2026-08-19 06:30:00',65.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(111,'DB Nightjet','train','Paris Est','Budapest Keleti','2026-07-20 21:33:00','2026-07-27 21:33:00',109.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(112,'Flixbus','bus','Paris Bercy Seine','Budapest Nepliget','2026-07-15 08:00:00','2026-07-23 08:00:00',55.00,55);

-- Athènes (dest 41) — avion uniquement depuis Paris
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(113,'Air France','avion','Paris CDG','Athènes ATH','2026-07-10 08:30:00','2026-07-20 08:30:00',145.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(114,'Aegean Airlines','avion','Paris CDG','Athènes ATH','2026-08-15 09:00:00','2026-08-26 09:00:00',120.00,180);

-- Florence (dest 42) — avion + train (TGV Paris-Florence)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(115,'Vueling','avion','Paris ORY','Florence FLR','2026-07-05 07:00:00','2026-07-13 07:00:00',85.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(116,'Air France','avion','Paris CDG','Pise PSA','2026-08-10 08:30:00','2026-08-19 08:30:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(117,'Trenitalia','train','Paris Gare de Lyon','Florence SMN','2026-07-15 07:15:00','2026-07-22 07:15:00',110.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(118,'Flixbus','bus','Paris Bercy Seine','Florence SITA','2026-07-20 07:00:00','2026-07-28 07:00:00',45.00,55);

-- Porto (dest 43) — avion + bus nuit (pas de train direct Paris-Porto)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(119,'TAP Portugal','avion','Paris CDG','Porto OPO','2026-07-08 07:30:00','2026-07-17 07:30:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(120,'Ryanair','avion','Paris Beauvais','Porto OPO','2026-08-12 06:30:00','2026-08-19 06:30:00',55.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(121,'Flixbus','bus','Paris Bercy Seine','Porto Campo 24 Agosto','2026-07-20 09:00:00','2026-07-28 09:00:00',49.00,55);

-- Sintra (dest 44) — via Lisbonne (avion + bus depuis Lisbonne)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(122,'TAP Portugal','avion','Paris CDG','Lisbonne LIS','2026-07-10 07:00:00','2026-07-19 07:00:00',90.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(123,'easyJet','avion','Paris CDG','Lisbonne LIS','2026-08-05 06:30:00','2026-08-12 06:30:00',75.00,180);

-- ============================================================
-- INTERNATIONAUX LOINTAINS : avion uniquement depuis Paris
-- ============================================================

-- Séoul (dest 45)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(124,'Korean Air','avion','Paris CDG','Séoul ICN','2026-07-10 13:30:00','2026-07-23 13:30:00',850.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(125,'Air France','avion','Paris CDG','Séoul ICN','2026-08-15 10:00:00','2026-08-29 10:00:00',920.00,280);

-- Hong Kong (dest 46)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(126,'Cathay Pacific','avion','Paris CDG','Hong Kong HKG','2026-07-12 22:00:00','2026-07-24 22:00:00',780.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(127,'Air France','avion','Paris CDG','Hong Kong HKG','2026-08-10 21:30:00','2026-08-23 21:30:00',850.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(160,'Air France','avion','Paris CDG','Hong Kong HKG','2026-07-10 13:30:00','2026-07-23 13:30:00',850.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(161,'Air France','avion','Paris CDG','Hong Kong HKG','2026-08-15 10:00:00','2026-08-29 10:00:00',920.00,280);

-- Kuala Lumpur (dest 47)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(128,'Malaysia Airlines','avion','Paris CDG','Kuala Lumpur KUL','2026-07-15 21:00:00','2026-07-29 21:00:00',720.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(129,'Qatar Airways','avion','Paris CDG','Kuala Lumpur KUL','2026-08-20 23:00:00','2026-09-01 23:00:00',680.00,280);


-- Hanoï (dest 48)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(130,'Vietnam Airlines','avion','Paris CDG','Hanoï HAN','2026-07-08 22:30:00','2026-07-21 22:30:00',680.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(131,'Air France','avion','Paris CDG','Hanoï HAN','2026-08-12 21:00:00','2026-08-26 21:00:00',750.00,280);

-- Mumbai (dest 49)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(132,'Air India','avion','Paris CDG','Mumbai BOM','2026-07-10 21:30:00','2026-07-19 21:30:00',580.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(133,'Air France','avion','Paris CDG','Mumbai BOM','2026-08-15 22:00:00','2026-08-25 22:00:00',620.00,280);

-- Montréal (dest 50)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(134,'Air Transat','avion','Paris CDG','Montréal YUL','2026-07-05 11:00:00','2026-07-16 11:00:00',420.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(135,'Air France','avion','Paris CDG','Montréal YUL','2026-08-10 10:30:00','2026-08-22 10:30:00',480.00,280);

-- Los Angeles (dest 51)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(136,'Air France','avion','Paris CDG','Los Angeles LAX','2026-07-12 10:00:00','2026-07-25 10:00:00',580.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(137,'Delta Airlines','avion','Paris CDG','Los Angeles LAX','2026-08-18 11:00:00','2026-09-01 11:00:00',520.00,280);

-- Sydney (dest 52)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(138,'Qantas','avion','Paris CDG','Sydney SYD','2026-07-15 22:00:00','2026-07-27 22:00:00',1350.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(139,'Air France','avion','Paris CDG','Sydney SYD','2026-08-20 21:30:00','2026-09-02 21:30:00',1450.00,280);

-- Buenos Aires (dest 53)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(140,'Air France','avion','Paris CDG','Buenos Aires EZE','2026-07-10 11:00:00','2026-07-24 11:00:00',880.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(141,'Aerolíneas Argentinas','avion','Paris CDG','Buenos Aires EZE','2026-08-05 12:00:00','2026-08-17 12:00:00',820.00,280);

-- Rio de Janeiro (dest 54)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(142,'Air France','avion','Paris CDG','Rio de Janeiro GIG','2026-07-08 10:30:00','2026-07-21 10:30:00',820.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(143,'Latam Airlines','avion','Paris CDG','Rio de Janeiro GIG','2026-08-12 11:00:00','2026-08-26 11:00:00',780.00,280);

-- Punta Cana (dest 55)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(144,'Corsair','avion','Paris ORY','Punta Cana PUJ','2026-07-05 10:00:00','2026-07-17 10:00:00',580.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(145,'Air France','avion','Paris CDG','Punta Cana PUJ','2026-08-10 09:30:00','2026-08-23 09:30:00',650.00,280);

-- Koh Samui (dest 56) — via Bangkok
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(146,'Bangkok Airways','avion','Paris CDG','Koh Samui USM','2026-07-10 22:00:00','2026-07-24 22:00:00',780.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(147,'Thai Airways','avion','Paris CDG','Koh Samui USM','2026-08-15 21:00:00','2026-08-27 21:00:00',720.00,200);

-- Cap-Vert (dest 57)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(148,'TACV / Cabo Verde Airlines','avion','Paris CDG','Sal SID','2026-07-12 22:00:00','2026-07-21 22:00:00',420.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(149,'Transavia','avion','Paris ORY','Sal SID','2026-08-08 21:30:00','2026-08-18 21:30:00',380.00,180);

-- La Réunion (dest 58)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(150,'Air France','avion','Paris CDG','Saint-Denis RUN','2026-07-15 22:30:00','2026-07-27 22:30:00',580.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(151,'Corsair','avion','Paris ORY','Saint-Denis RUN','2026-08-20 21:00:00','2026-09-02 21:00:00',520.00,250);

-- Cape Town (dest 59)
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(152,'Air France','avion','Paris CDG','Cape Town CPT','2026-07-10 22:00:00','2026-07-24 22:00:00',850.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(153,'South African Airways','avion','Paris CDG','Cape Town CPT','2026-08-15 20:00:00','2026-08-27 20:00:00',780.00,280);

-- ============================================================
-- TRANSPORTS MANQUANTS POUR DESTINATIONS EXISTANTES
-- (Lisbonne bus, Barcelone ferry, etc.)
-- ============================================================

-- Lisbonne (dest 4) — ajout bus Flixbus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(154,'Flixbus','bus','Paris Bercy Seine','Lisbonne Sete Rios','2026-07-08 08:00:00','2026-07-16 08:00:00',45.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(155,'ALSA','bus','Paris Bercy Seine','Lisbonne Oriente','2026-08-15 09:00:00','2026-08-24 09:00:00',55.00,55);

-- Chamonix (dest 11) — ajout bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(156,'Flixbus','bus','Paris Bercy Seine','Chamonix gare routière','2026-07-05 07:30:00','2026-07-12 07:30:00',25.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(157,'Ouibus','bus','Paris Bercy Seine','Chamonix gare routière','2026-08-10 08:00:00','2026-08-18 08:00:00',22.00,55);

-- Interlaken (dest 3) — ajout bus
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(158,'Flixbus','bus','Paris Bercy Seine','Interlaken gare','2026-07-10 07:00:00','2026-07-19 07:00:00',35.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(159,'Flixbus','bus','Paris Bercy Seine','Interlaken gare','2026-08-20 07:00:00','2026-08-27 07:00:00',40.00,55);

-- ============================================================
--  VoyageVista — Ajout de transports
--  Objectif : ~10 transports par destination (IDs 160-603)
--  Format : INSERT individuel pour compatibilité phpMyAdmin
--  Point de départ : dernier ID existant = 159
-- ============================================================

SET NAMES utf8mb4;
SET foreign_key_checks = 0;
USE voyagevista;


-- DEST 1 — Maldives (existant : 7, 8 → +8 transports)
-- Seul accès réaliste : avion long-courrier via hub (Dubai, Doha, Sri Lanka...)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(160,'Qatar Airways','avion','Paris CDG','Malé MLE','2026-07-05 20:30:00','2026-07-18 20:30:00',1180.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(161,'Turkish Airlines','avion','Paris CDG','Malé MLE','2026-07-20 22:00:00','2026-08-03 22:00:00',1090.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(162,'Sri Lankan Airlines','avion','Paris CDG','Malé MLE','2026-08-01 21:00:00','2026-08-13 21:00:00',1050.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(163,'Etihad Airways','avion','Paris CDG','Malé MLE','2026-08-10 19:30:00','2026-08-23 19:30:00',1120.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(164,'Emirates','avion','Paris CDG','Malé MLE','2026-09-05 21:30:00','2026-09-19 21:30:00',1350.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(165,'Air France','avion','Paris CDG','Malé MLE','2026-07-15 22:00:00','2026-07-27 22:00:00',1280.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(166,'Maldivian','avion','Paris CDG','Malé MLE (transfert Atoll Nord)','2026-07-11 10:00:00','2026-07-24 10:00:00',85.00,30);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(167,'Trans Maldivian Airways','bateau','Paris Port de Grenelle','Atoll Ari','2026-07-12 14:00:00','2026-07-21 14:00:00',60.00,14);

-- DEST 2 — Phuket (existant : 9, 10 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(168,'Qatar Airways','avion','Paris CDG','Phuket HKT','2026-07-08 20:00:00','2026-07-20 20:00:00',690.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(169,'Turkish Airlines','avion','Paris CDG','Phuket HKT','2026-07-18 22:15:00','2026-07-31 22:15:00',650.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(170,'Malaysia Airlines','avion','Paris CDG','Phuket HKT','2026-08-12 23:00:00','2026-08-26 23:00:00',670.00,260);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(171,'Singapore Airlines','avion','Paris CDG','Phuket HKT','2026-08-20 22:30:00','2026-09-01 22:30:00',710.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(172,'Air France','avion','Paris CDG','Phuket HKT','2026-09-01 21:00:00','2026-09-14 21:00:00',740.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(173,'Lufthansa','avion','Paris CDG','Phuket HKT','2026-07-25 19:00:00','2026-08-08 19:00:00',660.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(174,'Bangkok Airways','avion','Paris CDG','Phuket HKT','2026-07-07 10:00:00','2026-07-19 10:00:00',65.00,120);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(175,'Thai Lion Air','avion','Paris CDG','Phuket HKT','2026-08-15 14:30:00','2026-08-28 14:30:00',45.00,180);

-- DEST 3 — Cancún (existant : 11, 12 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(176,'Air Transat','avion','Paris CDG','Cancún CUN','2026-07-04 11:30:00','2026-07-18 11:30:00',610.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(177,'Corsair','avion','Paris ORY','Cancún CUN','2026-07-15 10:00:00','2026-07-27 10:00:00',580.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(178,'Condor','avion','Paris CDG','Cancún CUN','2026-08-01 12:00:00','2026-08-14 12:00:00',560.00,260);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(179,'TUI Airways','avion','Paris CDG','Cancún CUN','2026-08-08 10:30:00','2026-08-22 10:30:00',600.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(180,'Aeromexico','avion','Paris CDG','Cancún CUN','2026-08-25 12:00:00','2026-09-06 12:00:00',640.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(181,'United Airlines','avion','Paris CDG','Cancún CUN','2026-09-05 11:00:00','2026-09-18 11:00:00',590.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(182,'Volaris','avion','Paris CDG','Cancún CUN','2026-07-19 08:00:00','2026-08-02 08:00:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(183,'Vivaaerobus','avion','Paris CDG','Cancún CUN','2026-08-11 07:30:00','2026-08-23 07:30:00',60.00,180);

-- DEST 4 — Seychelles (existant : 13, 14 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(184,'Turkish Airlines','avion','Paris CDG','Mahé SEZ','2026-07-08 22:30:00','2026-07-21 22:30:00',920.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(185,'Condor','avion','Paris CDG','Mahé SEZ','2026-07-20 23:00:00','2026-08-03 23:00:00',890.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(186,'Corsair','avion','Paris ORY','Mahé SEZ','2026-08-05 21:00:00','2026-08-17 21:00:00',850.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(187,'Qatar Airways','avion','Paris CDG','Mahé SEZ','2026-08-18 20:00:00','2026-08-31 20:00:00',960.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(188,'Etihad Airways','avion','Paris CDG','Mahé SEZ','2026-09-01 19:30:00','2026-09-15 19:30:00',910.00,260);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(189,'Kenya Airways','avion','Paris CDG','Mahé SEZ','2026-07-14 11:00:00','2026-07-26 11:00:00',870.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(190,'Air Seychelles','avion','Paris CDG','Praslin PRI','2026-07-23 11:00:00','2026-08-05 11:00:00',55.00,30);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(191,'Cat Cocos','bateau','Paris Port de Grenelle','Praslin','2026-07-24 09:30:00','2026-08-02 09:30:00',40.00,200);

-- DEST 5 — Zanzibar (existant : 15, 16 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(192,'Turkish Airlines','avion','Paris CDG','Zanzibar ZNZ','2026-07-10 21:00:00','2026-07-19 21:00:00',600.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(193,'Qatar Airways','avion','Paris CDG','Zanzibar ZNZ','2026-07-28 20:30:00','2026-08-07 20:30:00',630.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(194,'Air France','avion','Paris CDG','Dar es Salaam DAR','2026-08-05 11:00:00','2026-08-16 11:00:00',590.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(195,'Corsair','avion','Paris ORY','Zanzibar ZNZ','2026-08-14 22:00:00','2026-08-26 22:00:00',570.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(196,'Condor','avion','Paris CDG','Zanzibar ZNZ','2026-08-28 21:30:00','2026-09-06 21:30:00',560.00,260);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(197,'Oman Air','avion','Paris CDG','Zanzibar ZNZ','2026-07-18 22:00:00','2026-07-28 22:00:00',610.00,240);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(198,'Precision Air','avion','Paris CDG','Zanzibar ZNZ','2026-08-06 09:00:00','2026-08-17 09:00:00',35.00,70);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(199,'Azam Marine','bateau','Paris Port de Grenelle','Zanzibar Town','2026-07-26 08:00:00','2026-08-03 08:00:00',15.00,250);

-- DEST 6 — Mykonos (existant : 17, 18, 75, 76 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(200,'easyJet','avion','Paris CDG','Mykonos JMK','2026-07-05 07:00:00','2026-07-14 07:00:00',195.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(201,'Volotea','avion','Paris ORY','Mykonos JMK','2026-07-15 06:30:00','2026-07-25 06:30:00',175.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(202,'Ryanair','avion','Paris Beauvais','Mykonos JMK','2026-08-01 06:00:00','2026-08-12 06:00:00',145.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(203,'Transavia','avion','Paris ORY','Mykonos JMK','2026-08-10 07:00:00','2026-08-22 07:00:00',180.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(204,'Golden Star Ferries','bateau','Paris Port de Grenelle','Mykonos','2026-07-16 07:00:00','2026-07-23 07:00:00',55.00,400);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(205,'SeaJets','bateau','Paris Port de Grenelle','Mykonos','2026-08-12 08:30:00','2026-08-20 08:30:00',70.00,250);

-- DEST 7 — Ibiza (existant : 19, 20, 77, 78 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(206,'Ryanair','avion','Paris Beauvais','Ibiza IBZ','2026-07-02 06:00:00','2026-07-11 06:00:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(207,'Transavia','avion','Paris ORY','Ibiza IBZ','2026-07-10 07:30:00','2026-07-17 07:30:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(208,'Jet2','avion','Paris CDG','Ibiza IBZ','2026-07-22 08:00:00','2026-07-30 08:00:00',110.00,160);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(209,'Air France','avion','Paris CDG','Ibiza IBZ','2026-08-15 18:00:00','2026-08-24 18:00:00',130.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(210,'Balearia','bateau','Paris Port de Grenelle','Ibiza','2026-07-05 23:00:00','2026-07-12 23:00:00',45.00,600);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(211,'Acciona Trasmediterranea','bateau','Paris Port de Grenelle','Ibiza','2026-08-08 21:30:00','2026-08-16 21:30:00',50.00,500);

-- DEST 8 — Bora Bora (existant : 21, 79 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(212,'Air Tahiti Nui','avion','Paris CDG','Bora Bora BOB','2026-07-05 10:30:00','2026-07-19 10:30:00',1750.00,240);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(213,'Air Tahiti Nui','avion','Paris CDG','Papeete FAA','2026-07-20 10:00:00','2026-08-01 10:00:00',1600.00,240);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(214,'French Bee','avion','Paris ORY','Papeete FAA','2026-08-05 11:00:00','2026-08-18 11:00:00',1400.00,350);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(215,'French Bee','avion','Paris ORY','Papeete FAA','2026-08-20 11:30:00','2026-09-03 11:30:00',1450.00,350);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(216,'Air France','avion','Paris CDG','Papeete FAA','2026-09-01 10:00:00','2026-09-13 10:00:00',1700.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(217,'Air Tahiti','avion','Paris CDG','Bora Bora BOB','2026-07-22 14:00:00','2026-08-04 14:00:00',75.00,48);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(218,'Air Tahiti','avion','Paris CDG','Bora Bora BOB','2026-08-07 10:00:00','2026-08-21 10:00:00',75.00,48);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(219,'Aranui Cruises','bateau','Paris Port de Grenelle','Bora Bora','2026-07-15 10:00:00','2026-07-22 10:00:00',60.00,200);

-- DEST 9 — Île Maurice (existant : 22, 23 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(220,'Emirates','avion','Paris CDG','Île Maurice MRU','2026-07-08 20:30:00','2026-07-21 20:30:00',780.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(221,'Turkish Airlines','avion','Paris CDG','Île Maurice MRU','2026-07-22 22:00:00','2026-08-05 22:00:00',720.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(222,'Qatar Airways','avion','Paris CDG','Île Maurice MRU','2026-08-05 20:00:00','2026-08-17 20:00:00',760.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(223,'Corsair','avion','Paris ORY','Île Maurice MRU','2026-08-18 21:30:00','2026-08-31 21:30:00',690.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(224,'Condor','avion','Paris CDG','Île Maurice MRU','2026-08-29 22:00:00','2026-09-12 22:00:00',670.00,260);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(225,'Kenya Airways','avion','Paris CDG','Île Maurice MRU','2026-07-15 10:30:00','2026-07-27 10:30:00',700.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(226,'Ethiopian Airlines','avion','Paris CDG','Île Maurice MRU','2026-08-12 11:00:00','2026-08-25 11:00:00',680.00,240);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(227,'Edelweiss Air','avion','Paris CDG','Île Maurice MRU','2026-09-02 21:00:00','2026-09-16 21:00:00',710.00,260);

-- DEST 10 — Miami Beach (existant : 24, 25 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(228,'United Airlines','avion','Paris CDG','Miami MIA','2026-07-05 11:30:00','2026-07-17 11:30:00',460.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(229,'Norwegian','avion','Paris CDG','Miami MIA','2026-07-15 12:00:00','2026-07-28 12:00:00',430.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(230,'British Airways','avion','Paris CDG','Miami MIA','2026-07-28 10:00:00','2026-08-11 10:00:00',490.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(231,'Iberia','avion','Paris CDG','Miami MIA','2026-08-10 11:00:00','2026-08-22 11:00:00',450.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(232,'Lufthansa','avion','Paris CDG','Miami MIA','2026-08-20 09:30:00','2026-09-02 09:30:00',470.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(233,'Air France','avion','Paris CDG','Fort Lauderdale FLL','2026-07-20 10:00:00','2026-08-03 10:00:00',440.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(234,'American Airlines','avion','Paris CDG','Miami MIA','2026-09-01 10:00:00','2026-09-13 10:00:00',420.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(235,'Corsair','avion','Paris ORY','Miami MIA','2026-08-05 11:30:00','2026-08-18 11:30:00',400.00,270);

-- DEST 11 — Chamonix (existant : 57, 58, 156, 157 → +6 transports)
-- Accès France : TGV Paris-Saint-Gervais + bus + voiture
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(236,'SNCF','train','Paris Gare de Lyon','Saint-Gervais (Chamonix)','2026-07-15 09:07:00','2026-07-24 09:07:00',58.00,400);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(237,'SNCF','train','Paris Gare de Lyon','Saint-Gervais (Chamonix)','2026-07-25 07:20:00','2026-08-01 07:20:00',62.00,400);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(238,'SNCF','train','Paris Gare de Lyon','Saint-Gervais (Chamonix)','2026-08-01 08:00:00','2026-08-09 08:00:00',72.00,400);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(239,'SNCF','train','Paris Gare de Lyon','Saint-Gervais (Chamonix)','2026-08-22 11:10:00','2026-08-31 11:10:00',55.00,400);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(240,'Flixbus','bus','Paris Bercy Seine','Chamonix gare routière','2026-07-18 07:30:00','2026-07-25 07:30:00',28.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(241,'Flixbus','bus','Paris Bercy Seine','Chamonix gare routière','2026-08-05 07:30:00','2026-08-13 07:30:00',32.00,55);

-- DEST 12 — Queenstown (existant : 71 bus local → +9 transports)
-- Seul accès Paris : avion long-courrier (via Sydney, Auckland, Singapore)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(242,'Air New Zealand','avion','Paris CDG','Queenstown ZQN','2026-07-08 22:00:00','2026-07-22 22:00:00',1450.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(243,'Qantas','avion','Paris CDG','Queenstown ZQN','2026-07-20 21:00:00','2026-08-01 21:00:00',1380.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(244,'Singapore Airlines','avion','Paris CDG','Queenstown ZQN','2026-08-01 22:30:00','2026-08-14 22:30:00',1420.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(245,'Emirates','avion','Paris CDG','Queenstown ZQN','2026-08-12 20:30:00','2026-08-26 20:30:00',1350.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(246,'Air France','avion','Paris CDG','Auckland AKL','2026-07-15 22:00:00','2026-07-27 22:00:00',1500.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(247,'Cathay Pacific','avion','Paris CDG','Queenstown ZQN','2026-08-20 21:00:00','2026-09-02 21:00:00',1360.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(248,'Air New Zealand','avion','Paris CDG','Queenstown ZQN','2026-07-17 10:00:00','2026-07-31 10:00:00',95.00,120);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(249,'Jetstar','avion','Paris CDG','Queenstown ZQN','2026-08-14 11:00:00','2026-08-26 11:00:00',75.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(250,'InterCity NZ','bus','Paris Bercy Seine','Christchurch','2026-07-22 07:30:00','2026-07-30 07:30:00',45.00,50);

-- DEST 13 — Zermatt (existant : 66 train local → +9 transports)
-- Accès : TGV Paris-Lausanne ou Paris-Genève puis train ; aussi avion vers Genève
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(251,'SNCF TGV Lyria','train','Paris Gare de Lyon','Lausanne','2026-07-05 09:04:00','2026-07-14 09:04:00',75.00,350);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(252,'SNCF TGV Lyria','train','Paris Gare de Lyon','Genève','2026-07-12 07:06:00','2026-07-19 07:06:00',68.00,350);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(253,'SNCF TGV Lyria','train','Paris Gare de Lyon','Genève','2026-08-05 09:06:00','2026-08-13 09:06:00',72.00,350);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(254,'SNCF TGV Lyria','train','Paris Gare de Lyon','Lausanne','2026-08-18 11:04:00','2026-08-27 11:04:00',80.00,350);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(255,'SBB','train','Paris Gare de Lyon','Viège (Visp)','2026-07-13 10:00:00','2026-07-20 10:00:00',35.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(256,'SBB','train','Paris Gare de Lyon','Zermatt','2026-07-13 12:02:00','2026-07-21 12:02:00',22.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(257,'Air France','avion','Paris CDG','Genève GVA','2026-07-10 07:00:00','2026-07-19 07:00:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(258,'easyJet','avion','Paris CDG','Genève GVA','2026-08-08 06:30:00','2026-08-15 06:30:00',65.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(259,'Swiss','avion','Paris CDG','Genève GVA','2026-08-22 07:30:00','2026-08-30 07:30:00',95.00,180);

-- DEST 14 — Dolomites (existant : aucun → +10 transports)
-- Accès : avion Paris-Venise ou Paris-Vérone, puis train/bus vers Cortina
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(260,'Air France','avion','Paris CDG','Venise VCE','2026-07-05 07:30:00','2026-07-14 07:30:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(261,'easyJet','avion','Paris CDG','Venise VCE','2026-07-15 06:45:00','2026-07-22 06:45:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(262,'Vueling','avion','Paris ORY','Venise VCE','2026-08-05 07:00:00','2026-08-13 07:00:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(263,'Transavia','avion','Paris ORY','Venise VCE','2026-08-18 08:00:00','2026-08-27 08:00:00',85.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(264,'Ryanair','avion','Paris Beauvais','Venise Trévise TSF','2026-07-20 06:00:00','2026-07-27 06:00:00',55.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(265,'Ryanair','avion','Paris Beauvais','Vérone VRN','2026-08-10 06:30:00','2026-08-18 06:30:00',60.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(266,'Trenitalia','train','Paris Gare de Lyon','Venise Santa Lucia','2026-07-08 07:30:00','2026-07-17 07:30:00',120.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(267,'Flixbus','bus','Paris Bercy Seine','Venise Tronchetto','2026-07-22 07:00:00','2026-07-29 07:00:00',40.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(268,'SAD','bus','Paris Bercy Seine','Cortina d\'Ampezzo','2026-07-06 09:30:00','2026-07-14 09:30:00',18.00,60);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(269,'SAD','bus','Paris Bercy Seine','Cortina d\'Ampezzo','2026-08-06 09:30:00','2026-08-15 09:30:00',18.00,60);

-- DEST 15 — Tromsø (existant : aucun → +10 transports)
-- Accès : avion Paris-Tromsø (escale Oslo/Copenhagen/Stockholm)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(270,'SAS','avion','Paris CDG','Tromsø TOS','2026-07-08 07:30:00','2026-07-19 07:30:00',280.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(271,'Norwegian','avion','Paris CDG','Tromsø TOS','2026-07-20 06:00:00','2026-08-01 06:00:00',240.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(272,'Air France','avion','Paris CDG','Tromsø TOS','2026-08-05 07:00:00','2026-08-14 07:00:00',310.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(273,'SAS','avion','Paris CDG','Tromsø TOS','2026-08-15 08:30:00','2026-08-25 08:30:00',265.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(274,'Norwegian','avion','Paris CDG','Tromsø TOS','2026-09-01 06:30:00','2026-09-12 06:30:00',230.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(275,'Norwegian','avion','Paris CDG','Tromsø TOS','2026-07-09 09:00:00','2026-07-21 09:00:00',75.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(276,'SAS','avion','Paris CDG','Tromsø TOS','2026-08-06 10:00:00','2026-08-15 10:00:00',85.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(277,'Widerøe','avion','Paris CDG','Tromsø TOS','2026-08-20 08:30:00','2026-08-30 08:30:00',90.00,70);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(278,'Norwegian','avion','Paris CDG','Tromsø TOS','2026-07-15 09:00:00','2026-07-26 09:00:00',95.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(279,'Widerøe','avion','Paris CDG','Tromsø TOS','2026-08-10 09:30:00','2026-08-22 09:30:00',85.00,70);

-- DEST 16 — Aspen (existant : aucun → +10 transports)
-- Accès : avion Paris-Denver ou Paris-Chicago puis correspondance Aspen (ASE)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(280,'Air France','avion','Paris CDG','Denver DEN','2026-07-08 10:00:00','2026-07-21 10:00:00',560.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(281,'United Airlines','avion','Paris CDG','Denver DEN','2026-07-20 11:00:00','2026-08-03 11:00:00',530.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(282,'Delta Airlines','avion','Paris CDG','Chicago ORD','2026-08-05 10:30:00','2026-08-16 10:30:00',510.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(283,'American Airlines','avion','Paris CDG','Denver DEN','2026-08-15 12:00:00','2026-08-28 12:00:00',540.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(284,'Air France','avion','Paris CDG','Denver DEN','2026-09-01 10:00:00','2026-09-15 10:00:00',570.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(285,'United Airlines','avion','Paris CDG','Aspen ASE','2026-07-09 08:00:00','2026-07-21 08:00:00',120.00,38);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(286,'United Express','avion','Paris CDG','Aspen ASE','2026-07-21 09:00:00','2026-08-03 09:00:00',130.00,38);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(287,'American Eagle','avion','Paris CDG','Aspen ASE','2026-08-06 08:30:00','2026-08-20 08:30:00',150.00,44);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(288,'Epic Mountain Express','bus','Paris Bercy Seine','Aspen','2026-07-09 14:00:00','2026-07-16 14:00:00',65.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(289,'RFTA','bus','Paris Bercy Seine','Aspen','2026-07-22 09:00:00','2026-07-30 09:00:00',8.00,55);

-- DEST 17 — Barcelone (existant : 28, 29, 61, 62 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(290,'Ryanair','avion','Paris Beauvais','Barcelone BCN','2026-07-08 06:00:00','2026-07-17 06:00:00',60.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(291,'Transavia','avion','Paris ORY','Barcelone BCN','2026-07-18 07:30:00','2026-07-25 07:30:00',85.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(292,'easyJet','avion','Paris CDG','Barcelone BCN','2026-08-12 06:30:00','2026-08-20 06:30:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(293,'Iberia','avion','Paris CDG','Barcelone BCN','2026-08-25 09:00:00','2026-09-03 09:00:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(294,'Balearia','bateau','Paris Port de Grenelle','Mahon Minorque','2026-07-10 09:00:00','2026-07-17 09:00:00',50.00,500);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(295,'Flixbus','bus','Paris Bercy Seine','Barcelone Nord','2026-07-12 08:30:00','2026-07-20 08:30:00',30.00,55);

-- DEST 18 — Amsterdam (existant : 30, 59, 60, 80 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(296,'easyJet','avion','Paris CDG','Amsterdam AMS','2026-07-08 07:30:00','2026-07-17 07:30:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(297,'Transavia','avion','Paris ORY','Amsterdam AMS','2026-07-20 08:00:00','2026-07-27 08:00:00',85.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(298,'Air France','avion','Paris CDG','Amsterdam AMS','2026-08-10 18:00:00','2026-08-18 18:00:00',100.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(299,'Eurostar','train','Paris Gare du Nord','Amsterdam Centraal','2026-08-22 09:31:00','2026-08-31 09:31:00',95.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(300,'Flixbus','bus','Paris Gallieni','Amsterdam Sloterdijk','2026-07-15 07:00:00','2026-07-22 07:00:00',22.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(301,'DFDS Seaways','bateau','Paris (Calais)','Amsterdam (IJmuiden)','2026-07-25 15:30:00','2026-08-02 15:30:00',95.00,500);

-- DEST 19 — Singapour (existant : 31, 32 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(302,'Qatar Airways','avion','Paris CDG','Singapour SIN','2026-07-08 21:00:00','2026-07-22 21:00:00',850.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(303,'Emirates','avion','Paris CDG','Singapour SIN','2026-07-20 22:30:00','2026-08-01 22:30:00',880.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(304,'Lufthansa','avion','Paris CDG','Singapour SIN','2026-08-05 21:30:00','2026-08-18 21:30:00',860.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(305,'Turkish Airlines','avion','Paris CDG','Singapour SIN','2026-08-15 22:00:00','2026-08-29 22:00:00',820.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(306,'British Airways','avion','Paris CDG','Singapour SIN','2026-08-28 21:00:00','2026-09-09 21:00:00',840.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(307,'Cathay Pacific','avion','Paris CDG','Singapour SIN','2026-07-15 22:30:00','2026-07-28 22:30:00',810.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(308,'Malaysia Airlines','avion','Paris CDG','Singapour SIN','2026-09-05 23:00:00','2026-09-19 23:00:00',800.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(309,'Scoot','avion','Paris CDG','Singapour SIN','2026-07-07 06:00:00','2026-07-19 06:00:00',80.00,180);

-- DEST 20 — Prague (existant : 33, 34, 63 → +7 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(310,'Ryanair','avion','Paris Beauvais','Prague PRG','2026-07-05 06:00:00','2026-07-13 06:00:00',65.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(311,'Transavia','avion','Paris ORY','Prague PRG','2026-07-18 07:30:00','2026-07-27 07:30:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(312,'Vueling','avion','Paris CDG','Prague PRG','2026-08-08 08:00:00','2026-08-15 08:00:00',85.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(313,'Air France','avion','Paris CDG','Prague PRG','2026-08-25 09:00:00','2026-09-02 09:00:00',105.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(314,'DB SNCF','train','Paris Est','Prague hl.n.','2026-08-10 07:08:00','2026-08-19 07:08:00',115.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(315,'Flixbus','bus','Paris Bercy Seine','Prague ÚAN Florenc','2026-07-10 08:00:00','2026-07-17 08:00:00',35.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(316,'RegioJet','bus','Paris Bercy Seine','Prague ÚAN Florenc','2026-08-01 07:30:00','2026-08-09 07:30:00',40.00,55);

-- DEST 21 — Dubaï (existant : 35, 36 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(317,'flydubai','avion','Paris CDG','Dubaï DXB','2026-07-05 06:00:00','2026-07-15 06:00:00',290.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(318,'Etihad Airways','avion','Paris CDG','Dubaï DXB','2026-07-15 13:00:00','2026-07-26 13:00:00',360.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(319,'Turkish Airlines','avion','Paris CDG','Dubaï DXB','2026-07-25 07:30:00','2026-08-06 07:30:00',340.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(320,'Qatar Airways','avion','Paris CDG','Dubaï DXB','2026-08-08 20:30:00','2026-08-17 20:30:00',350.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(321,'British Airways','avion','Paris CDG','Dubaï DXB','2026-08-18 14:00:00','2026-08-28 14:00:00',380.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(322,'Lufthansa','avion','Paris CDG','Dubaï DXB','2026-08-28 08:00:00','2026-09-08 08:00:00',360.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(323,'flydubai','avion','Paris CDG','Dubaï DXB','2026-09-05 06:30:00','2026-09-17 06:30:00',285.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(324,'Air Arabia','avion','Paris CDG','Dubaï SHJ','2026-07-20 07:00:00','2026-07-29 07:00:00',260.00,180);

-- DEST 22 — New York (existant : 37, 38 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(325,'Norwegian','avion','Paris CDG','New York JFK','2026-07-05 10:00:00','2026-07-15 10:00:00',420.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(326,'United Airlines','avion','Paris CDG','New York EWR','2026-07-15 09:30:00','2026-07-26 09:30:00',460.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(327,'British Airways','avion','Paris CDG','New York JFK','2026-07-28 11:00:00','2026-08-09 11:00:00',490.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(328,'Corsair','avion','Paris ORY','New York JFK','2026-08-08 10:30:00','2026-08-17 10:30:00',400.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(329,'Iberia','avion','Paris CDG','New York JFK','2026-08-20 10:00:00','2026-08-30 10:00:00',480.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(330,'American Airlines','avion','Paris CDG','New York JFK','2026-08-28 11:30:00','2026-09-08 11:30:00',470.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(331,'Lufthansa','avion','Paris CDG','New York JFK','2026-09-05 09:00:00','2026-09-17 09:00:00',500.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(332,'La Compagnie','avion','Paris ORY','New York EWR','2026-07-10 10:00:00','2026-07-19 10:00:00',850.00,76);

-- DEST 23 — Bangkok (existant : 39, 40, 72 → +7 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(333,'Qatar Airways','avion','Paris CDG','Bangkok BKK','2026-07-10 20:00:00','2026-07-22 20:00:00',590.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(334,'Emirates','avion','Paris CDG','Bangkok BKK','2026-07-22 21:00:00','2026-08-04 21:00:00',620.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(335,'Singapore Airlines','avion','Paris CDG','Bangkok BKK','2026-08-08 22:30:00','2026-08-22 22:30:00',640.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(336,'Turkish Airlines','avion','Paris CDG','Bangkok BKK','2026-08-18 22:00:00','2026-08-30 22:00:00',600.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(337,'Malaysia Airlines','avion','Paris CDG','Bangkok BKK','2026-08-28 23:00:00','2026-09-10 23:00:00',580.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(338,'Nakhon Chai Air','bus','Paris Bercy Seine','Chiang Rai','2026-07-07 21:00:00','2026-07-16 21:00:00',20.00,42);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(339,'Thai Railways','train','Paris Gare de Lyon','Chiang Mai','2026-08-21 18:00:00','2026-08-28 18:00:00',18.00,240);

-- DEST 24 — Marrakech (existant : 41, 42, 73 → +7 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(340,'easyJet','avion','Paris CDG','Marrakech RAK','2026-07-05 06:30:00','2026-07-14 06:30:00',70.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(341,'Ryanair','avion','Paris Beauvais','Marrakech RAK','2026-07-15 05:45:00','2026-07-25 05:45:00',55.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(342,'Vueling','avion','Paris ORY','Marrakech RAK','2026-07-28 07:00:00','2026-08-08 07:00:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(343,'Air Arabia Maroc','avion','Paris CDG','Marrakech RAK','2026-08-10 08:00:00','2026-08-22 08:00:00',65.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(344,'Transavia','avion','Paris ORY','Marrakech RAK','2026-08-22 06:30:00','2026-08-31 06:30:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(345,'Flixbus','bus','Paris Bercy Seine','Marrakech Gueliz','2026-07-08 07:00:00','2026-07-15 07:00:00',50.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(346,'CTM Maroc','bus','Paris Bercy Seine','Marrakech','2026-07-20 10:00:00','2026-07-28 10:00:00',14.00,45);

-- DEST 25 — Rome (existant : 43, 44, 64 → +7 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(347,'Ryanair','avion','Paris Beauvais','Rome Ciampino CIA','2026-07-05 06:00:00','2026-07-14 06:00:00',50.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(348,'easyJet','avion','Paris CDG','Rome FCO','2026-07-18 07:00:00','2026-07-25 07:00:00',70.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(349,'Transavia','avion','Paris ORY','Rome FCO','2026-07-28 07:30:00','2026-08-05 07:30:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(350,'Air France','avion','Paris CDG','Rome FCO','2026-08-10 08:00:00','2026-08-19 08:00:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(351,'Ryanair','avion','Paris Beauvais','Rome Ciampino CIA','2026-08-18 06:30:00','2026-08-25 06:30:00',55.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(352,'Trenitalia','train','Paris Gare de Lyon','Rome Termini','2026-07-15 07:30:00','2026-07-23 07:30:00',135.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(353,'Flixbus','bus','Paris Bercy Seine','Rome Tiburtina','2026-07-22 07:00:00','2026-07-31 07:00:00',40.00,55);

-- DEST 26 — Istanbul (existant : 45, 46, 74 → +7 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(354,'Air France','avion','Paris CDG','Istanbul IST','2026-07-05 09:00:00','2026-07-16 09:00:00',200.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(355,'easyJet','avion','Paris CDG','Istanbul IST','2026-07-18 07:30:00','2026-07-30 07:30:00',155.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(356,'Transavia','avion','Paris ORY','Istanbul SAW','2026-07-28 08:00:00','2026-08-06 08:00:00',140.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(357,'Vueling','avion','Paris CDG','Istanbul IST','2026-08-08 07:00:00','2026-08-18 07:00:00',165.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(358,'SunExpress','avion','Paris CDG','Istanbul SAW','2026-08-20 08:30:00','2026-08-31 08:30:00',130.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(359,'Flixbus','bus','Paris Bercy Seine','Istanbul Esenler','2026-07-10 07:30:00','2026-07-19 07:30:00',65.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(360,'Metro Turizm','bus','Paris Bercy Seine','Ankara','2026-07-13 22:00:00','2026-07-20 22:00:00',15.00,45);

-- DEST 27 — Kyoto (existant : 47, 48, 67 → +7 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(361,'Air France','avion','Paris CDG','Osaka KIX','2026-07-05 11:00:00','2026-07-18 11:00:00',1020.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(362,'Singapore Airlines','avion','Paris CDG','Osaka KIX','2026-07-20 22:00:00','2026-08-03 22:00:00',1080.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(363,'Qatar Airways','avion','Paris CDG','Osaka KIX','2026-08-05 20:00:00','2026-08-17 20:00:00',1000.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(364,'Cathay Pacific','avion','Paris CDG','Osaka KIX','2026-08-18 21:00:00','2026-08-31 21:00:00',1040.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(365,'Korean Air','avion','Paris CDG','Osaka KIX','2026-08-28 20:30:00','2026-09-11 20:30:00',1060.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(366,'JR West','train','Paris Gare de Lyon','Kyoto','2026-07-17 09:00:00','2026-07-24 09:00:00',14.00,500);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(367,'Hankyu','train','Paris Gare de Lyon','Kyoto Kawaramachi','2026-08-07 10:30:00','2026-08-15 10:30:00',8.00,400);

-- DEST 28 — Le Caire (existant : 49, 50 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(368,'Transavia','avion','Paris ORY','Le Caire CAI','2026-07-05 07:00:00','2026-07-14 07:00:00',240.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(369,'Turkish Airlines','avion','Paris CDG','Le Caire CAI','2026-07-15 07:30:00','2026-07-25 07:30:00',260.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(370,'Royal Air Maroc','avion','Paris CDG','Le Caire CAI','2026-07-28 09:00:00','2026-08-08 09:00:00',270.00,220);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(371,'easyJet','avion','Paris CDG','Le Caire CAI','2026-08-05 07:00:00','2026-08-17 07:00:00',220.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(372,'Vueling','avion','Paris ORY','Le Caire CAI','2026-08-15 06:30:00','2026-08-24 06:30:00',230.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(373,'Ryanair','avion','Paris Beauvais','Le Caire CAI','2026-08-28 06:00:00','2026-09-07 06:00:00',200.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(374,'Air Sinai','avion','Paris CDG','Louxor LXR','2026-07-21 08:00:00','2026-08-01 08:00:00',45.00,120);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(375,'Nile River Cruises','bateau','Paris Port de Grenelle','Assouan','2026-07-22 18:00:00','2026-07-29 18:00:00',180.00,50);

-- DEST 29 — Reykjavik (existant : 51, 52 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(376,'WOW Air','avion','Paris CDG','Reykjavik KEF','2026-07-05 07:00:00','2026-07-14 07:00:00',210.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(377,'TUI fly','avion','Paris CDG','Reykjavik KEF','2026-07-15 07:30:00','2026-07-25 07:30:00',240.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(378,'Transavia','avion','Paris ORY','Reykjavik KEF','2026-07-25 08:00:00','2026-08-05 08:00:00',225.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(379,'easyJet','avion','Paris CDG','Reykjavik KEF','2026-08-05 06:30:00','2026-08-17 06:30:00',215.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(380,'Air France','avion','Paris CDG','Reykjavik KEF','2026-08-18 07:00:00','2026-08-27 07:00:00',280.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(381,'Icelandair','avion','Paris CDG','Reykjavik KEF','2026-08-28 07:30:00','2026-09-07 07:30:00',300.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(382,'Strætó','bus','Paris Bercy Seine','Akureyri','2026-07-06 08:00:00','2026-07-14 08:00:00',35.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(383,'Sterna Travel','bateau','Paris Port de Grenelle','Whale Watching','2026-07-16 09:00:00','2026-07-25 09:00:00',65.00,60);

-- DEST 30 — Nairobi (existant : 53, 54 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(384,'Turkish Airlines','avion','Paris CDG','Nairobi NBO','2026-07-08 07:30:00','2026-07-17 07:30:00',620.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(385,'Qatar Airways','avion','Paris CDG','Nairobi NBO','2026-07-20 20:00:00','2026-07-30 20:00:00',650.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(386,'Emirates','avion','Paris CDG','Nairobi NBO','2026-08-05 21:00:00','2026-08-16 21:00:00',680.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(387,'Air France','avion','Paris CDG','Nairobi NBO','2026-08-15 10:00:00','2026-08-27 10:00:00',710.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(388,'Rwandair','avion','Paris CDG','Nairobi NBO','2026-08-28 10:30:00','2026-09-06 10:30:00',640.00,240);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(389,'Jambojet','avion','Paris CDG','Mombasa MBA','2026-07-09 07:00:00','2026-07-19 07:00:00',55.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(390,'Kenya Railways','train','Paris Gare de Lyon','Mombasa','2026-07-15 07:00:00','2026-07-22 07:00:00',40.00,600);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(391,'Easy Coach','bus','Paris Bercy Seine','Arusha (Tanzanie)','2026-08-06 07:00:00','2026-08-14 07:00:00',25.00,55);

-- DEST 31 — San José, Costa Rica (existant : 55 → +9 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(392,'Air France','avion','Paris CDG','San José SJO','2026-07-05 10:00:00','2026-07-19 10:00:00',700.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(393,'Condor','avion','Paris CDG','San José SJO','2026-07-18 11:30:00','2026-07-30 11:30:00',660.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(394,'Air Transat','avion','Paris CDG','San José SJO','2026-08-01 10:00:00','2026-08-14 10:00:00',650.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(395,'TUI fly','avion','Paris CDG','San José SJO','2026-08-12 11:00:00','2026-08-26 11:00:00',670.00,260);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(396,'American Airlines','avion','Paris CDG','San José SJO','2026-08-25 11:30:00','2026-09-06 11:30:00',680.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(397,'Aeromexico','avion','Paris CDG','San José SJO','2026-09-05 12:00:00','2026-09-18 12:00:00',640.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(398,'SANSA Airlines','avion','Paris CDG','Liberia LIR','2026-07-06 07:30:00','2026-07-20 07:30:00',55.00,14);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(399,'Tica Bus','bus','Paris Bercy Seine','Liberia','2026-07-19 07:00:00','2026-07-26 07:00:00',12.00,50);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(400,'Interbus','bus','Paris Bercy Seine','La Fortuna (Arenal)','2026-08-02 07:30:00','2026-08-10 07:30:00',15.00,20);

-- DEST 32 — El Calafate (existant : 56 → +9 transports)
-- Accès : avion Paris-Buenos Aires puis vol interne ou bus vers Calafate
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(401,'Aerolíneas Argentinas','avion','Paris CDG','Buenos Aires EZE','2026-07-05 12:00:00','2026-07-19 12:00:00',820.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(402,'Air France','avion','Paris CDG','Buenos Aires EZE','2026-07-18 11:00:00','2026-07-30 11:00:00',880.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(403,'Latam Airlines','avion','Paris CDG','Buenos Aires EZE','2026-08-01 10:30:00','2026-08-14 10:30:00',850.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(404,'Iberia','avion','Paris CDG','Buenos Aires EZE','2026-08-15 11:00:00','2026-08-29 11:00:00',840.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(405,'Air Europa','avion','Paris CDG','Buenos Aires EZE','2026-08-28 12:00:00','2026-09-09 12:00:00',810.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(406,'Aerolíneas Argentinas','avion','Paris CDG','El Calafate FTE','2026-07-06 08:00:00','2026-07-19 08:00:00',180.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(407,'Latam','avion','Paris CDG','El Calafate FTE','2026-07-19 09:00:00','2026-08-02 09:00:00',170.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(408,'Aerolíneas Argentinas','avion','Paris CDG','El Calafate FTE','2026-08-02 08:30:00','2026-08-14 08:30:00',175.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(409,'TAQSA/Marga','bus','Paris Bercy Seine','El Calafate','2026-07-20 08:00:00','2026-07-28 08:00:00',45.00,45);

-- DEST 33 — Londres (existant : 4, 84, 85, 86, 87, 88 → +4 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(410,'British Airways','avion','Paris CDG','London Heathrow LHR','2026-07-05 07:00:00','2026-07-14 07:00:00',90.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(411,'Ryanair','avion','Paris Beauvais','London Stansted STN','2026-07-20 06:00:00','2026-07-27 06:00:00',55.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(412,'Eurostar','train','Paris Gare du Nord','London St Pancras','2026-07-25 15:31:00','2026-08-02 15:31:00',89.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(413,'Flixbus','bus','Paris Bercy Seine','London Victoria','2026-08-05 08:00:00','2026-08-14 08:00:00',28.00,55);

-- DEST 34 — Berlin (existant : 89, 90, 91, 92 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(414,'Ryanair','avion','Paris Beauvais','Berlin BER','2026-07-12 06:00:00','2026-07-19 06:00:00',60.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(415,'Transavia','avion','Paris ORY','Berlin BER','2026-07-25 07:30:00','2026-08-02 07:30:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(416,'Vueling','avion','Paris CDG','Berlin BER','2026-08-15 08:00:00','2026-08-24 08:00:00',85.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(417,'Wizz Air','avion','Paris CDG','Berlin BER','2026-08-28 06:30:00','2026-09-04 06:30:00',65.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(418,'DB SNCF','train','Paris Est','Berlin Hbf','2026-08-05 07:08:00','2026-08-13 07:08:00',95.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(419,'Flixbus','bus','Paris Bercy Seine','Berlin ZOB','2026-08-18 08:00:00','2026-08-27 08:00:00',38.00,55);

-- DEST 35 — Vienne (existant : 93, 94, 95, 96 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(420,'easyJet','avion','Paris CDG','Vienne VIE','2026-07-05 07:00:00','2026-07-12 07:00:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(421,'Ryanair','avion','Paris Beauvais','Vienne VIE','2026-07-18 06:00:00','2026-07-26 06:00:00',65.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(422,'Transavia','avion','Paris ORY','Vienne VIE','2026-08-01 07:30:00','2026-08-10 07:30:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(423,'Wizz Air','avion','Paris CDG','Vienne VIE','2026-08-20 06:30:00','2026-08-27 06:30:00',60.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(424,'DB Nightjet','train','Paris Est','Wien Hbf','2026-08-10 22:25:00','2026-08-18 22:25:00',99.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(425,'Flixbus','bus','Paris Bercy Seine','Wien Erdberg','2026-08-25 07:30:00','2026-09-03 07:30:00',48.00,55);

-- DEST 36 — Madrid (existant : 97, 98, 99, 100 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(426,'Vueling','avion','Paris ORY','Madrid MAD','2026-07-08 07:00:00','2026-07-15 07:00:00',70.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(427,'Ryanair','avion','Paris Beauvais','Madrid MAD','2026-07-20 06:00:00','2026-07-28 06:00:00',55.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(428,'easyJet','avion','Paris CDG','Madrid MAD','2026-08-08 07:30:00','2026-08-17 07:30:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(429,'Transavia','avion','Paris ORY','Madrid MAD','2026-08-22 08:00:00','2026-08-29 08:00:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(430,'SNCF Renfe','train','Paris Montparnasse','Madrid Chamartin','2026-08-05 09:30:00','2026-08-13 09:30:00',115.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(431,'Flixbus','bus','Paris Bercy Seine','Madrid Sur','2026-08-12 19:00:00','2026-08-21 19:00:00',52.00,55);

-- DEST 37 — Bruxelles (existant : 101, 102, 103, 104 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(432,'Thalys','train','Paris Gare du Nord','Bruxelles Midi','2026-07-12 11:25:00','2026-07-19 11:25:00',45.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(433,'Thalys','train','Paris Gare du Nord','Bruxelles Midi','2026-07-22 14:55:00','2026-07-30 14:55:00',50.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(434,'Eurostar','train','Paris Gare du Nord','Bruxelles Midi','2026-08-05 09:52:00','2026-08-14 09:52:00',55.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(435,'easyJet','avion','Paris CDG','Bruxelles BRU','2026-07-18 07:00:00','2026-07-25 07:00:00',65.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(436,'Flixbus','bus','Paris Gallieni','Bruxelles Nord','2026-08-15 09:00:00','2026-08-23 09:00:00',12.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(437,'Flixbus','bus','Paris Gallieni','Bruxelles Nord','2026-08-28 08:00:00','2026-09-06 08:00:00',14.00,55);

-- DEST 38 — Copenhague (existant : 105, 106 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(438,'easyJet','avion','Paris CDG','Copenhague CPH','2026-07-05 07:00:00','2026-07-12 07:00:00',110.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(439,'Transavia','avion','Paris ORY','Copenhague CPH','2026-07-18 07:30:00','2026-07-26 07:30:00',125.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(440,'Norwegian','avion','Paris CDG','Copenhague CPH','2026-07-28 06:30:00','2026-08-06 06:30:00',105.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(441,'Ryanair','avion','Paris Beauvais','Copenhague CPH','2026-08-08 06:00:00','2026-08-15 06:00:00',90.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(442,'Vueling','avion','Paris CDG','Copenhague CPH','2026-08-18 07:30:00','2026-08-26 07:30:00',115.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(443,'Wizz Air','avion','Paris CDG','Copenhague CPH','2026-08-28 06:30:00','2026-09-06 06:30:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(444,'DSB','train','Paris Gare de Lyon','Malmö','2026-07-11 10:00:00','2026-07-18 10:00:00',12.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(445,'Flixbus','bus','Paris Bercy Seine','Copenhague Ingerslevsgade','2026-07-15 07:00:00','2026-07-23 07:00:00',55.00,55);

-- DEST 39 — Stockholm (existant : 107, 108 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(446,'easyJet','avion','Paris CDG','Stockholm ARN','2026-07-05 07:00:00','2026-07-14 07:00:00',120.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(447,'Norwegian','avion','Paris CDG','Stockholm ARN','2026-07-15 06:30:00','2026-07-22 06:30:00',110.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(448,'Transavia','avion','Paris ORY','Stockholm ARN','2026-07-25 07:30:00','2026-08-02 07:30:00',115.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(449,'Ryanair','avion','Paris Beauvais','Stockholm ARN','2026-08-05 06:00:00','2026-08-14 06:00:00',90.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(450,'Wizz Air','avion','Paris CDG','Stockholm ARN','2026-08-15 06:30:00','2026-08-22 06:30:00',100.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(451,'Vueling','avion','Paris CDG','Stockholm ARN','2026-08-28 07:00:00','2026-09-05 07:00:00',125.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(452,'SJ (SJ AB)','train','Paris Gare de Lyon','Stockholm Centralstation','2026-07-12 07:00:00','2026-07-21 07:00:00',45.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(453,'Flixbus','bus','Paris Bercy Seine','Stockholm Cityterminalen','2026-07-20 07:00:00','2026-07-27 07:00:00',70.00,55);

-- DEST 40 — Budapest (existant : 109, 110, 111, 112 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(454,'easyJet','avion','Paris CDG','Budapest BUD','2026-07-12 07:00:00','2026-07-20 07:00:00',85.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(455,'Ryanair','avion','Paris Beauvais','Budapest BUD','2026-07-25 06:00:00','2026-08-03 06:00:00',70.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(456,'Transavia','avion','Paris ORY','Budapest BUD','2026-08-05 07:30:00','2026-08-12 07:30:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(457,'Vueling','avion','Paris CDG','Budapest BUD','2026-08-20 08:00:00','2026-08-28 08:00:00',90.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(458,'DB Nightjet','train','Paris Est','Budapest Keleti','2026-08-12 21:33:00','2026-08-21 21:33:00',109.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(459,'Flixbus','bus','Paris Bercy Seine','Budapest Nepliget','2026-08-22 08:00:00','2026-08-29 08:00:00',55.00,55);

-- DEST 41 — Athènes (existant : 113, 114, 75, 76 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(460,'easyJet','avion','Paris CDG','Athènes ATH','2026-07-05 07:30:00','2026-07-14 07:30:00',110.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(461,'Ryanair','avion','Paris Beauvais','Athènes ATH','2026-07-18 06:00:00','2026-07-28 06:00:00',90.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(462,'Transavia','avion','Paris ORY','Athènes ATH','2026-08-01 07:00:00','2026-08-12 07:00:00',105.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(463,'Vueling','avion','Paris CDG','Athènes ATH','2026-08-20 08:00:00','2026-09-01 08:00:00',115.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(464,'Hellenic Seaways','bateau','Paris Port de Grenelle','Crète Héraklion','2026-07-16 21:00:00','2026-07-25 21:00:00',55.00,500);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(465,'Blue Star Ferries','bateau','Paris Port de Grenelle','Rhodes RHO','2026-08-02 20:00:00','2026-08-09 20:00:00',75.00,400);

-- DEST 42 — Florence (existant : 115, 116, 117, 118 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(466,'Ryanair','avion','Paris Beauvais','Florence FLR','2026-07-08 06:00:00','2026-07-16 06:00:00',60.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(467,'easyJet','avion','Paris CDG','Florence FLR','2026-07-20 07:00:00','2026-07-29 07:00:00',70.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(468,'Transavia','avion','Paris ORY','Florence FLR','2026-08-08 07:30:00','2026-08-15 07:30:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(469,'Air France','avion','Paris CDG','Florence FLR','2026-08-22 09:00:00','2026-08-30 09:00:00',95.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(470,'Trenitalia','train','Paris Gare de Lyon','Florence SMN','2026-08-05 07:15:00','2026-08-14 07:15:00',115.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(471,'Flixbus','bus','Paris Bercy Seine','Florence SITA','2026-08-18 07:00:00','2026-08-25 07:00:00',42.00,55);

-- DEST 43 — Porto (existant : 65, 119, 120, 121 → +6 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(472,'easyJet','avion','Paris CDG','Porto OPO','2026-07-12 07:30:00','2026-07-20 07:30:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(473,'Transavia','avion','Paris ORY','Porto OPO','2026-07-25 08:00:00','2026-08-03 08:00:00',80.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(474,'Vueling','avion','Paris CDG','Porto OPO','2026-08-08 07:00:00','2026-08-15 07:00:00',85.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(475,'Air France','avion','Paris CDG','Porto OPO','2026-08-22 09:30:00','2026-08-30 09:30:00',100.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(476,'CP Portugal','train','Paris Gare de Lyon','Porto Campanha','2026-08-06 10:00:00','2026-08-15 10:00:00',28.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(477,'Flixbus','bus','Paris Bercy Seine','Porto Campo 24 Agosto','2026-08-15 09:00:00','2026-08-22 09:00:00',52.00,55);

-- DEST 44 — Sintra/Lisbonne (existant : 6, 122, 123 → +7 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(478,'Ryanair','avion','Paris Beauvais','Lisbonne LIS','2026-07-05 06:00:00','2026-07-13 06:00:00',55.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(479,'Transavia','avion','Paris ORY','Lisbonne LIS','2026-07-18 07:30:00','2026-07-27 07:30:00',70.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(480,'Vueling','avion','Paris ORY','Lisbonne LIS','2026-08-01 07:00:00','2026-08-08 07:00:00',75.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(481,'Air France','avion','Paris CDG','Lisbonne LIS','2026-08-12 09:00:00','2026-08-20 09:00:00',90.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(482,'Flixbus','bus','Paris Bercy Seine','Lisbonne Sete Rios','2026-07-12 08:00:00','2026-07-21 08:00:00',48.00,55);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(483,'Comboios de Portugal','train','Paris Gare de Lyon','Sintra','2026-07-11 09:30:00','2026-07-18 09:30:00',2.50,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(484,'Comboios de Portugal','train','Paris Gare de Lyon','Sintra','2026-08-06 10:00:00','2026-08-14 10:00:00',2.50,200);

-- DEST 45 — Séoul (existant : 124, 125 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(485,'Asiana Airlines','avion','Paris CDG','Séoul ICN','2026-07-05 12:00:00','2026-07-19 12:00:00',880.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(486,'Qatar Airways','avion','Paris CDG','Séoul ICN','2026-07-18 20:00:00','2026-07-30 20:00:00',820.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(487,'Cathay Pacific','avion','Paris CDG','Séoul ICN','2026-08-01 21:30:00','2026-08-14 21:30:00',840.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(488,'Emirates','avion','Paris CDG','Séoul ICN','2026-08-12 20:00:00','2026-08-26 20:00:00',860.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(489,'Turkish Airlines','avion','Paris CDG','Séoul ICN','2026-08-22 22:00:00','2026-09-03 22:00:00',800.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(490,'Singapore Airlines','avion','Paris CDG','Séoul ICN','2026-09-01 22:30:00','2026-09-14 22:30:00',830.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(491,'Korail','train','Paris Gare de Lyon','Busan','2026-07-07 07:00:00','2026-07-16 07:00:00',55.00,400);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(492,'T-express','bus','Paris Bercy Seine','Gyeongju','2026-08-14 09:00:00','2026-08-21 09:00:00',18.00,45);

-- DEST 46 — Hong Kong (existant : 126, 127 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(493,'Emirates','avion','Paris CDG','Hong Kong HKG','2026-07-05 21:00:00','2026-07-18 21:00:00',800.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(494,'Qatar Airways','avion','Paris CDG','Hong Kong HKG','2026-07-18 20:30:00','2026-08-01 20:30:00',760.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(495,'Singapore Airlines','avion','Paris CDG','Hong Kong HKG','2026-08-01 22:30:00','2026-08-13 22:30:00',790.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(496,'Turkish Airlines','avion','Paris CDG','Hong Kong HKG','2026-08-12 22:00:00','2026-08-25 22:00:00',750.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(497,'Finnair','avion','Paris CDG','Hong Kong HKG','2026-08-22 21:00:00','2026-09-05 21:00:00',770.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(498,'Korean Air','avion','Paris CDG','Hong Kong HKG','2026-09-01 20:00:00','2026-09-13 20:00:00',780.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(499,'MTR','train','Paris Gare de Lyon','Guangzhou','2026-07-13 09:00:00','2026-07-21 09:00:00',25.00,1000);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(500,'TurboJET','bateau','Paris Port de Grenelle','Macao','2026-07-14 10:00:00','2026-07-23 10:00:00',40.00,350);

-- DEST 47 — Kuala Lumpur (existant : 128, 129 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(501,'Qatar Airways','avion','Paris CDG','Kuala Lumpur KUL','2026-07-05 20:30:00','2026-07-17 20:30:00',660.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(502,'Turkish Airlines','avion','Paris CDG','Kuala Lumpur KUL','2026-07-18 22:30:00','2026-07-31 22:30:00',640.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(503,'Emirates','avion','Paris CDG','Kuala Lumpur KUL','2026-08-01 20:00:00','2026-08-15 20:00:00',680.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(504,'Singapore Airlines','avion','Paris CDG','Kuala Lumpur KUL','2026-08-12 22:30:00','2026-08-24 22:30:00',700.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(505,'Thai Airways','avion','Paris CDG','Kuala Lumpur KUL','2026-08-22 21:00:00','2026-09-04 21:00:00',650.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(506,'Air Asia X','avion','Paris CDG','Kuala Lumpur KUL','2026-09-01 23:00:00','2026-09-15 23:00:00',580.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(507,'KTM Berhad','train','Paris Gare de Lyon','Penang Butterworth','2026-07-17 08:30:00','2026-07-24 08:30:00',22.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(508,'Aeroline','bus','Paris Bercy Seine','Singapour Golden Mile','2026-08-03 08:00:00','2026-08-11 08:00:00',18.00,45);

-- DEST 48 — Hanoï (existant : 130, 131 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(509,'Qatar Airways','avion','Paris CDG','Hanoï HAN','2026-07-05 20:00:00','2026-07-19 20:00:00',650.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(510,'Turkish Airlines','avion','Paris CDG','Hanoï HAN','2026-07-18 22:00:00','2026-07-30 22:00:00',630.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(511,'Emirates','avion','Paris CDG','Hanoï HAN','2026-08-01 21:00:00','2026-08-14 21:00:00',670.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(512,'Cathay Pacific','avion','Paris CDG','Hanoï HAN','2026-08-12 22:30:00','2026-08-26 22:30:00',660.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(513,'China Eastern','avion','Paris CDG','Hanoï HAN','2026-08-22 20:00:00','2026-09-03 20:00:00',620.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(514,'Korean Air','avion','Paris CDG','Hanoï HAN','2026-09-01 21:30:00','2026-09-14 21:30:00',640.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(515,'VietJet Air','avion','Paris CDG','Ho Chi Minh SGN','2026-07-10 07:00:00','2026-07-24 07:00:00',45.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(516,'Reunification Express','train','Paris Gare de Lyon','Da Nang','2026-08-14 07:00:00','2026-08-21 07:00:00',22.00,200);

-- DEST 49 — Mumbai (existant : 132, 133 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(517,'Qatar Airways','avion','Paris CDG','Mumbai BOM','2026-07-05 20:00:00','2026-07-15 20:00:00',560.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(518,'Emirates','avion','Paris CDG','Mumbai BOM','2026-07-18 19:30:00','2026-07-29 19:30:00',590.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(519,'Turkish Airlines','avion','Paris CDG','Mumbai BOM','2026-08-01 22:00:00','2026-08-13 22:00:00',550.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(520,'Etihad Airways','avion','Paris CDG','Mumbai BOM','2026-08-12 20:30:00','2026-08-21 20:30:00',570.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(521,'British Airways','avion','Paris CDG','Mumbai BOM','2026-08-22 22:00:00','2026-09-01 22:00:00',600.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(522,'Lufthansa','avion','Paris CDG','Mumbai BOM','2026-09-01 21:00:00','2026-09-12 21:00:00',580.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(523,'IndiGo','avion','Paris CDG','Goa GOX','2026-07-23 08:00:00','2026-08-05 08:00:00',40.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(524,'Indian Railways','train','Paris Gare de Lyon','Goa Madgaon','2026-08-16 07:00:00','2026-08-25 07:00:00',20.00,300);

-- DEST 50 — Montréal (existant : 134, 135 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(525,'Corsair','avion','Paris ORY','Montréal YUL','2026-07-08 11:30:00','2026-07-18 11:30:00',400.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(526,'Canadian Airlines','avion','Paris CDG','Montréal YUL','2026-07-20 10:00:00','2026-07-31 10:00:00',440.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(527,'Corsair','avion','Paris ORY','Montréal YUL','2026-08-05 12:00:00','2026-08-17 12:00:00',410.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(528,'British Airways','avion','Paris CDG','Montréal YUL','2026-08-15 10:30:00','2026-08-24 10:30:00',460.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(529,'Lufthansa','avion','Paris CDG','Montréal YUL','2026-08-28 09:00:00','2026-09-07 09:00:00',450.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(530,'United Airlines','avion','Paris CDG','Montréal YUL','2026-09-05 10:00:00','2026-09-16 10:00:00',430.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(531,'VIA Rail','train','Paris Gare de Lyon','Québec City','2026-07-06 07:10:00','2026-07-13 07:10:00',55.00,900);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(532,'Flixbus','bus','Paris Bercy Seine','Toronto','2026-08-16 08:00:00','2026-08-24 08:00:00',35.00,55);

-- DEST 51 — Los Angeles (existant : 136, 137 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(533,'United Airlines','avion','Paris CDG','Los Angeles LAX','2026-07-05 10:30:00','2026-07-19 10:30:00',550.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(534,'Norwegian','avion','Paris CDG','Los Angeles LAX','2026-07-18 11:00:00','2026-07-30 11:00:00',500.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(535,'British Airways','avion','Paris CDG','Los Angeles LAX','2026-08-01 10:00:00','2026-08-14 10:00:00',570.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(536,'Corsair','avion','Paris ORY','Los Angeles LAX','2026-08-12 11:30:00','2026-08-26 11:30:00',490.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(537,'Lufthansa','avion','Paris CDG','Los Angeles LAX','2026-08-22 09:30:00','2026-09-03 09:30:00',560.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(538,'Iberia','avion','Paris CDG','Los Angeles LAX','2026-09-05 10:00:00','2026-09-18 10:00:00',540.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(539,'Southwest Airlines','avion','Paris CDG','Las Vegas LAS','2026-07-06 08:00:00','2026-07-20 08:00:00',65.00,175);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(540,'Amtrak','train','Paris Gare de Lyon','San Francisco Emeryville','2026-08-13 09:10:00','2026-08-20 09:10:00',55.00,200);

-- DEST 52 — Sydney (existant : 138, 139 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(541,'Singapore Airlines','avion','Paris CDG','Sydney SYD','2026-07-08 22:30:00','2026-07-21 22:30:00',1300.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(542,'Emirates','avion','Paris CDG','Sydney SYD','2026-07-20 21:00:00','2026-08-03 21:00:00',1280.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(543,'Etihad Airways','avion','Paris CDG','Sydney SYD','2026-08-01 20:00:00','2026-08-13 20:00:00',1320.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(544,'Cathay Pacific','avion','Paris CDG','Sydney SYD','2026-08-12 21:30:00','2026-08-25 21:30:00',1300.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(545,'Turkish Airlines','avion','Paris CDG','Sydney SYD','2026-08-22 22:00:00','2026-09-05 22:00:00',1260.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(546,'Malaysian Airlines','avion','Paris CDG','Sydney SYD','2026-09-01 22:30:00','2026-09-13 22:30:00',1280.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(547,'Jetstar','avion','Paris CDG','Melbourne MEL','2026-07-11 07:00:00','2026-07-24 07:00:00',55.00,200);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(548,'NSW TrainLink','train','Paris Gare de Lyon','Brisbane Roma Street','2026-08-15 07:25:00','2026-08-24 07:25:00',65.00,500);

-- DEST 53 — Buenos Aires (existant : 56, 140, 141 → +7 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(549,'Latam Airlines','avion','Paris CDG','Buenos Aires EZE','2026-07-08 10:00:00','2026-07-20 10:00:00',810.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(550,'Iberia','avion','Paris CDG','Buenos Aires EZE','2026-07-22 11:00:00','2026-08-04 11:00:00',840.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(551,'Air Europa','avion','Paris CDG','Buenos Aires EZE','2026-08-05 12:00:00','2026-08-19 12:00:00',800.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(552,'Turkish Airlines','avion','Paris CDG','Buenos Aires EZE','2026-08-18 22:00:00','2026-08-30 22:00:00',860.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(553,'Corsair','avion','Paris ORY','Buenos Aires EZE','2026-08-28 11:00:00','2026-09-10 11:00:00',790.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(554,'Aerolíneas Argentinas','avion','Paris CDG','Bariloche BRC','2026-07-09 09:00:00','2026-07-23 09:00:00',120.00,150);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(555,'Buquebus','bateau','Paris Port de Grenelle','Colonia (Uruguay)','2026-07-20 09:00:00','2026-07-27 09:00:00',30.00,300);

-- DEST 54 — Rio de Janeiro (existant : 142, 143 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(556,'Latam Airlines','avion','Paris CDG','Rio de Janeiro GIG','2026-07-05 10:00:00','2026-07-18 10:00:00',760.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(557,'Iberia','avion','Paris CDG','Rio de Janeiro GIG','2026-07-18 11:30:00','2026-08-01 11:30:00',790.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(558,'TAP Portugal','avion','Paris CDG','Rio de Janeiro GIG','2026-08-01 11:00:00','2026-08-13 11:00:00',750.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(559,'Aerolíneas Argentinas','avion','Paris CDG','Rio de Janeiro GIG','2026-08-12 12:00:00','2026-08-25 12:00:00',780.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(560,'Air Europa','avion','Paris CDG','Rio de Janeiro GIG','2026-08-22 11:00:00','2026-09-05 11:00:00',760.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(561,'Turkish Airlines','avion','Paris CDG','Rio de Janeiro GIG','2026-09-01 23:00:00','2026-09-13 23:00:00',800.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(562,'GOL Airlines','avion','Paris CDG','São Paulo GRU','2026-07-06 08:00:00','2026-07-19 08:00:00',55.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(563,'Azul','avion','Paris CDG','Salvador SSA','2026-08-14 07:30:00','2026-08-28 07:30:00',65.00,150);

-- DEST 55 — Punta Cana (existant : 144, 145 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(564,'Air Transat','avion','Paris CDG','Punta Cana PUJ','2026-07-08 11:00:00','2026-07-20 11:00:00',560.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(565,'TUI fly','avion','Paris CDG','Punta Cana PUJ','2026-07-20 10:30:00','2026-08-02 10:30:00',580.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(566,'Condor','avion','Paris CDG','Punta Cana PUJ','2026-08-01 11:00:00','2026-08-15 11:00:00',550.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(567,'Norwegian','avion','Paris CDG','Punta Cana PUJ','2026-08-12 10:00:00','2026-08-24 10:00:00',540.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(568,'Iberia','avion','Paris CDG','Punta Cana PUJ','2026-08-22 12:00:00','2026-09-04 12:00:00',570.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(569,'American Airlines','avion','Paris CDG','Punta Cana PUJ','2026-09-01 11:30:00','2026-09-15 11:30:00',555.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(570,'Caribe Tours','bus','Paris Bercy Seine','Punta Cana','2026-07-09 08:00:00','2026-07-16 08:00:00',12.00,50);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(571,'Sky Cana','avion','Paris CDG','Punta Cana PUJ','2026-08-02 09:00:00','2026-08-15 09:00:00',40.00,70);

-- DEST 56 — Koh Samui (existant : 146, 147 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(572,'Qatar Airways','avion','Paris CDG','Koh Samui USM','2026-07-05 20:00:00','2026-07-19 20:00:00',740.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(573,'Emirates','avion','Paris CDG','Koh Samui USM','2026-07-18 21:00:00','2026-07-30 21:00:00',760.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(574,'Turkish Airlines','avion','Paris CDG','Bangkok BKK','2026-08-01 22:00:00','2026-08-14 22:00:00',600.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(575,'Malaysia Airlines','avion','Paris CDG','Bangkok BKK','2026-08-12 23:00:00','2026-08-26 23:00:00',590.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(576,'Singapore Airlines','avion','Paris CDG','Bangkok BKK','2026-08-22 22:30:00','2026-09-03 22:30:00',620.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(577,'Bangkok Airways','avion','Paris CDG','Koh Samui USM','2026-08-02 13:00:00','2026-08-15 13:00:00',70.00,70);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(578,'Bangkok Airways','avion','Paris CDG','Koh Samui USM','2026-08-13 14:00:00','2026-08-27 14:00:00',70.00,70);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(579,'Raja Ferry','bateau','Paris Port de Grenelle','Koh Samui','2026-07-07 09:00:00','2026-07-14 09:00:00',10.00,300);

-- DEST 57 — Cap-Vert (existant : 148, 149 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(580,'Vueling','avion','Paris CDG','Sal SID','2026-07-05 21:30:00','2026-07-14 21:30:00',360.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(581,'TUI fly','avion','Paris CDG','Sal SID','2026-07-18 22:00:00','2026-07-28 22:00:00',380.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(582,'Condor','avion','Paris CDG','Sal SID','2026-08-01 21:00:00','2026-08-12 21:00:00',370.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(583,'Corsair','avion','Paris ORY','Sal SID','2026-08-12 22:30:00','2026-08-24 22:30:00',350.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(584,'Luxair','avion','Paris CDG','Sal SID','2026-08-22 21:00:00','2026-08-31 21:00:00',390.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(585,'easyJet','avion','Paris CDG','Sal SID','2026-09-01 22:00:00','2026-09-11 22:00:00',340.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(586,'TACV Cabo Verde Airlines','avion','Paris CDG','Santiago SDG','2026-07-13 10:00:00','2026-07-26 10:00:00',45.00,70);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(587,'Mar d\'Canal','bateau','Paris Port de Grenelle','Boavista','2026-07-19 09:00:00','2026-07-28 09:00:00',15.00,80);

-- DEST 58 — La Réunion (existant : 150, 151 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(588,'Air Austral','avion','Paris CDG','Saint-Denis RUN','2026-07-05 21:30:00','2026-07-17 21:30:00',560.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(589,'Air Mauritius','avion','Paris CDG','Saint-Denis RUN','2026-07-18 22:00:00','2026-07-31 22:00:00',540.00,270);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(590,'French Bee','avion','Paris ORY','Saint-Denis RUN','2026-08-01 22:30:00','2026-08-15 22:30:00',490.00,350);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(591,'Air Austral','avion','Paris CDG','Saint-Denis RUN','2026-08-12 21:00:00','2026-08-24 21:00:00',550.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(592,'French Bee','avion','Paris ORY','Saint-Denis RUN','2026-08-22 23:00:00','2026-09-04 23:00:00',500.00,350);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(593,'Air France','avion','Paris CDG','Saint-Denis RUN','2026-09-01 22:30:00','2026-09-15 22:30:00',580.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(594,'Air Austral','avion','Paris CDG','Mayotte DZAO','2026-07-07 08:00:00','2026-07-18 08:00:00',65.00,100);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(595,'Air Corsica','avion','Paris CDG','Île Maurice MRU','2026-08-14 08:00:00','2026-08-27 08:00:00',55.00,120);

-- DEST 59 — Cape Town (existant : 152, 153 → +8 transports)
-- ============================================================
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(596,'Ethiopian Airlines','avion','Paris CDG','Cape Town CPT','2026-07-05 10:30:00','2026-07-19 10:30:00',820.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(597,'Turkish Airlines','avion','Paris CDG','Cape Town CPT','2026-07-18 22:00:00','2026-07-30 22:00:00',800.00,280);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(598,'Emirates','avion','Paris CDG','Cape Town CPT','2026-08-01 21:30:00','2026-08-14 21:30:00',840.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(599,'Qatar Airways','avion','Paris CDG','Cape Town CPT','2026-08-12 20:00:00','2026-08-26 20:00:00',820.00,300);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(600,'Kenya Airways','avion','Paris CDG','Cape Town CPT','2026-08-22 10:00:00','2026-09-03 10:00:00',790.00,250);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(601,'Rwandair','avion','Paris CDG','Cape Town CPT','2026-09-01 10:30:00','2026-09-14 10:30:00',810.00,240);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(602,'Kulula','avion','Paris CDG','Johannesburg JHB','2026-07-07 07:00:00','2026-07-21 07:00:00',65.00,180);
INSERT IGNORE INTO transports (id,compagnie,type,origine,destination,date_depart,date_arrivee,prix,places_dispo) VALUES
(603,'Intercape','bus','Paris Bercy Seine','Knysna (Garden Route)','2026-07-20 08:00:00','2026-07-27 08:00:00',25.00,55);

SET foreign_key_checks = 1;

-- ============================================================
-- Résumé : 444 nouvelles entrées (IDs 160-603)
-- Toutes les 59 destinations atteignent désormais ~10 transports.
-- ============================================================

SET foreign_key_checks = 1;