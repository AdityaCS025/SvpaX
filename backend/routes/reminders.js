const express = require('express');
const router = express.Router();
const {
  getAllReminders,
  createReminder,
  updateReminder,
  deleteReminder,
  getUpcomingReminders
} = require('../controllers/reminders');

/**
 * @route   GET /api/reminders
 * @desc    Get all reminders sorted by dateTime
 * @access  Private
 */
router.get('/', getAllReminders);

/**
 * @route   GET /api/reminders/upcoming
 * @desc    Get upcoming reminders (next 5)
 * @access  Private
 */
router.get('/upcoming', getUpcomingReminders);

/**
 * @route   POST /api/reminders
 * @desc    Create a new reminder
 * @body    {title, description, dateTime, priority, repeat}
 * @access  Private
 */
router.post('/', createReminder);

/**
 * @route   PUT /api/reminders/:id
 * @desc    Update a reminder
 * @body    {title, description, dateTime, priority, repeat, completed}
 * @access  Private
 */
router.put('/:id', updateReminder);

/**
 * @route   DELETE /api/reminders/:id
 * @desc    Delete a reminder
 * @access  Private
 */
router.delete('/:id', deleteReminder);

module.exports = router;
