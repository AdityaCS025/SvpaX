const Reminder = require('../models/Reminder');
const Todo = require('../models/Todo');
const googleCalendar = require('../services/googleCalendar');

// Get auth URL for Google Calendar
exports.getAuthUrl = async (req, res) => {
    try {
        const url = await googleCalendar.getAuthUrl();
        res.json({ url });
    } catch (error) {
        console.error('Error getting auth URL:', error);
        res.status(500).json({ error: 'Failed to get auth URL' });
    }
};

// Handle Google Calendar OAuth callback
exports.handleCallback = async (req, res) => {
    try {
        const { code } = req.query;
        const tokens = await googleCalendar.getTokens(code);
        // Store tokens securely (you might want to save these in your user model)
        res.json({ success: true });
    } catch (error) {
        console.error('Error handling callback:', error);
        res.status(500).json({ error: 'Failed to handle callback' });
    }
};

// Get calendar events (combines todos, reminders, and Google Calendar events)
exports.getCalendarEvents = async (req, res) => {
    try {
        const { start, end } = req.query;
        const startDate = start ? new Date(start) : new Date();
        const endDate = end ? new Date(end) : new Date(startDate.getTime() + 30 * 24 * 60 * 60 * 1000); // Default to 30 days

        // Get reminders
        const reminders = await Reminder.find({
            dateTime: {
                $gte: startDate,
                $lte: endDate
            }
        }).sort({ dateTime: 1 });

        // Get todos with due dates
        const todos = await Todo.find({
            dueDate: {
                $gte: startDate,
                $lte: endDate
            }
        }).sort({ dueDate: 1 });

        // Combine and format events
        const events = [
            ...reminders.map(r => ({
                id: r._id,
                title: r.title,
                start: r.dateTime,
                end: r.dateTime,
                type: 'reminder',
                description: r.description,
                priority: r.priority
            })),
            ...todos.map(t => ({
                id: t._id,
                title: t.title,
                start: t.dueDate,
                end: t.dueDate,
                type: 'todo',
                description: t.description,
                priority: t.priority,
                completed: t.completed
            }))
        ];

        res.json(events);
    } catch (error) {
        console.error('Error fetching calendar events:', error);
        res.status(500).json({ error: 'Failed to fetch calendar events' });
    }
};

// Get events by date
exports.getEventsByDate = async (req, res) => {
    try {
        const { date } = req.params;
        const targetDate = new Date(date);
        const nextDate = new Date(targetDate);
        nextDate.setDate(nextDate.getDate() + 1);

        const [reminders, todos] = await Promise.all([
            Reminder.find({
                dateTime: {
                    $gte: targetDate,
                    $lt: nextDate
                }
            }),
            Todo.find({
                dueDate: {
                    $gte: targetDate,
                    $lt: nextDate
                }
            })
        ]);

        const events = {
            date: targetDate.toISOString().split('T')[0],
            reminders,
            todos
        };

        res.json(events);
    } catch (error) {
        console.error('Error fetching events by date:', error);
        res.status(500).json({ error: 'Failed to fetch events' });
    }
};