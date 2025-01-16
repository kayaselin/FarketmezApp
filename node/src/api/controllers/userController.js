
const userService = require('../services/userService');
const campaignService = require('../services/campaignService');
const ratingService = require('../services/ratingService');
const institutionService = require('../services/institutionService');
const azureBlobService = require('../services/azureBlobService');

exports.updateUser = async (req, res) => {
    const { userId, username, email, password} = req.body;
    console.log("updateUser");
    try {
      const result = await userService.updateUserDetails({
        userId,
        username,
        email,
        password,
        
      });
  
      if (result) {
        res.send('User updated successfully.');
      } else {
        res.status(400).send('Update failed.');
      }
    } catch (error) {
      console.error('Error updating user:', error);
      res.status(500).send('Server error.');
    }
};

exports.registerUser = async (req, res) => {
    try {
        const { username, email, password } = req.body;
        if (!password) {
            return res.status(400).send('Password is required');
        }
        const result = await userService.registerUser(req.body);
        res.status(201).send(result);
    } catch (err) {
        if (err.code === '23505') { // PostgreSQL unique violation
            if (err.detail.includes('username')) {
                return res.status(400).json({ message: 'Username is already in use' });
            } else if (err.detail.includes('mail')) {
                return res.status(400).json({ message: 'Email is already in use' });
            }
        }
        console.error(err.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};

exports.loginUser = async (req, res) => {
    try {
        const token = await userService.loginUser(req.body);
        res.json({ token });
    } catch (err) {
        console.error(err.message);
        res.status(err.statusCode || 500).send(err.message);
    }
};
exports.getUserProfile = async (req, res) => {
    try {
        const userId = req.body.userId; 

        if (!userId) {
            return res.status(401).json({ message: 'Unauthorized' });
        }

        const userProfile = await userService.getUserProfile(userId);
        res.json(userProfile);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.uploadProfilePhoto = async (req, res) => {
    try {
        const userId = req.user.userId; // Extracted from JWT token
        const file = req.file;

        if (!file) {
            return res.status(400).send('No file uploaded');
        }

        const imageUrl = await azureBlobService.uploadFileToBlob(file, 'farketmez');

        await userService.updateUserProfilePhoto(userId, imageUrl);

        res.status(200).json({ message: 'Profile photo uploaded successfully', imageUrl });
    } catch (err) {
        console.error('Error in uploadProfilePhoto:', err);
        res.status(500).send('Server error');
    }
};

exports.changeUsername = async (req, res) => {
    try {
        const userId = req.user.userId; // Extracted from the authenticated user
        const { newUsername } = req.body;

        if (!newUsername) {
            return res.status(400).send('New username is required');
        }

        // Check if the new username is already in use
        const isUsernameAvailable = await userService.isUsernameAvailable(newUsername);
        if (!isUsernameAvailable) {
            return res.status(400).send('This username is in use');
        }

        // Update the username in the database
        await userService.updateUsername(userId, newUsername);

        res.status(200).send('Username updated successfully');
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.changeEmail = async (req, res) => {
    try {
        const userId = req.user.userId; // Extracted from the authenticated user
        const { newEmail } = req.body;

        if (!newEmail) {
            return res.status(400).send('New email is required');
        }

        // Check if the new email is already in use
        const isEmailAvailable = await userService.isEmailAvailable(newEmail);
        if (!isEmailAvailable) {
            return res.status(400).send('This email is in use');
        }

        // Update the email in the database
        await userService.updateEmail(userId, newEmail);

        res.status(200).send('Email updated successfully');
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.changePassword = async (req, res) => {
    try {
        const userId = req.user.userId; // Extracted from the authenticated user
        const { newPassword, confirmPassword } = req.body;

        if (!newPassword || !confirmPassword) {
            return res.status(400).send('New password and confirmation are required');
        }

        if (newPassword !== confirmPassword) {
            return res.status(400).send('Passwords do not match');
        }

        // Update the password in the database
        await userService.updatePassword(userId, newPassword);

        res.status(200).send('Password updated successfully');
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.generateCampaignCode = async (req, res) => {
    try {
        const campaignId = req.params.campaignId;
        const userId = req.user.userId;
        const result = await campaignService.storeCampaignCode(campaignId, userId);

        if (result.error) {
            return res.status(400).send(result.error);
        }

        res.json({ code: result.code ,ID:result.campaignId});
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.getInstitutionCampaigns = async (req, res) => {
    const { institutionId } = req.params; // Extract institutionId from the route parameter

    try {
        const campaigns = await campaignService.getInstitutionCampaigns(institutionId);
        res.json(campaigns);
    } catch (error) {
        console.error('Error getting institution campaigns:', error);
        res.status(500).send('Server error');
    }
};

exports.getCampaignDetails = async (req, res) => {
    try {
        const campaignId = req.params.campaignId;
        const campaignDetails = await campaignService.getCampaignDetails(campaignId);

        if (!campaignDetails) {
            return res.status(404).send('Campaign not found');
        }

        res.json(campaignDetails);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
exports.submitRating = async (req, res) => {
    const userId = req.user.userId;
    const institutionId = req.params.institutionId;
    const { score } = req.body;

    if (!score || score < 1 || score > 5) {
        return res.status(400).send('Invalid rating. Ratings must be between 1 and 5.');
    }

    try {
        await ratingService.addOrUpdateRating(userId, institutionId, score);
        res.status(200).send('Rating submitted successfully.');
    } catch (error) {
        console.error(error);
        res.status(500).send('Error submitting rating.');
    }
};

exports.getInstitutionDetails = async (req, res) => {
    try {
        const institutionId = req.params.institutionId;
        const details = await institutionService.getInstitutionDetails(institutionId);

        if (!details) {
            return res.status(404).send('Institution not found');
        }

        res.json(details);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.searchInstitutions = async (req, res) => {
    try {
        const { searchQuery, tags, locationTag, random } = req.query;
        const tagArray = tags ? tags.split(',') : []; // Assuming tags are comma-separated
        const institutions = await institutionService.searchInstitutions(searchQuery, tagArray, locationTag, random === 'true');
        res.json(institutions);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.getCampaigns = async (req, res) => {
    try {
        const campaigns = await campaignService.getRandomCampaigns();
        res.status(200).json(campaigns);
    } catch (err) {
        console.error('Error in getCampaigns:', err);
        res.status(500).send('Server error');
    }
};

exports.getRandomCampaigns = async (req, res) => {
    try {
        const campaigns = await userService.getRandomCampaigns();
        res.json(campaigns);
    } catch (error) {
        console.error('Error fetching random campaigns:', error);
        res.status(500).send('Server error');
    }
};

exports.getCampaign = async (req, res) => {
    const { campaignId } = req.params;
    try {
        const campaign = await userService.getCampaignById(campaignId);
        if (!campaign) {
            return res.status(404).json({ message: 'Campaign not found' });
        }
        res.json(campaign);
    } catch (error) {
        console.error('Error in getCampaign controller: ', error);
        res.status(500).json({ message: 'Server error' });
    }
};