# VoyageVista — GroupTrip

Plateforme de planification de voyages en groupe.

**Équipe :** Gabin Kerevel · Aurélien Kammerer · Brice Fargeat · Isiah Perelman  
**Projet Web dynamique 2026 — ING2, ECE Paris**

---

## Stack technique

- **Frontend :** React 19 + Vite (servi par Apache/WAMP après build)
- **Backend :** PHP 8 — API REST (servi par Apache/WAMP)
- **Base de données :** MariaDB / MySQL (via WAMP)

---

## Prérequis

- [WAMP Server](https://www.wampserver.com/) installé et démarré (icône verte dans la barre des tâches)
- [Node.js](https://nodejs.org/) v18 ou supérieur (pour la compilation du frontend, une seule fois)

---

## Installation

### 1. Placer le projet

Le dossier doit être dans le répertoire `www` de WAMP :

```
C:\wamp64\www\voyagevista-grouptrip\
```

### 2. Créer la base de données

Ouvrir **phpMyAdmin** à l'adresse `http://localhost/phpmyadmin` puis :

1. Cliquer sur **Importer**
2. Importer `database/schema.sql` → crée la base et toutes les tables
3. Importer `database/seed.sql` → insère les données de test (destinations, transports, hébergements, activités, comptes utilisateurs)

### 3. Compiler le frontend (une seule fois)

Dans le terminal VS Code (`Ctrl+ù`) :

```bash
cd frontend && npm install && npm run build
```

---

## Lancer le site

1. Démarrer **WAMP** (icône verte dans la barre des tâches)
2. Ouvrir le navigateur à l'adresse :

**`http://localhost/voyagevista-grouptrip/frontend/dist/`**

C'est tout. Aucune commande à lancer.

> Si tu modifies du code React, relancer `npm run build` dans le terminal VS Code pour recompiler.

---

## Comptes de test

| Rôle | Email | Mot de passe |
|---|---|---|
| Admin | `gabin@test.fr` | `password` |
| Membre | `aurelien@test.fr` | `password` |
| Membre | `brice@test.fr` | `password` |
| Membre | `isiah@test.fr` | `password` |

> Le compte `gabin@test.fr` a le rôle `admin` et accède à la page `/admin` pour gérer le catalogue.

---

## Structure du projet

```
voyagevista-grouptrip/
├── backend/
│   ├── config/            # Connexion base de données (database.php)
│   ├── controllers/       # AuthController, GroupController, CatalogueController,
│   │                      # VoteController, ItineraireController,
│   │                      # ReservationController, NotifController
│   ├── middleware/        # auth.php — vérification session
│   ├── routes/            # router.php — routing de l'API REST
│   └── index.php          # Point d'entrée — headers CORS + session
├── frontend/
│   ├── src/
│   │   ├── components/    # Navbar (avec badge notifications)
│   │   ├── context/       # AuthContext
│   │   ├── pages/         # Home, Login, Register, Dashboard, Catalogue,
│   │   │                  # GroupCreate, GroupDetail, Vote,
│   │   │                  # Transport, Hebergement, Activites, Itineraire,
│   │   │                  # Panier, Paiement, Profil, Notifications, Admin
│   │   └── services/      # api.js, auth.service.js, group.service.js,
│   │                      # catalogue.service.js, vote.service.js
│   └── .env               # VITE_API_URL=http://localhost/voyagevista-grouptrip/backend
└── database/
    ├── schema.sql          # Création des tables
    └── seed.sql            # Données de test
```

---

## Fonctionnalités

- Inscription / Connexion / Déconnexion
- Profil utilisateur (modification nom, email, mot de passe)
- Création de groupes de voyage, invitation de membres par email
- Vote pour la destination du groupe
- Tunnel de réservation : Transport → Hébergement → Activités → Itinéraire
- Annulation de transport et retrait d'activités depuis le panier
- Paiement simulé avec confirmation et référence (VV-2026-XXXX)
- Notifications (invitation, itinéraire, réservation) avec badge en temps réel
- Interface d'administration : ajout/suppression de destinations, hébergements, activités
