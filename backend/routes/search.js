const express = require('express');
const router = express.Router();
const searchController = require('../controllers/search');

// Route for web search
router.get('/', searchController.search);

module.exports = router;
