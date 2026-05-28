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

function PrivateRoute({ children }) {
  const { user, loading } = useAuth();
  if (loading) return <div>Chargement...</div>;
  return user ? children : <Navigate to="/login" />;
}

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
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
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
