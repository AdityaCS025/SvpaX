const mongoose = require('mongoose');

const ReminderSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  dateTime: { type: Date, required: true },
  repeat: {
    type: String,
    enum: ['none', 'daily', 'weekly', 'monthly', 'yearly'],
    default: 'none'
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium'
  },
  completed: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('Reminder', ReminderSchema);
