const express = require('express');
const cors = require('cors');
const db = require('./database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'bypass-tunnel-reminder']
}));
app.use(express.json());

// Logger middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// ---------- AUTH ----------

// POST /api/auth/login - returns JWT on success
app.post('/api/auth/login', (req, res) => {
  console.log("Auth Request (Login):", req.body);
  const { username, password } = req.body;
  if (!username || !password) {
    console.log("Auth Failure (Login): Missing username or password");
    return res.status(400).json({ error: 'Username and password required' });
  }
  db.get('SELECT * FROM users WHERE username = ?', [username], (err, user) => {
    if (err) {
      console.error("Auth Database Error (Login):", err.message);
      return res.status(500).json({ error: err.message });
    }
    if (!user) {
      console.log(`Auth Failure (Login): User '${username}' not found`);
      return res.status(401).json({ error: 'Invalid credentials. Please contact venue IT support.' });
    }
    bcrypt.compare(password, user.passwordHash, (err, isMatch) => {
      if (err) {
        console.error("Auth Bcrypt Error (Login):", err.message);
        return res.status(500).json({ error: err.message });
      }
      if (!isMatch) {
        console.log(`Auth Failure (Login): Incorrect password for user '${username}'`);
        return res.status(401).json({ error: 'Invalid credentials. Please contact venue IT support.' });
      }
      
      const token = jwt.sign(
        { userId: user.id, role: user.role }, 
        'ASTRO_SECURE_COMMERCIAL_KEY_2026', 
        { expiresIn: '1d' }
      );
      console.log(`Auth Success (Login): User '${username}' logged in successfully`);
      res.json({
        token,
        user: {
          id: user.id,
          username: user.username,
          role: user.role,
          name: user.name || user.username,
        },
      });
    });
  });
});

// GET /api/auth/me - returns the authenticated user's profile
app.get('/api/auth/me', verifyToken, (req, res) => {
  db.get(
    'SELECT id, username, role, name, phoneNumber, gender FROM users WHERE id = ?',
    [req.user.userId],
    (err, user) => {
      if (err) return res.status(500).json({ error: err.message });
      if (!user) return res.status(404).json({ error: 'User not found' });
      res.json({
        id: user.id,
        username: user.username,
        role: user.role,
        name: user.name || user.username,
        phoneNumber: user.phoneNumber || user.username,
        gender: user.gender || null,
      });
    }
  );
});

// POST /api/auth/register - registers a new customer with profile fields
app.post('/api/auth/register', (req, res) => {
  console.log("Auth Request (Register):", req.body);
  const { name, phoneNumber, gender, password, username } = req.body;
  const resolvedPhone = phoneNumber || username;

  if (!name || !resolvedPhone || !gender || !password) {
    console.log("Auth Failure (Register): Missing required registration fields");
    return res.status(400).json({ error: 'Name, phone number, gender, and password are required' });
  }

  const loginUsername = String(resolvedPhone).trim();

  db.get('SELECT * FROM users WHERE username = ? OR phoneNumber = ?', [loginUsername, loginUsername], (err, user) => {
    if (err) {
      console.error("Auth Database Error (Register):", err.message);
      return res.status(500).json({ error: err.message });
    }
    if (user) {
      console.log(`Auth Failure (Register): Phone '${loginUsername}' already registered`);
      return res.status(409).json({ error: 'This phone number is already registered' });
    }

    const salt = bcrypt.genSaltSync(10);
    const hash = bcrypt.hashSync(password, salt);

    db.run(
      'INSERT INTO users (username, passwordHash, role, name, phoneNumber, gender) VALUES (?, ?, ?, ?, ?, ?)',
      [loginUsername, hash, 'customer', String(name).trim(), loginUsername, String(gender).trim()],
      function (err) {
        if (err) {
          console.error("Auth Database Insert Error (Register):", err.message);
          return res.status(500).json({ error: err.message });
        }
        console.log(`Auth Success (Register): Customer '${name}' registered with ID ${this.lastID}`);
        res.status(201).json({ message: 'User registered successfully', userId: this.lastID });
      }
    );
  });
});

