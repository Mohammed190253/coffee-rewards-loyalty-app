import React, { createContext, useState, useContext, useCallback } from 'react';
import { API_BASE_URL } from '../config/apiConfig';

const AuthContext = createContext(null);

export const AUTH_TOKEN_KEY = 'astro_admin_token';
export const AUTH_USER_KEY = 'astro_admin_user';

function parseStoredUser(raw) {
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw);
    if (parsed && typeof parsed.username === 'string' && typeof parsed.role === 'string') {
      return {
        id: parsed.id,
        username: parsed.username,
        role: parsed.role,
      };
    }
    return null;
  } catch {
    return null;
  }
}

export const AuthProvider = ({ children }) => {
  const [token, setToken] = useState(() => {
    const stored = localStorage.getItem(AUTH_TOKEN_KEY);
    return stored?.trim() || null;
  });
  const [user, setUser] = useState(() => {
    return parseStoredUser(localStorage.getItem(AUTH_USER_KEY));
  });
  const [loading, setLoading] = useState(false);

  const getToken = useCallback(() => {
    const storedToken = localStorage.getItem(AUTH_TOKEN_KEY);
    if (storedToken?.trim()) {
      return storedToken.trim();
    }
    return token?.trim() || null;
  }, [token]);

  const login = async (username, password) => {
    setLoading(true);
    try {
      const res = await fetch(`${API_BASE_URL}/api/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'bypass-tunnel-reminder': 'true',
        },
        body: JSON.stringify({ username, password }),
      });
      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.error || 'Login failed. Please contact venue IT support.');
      }

      if (!data || typeof data.token !== 'string' || !data.token.trim()) {
        throw new Error('Login response missing a valid authentication token.');
      }

      if (!data.user || typeof data.user !== 'object') {
        throw new Error('Login response missing user profile data.');
      }

      const jwtToken = data.token.trim();
      const profile = {
        id: data.user.id,
        username: data.user.username,
        role: data.user.role,
      };

      if (!profile.username || !profile.role) {
        throw new Error('Login response user profile is incomplete.');
      }

      if (profile.role !== 'admin') {
        throw new Error('Access denied. Admin staff credentials are required for this portal.');
      }

      setToken(jwtToken);
      setUser(profile);
      localStorage.setItem(AUTH_TOKEN_KEY, jwtToken);
      localStorage.setItem(AUTH_USER_KEY, JSON.stringify(profile));

      return { success: true, user: profile };
    } catch (err) {
      return { success: false, error: err.message };
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem(AUTH_TOKEN_KEY);
    localStorage.removeItem(AUTH_USER_KEY);
  };

  return (
    <AuthContext.Provider
      value={{
        token,
        user,
        login,
        logout,
        getToken,
        isAuthenticated: Boolean(getToken()),
        loading,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
