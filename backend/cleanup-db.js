require('dotenv').config();
const mongoose = require('mongoose');

async function cleanupDatabase() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');

    const db = mongoose.connection.db;

    // Drop the problematic username index if it exists
    try {
      await db.collection('users').dropIndex('username_1');
      console.log('Dropped username index');
    } catch (err) {
      console.log('Username index not found or already dropped');
    }

    // List all indexes
    const indexes = await db.collection('users').indexes();
    console.log('Current indexes:', indexes);

    console.log('Database cleanup completed');
    process.exit(0);
  } catch (error) {
    console.error('Cleanup error:', error);
    process.exit(1);
  }
}

cleanupDatabase();