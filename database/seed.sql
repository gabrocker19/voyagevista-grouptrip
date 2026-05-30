-- ============================================================
-- VoyageVista – Seed enrichi v2
-- Petits lots pour compatibilité phpMyAdmin
-- Importer APRÈS schema.sql
-- ============================================================
SET NAMES utf8mb4;
SET foreign_key_checks = 0;

-- ============================================================
-- DESTINATIONS (6 existantes + 32 nouvelles = 38 total)
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

-- ============================================================
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

-- ============================================================
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

-- ============================================================
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

SET foreign_key_checks = 1;
