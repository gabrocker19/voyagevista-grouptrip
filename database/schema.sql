-- ============================================================
--  VoyageVista — GroupTrip
--  Schema SQL — Création de la base de données
--  Équipe : Gabin Kerevel · Aurélien Kammerer · Brice Fargeat · Isiah Perelman
--  Projet Web dynamique 2026 — ING2
-- ============================================================

CREATE DATABASE IF NOT EXISTS voyagevista CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
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
    valeur           VARCHAR(255) NOT NULL,  -- id de la destination/hébergement/activité votée, ou dates
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_vote (utilisateur_id, groupe_id, type),  -- R1 : un seul vote par membre par type
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (groupe_id)      REFERENCES groupes(id)      ON DELETE CASCADE
);

-- ============================================================
-- 9. ITINÉRAIRES
-- ============================================================
CREATE TABLE itineraires (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    groupe_id        INT NOT NULL UNIQUE,   -- un groupe = un itinéraire
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
-- 11. APPROBATIONS (validation collective)
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
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
);

-- ============================================================
-- DONNÉES DE TEST (seed)
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

-- Destinations
INSERT INTO destinations (nom, pays, categorie, description, prix_min) VALUES
('Bali',       'Indonésie',  'plage',     'Île paradisiaque avec temples et rizières.', 899),
('Tokyo',      'Japon',      'ville',     'Mégapole entre tradition et modernité.',     1100),
('Interlaken', 'Suisse',     'montagne',  'Capitale des sports de montagne.',           1249),
('Lisbonne',   'Portugal',   'ville',     'Capitale ensoleillée au bord du Tage.',       420),
('Santorin',   'Grèce',      'plage',     'Villages blancs et couchers de soleil.',      784),
('Cusco',      'Pérou',      'culture',   'Ancienne capitale de l\'empire Inca.',        1099);

-- Hébergements
INSERT INTO hebergements (destination_id, nom, type, prix_nuit, capacite, description) VALUES
(1, 'The Kayon Resort',    'resort',  125, 2, 'Vue sur la jungle, piscine à débordement.'),
(1, 'Villa Umah Sunset',   'villa',   180, 4, 'Villa privée avec vue sur l\'océan.'),
(1, 'Sunshine Beach Hotel','hotel',    60, 2, 'Hôtel 3 étoiles à 200m de la plage.'),
(2, 'Shinjuku Grand Hotel','hotel',   110, 2, 'Idéalement situé dans le quartier Shinjuku.'),
(3, 'Alpine Lodge',        'hotel',    95, 2, 'Chalet avec vue sur les Alpes.'),
(4, 'LX Boutique Hotel',   'hotel',    85, 2, 'Boutique hôtel en centre-ville.'),
(5, 'Caldera Suites',      'hotel',   160, 2, 'Vue directe sur la caldeira.'),
(6, 'Casa Andina',         'hotel',    70, 2, 'Hôtel confortable en centre historique.');

-- Activités
INSERT INTO activites (destination_id, nom, prix, capacite_max, places_restantes, duree_heures) VALUES
(1, 'Snorkeling Blue Lagoon',  45, 15, 15, 3),
(1, 'Temple Tanah Lot',        35, 30, 30, 2),
(1, 'Cours de surf à Kuta',    60, 10, 0,  3),  -- complet pour la démo
(1, 'Randonnée rizières',      40, 12, 12, 4),
(2, 'Visite du Mont Fuji',     80, 20, 20, 8),
(2, 'Quartier d\'Akihabara',   25, 50, 50, 3),
(3, 'Parachutisme',           180, 8,   8, 2),
(3, 'Canyoning',               90, 10, 10, 4),
(4, 'Tram 28 + Alfama',        20, 40, 40, 3),
(5, 'Coucher de soleil Oia',   30, 25, 25, 2);

-- Transports
INSERT INTO transports (compagnie, type, origine, destination, date_depart, date_arrivee, prix, places_dispo) VALUES
('Air France',    'avion', 'Paris CDG', 'Bali DPS',   '2026-06-14 11:30:00', '2026-06-15 05:45:00', 789, 50),
('Qatar Airways', 'avion', 'Paris CDG', 'Bali DPS',   '2026-06-14 15:20:00', '2026-06-15 09:00:00', 672, 40),
('Air France',    'avion', 'Bali DPS',  'Paris CDG',  '2026-06-28 23:55:00', '2026-06-29 14:30:00', 789, 50),
('Eurostar',      'train', 'Paris',     'Londres',    '2026-07-01 08:00:00', '2026-07-01 10:00:00', 120, 80),
('Air France',    'avion', 'Paris CDG', 'Tokyo HND',  '2026-08-01 10:00:00', '2026-08-02 08:00:00',1100, 30),
('TAP Portugal',  'avion', 'Paris CDG', 'Lisbonne',   '2026-09-15 07:30:00', '2026-09-15 09:45:00', 180, 60);
