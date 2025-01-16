const tagService = require('../services/tagService');

exports.getTags = async (req, res) => {
    try {
        const tags = await tagService.getTags();
        res.json(tags);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error fetching tags' });
    }
};


