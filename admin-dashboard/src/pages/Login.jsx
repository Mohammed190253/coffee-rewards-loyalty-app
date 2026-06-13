import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { Coffee, Lock, User, AlertCircle, Loader } from 'lucide-react';

const PREMIUM_GOLD_BORDER = '1px solid rgba(212, 175, 55, 0.2)';

export default function Login() {
  const { login, loading } = useAuth();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    if (!username.trim() || !password.trim()) {
      setError('Please enter both username and password.');
      return;
    }
    const result = await login(username.trim(), password);
    if (!result.success) {
      setError(result.error || 'Invalid credentials. Please contact venue IT support.');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-tr from-astrolabe-teal via-astrolabe-teal to-astrolabe-tealLight relative overflow-hidden px-4">
      <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-astrolabe-gold/5 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-astrolabe-tealLight/40 rounded-full blur-[120px] pointer-events-none" />

      <div className="w-full max-w-md z-10">
        <div className="flex flex-col items-center mb-8">
          <div
            className="w-16 h-16 rounded-2xl bg-gradient-to-br from-astrolabe-gold to-astrolabe-goldLight flex items-center justify-center shadow-xl shadow-astrolabe-gold/10 mb-4"
            style={{ border: PREMIUM_GOLD_BORDER }}
          >
            <Coffee className="w-9 h-9 text-astrolabe-teal stroke-[2]" />
          </div>
          <h1 className="text-3xl font-bold text-astrolabe-cream tracking-wider">ASTROLABE</h1>
          <p className="text-sm text-astrolabe-goldLight mt-1 tracking-widest uppercase font-light">
            Sanctuary Workspace Portal
          </p>
        </div>

        <div
          className="bg-astrolabe-tealLight/80 backdrop-blur-md rounded-2xl p-8 shadow-2xl"
          style={{ border: PREMIUM_GOLD_BORDER }}
        >
          <h2 className="text-xl font-semibold text-astrolabe-cream mb-6">Staff Authentication</h2>

          <form onSubmit={handleSubmit} className="space-y-5">
            {error && (
              <div
                className="p-4 bg-rose-500/10 text-rose-200 text-xs rounded-xl flex items-start gap-2.5"
                style={{ border: '1px solid rgba(244, 63, 94, 0.3)' }}
              >
                <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
                <span>{error}</span>
              </div>
            )}

            <div>
              <label className="block text-xs font-semibold text-astrolabe-goldLight uppercase mb-2">
                Username
              </label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 pl-3.5 flex items-center text-astrolabe-gold">
                  <User className="w-4 h-4" />
                </span>
                <input
                  type="text"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  placeholder="Enter username"
                  className="w-full bg-astrolabe-teal border text-astrolabe-cream rounded-xl pl-10 pr-4 py-3 text-sm outline-none transition-all placeholder:text-astrolabe-goldLight/50 focus:border-astrolabe-gold/50"
                  style={{ border: PREMIUM_GOLD_BORDER }}
                  disabled={loading}
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-astrolabe-goldLight uppercase mb-2">
                Password
              </label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 pl-3.5 flex items-center text-astrolabe-gold">
                  <Lock className="w-4 h-4" />
                </span>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter password"
                  className="w-full bg-astrolabe-teal border text-astrolabe-cream rounded-xl pl-10 pr-4 py-3 text-sm outline-none transition-all placeholder:text-astrolabe-goldLight/50 focus:border-astrolabe-gold/50"
                  style={{ border: PREMIUM_GOLD_BORDER }}
                  disabled={loading}
                />
              </div>
            </div>

            <button
              type="submit"
              className="w-full py-3.5 bg-gradient-to-r from-astrolabe-gold to-astrolabe-goldLight hover:from-astrolabe-goldLight hover:to-astrolabe-gold text-astrolabe-teal font-bold rounded-xl text-sm tracking-wider uppercase transition shadow-lg shadow-astrolabe-gold/10 flex items-center justify-center gap-2 mt-8"
              style={{ border: PREMIUM_GOLD_BORDER }}
              disabled={loading}
            >
              {loading ? (
                <>
                  <Loader className="w-4 h-4 animate-spin" />
                  Verifying Credentials...
                </>
              ) : (
                'Sign In to Dashboard'
              )}
            </button>
          </form>
        </div>

        <div className="text-center mt-8 text-xs text-astrolabe-goldLight/70">
          <p>© 2026 Astrolabe Sanctuary Cafe. All rights reserved.</p>
          <p className="mt-1 text-astrolabe-goldLight/50">Enterprise SaaS Demo Environment</p>
        </div>
      </div>
    </div>
  );
}