// JWT verification middleware (optional protection for demo)
function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).json({ error: 'Missing Authorization header' });
  const token = authHeader.split(' ')[1];
  jwt.verify(token, 'ASTRO_SECURE_COMMERCIAL_KEY_2026', (err, decoded) => {
    if (err) return res.status(401).json({ error: 'Invalid token' });
    req.user = decoded;
    next();
  });
}

// Role-based access control — must run after verifyToken
function requireRole(role) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }
    if (req.user.role !== role) {
      return res.status(403).json({ error: 'Forbidden: insufficient permissions' });
    }
    next();
  };
}

// ---------- MENU ROUTES ----------

// GET /api/menu
app.get('/api/menu', (req, res) => {
  db.all('SELECT * FROM menu_items', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows.map(row => ({
      id: row.id,
      name: row.name,
      description: row.description,
      category: row.category,
      smallPrice: row.smallPrice,
      regularPrice: row.regularPrice,
      imageUrl: row.imageUrl
    })));
  });
});

// POST /api/menu (admin only)
app.post('/api/menu', verifyToken, requireRole('admin'), (req, res) => {
  const { id, name, description, category, smallPrice, regularPrice, imageUrl } = req.body;
  if (!name || !category) {
    return res.status(400).json({ error: 'Name and category are required fields' });
  }

  if (id) {
    const sql = `UPDATE menu_items SET name = ?, description = ?, category = ?, smallPrice = ?, regularPrice = ?, imageUrl = ? WHERE id = ?`;
    const params = [name, description || '', category, smallPrice || 0.0, regularPrice || null, imageUrl || '', id];
    db.run(sql, params, function (err) {
      if (err) return res.status(500).json({ error: err.message });
      if (this.changes === 0) return res.status(404).json({ error: 'Menu item not found' });
      res.json({ message: 'Menu item updated successfully', id });
    });
    return;
  }

  const itemId = 'm_' + Date.now();
  const sql = `INSERT INTO menu_items (id, name, description, category, smallPrice, regularPrice, imageUrl) VALUES (?, ?, ?, ?, ?, ?, ?)`;
  const params = [itemId, name, description || '', category, smallPrice || 0.0, regularPrice || null, imageUrl || ''];
  db.run(sql, params, function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Menu item created successfully', id: itemId });
  });
});

// ---------- EVENTS ROUTES ----------

// GET /api/events
app.get('/api/events', (req, res) => {
  db.all('SELECT * FROM event_circles', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows.map(row => ({
      title: row.title,
      topic: row.topic,
      date: row.date,
      time: row.time,
      price: row.price,
      location: row.location,
      imagePath: row.imagePath,
      isFree: row.isFree === 1,
      ticketPrice: row.ticketPrice,
      maxCapacity: row.maxCapacity,
      joinedCount: row.joinedCount,
      isBookedByUser: row.isBookedByUser === 1,
      confirmedAttendeeCount: row.confirmedAttendeeCount
    })));
  });
});

