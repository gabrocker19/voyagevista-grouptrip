-- ============================================================
-- VoyageVista – Seed Extra
-- 25 nouvelles destinations + hébergements + activités
-- Transports cohérents depuis PARIS uniquement
-- Importer APRÈS seed.sql
-- ============================================================
SET NAMES utf8mb4;
SET foreign_key_checks = 0;

-- ============================================================
-- NOUVELLES DESTINATIONS (IDs 39-63)
-- ============================================================

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
