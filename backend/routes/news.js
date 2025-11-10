const express = require('express');
const router = express.Router();
const { getNewsHeadlines, searchNews } = require('../controllers/news');

/**
 * @route   GET /api/news/headlines
 * @desc    Get top news headlines by category and country
 * @query   {category, country}
 * @access  Public
 */
router.get('/headlines', getNewsHeadlines);

/**
 * @route   GET /api/news/search
 * @desc    Search news articles
 * @query   {q, from, sortBy}
 * @access  Public
 */
router.get('/search', searchNews);

module.exports = router;
