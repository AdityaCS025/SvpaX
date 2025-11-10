const Reminder = require('../models/Reminder');

// Get all reminders
exports.getAllReminders = async (req, res) => {
    try {
        const reminders = await Reminder.find().sort({ dateTime: 1 });
        res.json(reminders);
    } catch (error) {
        console.error('Error fetching reminders:', error);
        res.status(500).json({ error: 'Failed to fetch reminders' });
    }
};

// Create a new reminder
exports.createReminder = async (req, res) => {
    try {
        const { title, description, dateTime, priority, repeat } = req.body;
        const reminder = new Reminder({
            title,
            description,
            dateTime,
            priority: priority || 'medium',
            repeat: repeat || 'none'
        });
        await reminder.save();
        res.status(201).json(reminder);
    } catch (error) {
        console.error('Error creating reminder:', error);
        res.status(500).json({ error: 'Failed to create reminder' });
    }
};

// Update a reminder
exports.updateReminder = async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;
        const reminder = await Reminder.findByIdAndUpdate(id, updates, { new: true });
        if (!reminder) {
            return res.status(404).json({ error: 'Reminder not found' });
        }
        res.json(reminder);
    } catch (error) {
        console.error('Error updating reminder:', error);
        res.status(500).json({ error: 'Failed to update reminder' });
    }
};

// Delete a reminder
exports.deleteReminder = async (req, res) => {
    try {
        const { id } = req.params;
        const reminder = await Reminder.findByIdAndDelete(id);
        if (!reminder) {
            return res.status(404).json({ error: 'Reminder not found' });
        }
        res.json({ message: 'Reminder deleted successfully' });
    } catch (error) {
        console.error('Error deleting reminder:', error);
        res.status(500).json({ error: 'Failed to delete reminder' });
    }
};

// Get upcoming reminders
exports.getUpcomingReminders = async (req, res) => {
    try {
        const now = new Date();
        const reminders = await Reminder.find({
            dateTime: { $gte: now }
        }).sort({ dateTime: 1 }).limit(5);
        res.json(reminders);
    } catch (error) {
        console.error('Error fetching upcoming reminders:', error);
        res.status(500).json({ error: 'Failed to fetch upcoming reminders' });
    }
};