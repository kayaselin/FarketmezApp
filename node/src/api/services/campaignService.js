const pool = require('../../config/dbConfig');
const crypto = require('crypto');
const moment = require('moment-timezone');




const getCampaignsByInstitution = async (institutionId) => {
    const query = `
        SELECT title, description, image_url
        FROM Campaign_TBL
        WHERE institution_id = $1;
    `;
    const result = await pool.query(query, [institutionId]);
    return result.rows;
};

const storeCampaignCode = async (campaignId, userId) => {
    const code = generateRandomCode();

    // Check if the user has successfully used this campaign in the last 24 hours
    const usageCheckQuery = `
        SELECT creation_date
        FROM campaign_codes_tbl
        WHERE campaign_id = $1 AND user_id = $2 AND used = TRUE
        ORDER BY creation_date DESC
        LIMIT 1;
    `;
    const usageResult = await pool.query(usageCheckQuery, [campaignId, userId]);

    if (usageResult.rowCount > 0) {
        const lastUsedDate = usageResult.rows[0].creation_date;
        const currentDate = new Date();
        const hoursDiff = (currentDate - new Date(lastUsedDate)) / 36e5; // Convert milliseconds to hours

        if (hoursDiff < 24) {
            return { error: 'Campaign can only be reused after 24 hours' };
        }
    }

    // Store the new campaign code
    const query = `INSERT INTO campaign_codes_tbl (campaign_id, user_id, code) VALUES ($1, $2, $3);`;
    await pool.query(query, [campaignId, userId, code]);

    return { code,campaignId };
};

const validateCode = async (campaignId, code, userId) => {
    // Check if the code is valid and not used yet
    const checkCodeQuery = `SELECT * FROM campaign_codes_tbl WHERE campaign_id = $1 AND code = $2 AND used = FALSE;`;
    const checkResult = await pool.query(checkCodeQuery, [campaignId, code]);

    if (checkResult.rowCount === 0) {
        return false; // Code is invalid or already used
    }

    // Mark the code as used
    const markCodeUsedQuery = `UPDATE campaign_codes_tbl SET used = TRUE WHERE code_id = $1;`;
    await pool.query(markCodeUsedQuery, [checkResult.rows[0].code_id]);

    const updateStatsQuery = `
    INSERT INTO campaign_usage_statistics_tbl (campaign_id, total_uses, last_used_date)
    VALUES ($1, 1, NOW())
    ON CONFLICT (campaign_id)
    DO UPDATE SET 
        total_uses = campaign_usage_statistics_tbl.total_uses + 1,
        last_used_date = NOW();
    `;
    await pool.query(updateStatsQuery, [campaignId]);

    return true; // Successfully validated and recorded the campaign usage
};
const getCampaignDetails = async (campaignId) => {
    const query = `SELECT title, description, image_url FROM campaign_tbl WHERE campaign_id = $1;`;
    const result = await pool.query(query, [campaignId]);
    return result.rows[0];
};


const deleteCampaign = async (campaignId, institutionId) => {
    // First, verify that the campaign belongs to the institution
    const verifyQuery = `SELECT institution_id FROM campaign_tbl WHERE campaign_id = $1;`;
    const verifyResult = await pool.query(verifyQuery, [campaignId]);

    if (verifyResult.rowCount === 0 || verifyResult.rows[0].institution_id !== institutionId) {
        return { success: false, message: 'Campaign not found or access denied' };
    }

    // Proceed with deletion
    const deleteQuery = `DELETE FROM campaign_tbl WHERE campaign_id = $1;`;
    await pool.query(deleteQuery, [campaignId]);

    return { success: true };
};

const createCampaign = async ({ institutionId, title, description, base64Image }) => {
    const creationDate = new Date();
    const query = `
        INSERT INTO campaign_tbl (institution_id, title, description, image_url, creation_date)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING campaign_id; 
    `;
    const values = [institutionId, title, description, base64Image, creationDate];

    try {
        const result = await pool.query(query, values);
        return result.rows[0]; // Return the created campaign's ID
    } catch (error) {
        console.error('Error in institutionService createCampaign:', error);
        throw error;
    }
};

const getInstitutionCampaigns = async (institutionId) => {
    const query = `
        SELECT campaign_id, title, description, image_url
        FROM campaign_tbl
        WHERE institution_id = $1;
    `;

    try {
        const result = await pool.query(query, [institutionId]);
        return result.rows; // Return the array of campaign objects
    } catch (error) {
        console.error('Error in campaignService getting institution campaigns:', error);
        throw error;
    }
};

