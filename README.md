# VoyageVista — GroupTrip
Plateforme collaborative de planification de voyages en groupe.

## Équipe
- Gabin Kerevel
- Aurélien Kammerer
- Brice Fargeat
- Isiah Perelman

## Stack
- Frontend : React (Vite)
- Backend : PHP REST API
- Base de données : MySQL

## Installation

### 1. Base de données
```sql
mysql -u root -p < database/schema.sql
mysql -u root -p voyagevista < database/seed.sql
```

### 2. Backend
```bash
cd backend
# Configurer backend/config/database.php avec vos identifiants MySQL
# Lancer avec XAMPP/WAMP ou PHP built-in server :
php -S localhost:8000
```

### 3. Frontend
```bash
cd frontend
npm install
cp .env.example .env   # éditer VITE_API_URL=http://localhost:8000
npm run dev
```

L'application sera disponible sur http://localhost:5173
