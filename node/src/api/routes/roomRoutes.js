const express = require('express');
const router = express.Router();
const roomController = require('../controllers/roomController');

// Route for selecting a tag for a room
router.post('/select-tag', roomController.selectTagForRoom);

// Route for fetching institutions by the most selected tag and location
router.get('/institutions/:roomId', roomController.checkAndListInstitutions);

// Route for fetching a random institution by the most selected tag and location
router.get('/institutions/random/:roomId', roomController.getRandomInstitution);

router.get('/is-finished/:roomId', roomController.checkIfRoomIsFinished);

module.exports = router;
