import React from 'react';
import { useAuth } from '../context/AuthContext';
import Login from '../pages/Login';

export default function ProtectedRoute({ children }) {
  const { isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <Login />;
  }

  return children;
}
