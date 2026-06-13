import React, { useState, useEffect } from 'react';
import { 
  Coffee, 
  Calendar, 
  Users, 
  Plus, 
  CheckCircle, 
  TrendingUp, 
  MapPin, 
  Clock, 
  DollarSign, 
  Layers, 
  ShieldCheck, 
  Activity,
  Edit2,
  LogOut
} from 'lucide-react';
import { AuthProvider, useAuth } from './context/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';
import KPIGrid from './components/dashboard/KPIGrid';
import { API_BASE_URL } from './config/apiConfig';

const API_BASE = API_BASE_URL;
const PREMIUM_GOLD_BORDER = '1px solid rgba(212, 175, 55, 0.2)';

function AppContent() {
  const [activeTab, setActiveTab] = useState('analytics');
  const { token, logout, user, getToken } = useAuth();
  
  // Data States
  const [analytics, setAnalytics] = useState({
    totalMenuItems: 0,
    totalEvents: 0,
    totalBookings: 0,
    totalCheckins: 0,
    averageAttendanceRate: 0
  });
  const [menuItems, setMenuItems] = useState([]);
  const [events, setEvents] = useState([]);
  
  // Loading & Action States
  const [loading, setLoading] = useState(false);
  const [feedback, setFeedback] = useState({ type: '', message: '' });
  
  // Modal / Form States
  const [isMenuModalOpen, setIsMenuModalOpen] = useState(false);
  const [menuForm, setMenuForm] = useState({
    id: '',
    name: '',
    description: '',
    category: 'Coffee',
    smallPrice: '',
    regularPrice: '',
    imageUrl: ''
  });
  const [isEditingMenu, setIsEditingMenu] = useState(false);

  const [eventForm, setEventForm] = useState({
    title: '',
    topic: '',
    date: '',
    time: '',
    location: 'Abdoun Branch',
    imagePath: '',
    isFree: true,
    ticketPrice: '',
    maxCapacity: ''
  });

  const [scanToken, setScanToken] = useState('');
  const [scanStatus, setScanStatus] = useState(null);

  const showFeedback = (type, message) => {
    setFeedback({ type, message });
    setTimeout(() => setFeedback({ type: '', message: '' }), 5000);
  };

  const getAuthHeaders = (includeJsonContentType = false) => {
    const token = getToken();
    if (!token) {
      throw new Error('No authentication token available. Please sign in again.');
    }

    return {
      ...(includeJsonContentType && { 'Content-Type': 'application/json' }),
      Authorization: `Bearer ${token}`,
      'bypass-tunnel-reminder': 'true',
    };
  };

  const handleUnauthorized = (status, errorMessage) => {
    if (status === 401 || errorMessage === 'Invalid token') {
      logout();
      showFeedback('error', 'Your session has expired. Please sign in again.');
      return true;
    }
    return false;
  };

  const fetchTabData = async (tab) => {
    try {
      if (!getToken()) return;

      setLoading(true);
      const headers = getAuthHeaders();

      if (tab === 'analytics') {
        const res = await fetch(`${API_BASE}/api/analytics`, { headers });
        const data = await res.json();
        setAnalytics(data);
      } else if (tab === 'menu') {
        const res = await fetch(`${API_BASE}/api/menu`, { headers });
        const data = await res.json();
        setMenuItems(data);
      } else if (tab === 'events' || tab === 'checkin') {
        const res = await fetch(`${API_BASE}/api/events`, { headers });
        const data = await res.json();
        setEvents(data);
      }
    } catch (err) {
      console.error('Error connecting to backend API server', err);
      if (err.message?.includes('authentication token')) {
        showFeedback('error', err.message);
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!getToken()) return;

    fetchTabData(activeTab);

    const interval = setInterval(() => fetchTabData(activeTab), 10000);
    return () => clearInterval(interval);
  }, [token, activeTab, getToken]);

  // Create or Update Menu Item
  const handleMenuSubmit = async (e) => {
    e.preventDefault();
    try {
      const payload = {
        name: menuForm.name,
        category: menuForm.category,
        description: menuForm.description,
        smallPrice: parseFloat(menuForm.smallPrice) || 0,
        regularPrice: menuForm.regularPrice ? parseFloat(menuForm.regularPrice) : null,
        imageUrl: menuForm.imageUrl || '',
      };
      if (menuForm.id) {
        payload.id = menuForm.id;
      }

      const url = `${API_BASE}/api/menu`;
      const res = await fetch(url, {
        method: 'POST',
        headers: getAuthHeaders(true),
        body: JSON.stringify(payload),
      });

      if (res.ok) {
        showFeedback('success', isEditingMenu ? 'Menu item updated successfully!' : 'New Menu item added successfully!');
        setIsMenuModalOpen(false);
        setMenuForm({ id: '', name: '', description: '', category: 'Coffee', smallPrice: '', regularPrice: '', imageUrl: '' });
        setIsEditingMenu(false);
        fetchTabData('menu');
      } else {
        const err = await res.json();
        if (!handleUnauthorized(res.status, err.error)) {
          showFeedback('error', err.error || 'Failed to save menu item');
        }
      }
    } catch (err) {
      showFeedback('error', err.message || 'Network failure connecting to server');
    }
  };

  // Open modal to add menu
  const openAddMenuModal = () => {
    setMenuForm({ id: '', name: '', description: '', category: 'Coffee', smallPrice: '', regularPrice: '', imageUrl: '' });
    setIsEditingMenu(false);
    setIsMenuModalOpen(true);
  };

  // Open modal to edit menu
  const openEditMenuModal = (item) => {
    setMenuForm({
      id: item.id,
      name: item.name,
      description: item.description,
      category: item.category,
      smallPrice: item.smallPrice.toString(),
      regularPrice: item.regularPrice ? item.regularPrice.toString() : '',
      imageUrl: item.imageUrl || ''
    });
    setIsEditingMenu(true);
    setIsMenuModalOpen(true);
  };

  // Create Event Circle
  const handleEventSubmit = async (e) => {
    e.preventDefault();
    try {
      const payload = {
        ...eventForm,
        isFree: eventForm.isFree,
        ticketPrice: eventForm.isFree ? 0 : parseFloat(eventForm.ticketPrice) || 0,
        maxCapacity: parseInt(eventForm.maxCapacity) || 0,
      };

      const res = await fetch(`${API_BASE}/api/events`, {
        method: 'POST',
        headers: getAuthHeaders(true),
        body: JSON.stringify(payload),
      });

      if (res.ok) {
        showFeedback('success', 'Circle Event registered and broadcasted successfully!');
        setEventForm({
          title: '',
          topic: '',
          date: '',
          time: '',
          location: 'Abdoun Branch',
          imagePath: '',
          isFree: true,
          ticketPrice: '',
          maxCapacity: ''
        });
        setActiveTab('analytics');
      } else {
        const err = await res.json();
        showFeedback('error', err.error || 'Failed to create event');
      }
    } catch (err) {
      showFeedback('error', err.message || 'Network failure connecting to server');
    }
  };

  // Simulate Check-In QR scan
  const handleScanSubmit = async (e) => {
    e.preventDefault();
    if (!scanToken.trim()) return;

    try {
      const res = await fetch(`${API_BASE}/api/events`, {
        method: 'PUT',
        headers: getAuthHeaders(true),
        body: JSON.stringify({ token: scanToken }),
      });

      const data = await res.json();
      if (res.ok) {
        setScanStatus({
          success: true,
          message: data.message,
          event: data.event
        });
        setScanToken('');
        fetchTabData(activeTab);
      } else {
        setScanStatus({
          success: false,
          message: data.error || 'Failed to process check-in token'
        });
      }
    } catch (err) {
      setScanStatus({
        success: false,
        message: 'Network error connecting to verification system'
      });
    }
  };

  const handleLogout = () => {
    setActiveTab('analytics');
    setAnalytics({
      totalMenuItems: 0,
      totalEvents: 0,
      totalBookings: 0,
      totalCheckins: 0,
      averageAttendanceRate: 0,
    });
    setMenuItems([]);
    setEvents([]);
    setFeedback({ type: '', message: '' });
    setIsMenuModalOpen(false);
    setScanStatus(null);
    logout();
  };

  return (
    <div className="min-h-screen flex bg-slate-50">
      {/* SIDEBAR NAVIGATION */}
      <aside className="w-64 bg-astrolabe-teal text-white flex flex-col min-h-screen border-r border-astrolabe-gold/20">
        <div className="p-6 border-b border-white/5">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-amber-400 to-amber-500 flex items-center justify-center text-slate-950 font-bold shadow-lg shadow-amber-500/10">
              <Coffee className="w-6 h-6 stroke-[2]" />
            </div>
            <div>
              <h1 className="font-bold text-base tracking-wider text-slate-100">ASTROLABE</h1>
              <p className="text-[10px] text-slate-400 tracking-widest font-light uppercase">ADMIN PORTAL</p>
            </div>
          </div>
        </div>

        {/* User Badge */}
        <div className="px-6 py-4 border-b border-white/5 bg-slate-950/20">
          <p className="text-xs text-slate-500 font-medium">Logged in as</p>
          <p className="text-sm font-semibold text-slate-300">{user?.username || 'Administrator'}</p>
        </div>

        <nav className="flex-1 p-4 space-y-1">
          <button
            onClick={() => setActiveTab('analytics')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm transition-all ${
              activeTab === 'analytics' 
                ? 'bg-amber-500/10 text-amber-400 font-semibold border-l-4 border-amber-500 pl-3' 
                : 'text-slate-400 hover:bg-white/5 hover:text-white'
            }`}
          >
            <Activity className="w-4 h-4" />
            Analytics Overview
          </button>
          
          <button
            onClick={() => setActiveTab('menu')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm transition-all ${
              activeTab === 'menu' 
                ? 'bg-amber-500/10 text-amber-400 font-semibold border-l-4 border-amber-500 pl-3' 
                : 'text-slate-400 hover:bg-white/5 hover:text-white'
            }`}
          >
            <Coffee className="w-4 h-4" />
            Menu Management
          </button>

          <button
            onClick={() => setActiveTab('events')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm transition-all ${
              activeTab === 'events' 
                ? 'bg-amber-500/10 text-amber-400 font-semibold border-l-4 border-amber-500 pl-3' 
                : 'text-slate-400 hover:bg-white/5 hover:text-white'
            }`}
          >
            <Calendar className="w-4 h-4" />
            Circle Event Manager
          </button>

          <button
            onClick={() => setActiveTab('checkin')}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm transition-all ${
              activeTab === 'checkin' 
                ? 'bg-amber-500/10 text-amber-400 font-semibold border-l-4 border-amber-500 pl-3' 
                : 'text-slate-400 hover:bg-white/5 hover:text-white'
            }`}
          >
            <ShieldCheck className="w-4 h-4" />
            Check-In Scanner
          </button>
        </nav>

        <div className="mt-auto p-4 border-t border-astrolabe-gold/10 space-y-3">
          <button
            type="button"
            onClick={handleLogout}
            className="w-full flex items-center justify-center gap-3 px-4 py-3 rounded-2xl text-sm font-semibold text-astrolabe-goldLight bg-astrolabe-tealLight/40 hover:text-astrolabe-gold hover:bg-astrolabe-tealLight/70 hover:border-astrolabe-gold/40 transition-all duration-200"
            style={{ border: PREMIUM_GOLD_BORDER }}
            aria-label="Log Out"
          >
            <LogOut className="w-4 h-4 shrink-0" />
            Log Out
          </button>

          <div className="text-center">
            <div
              className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-[10px] text-astrolabe-goldLight border border-astrolabe-gold/20 bg-astrolabe-tealLight/30"
            >
              <span className="w-1.5 h-1.5 rounded-full bg-astrolabe-gold animate-pulse" />
              Secured Session Active
            </div>
          </div>
        </div>
      </aside>

      {/* MAIN CONTAINER */}
      <main className="flex-1 flex flex-col overflow-y-auto">
        <header className="bg-white border-b border-slate-200 px-8 py-4.5 flex items-center justify-between shadow-sm">
          <h2 className="text-lg font-bold text-slate-800 tracking-wide capitalize">
            {activeTab.replace('-', ' ')}
          </h2>
          <div className="flex items-center gap-4">
            <button 
              onClick={() => fetchTabData(activeTab)} 
              className="text-xs px-3 py-1.5 border border-slate-200 hover:bg-slate-50 rounded-lg text-slate-600 transition font-medium"
            >
              Refresh Data
            </button>
            <div className="text-xs text-slate-400 font-light">
              System Time: {new Date().toLocaleTimeString()}
            </div>
          </div>
        </header>

        {/* FEEDBACK BANNER */}
        {feedback.message && (
          <div className={`mx-8 mt-6 p-4 rounded-xl flex items-center gap-3 text-sm shadow-sm ${
            feedback.type === 'success' ? 'bg-emerald-50 text-emerald-800 border border-emerald-200' : 'bg-rose-50 text-rose-800 border border-rose-200'
          }`}>
            <span className="font-bold">{feedback.type === 'success' ? '✓' : '✗'}</span>
            {feedback.message}
          </div>
        )}

        <div className="p-8">
          {/* 1. ANALYTICS OVERVIEW */}
          {activeTab === 'analytics' && (
            <div className="space-y-8">
              <KPIGrid metrics={analytics} />

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm lg:col-span-1 flex flex-col justify-between">
                  <div>
                    <h4 className="text-xs font-bold text-slate-800 tracking-wider uppercase">Attendance Rate</h4>
                    <p className="text-xs text-slate-400 mt-1">Percentage of bookers who checked in</p>
                  </div>
                  <div className="my-6 flex items-baseline gap-2">
                    <span className="text-5xl font-black text-slate-800">{analytics.averageAttendanceRate}%</span>
                    <TrendingUp className="w-6 h-6 text-emerald-500" />
                  </div>
                  <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                    <div 
                      className="bg-amber-500 h-full rounded-full transition-all duration-500" 
                      style={{ width: `${analytics.averageAttendanceRate}%` }}
                    />
                  </div>
                </div>

                <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm lg:col-span-2">
                  <h4 className="text-xs font-bold text-slate-800 mb-4 uppercase tracking-wider">Live Circles Enrollment</h4>
                  <div className="space-y-4">
                    {events.length === 0 ? (
                      <p className="text-xs text-slate-400">No active events created yet.</p>
                    ) : (
                      events.map(ev => {
                        const fillPercent = Math.min(100, Math.round((ev.joinedCount / ev.maxCapacity) * 100)) || 0;
                        return (
                          <div key={ev.title} className="p-4 border border-slate-100 rounded-xl">
                            <div className="flex justify-between items-center text-xs mb-1.5">
                              <span className="font-bold text-slate-700">{ev.title}</span>
                              <span className="text-slate-400 font-mono">{ev.joinedCount} / {ev.maxCapacity} chairs</span>
                            </div>
                            <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                              <div 
                                className="bg-slate-800 h-full rounded-full" 
                                style={{ width: `${fillPercent}%` }}
                              />
                            </div>
                            <div className="flex justify-between text-[10px] text-slate-400 mt-2">
                              <span className="flex items-center gap-1"><MapPin className="w-3 h-3" /> {ev.location}</span>
                              <span className="flex items-center gap-1 text-emerald-600 font-semibold"><CheckCircle className="w-3 h-3" /> {ev.confirmedAttendeeCount} Checked-in</span>
                            </div>
                          </div>
                        )
                      })
                    )}
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'menu' && (
            <div className="space-y-6">
              <div className="flex justify-between items-center">
                <p className="text-xs text-slate-400">Manage beverage menu items, categories, and size-specific pricing tiers.</p>
                <button
                  onClick={openAddMenuModal}
                  className="bg-slate-900 hover:bg-slate-800 text-white px-4.5 py-2.5 rounded-xl text-xs font-bold flex items-center gap-2 transition shadow-sm border border-white/10"
                >
                  <Plus className="w-4 h-4 text-amber-400" />
                  Add Menu Item
                </button>
              </div>

              <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-slate-50 border-b border-slate-100 text-slate-400 text-[10px] font-bold uppercase tracking-wider">
                      <th className="p-4">Name</th>
                      <th className="p-4">Category</th>
                      <th className="p-4">Description</th>
                      <th className="p-4">Small Price</th>
                      <th className="p-4">Regular Price</th>
                      <th className="p-4 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 text-sm text-slate-700">
                    {menuItems.length === 0 ? (
                      <tr>
                        <td colSpan="6" className="p-8 text-center text-slate-400 text-xs">No items available. Click "Add Menu Item" to seed.</td>
                      </tr>
                    ) : (
                      menuItems.map(item => (
                        <tr key={item.id} className="hover:bg-slate-50/50">
                          <td className="p-4 font-bold text-slate-800">{item.name}</td>
                          <td className="p-4">
                            <span className="px-2.5 py-1 bg-slate-100 text-slate-600 rounded-full text-[10px] font-bold uppercase tracking-wider">
                              {item.category}
                            </span>
                          </td>
                          <td className="p-4 max-w-xs truncate text-slate-500 text-xs">{item.description}</td>
                          <td className="p-4 font-mono font-semibold text-slate-600 text-xs">{item.smallPrice?.toFixed(2)} JOD</td>
                          <td className="p-4 font-mono font-semibold text-slate-600 text-xs">{item.regularPrice ? `${item.regularPrice.toFixed(2)} JOD` : '—'}</td>
                          <td className="p-4 text-right">
                            <button
                              onClick={() => openEditMenuModal(item)}
                              className="text-amber-500 hover:text-slate-800 transition p-1.5 hover:bg-slate-100 rounded-lg"
                            >
                              <Edit2 className="w-3.5 h-3.5" />
                            </button>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {activeTab === 'events' && (
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              <div className="lg:col-span-1 bg-white p-6 rounded-2xl border border-slate-100 shadow-sm self-start">
                <h3 className="font-bold text-slate-800 border-b border-slate-100 pb-3 mb-4 uppercase tracking-wider text-xs">Create Circle Event</h3>
                <form onSubmit={handleEventSubmit} className="space-y-4">
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Event Title</label>
                    <input
                      type="text"
                      required
                      value={eventForm.title}
                      onChange={e => setEventForm({ ...eventForm, title: e.target.value })}
                      placeholder="e.g. The Philosopher Circle"
                      className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                    />
                  </div>

                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Event Topic</label>
                    <input
                      type="text"
                      value={eventForm.topic}
                      onChange={e => setEventForm({ ...eventForm, topic: e.target.value })}
                      placeholder="e.g. Dialogue on Stoicism"
                      className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Date</label>
                      <input
                        type="text"
                        placeholder="May 25, 2026"
                        value={eventForm.date}
                        onChange={e => setEventForm({ ...eventForm, date: e.target.value })}
                        className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Time</label>
                      <input
                        type="text"
                        placeholder="7:00 PM"
                        value={eventForm.time}
                        onChange={e => setEventForm({ ...eventForm, time: e.target.value })}
                        className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Location Branch</label>
                    <select
                      value={eventForm.location}
                      onChange={e => setEventForm({ ...eventForm, location: e.target.value })}
                      className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                    >
                      <option value="Abdoun Branch">Abdoun Branch</option>
                      <option value="Dabouq Branch">Dabouq Branch</option>
                      <option value="Jabal Al-Lweibdeh Branch">Jabal Al-Lweibdeh Branch</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Banner Image Url</label>
                    <input
                      type="url"
                      placeholder="https://..."
                      value={eventForm.imagePath}
                      onChange={e => setEventForm({ ...eventForm, imagePath: e.target.value })}
                      className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                    />
                  </div>

                  <div className="border-t border-slate-100 pt-3">
                    <label className="flex items-center gap-2.5 cursor-pointer mb-3">
                      <input
                        type="checkbox"
                        checked={eventForm.isFree}
                        onChange={e => setEventForm({ ...eventForm, isFree: e.target.checked, ticketPrice: '' })}
                        className="rounded border-slate-300 text-amber-500 focus:ring-amber-500/50"
                      />
                      <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">This is a free event</span>
                    </label>

                    {!eventForm.isFree && (
                      <div>
                        <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Ticket Price (JOD)</label>
                        <input
                          type="number"
                          step="0.01"
                          required
                          value={eventForm.ticketPrice}
                          onChange={e => setEventForm({ ...eventForm, ticketPrice: e.target.value })}
                          placeholder="e.g. 10.00"
                          className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                        />
                      </div>
                    )}
                  </div>

                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Maximum Seats Capacity</label>
                    <input
                      type="number"
                      required
                      value={eventForm.maxCapacity}
                      onChange={e => setEventForm({ ...eventForm, maxCapacity: e.target.value })}
                      placeholder="e.g. 20"
                      className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                    />
                  </div>

                  <button
                    type="submit"
                    className="w-full bg-slate-900 hover:bg-slate-800 text-white py-2.5 rounded-xl text-xs font-bold transition mt-2 border border-white/10"
                  >
                    Broadcast to Mobile Clients
                  </button>
                </form>
              </div>

              <div className="lg:col-span-2 space-y-4">
                <h3 className="font-bold text-slate-800 uppercase tracking-wider text-xs">Active Circles Directory</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {events.map(ev => (
                    <div key={ev.title} className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden flex flex-col justify-between">
                      <div>
                        <img 
                          src={ev.imagePath} 
                          alt={ev.title} 
                          className="w-full h-36 object-cover"
                          onError={(e) => {
                            e.target.src = 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?q=80&w=400';
                          }}
                        />
                        <div className="p-5 space-y-2">
                           <div className="flex justify-between items-start gap-2">
                            <span className={`text-[9px] px-2.5 py-0.5 rounded-full font-bold uppercase tracking-wider border ${
                              ev.isFree 
                                ? 'bg-emerald-50 text-emerald-700 border-emerald-100' 
                                : 'bg-amber-50 text-amber-700 border-amber-100'
                            }`}>
                              {ev.isFree ? 'Free Circle' : `${ev.ticketPrice?.toFixed(2)} JOD`}
                            </span>
                            <span className="text-[10px] text-slate-400 font-semibold flex items-center gap-1">
                              <MapPin className="w-3.5 h-3.5" /> {ev.location}
                            </span>
                          </div>
                          <h4 className="font-bold text-slate-800">{ev.title}</h4>
                          <p className="text-xs text-slate-500 leading-relaxed">{ev.topic}</p>
                        </div>
                      </div>

                      <div className="px-5 py-4 border-t border-slate-50 bg-slate-50/50 flex justify-between items-center text-xs text-slate-500">
                        <span className="flex items-center gap-1 font-semibold text-slate-500"><Clock className="w-3.5 h-3.5" /> {ev.date} @ {ev.time}</span>
                        <span className="font-bold text-slate-700">{ev.joinedCount} / {ev.maxCapacity} seats</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {activeTab === 'checkin' && (
            <div className="max-w-xl mx-auto space-y-6">
              <div className="bg-white p-8 rounded-2xl border border-slate-100 shadow-sm text-center space-y-6">
                <div className="w-16 h-16 bg-amber-500/10 text-amber-500 rounded-2xl flex items-center justify-center mx-auto border border-amber-500/10">
                  <ShieldCheck className="w-8 h-8" />
                </div>
                <div>
                  <h3 className="text-base font-bold text-slate-800 uppercase tracking-wider">Mobile QR Check-In Simulator</h3>
                  <p className="text-xs text-slate-400 mt-1 max-w-sm mx-auto">
                    Simulate scanning the QR code generated on the customer's phone during ticket claims. Entering the code increments check-in counts in real-time.
                  </p>
                </div>

                <form onSubmit={handleScanSubmit} className="space-y-4 text-left">
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1.5">Verification QR Payload Token</label>
                    <input
                      type="text"
                      required
                      placeholder="e.g. ASTRO_CHECKIN_The Traveler Circle_userId123"
                      value={scanToken}
                      onChange={e => setScanToken(e.target.value)}
                      className="w-full border border-slate-200 rounded-xl p-3 text-xs font-mono tracking-wide focus:border-amber-500/50 outline-none transition"
                    />
                  </div>
                  <div className="flex gap-2">
                    <button
                      type="button"
                      onClick={() => setScanToken(`ASTRO_CHECKIN_The Traveler Circle_u${Math.floor(Math.random() * 1000)}`)}
                      className="text-[10px] font-bold uppercase tracking-wider px-3.5 py-2 border border-slate-200 text-slate-600 rounded-lg hover:bg-slate-50 transition"
                    >
                      Fill Traveler Demo
                    </button>
                    <button
                      type="button"
                      onClick={() => setScanToken(`ASTRO_CHECKIN_The Scholar Circle_u${Math.floor(Math.random() * 1000)}`)}
                      className="text-[10px] font-bold uppercase tracking-wider px-3.5 py-2 border border-slate-200 text-slate-600 rounded-lg hover:bg-slate-50 transition"
                    >
                      Fill Scholar Demo
                    </button>
                  </div>
                  <button
                    type="submit"
                    className="w-full bg-slate-900 hover:bg-slate-800 text-white py-3.5 rounded-xl text-xs font-bold tracking-wider transition border border-white/10"
                  >
                    VERIFY & LOG ATTENDANCE
                  </button>
                </form>

                {scanStatus && (
                  <div className={`p-4 rounded-xl border text-left space-y-2 ${
                    scanStatus.success 
                      ? 'bg-emerald-50 border-emerald-100 text-emerald-800' 
                      : 'bg-rose-50 border-rose-100 text-rose-800'
                  }`}>
                    <div className="flex items-center gap-2 font-bold text-sm">
                      <span>{scanStatus.success ? '✓ Verification Successful' : '✗ Verification Failed'}</span>
                    </div>
                    <p className="text-xs">{scanStatus.message}</p>
                    {scanStatus.success && scanStatus.event && (
                      <div className="bg-white/85 p-3 rounded-lg border border-emerald-200/50 mt-2 text-xs space-y-1">
                        <div><span className="font-semibold text-slate-700">Circle Event:</span> {scanStatus.event.title}</div>
                        <div><span className="font-semibold text-slate-700">Confirmed Attendees:</span> {scanStatus.event.confirmedAttendeeCount} / {scanStatus.event.joinedCount}</div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      </main>

      {isMenuModalOpen && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50">
          <div className="bg-white rounded-2xl border border-slate-100 shadow-2xl p-6 w-full max-w-md space-y-4 animate-in fade-in zoom-in duration-150">
            <h3 className="font-bold text-slate-800 text-sm border-b border-slate-100 pb-2">
              {isEditingMenu ? 'Edit Menu Item' : 'Add New Menu Item'}
            </h3>
            <form onSubmit={handleMenuSubmit} className="space-y-4">
              <div>
                <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Item Name</label>
                <input
                  type="text"
                  required
                  value={menuForm.name}
                  onChange={e => setMenuForm({ ...menuForm, name: e.target.value })}
                  placeholder="e.g. Iced Latte"
                  className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                />
              </div>

              <div>
                <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Category</label>
                <select
                  value={menuForm.category}
                  onChange={e => setMenuForm({ ...menuForm, category: e.target.value })}
                  className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                >
                  <option value="Coffee">Coffee</option>
                  <option value="Bakery">Bakery</option>
                  <option value="Beverages">Beverages</option>
                </select>
              </div>

              <div>
                <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Description</label>
                <textarea
                  value={menuForm.description}
                  onChange={e => setMenuForm({ ...menuForm, description: e.target.value })}
                  placeholder="Premium blend espresso poured over milk..."
                  rows="2"
                  className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Small Price (Required)</label>
                  <input
                    type="number"
                    step="0.01"
                    required
                    value={menuForm.smallPrice}
                    onChange={e => setMenuForm({ ...menuForm, smallPrice: e.target.value })}
                    placeholder="1.80"
                    className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                  />
                </div>
                <div>
                  <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Reg Price (Optional)</label>
                  <input
                    type="number"
                    step="0.01"
                    value={menuForm.regularPrice}
                    onChange={e => setMenuForm({ ...menuForm, regularPrice: e.target.value })}
                    placeholder="2.50 (leave empty for single-size)"
                    className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[10px] font-bold text-slate-400 uppercase mb-1">Image URL</label>
                <input
                  type="url"
                  value={menuForm.imageUrl}
                  onChange={e => setMenuForm({ ...menuForm, imageUrl: e.target.value })}
                  placeholder="https://..."
                  className="w-full border border-slate-200 rounded-xl p-2.5 text-xs focus:border-amber-500/50 outline-none transition"
                />
              </div>

              <div className="flex gap-3 justify-end pt-2">
                <button
                  type="button"
                  onClick={() => setIsMenuModalOpen(false)}
                  className="px-4 py-2 border border-slate-200 text-slate-600 rounded-xl text-xs hover:bg-slate-50 transition"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-slate-900 text-white px-4 py-2 rounded-xl text-xs font-bold hover:bg-slate-800 transition border border-white/10"
                >
                  Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <ProtectedRoute>
        <AppContent />
      </ProtectedRoute>
    </AuthProvider>
  );
}
