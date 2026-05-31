import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider, useAuth } from "./context/AuthContext";
import Navbar from "./components/Navbar";
import Home from "./pages/Home";
import Login from "./pages/Login";
import Register from "./pages/Register";
import Dashboard from "./pages/Dashboard";
import Catalogue from "./pages/Catalogue";
import GroupCreate from "./pages/GroupCreate";
import GroupDetail from "./pages/GroupDetail";
import Vote from "./pages/Vote";
import Transport from "./pages/Transport";
import Hebergement from "./pages/Hebergement";
import Activites from "./pages/Activites";
import Itineraire from "./pages/Itineraire";
import Panier from "./pages/Panier";
import Paiement from "./pages/Paiement";
import Profil from "./pages/Profil";
import Notifications from "./pages/Notifications";
import Admin from "./pages/Admin";
import DestinationDetail from "./pages/DestinationDetail";

function PrivateRoute({ children }) {
  const { user, loading } = useAuth();
  if (loading) return <div>Chargement...</div>;
  return user ? children : <Navigate to="/login" />;
}

function App() {
  return (
    <AuthProvider>
      <BrowserRouter basename="/voyagevista-grouptrip/frontend/dist">
        <Navbar />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route
            path="/dashboard"
            element={
              <PrivateRoute>
                <Dashboard />
              </PrivateRoute>
            }
          />
          <Route
            path="/catalogue"
            element={
              <PrivateRoute>
                <Catalogue />
              </PrivateRoute>
            }
          />
          <Route
            path="/groupes/creer"
            element={
              <PrivateRoute>
                <GroupCreate />
              </PrivateRoute>
            }
          />
          <Route
            path="/groupes/:id"
            element={
              <PrivateRoute>
                <GroupDetail />
              </PrivateRoute>
            }
          />
          <Route
            path="/groupes/:id/vote"
            element={
              <PrivateRoute>
                <Vote />
              </PrivateRoute>
            }
          />
          <Route
            path="/groupes/:id/transport"
            element={
              <PrivateRoute>
                <Transport />
              </PrivateRoute>
            }
          />
          <Route
            path="/groupes/:id/hebergement"
            element={
              <PrivateRoute>
                <Hebergement />
              </PrivateRoute>
            }
          />
          <Route
            path="/groupes/:id/activites"
            element={
              <PrivateRoute>
                <Activites />
              </PrivateRoute>
            }
          />
          <Route
            path="/groupes/:id/itineraire"
            element={
              <PrivateRoute>
                <Itineraire />
              </PrivateRoute>
            }
          />
          <Route
            path="/groupes/:id/panier"
            element={
              <PrivateRoute>
                <Panier />
              </PrivateRoute>
            }
          />
          <Route
            path="/groupes/:id/paiement"
            element={
              <PrivateRoute>
                <Paiement />
              </PrivateRoute>
            }
          />
          <Route
            path="/profil"
            element={
              <PrivateRoute>
                <Profil />
              </PrivateRoute>
            }
          />
          <Route
            path="/notifications"
            element={
              <PrivateRoute>
                <Notifications />
              </PrivateRoute>
            }
          />
          <Route
            path="/admin"
            element={
              <PrivateRoute>
                <Admin />
              </PrivateRoute>
            }
          />
          <Route
            path="/catalogue/destinations/:id"
            element={
              <PrivateRoute>
                <DestinationDetail />
              </PrivateRoute>
            }
          />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
