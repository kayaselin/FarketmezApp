const pool = require('../../config/dbConfig'); // Your database connection pool

const addOrUpdateRating = async (userId, institutionId, score) => {
    const query = `
        INSERT INTO user_ratings (user_id, institution_id, score)
        VALUES ($1, $2, $3)
        ON CONFLICT (user_id, institution_id)
        DO UPDATE SET score = $3;
    `;

    await pool.query(query, [userId, institutionId, score]);
};
const updateInstitutionAverageRatings = async () => {
    const updateQuery = `
        UPDATE institutions
        SET average_rating = subquery.avg_rating
        FROM (
            SELECT institution_id, AVG(score) AS avg_rating
            FROM user_ratings
            GROUP BY institution_id
        ) AS subquery
        WHERE institutions.institution_id = subquery.institution_id;
    `;
    await pool.query(updateQuery);
};

module.exports = {
    updateInstitutionAverageRatings,
    addOrUpdateRating,
};