const getCampaignStatistics = async (institutionId) => {
    const query = `
        SELECT c.campaign_id, c.title, COUNT(cs.statistic_id) AS total_uses
        FROM campaign_tbl c
        LEFT JOIN campaign_usage_statistics_tbl cs ON c.campaign_id = cs.campaign_id
        WHERE c.institution_id = $1
        GROUP BY c.campaign_id;
    `;
    const result = await pool.query(query, [institutionId]);
    return result.rows;
};

async function getRandomCampaigns() {
    const query = `
        SELECT c.campaign_id, c.title, c.image_url, i.institution_name
        FROM campaign_tbl c
        JOIN institution_tbl i ON c.institution_id = i.institution_id
        ORDER BY RANDOM()
        LIMIT 10; 
    `;

    const result = await pool.query(query);
    return result.rows;
};
const generateRandomCode = (length = 5) => {
    let code = '';
    const characters = '0123456789';
    for (let i = 0; i < length; i++) {
        code += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return code;
};
const generateCampaignCode = async (campaignId) => {
    const code = generateRandomCode();
    const expiresAt = moment.tz('Europe/Istanbul').add(3, 'minutes').toDate();

    const insertQuery = 'INSERT INTO campaign_codes_tbl (campaign_id, code, expires_at) VALUES ($1, $2, $3) RETURNING code;';
    const { rows } = await pool.query(insertQuery, [campaignId, code, expiresAt]);
    console.log(`Generated code expires at: ${expiresAt.toISOString()}`);
    console.log(`Current server time: ${new Date().toISOString()}`);

    return rows[0].code; // Return the generated code
    
};

const validateCampaignCode = async (code, institutionId) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // Check if the code is valid, not expired, and not used
        const validateQuery = `
            SELECT cc.campaign_id, c.title, c.description
            FROM campaign_codes_tbl cc
            JOIN campaign_tbl c ON cc.campaign_id = c.campaign_id
            WHERE cc.code = $1 AND c.institution_id = $2 AND cc.expires_at > NOW() AND cc.used = FALSE
        `;

        const validationRes = await client.query(validateQuery, [code, institutionId]);
        if (validationRes.rowCount === 0) {
            await client.query('ROLLBACK');
            throw new Error('Invalid, expired, or already used code.');
        }

        const campaign = validationRes.rows[0];

        // Mark the code as used
        const markUsedQuery = 'UPDATE campaign_codes_tbl SET used = TRUE WHERE code = $1';
        await client.query(markUsedQuery, [code]);

        // Update campaign usage statistics
        const updateStatsQuery = `
            INSERT INTO campaign_usage_statistics_tbl (campaign_id, total_uses)
            VALUES ($1, 1)
            ON CONFLICT (campaign_id) DO UPDATE SET total_uses = campaign_usage_statistics_tbl.total_uses + 1;
        `;
        await client.query(updateStatsQuery, [campaign.campaign_id]);

        await client.query('COMMIT');

        return campaign; // Return campaign details for response
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
};

const approveCampaignCode = async (institutionId, userId, code) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // Step 1: Fetch campaign details for the given code that belongs to the institution
        const campaignQuery = `
            SELECT cc.campaign_id, c.title, c.description
            FROM campaign_codes_tbl cc
            JOIN campaign_tbl c ON cc.campaign_id = c.campaign_id
            WHERE cc.code = $1 AND c.institution_id = $2 AND cc.expires_at > NOW() AND cc.used = FALSE;
        `;
        const campaignRes = await client.query(campaignQuery, [code, institutionId]);
        if (campaignRes.rowCount === 0) {
            throw new Error("Invalid code or not belonging to this institution.");
        }
        const campaign = campaignRes.rows[0];

        // Step 2: Check if the user has redeemed this campaign in the last 24 hours
        const redemptionCheckQuery = `
            SELECT redeemed_at
            FROM campaign_redemptions
            WHERE user_id = $1 AND campaign_id = $2
            ORDER BY redeemed_at DESC
            LIMIT 1;
        `;
        const redemptionCheckRes = await client.query(redemptionCheckQuery, [userId, campaign.campaign_id]);
        if (redemptionCheckRes.rowCount > 0) {
            const lastRedeemedAt = redemptionCheckRes.rows[0].redeemed_at;
            const hoursSinceLastRedemption = (new Date() - new Date(lastRedeemedAt)) / (1000 * 60 * 60);
            if (hoursSinceLastRedemption < 24) {
                throw new Error("This campaign can only be redeemed again after 24 hours.");
            }
        }

        // Step 3: Mark the code as used (or log the redemption)
        const logRedemptionQuery = `
            INSERT INTO campaign_redemptions (user_id, campaign_id, redeemed_at)
            VALUES ($1, $2, NOW());
        `;
        await client.query(logRedemptionQuery, [userId, campaign.campaign_id]);

        await client.query('COMMIT');

        return { 
            success: true, 
            message: "Campaign code approved successfully.",
            campaign: { title: campaign.title, description: campaign.description }
        };
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
};

