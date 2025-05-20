const express = require('express');
const router = express.Router();
const User = require('../models/User');

// Create User
router.post('/', async (req, res) => {
    const newUser = new User(req.body);
    try {
        await newUser.save();
        res.status(201).json(newUser);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Get All Users
router.get('/', async (req, res) => {
    try {
        const users = await User.find();
        res.json(users);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Update User
router.put('/:id', async (req, res) => {
    try {
        const updatedUser = await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json(updatedUser);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Delete User
router.delete('/:id', async (req, res) => {
    try {
        await User.findByIdAndDelete(req.params.id);
        res.json({ message: "User deleted" });
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Login User
router.post('/login', async (req, res) => {
    const { name, password } = req.body;

    try {
        // Find user by name
        const user = await User.findOne({ name });
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        // Check if password matches
        if (user.password !== password) {
            return res.status(401).json({ message: "Invalid password" });
        }

        // Login successful
        res.json({ message: "Login successful", user });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;