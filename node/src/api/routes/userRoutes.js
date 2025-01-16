
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const campaignController = require('../controllers/campaignController');
const roomController = require('../controllers/roomController');
const authenticate = require('../middleware/authenticate');
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() }); 

router.post('/register', userController.registerUser);
router.post('/login', userController.loginUser);
router.post('/profile',userController.getUserProfile);
router.post('/profile-photo', authenticate, upload.single('profilePhoto'), userController.uploadProfilePhoto);


router.put('/change-username', authenticate, userController.changeUsername);
router.put('/change-email', authenticate, userController.changeEmail);
router.put('/change-password', authenticate, userController.changePassword);

router.put('/update-user', userController.updateUser);

router.get('/campaigns/:campaignId/code', authenticate, userController.generateCampaignCode);//kampanyaya ait code
router.get('/institutions/:institutionId/campaigns', authenticate, userController.getInstitutionCampaigns);//kurum kampanyalarını görüntüleme
router.get('/campaigns/:campaignId', authenticate, userController.getCampaignDetails);//kuruma ait kampanya görüntüleme
router.post('/institutions/:institutionId/rate', authenticate, userController.submitRating);//puan verme
router.get('/institutions/:institutionId/details', authenticate, userController.getInstitutionDetails);//kullanıcnın kurum profilini görüntülemesi. Buunun içerisinde kurumun kampanyaları da yer alıyor.
router.get('/institutions/search',authenticate, userController.searchInstitutions);//kurum arama
router.get('/random-campaigns', userController.getRandomCampaigns);//random kampanyalar
router.get('/institution-campaigns/:institutionId', userController.getInstitutionCampaigns);//kuruma ait kampanyalar

router.get('/campaigns/generateCode/:campaignId', campaignController.generateCampaignCode);// şu anlık önemsiz generate

router.post('/campaigns/generateCodeForUser/:campaignId', campaignController.generateCampaignCodeForUser);// user kod generate etme 
router.get('/campaign/:campaignId', userController.getCampaign);// user spesifik kampanya görüntüleme


router.post('/create', roomController.createRoomHandler);
router.post('/join', roomController.joinRoomHandler);



module.exports = router;


