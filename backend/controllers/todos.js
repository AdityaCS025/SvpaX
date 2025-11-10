const Todo = require('../models/Todo');

// Get all todos
exports.getAllTodos = async (req, res) => {
    try {
        const todos = await Todo.find().sort({ createdAt: -1 });
        res.json(todos);
    } catch (error) {
        console.error('Error fetching todos:', error);
        res.status(500).json({ error: 'Failed to fetch todos' });
    }
};

// Create a new todo
exports.createTodo = async (req, res) => {
    try {
        const { title, description, dueDate, priority } = req.body;
        const todo = new Todo({
            title,
            description,
            dueDate,
            priority: priority || 'medium',
            completed: false
        });
        await todo.save();
        res.status(201).json(todo);
    } catch (error) {
        console.error('Error creating todo:', error);
        res.status(500).json({ error: 'Failed to create todo' });
    }
};

// Update a todo
exports.updateTodo = async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;
        const todo = await Todo.findByIdAndUpdate(id, updates, { new: true });
        if (!todo) {
            return res.status(404).json({ error: 'Todo not found' });
        }
        res.json(todo);
    } catch (error) {
        console.error('Error updating todo:', error);
        res.status(500).json({ error: 'Failed to update todo' });
    }
};

// Delete a todo
exports.deleteTodo = async (req, res) => {
    try {
        const { id } = req.params;
        const todo = await Todo.findByIdAndDelete(id);
        if (!todo) {
            return res.status(404).json({ error: 'Todo not found' });
        }
        res.json({ message: 'Todo deleted successfully' });
    } catch (error) {
        console.error('Error deleting todo:', error);
        res.status(500).json({ error: 'Failed to delete todo' });
    }
};