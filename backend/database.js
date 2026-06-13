const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const bcrypt = require('bcryptjs');

const dbPath = path.resolve(__dirname, 'astrolabe.db');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening database', err.message);
  } else {
    console.log('Connected to the SQLite database.');
    initializeDatabase();
  }
});

function seedRetailMenuItems() {
  console.log('Seeding retail MenuItems catalog...');
  const stmt = db.prepare(
    `INSERT INTO menu_items (id, name, description, category, smallPrice, regularPrice, imageUrl) VALUES (?, ?, ?, ?, ?, ?, ?)`
  );

  // Coffee Bags
  stmt.run(
    'retail_cb_001',
    'Astrolabe House Blend - 1KG Bag',
    'Our signature balanced blend with rich chocolate and hazelnut notes, roasted locally.',
    'Coffee Bags',
    24.0,
    null,
    'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?q=80&w=400'
  );
  stmt.run(
    'retail_cb_002',
    'Ethiopia Sidamo Single-Origin - 250g',
    'Premium single-origin beans featuring bright floral aromas and distinct citrus overtones.',
    'Coffee Bags',
    9.5,
    null,
    'https://images.unsplash.com/photo-1447933601403-0c6686de566e?q=80&w=400'
  );
  stmt.run(
    'retail_cb_003',
    'Colombia Supremo - 500g Bag',
    'Medium-bodied single-origin selection with a smooth caramel finish.',
    'Coffee Bags',
    14.0,
    null,
    'https://images.unsplash.com/photo-1611854779393-48e982a7cc0f?q=80&w=400'
  );

  // Tea Merchandise
  stmt.run(
    'retail_tm_001',
    'Premium Signature Black Tea Box',
    'Hand-picked full-leaf black tea blend, 20 pyramid sachets.',
    'Tea Merchandise',
    6.0,
    null,
    'https://images.unsplash.com/photo-1564890369478-c89ca6d2cb05?q=80&w=400'
  );
  stmt.run(
    'retail_tm_002',
    'Organic Herbal Infusion Box',
    'A soothing caffeine-free blend of chamomile, mint, and local organic herbs.',
    'Tea Merchandise',
    6.5,
    null,
    'https://images.unsplash.com/photo-1597318181409-e75a6efd7a65?q=80&w=400'
  );

  // Brewing Hardware
  stmt.run(
    'retail_bh_001',
    'V60 Ceramic Dripper - Size 02',
    'Classic ceramic coffee dripper for precise pour-over extraction control.',
    'Brewing Hardware',
    18.0,
    null,
    'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?q=80&w=400'
  );
  stmt.run(
    'retail_bh_002',
    'Precision Gooseneck Matte Black Kettle',
    'Ergonomic temperature-stable gooseneck kettle for perfect water flow management.',
    'Brewing Hardware',
    35.0,
    null,
    'https://images.unsplash.com/photo-1571781926291-c477eb459024?q=80&w=400'
  );

  stmt.finalize();
}

function ensureUserProfileColumns() {
  db.all('PRAGMA table_info(users)', (err, columns) => {
    if (err || !columns) return;

    const columnNames = columns.map((column) => column.name);
    if (!columnNames.includes('name')) {
      db.run('ALTER TABLE users ADD COLUMN name TEXT');
    }
    if (!columnNames.includes('phoneNumber')) {
      db.run('ALTER TABLE users ADD COLUMN phoneNumber TEXT');
    }
    if (!columnNames.includes('gender')) {
      db.run('ALTER TABLE users ADD COLUMN gender TEXT');
    }
  });
}

function purgeLegacyMockData() {
  db.run("DELETE FROM menu_items WHERE id IN ('m1', 'm2', 'm3', 'm4')");
  db.run("DELETE FROM event_circles WHERE title IN ('The Traveler Circle', 'The Scholar Circle')");
  db.run("DELETE FROM users WHERE username = 'customer_demo'");
}

function ensureRetailCatalog() {
  db.get(
    "SELECT COUNT(*) as count FROM menu_items WHERE id LIKE 'retail_%'",
    (err, retailRow) => {
      if (err) return;

      const hasRetailCatalog = retailRow && retailRow.count >= 7;
      if (hasRetailCatalog) return;

      db.run('DELETE FROM menu_items', (deleteErr) => {
        if (deleteErr) {
          console.error('Failed to clear legacy menu_items:', deleteErr.message);
          return;
        }
        seedRetailMenuItems();
      });
    }
  );
}

function initializeDatabase() {
  db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS menu_items (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      category TEXT,
      smallPrice REAL NOT NULL,
      regularPrice REAL,
      imageUrl TEXT
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS event_circles (
      title TEXT PRIMARY KEY,
      topic TEXT,
      date TEXT,
      time TEXT,
      price TEXT,
      location TEXT,
      imagePath TEXT,
      isFree INTEGER DEFAULT 1,
      ticketPrice REAL DEFAULT 0.0,
      maxCapacity INTEGER DEFAULT 0,
      joinedCount INTEGER DEFAULT 0,
      isBookedByUser INTEGER DEFAULT 0,
      confirmedAttendeeCount INTEGER DEFAULT 0
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS user_stamps (
      id TEXT PRIMARY KEY,
      userId TEXT,
      title TEXT,
      description TEXT,
      dateEarned TEXT,
      branchName TEXT
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      passwordHash TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT 'customer',
      name TEXT,
      phoneNumber TEXT,
      gender TEXT
    )`);

    ensureUserProfileColumns();
    purgeLegacyMockData();
    ensureRetailCatalog();

    db.get('SELECT COUNT(*) as count FROM users WHERE username = ?', ['admin'], (err, row) => {
      if (err) return;

      if (row && row.count === 0) {
        console.log('Seeding admin staff account...');
        const salt = bcrypt.genSaltSync(10);
        const adminHash = bcrypt.hashSync('admin', salt);
        db.run(
          'INSERT INTO users (username, passwordHash, role) VALUES (?, ?, ?)',
          ['admin', adminHash, 'admin']
        );
      }
    });
  });
}

module.exports = db;
