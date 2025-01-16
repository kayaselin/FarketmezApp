
const cron = require('node-cron');
const ratingService = require('./services/ratingService');

const updateAverageRatings = async () => {
    try {
        console.log('Updating average ratings...');
        await ratingService.updateInstitutionAverageRatings();
    } catch (error) {
        console.error('Error updating average ratings:', error);
    }
};

cron.schedule('*/2 * * * *', updateAverageRatings);
