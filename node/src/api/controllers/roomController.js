const roomService = require('../services/roomService');

// Controller for selecting a tag for a room
exports.selectTagForRoom = async (req, res) => {
    try {
        const { roomId, userId, tagId } = req.body;

        // Basic validation (You might want to use a library like express-validator for more comprehensive validation)
        if (!roomId || !userId || !tagId) {
            return res.status(400).send({ message: "Missing required fields: roomId, userId, or tagId." });
        }

        await roomService.selectTagForRoom(roomId, userId, tagId);

        return res.status(200).send({ message: "Tag selection successful." });
    } catch (error) {
        console.error('Error selecting tag for room:', error);
        // Customize the error response based on the error type
        const statusCode = error.statusCode || 500;
        const message = error.message || "An error occurred while selecting a tag for the room.";
        return res.status(statusCode).send({ message });
    }
};


// Controller for fetching a random institution based on the most selected tag and location
exports.getInstitutionsForRoom = async (req, res) => {
    try {
        const roomId = parseInt(req.params.roomId);
        
        // Validate roomId is a number
        if (isNaN(roomId)) {
            return res.status(400).send({ message: "Invalid room ID." });
        }

        const institutions = await roomService.getInstitutionsByTagAndLocation(roomId);
        
        // Check if institutions were found
        if (institutions.length === 0) {
            return res.status(404).send({ message: "No institutions found for the selected tags and location." });
        }

        return res.status(200).json(institutions);
    } catch (error) {
        console.error('Error getting institutions for room:', error);
        return res.status(500).send({ message: "An error occurred while fetching institutions." });
    }
};

exports.joinRoomHandler = async (req, res) => {
    const { roomId, userId } = req.body;

    try {
        // joinRoom fonksiyonunun dönüş değerini result değişkeninde tut
        const result = await roomService.joinRoom(roomId, userId);
        // result içindeki district_name'i response'a ekleyerek döndür
        res.status(200).json({ message: "Successfully joined room", districtName: result.district_name });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};


exports.createRoomHandler = async (req, res) => {
    const { maxParticipants, locationTagId, userId } = req.body;

    try {
        const roomId = await roomService.createRoom(maxParticipants, locationTagId, userId);
        res.status(201).json({ roomId, message: "Room created and joined successfully" });
    } catch (error) {
        res.status(500).json({ error: "Failed to create room: " + error.message });
    }
};

exports.getRandomInstitution = async (req, res) => {
    try {
        const roomId = req.params.roomId;
        const institution = await roomService.getRandomInstitutionByTagAndLocation(roomId);
        if (!institution) {
            return res.status(404).send({ message: 'Institution not found.' });
        }
        res.json(institution);
    } catch (error) {
        console.error('Error fetching random institution:', error);
        res.status(500).send({ message: 'Internal server error' });
    }
};

exports.checkAndListInstitutions = async (req, res) => {
    const { roomId } = req.params;
    
    try {
        // Oda doluluğunu ve tüm kullanıcıların tag seçimlerini tamamladığını kontrol et
        const roomFullAndReady = await roomService.isRoomFullAndAllUsersReady(roomId);
        if (!roomFullAndReady) {
            return res.status(400).json({ message: "Room is not full or all users have not yet made their selections." });
        }

        // Oda dolu ve tüm kullanıcılar hazır olduğunda, `is_finished` durumunu TRUE olarak güncelle
        await roomService.markRoomAsFinished(roomId);

        // `is_finished` güncellendikten sonra, en çok seçilen tag ve oda lokasyonuna göre kurumları listele
        const institutionsData = await roomService.getInstitutionsByTagAndLocation(roomId);
        res.json(institutionsData);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "An error occurred while listing institutions." });
    }
};

exports.checkIfRoomIsFinished = async (req, res) => {
    const { roomId } = req.params; // URL'den oda ID'sini al

    try {
        // Oda durumunu sorgula
        const isFinished = await roomService.checkRoomFinishedStatus(roomId);

        // isFinished durumuna göre yanıt döndür
        res.json({ isFinished });
    } catch (error) {
        console.error('Error checking if room is finished:', error);
        res.status(500).json({ message: "An error occurred while checking if the room is finished." });
    }
};


