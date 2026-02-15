import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './pages/LoginPage';
import WelcomePage from './pages/WelcomePage';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);

  const handleLogin = (userData, authToken) => {
    setIsAuthenticated(true);
    setUser(userData);
    setToken(authToken);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setUser(null);
    setToken(null);
  };

  return (
    <Router>
      <div className="App">
        <Routes>
          <Route
            path="/"
            element={isAuthenticated ? (
              <Navigate to="/welcome" replace />
            ) : (
              <LoginPage onLogin={handleLogin} />
            )}
          />
          <Route
            path="/login"
            element={isAuthenticated ? (
              <Navigate to="/welcome" replace />
            ) : (
              <LoginPage onLogin={handleLogin} />
            )}
          />
          <Route
            path="/welcome"
            element={isAuthenticated ? (
              <WelcomePage user={user} token={token} onLogout={handleLogout} />
            ) : (
              <Navigate to="/login" replace />
            )}
          />
        </Routes>
      </div>
    </Router>
  );
}

export default App;