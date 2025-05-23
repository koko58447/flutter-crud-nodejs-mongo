const express = require('express');
const multer = require('multer');
const path = require('path');
const Video = require('../models/Video');
const fs=require('fs');

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
    try {
        const newUpload = new Video({
            finename: req.body.filename,
            path: req.file.path
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
        const updatedUpload = await Upload.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedUpload) return res.status(404).json({ error: "Supplier not found" });
        res.json(updatedUpload);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Delete an uploaded file by ID
router.delete('/:id', async (req, res) => {
    try {
        const upload = await Upload.findById(req.params.id);
        if (!upload) {
            return res.status(404).json({ error: 'File not found' });
        }

        // Delete the file from the filesystem
        fs.unlink(upload.path, async (err) => {
            if (err && err.code !== 'ENOENT') {
                return res.status(500).json({ error: 'Failed to delete file from server' });
            }

            // Remove the file record from the database
            await Upload.findByIdAndDelete(req.params.id); // Corrected method
            res.json({ message: 'File deleted successfully' });
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;