const express = require('express');
const router = express.Router();
const locationTagController = require('../controllers/locationTagController');

router.get('/', locationTagController.getLocationTags);

module.exports = router;