const generateCampaignCodeForUser = async (userId, campaignId) => {
    const client = await pool.connect();
    try {
        const checkUsageQuery = `
            SELECT used_at
            FROM campaign_codes_tbl
            WHERE user_id = $1 AND campaign_id = $2 AND used_at IS NOT NULL
            ORDER BY used_at DESC
            LIMIT 1;
        `;
        const { rows } = await client.query(checkUsageQuery, [userId, campaignId]);

        if (rows.length > 0) {
            const lastUsedAt = rows[0].used_at;
            const hoursSinceLastUse = (new Date() - new Date(lastUsedAt)) / (1000 * 60 * 60);
            if (hoursSinceLastUse < 24) {
                throw new Error("You can generate a new code for this campaign after 24 hours.");
            }
        }
        
        // Generate a unique code
        const code = generateRandomCode(); // Customize as needed

        // Calculate expiration time (15 minutes from now)
        const expiredAt = moment.tz('Europe/Istanbul').add(5, 'minutes').toDate();

        const insertCodeQuery = `
            INSERT INTO campaign_codes_tbl (campaign_id, user_id, code, expires_at)
            VALUES ($1, $2, $3, $4)
            RETURNING code_id, code, expires_at;
        `;
        const res = await client.query(insertCodeQuery, [campaignId, userId, code, expiredAt]);

        return res.rows[0]; // Return the generated code details
    } catch (error) {
        throw new Error('Failed to generate campaign code: ' + error.message);
    } finally {
        client.release();
    }
};

const approveCampaignCodes = async (code, institutionId) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // Fetch the campaign code details including expiration and usage status
        const fetchCodeQuery = `
            SELECT cc.campaign_id, cc.used, cc.expires_at, c.title, c.description
            FROM campaign_codes_tbl cc
            JOIN campaign_tbl c ON cc.campaign_id = c.campaign_id
            WHERE cc.code = $1 AND c.institution_id = $2 AND cc.expires_at > NOW();
        `;
        const codeRes = await client.query(fetchCodeQuery, [code, institutionId]);
        if (codeRes.rowCount === 0) {
            throw new Error("Code was expired or doesn't belong to this institution.");
        }

        const { campaign_id, used, expires_at, title, description } = codeRes.rows[0];
        
        // Check if the code has already been used
        if (used) {
            throw new Error("This code has already been used.");
        }

        // Mark the code as used and update the used timestamp
        const markUsedQuery = `
            UPDATE campaign_codes_tbl
            SET used = TRUE, used_at = NOW()
            WHERE code = $1;
        `;
        await client.query(markUsedQuery, [code]);

        // Increment the total uses for the campaign or insert if it does not exist
        const upsertUsageQuery = `
            INSERT INTO campaign_usage_statistics_tbl (campaign_id, total_uses)
            VALUES ($1, 1)
            ON CONFLICT (campaign_id)
            DO UPDATE SET total_uses = campaign_usage_statistics_tbl.total_uses + 1;
        `;
        await client.query(upsertUsageQuery, [campaign_id]);

        await client.query('COMMIT');

        return {
            success: true,
            message: "Campaign code approved successfully.",
            campaign: { title, description }
        };
    } catch (error) {
        await client.query('ROLLBACK');
        throw new Error(`Failed to approve campaign code: ${error.message}`);
    } finally {
        client.release();
    }
};

const getCampaignUsageStatsByInstitution = async (institutionId) => {
    const client = await pool.connect();
    try {
        const query = `
            SELECT c.title, c.description, coalesce(cus.total_uses, 0) as total_uses
            FROM campaign_tbl c
            LEFT JOIN campaign_usage_statistics_tbl cus ON c.campaign_id = cus.campaign_id
            WHERE c.institution_id = $1;
        `;
        const res = await client.query(query, [institutionId]);
        return res.rows;
    } finally {
        client.release();
    }
};




module.exports = {
    getCampaignUsageStatsByInstitution,
    approveCampaignCodes,
    generateCampaignCodeForUser,
    approveCampaignCode,
    validateCampaignCode,
    generateCampaignCode,
    generateRandomCode,
    getRandomCampaigns,
    getCampaignStatistics,
    deleteCampaign,
    getCampaignDetails,
    getInstitutionCampaigns,
    validateCode,
    storeCampaignCode,
    getCampaignsByInstitution,
    createCampaign,
};
