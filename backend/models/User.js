const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  preferences: {
    type: Object,
    default: {}
  }
}, {
  timestamps: true // This adds createdAt and updatedAt fields automatically
});

// Create index for email for faster queries
UserSchema.index({ email: 1 });

module.exports = mongoose.model('User', UserSchema);
