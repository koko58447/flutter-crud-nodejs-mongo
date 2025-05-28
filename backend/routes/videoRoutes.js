const express = require('express');
const multer = require('multer'); 
const path = require('path');
const Video = require('../models/Video');
const fs = require('fs/promises');

const router = express.Router();


// Configure multer for file storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploadvideos/'); // Directory to save files
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname)); // Unique file name
    }
});

const upload = multer({ storage });

// Upload an image
router.post('/upload', upload.single('video'), async (req, res) => {
    console.log(req.body);
    const path = `/uploadvideos/${req.file.filename}`;
    try {
        const newUpload = new Video({
            name: req.body.name,
            path: path
        });
        const savedUpload = await newUpload.save();
        res.status(201).json(savedUpload);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Get all uploaded files
router.get('/', async (req, res) => {
    try {
        const uploads = await Video.find().sort({ _id: -1 });
        res.json(uploads);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Update a supplier
router.put('/:id', async (req, res) => {
    try {
        const updatedUpload = await Video.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedUpload) return res.status(404).json({ error: "Supplier not found" });
        res.json(updatedUpload);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Delete an uploaded file by ID
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        console.log("Deleting file with ID:", id);

        const upload = await Video.findById(id);
        if (!upload) {
            return res.status(404).json({ error: 'File not found' });
        }

        // const filePath = path.resolve(__dirname, '..', upload.path);
        const filePath = path.join(__dirname,'..',  upload.path);
        console.log("Attempting to delete file at:", filePath);

        try {
            await fs.unlink(filePath); // ✅ ဒါက fs.promises ဖြစ်နေတယ်
        } catch (err) {
            if (err.code === 'ENOENT') {
                console.warn("File already deleted");
            } else {
                throw err;
            }
        }

        await Video.findByIdAndDelete(id);
        res.json({ message: 'File deleted successfully' });

    } catch (err) {
        console.error("Error deleting file:", err);
        res.status(500).json({ error: err.message || 'Failed to delete file' });
    }
});

module.exports = router;