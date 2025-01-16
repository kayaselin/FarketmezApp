const pool = require('../../config/dbConfig');

const getLocationTags = async () => {
    const result = await pool.query('SELECT loc_tag_id, district_name FROM Loc_tags_TBL');
    return result.rows; // Returns an array of location tag objects
};

module.exports = { getLocationTags };
