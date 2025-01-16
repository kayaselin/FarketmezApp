const locationTagService = require('../services/locationTagService');

exports.getLocationTags = async (req, res) => {
    try {
        const locationTags = await locationTagService.getLocationTags();
        res.json(locationTags);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error fetching location tags' });
    }
};