// POST /api/events (admin only)
app.post('/api/events', verifyToken, requireRole('admin'), (req, res) => {
  const { title, topic, date, time, price, location, imagePath, isFree, ticketPrice, maxCapacity } = req.body;
  if (!title || !location) {
    return res.status(400).json({ error: 'Title and location are required fields' });
  }
  const sql = `INSERT INTO event_circles (title, topic, date, time, price, location, imagePath, isFree, ticketPrice, maxCapacity, joinedCount, isBookedByUser, confirmedAttendeeCount) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;
  const params = [
    title,
    topic || '',
    date || '',
    time || '',
    price || (isFree ? 'Free' : `${ticketPrice} JOD`),
    location,
    imagePath || 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?q=80&w=400',
    isFree ? 1 : 0,
    ticketPrice || 0.0,
    maxCapacity || 0,
    0,
    0,
    0
  ];
  db.run(sql, params, function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ message: 'Event circle created successfully', title });
  });
});

// POST /api/events/update (protected)
app.post('/api/events/update', verifyToken, (req, res) => {
  const { title, joinedCount, isBookedByUser, confirmedAttendeeCount } = req.body;
  if (!title) return res.status(400).json({ error: 'Event title is required for update' });
  const sql = `UPDATE event_circles SET joinedCount = ?, isBookedByUser = ?, confirmedAttendeeCount = ? WHERE title = ?`;
  const params = [joinedCount || 0, isBookedByUser ? 1 : 0, confirmedAttendeeCount || 0, title];
  db.run(sql, params, function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Event status updated successfully' });
  });
});

// PUT /api/events (QR check‑in, protected)
app.put('/api/events', verifyToken, (req, res) => {
  const { token } = req.body;
  if (!token || !token.startsWith('ASTRO_CHECKIN_')) {
    return res.status(400).json({ error: 'Invalid check-in token format. Expected: ASTRO_CHECKIN_${EventName}_${UserID}' });
  }
  const parts = token.split('_');
  if (parts.length < 4) return res.status(400).json({ error: 'Invalid check-in token segments' });
  const eventTitleParts = parts.slice(2, parts.length - 1);
  const eventTitle = eventTitleParts.join('_').replace(/%20/g, ' ').trim();
  db.all('SELECT title FROM event_circles', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    const matchedRow = rows.find(r => r.title.toLowerCase().replace(/[^a-z0-9]/g, '') === eventTitle.toLowerCase().replace(/[^a-z0-9]/g, ''));
    const targetTitle = matchedRow ? matchedRow.title : eventTitle;
    db.run(`UPDATE event_circles SET confirmedAttendeeCount = confirmedAttendeeCount + 1 WHERE title = ?`, [targetTitle], function (err) {
      if (err) return res.status(500).json({ error: err.message });
      if (this.changes === 0) return res.status(404).json({ error: `Event circle matching '${eventTitle}' was not found in active records` });
      db.get('SELECT * FROM event_circles WHERE title = ?', [targetTitle], (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({
          message: 'Scan verified! Attendance successfully logged.',
          event: {
            title: row.title,
            topic: row.topic,
            date: row.date,
            time: row.time,
            price: row.price,
            location: row.location,
            imagePath: row.imagePath,
            isFree: row.isFree === 1,
            ticketPrice: row.ticketPrice,
            maxCapacity: row.maxCapacity,
            joinedCount: row.joinedCount,
            isBookedByUser: row.isBookedByUser === 1,
            confirmedAttendeeCount: row.confirmedAttendeeCount
          }
        });
      });
    });
  });
});

// GET /api/analytics (admin only)
app.get('/api/analytics', verifyToken, requireRole('admin'), (req, res) => {
  const queryMenu = 'SELECT COUNT(*) as totalItems FROM menu_items';
  const queryEvents = 'SELECT COUNT(*) as totalEvents, SUM(joinedCount) as totalBookings, SUM(confirmedAttendeeCount) as totalCheckins FROM event_circles';
  db.get(queryMenu, [], (err, menuRow) => {
    if (err) return res.status(500).json({ error: err.message });
    db.get(queryEvents, [], (err, eventRow) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({
        totalMenuItems: menuRow.totalItems,
        totalEvents: eventRow.totalEvents || 0,
        totalBookings: eventRow.totalBookings || 0,
        totalCheckins: eventRow.totalCheckins || 0,
        averageAttendanceRate: eventRow.totalBookings > 0 ? Math.round((eventRow.totalCheckins / eventRow.totalBookings) * 100) : 0
      });
    });
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running locally at http://localhost:${PORT}`);
  console.log(`Accessible on local network via your machine's IP address.`);

// Note: The server now relies on ngrok for external exposure.
// Run `npm run tunnel` (which executes `ngrok http 3000`) to start the tunnel.
// The public URL will be printed by ngrok and must be set in the Flutter configuration.
// No longer using localtunnel, so the previous import and reconnection logic have been removed.
});
