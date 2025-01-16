const campaignService = require('../services/campaignService');


exports.addCampaign = async (req, res) => {
    if (!req.user || !req.user.institutionId) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    try {
        const { institutionId } = req.user; // Extracted from the authenticated user's data
        const { title, description, imageUrl } = req.body;

        if (!title || !description) {
            return res.status(400).json({ message: 'Title and description are required' });
        }

        const campaignId = await campaignService.createCampaign({
            institutionId, title, description, imageUrl
        });

        res.status(201).json({ message: 'Campaign created successfully', campaignId });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getCampaigns = async (req, res) => {
    try {
        const institutionId = req.user.institutionId; // Assuming this is set by the authenticate middleware

        if (!institutionId) {
            return res.status(401).json({ message: 'Unauthorized' });
        }

        const campaigns = await campaignService.getCampaignsByInstitution(institutionId);
        res.json(campaigns);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.generateCampaignCode = async (req, res) => {
    try {
        // Extract campaignId from route parameters
        const { campaignId } = req.params;
        const code = await campaignService.generateCampaignCode(campaignId);
        res.json({ success: true, code });
        
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
exports.validateCampaignCode = async (req, res) => {
    const { code, institutionId } = req.body;
    try {
        const campaign = await campaignService.validateCampaignCode(code, institutionId);
        res.status(200).json({ success: true, campaign });
    } catch (error) {
        res.status(400).json({ success: false, message: error.message });
    }
};

exports.approveCampaignCode = async (req, res) => {
    const { institutionId, userId, code } = req.body; // Adjust based on actual data extraction method
    try {
        const result = await campaignService.approveCampaignCode(institutionId, userId, code);
        res.json(result);
    } catch (error) {
        res.status(400).json({ success: false, message: error.message });
    }
};


exports.generateCampaignCodeForUser = async (req, res) => {
    // Extract userId and campaignId from the request. 
    // This example assumes these values are sent in the request body. Adjust as needed.
    const campaignId = req.params.campaignId;
    const userId = req.body.userId;

    try {
        // Call the service function with the extracted values
        const codeDetails = await campaignService.generateCampaignCodeForUser(userId, parseInt(campaignId));

        // If the code generation is successful, send the code details back to the client
        res.status(200).json({
            success: true,
            message: 'Campaign code generated successfully',
            codeDetails
        });
    } catch (error) {
        // In case of any errors, send an error response back to the client
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
};

exports.approveCampaignCodes = async (req, res) => {
    const { code, institutionId } = req.body; // Directly obtaining institutionId from the request body

    try {
        const result = await campaignService.approveCampaignCodes(code, institutionId);
        res.json(result);
    } catch (error) {
        res.status(400).json({ success: false, message: error.message });
    }
};

exports.getCampaignStats = async (req, res) => {
    try {
        const { institutionId } = req.body; // Body'den kurum ID'si alınır
        const stats = await campaignService.getCampaignUsageStatsByInstitution(institutionId);
        res.json(stats);
    } catch (error) {
        res.status(500).send({ error: 'An error occurred while fetching campaign statistics.' });
    }
};

