const express = require('express');
const router = express.Router();
const Supplier = require('../models/Supplier');

// Get all suppliers
router.get('/', async (req, res) => {
    try {
        const suppliers = await Supplier.find().sort({ _id: -1 });
        res.json(suppliers);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Create a new supplier
router.post('/', async (req, res) => {
    try {
        const newSupplier = new Supplier(req.body);
        const savedSupplier = await newSupplier.save();
        res.status(201).json(savedSupplier);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Update a supplier
router.put('/:id', async (req, res) => {
    try {
        const updatedSupplier = await Supplier.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedSupplier) return res.status(404).json({ error: "Supplier not found" });
        res.json(updatedSupplier);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Delete a supplier
router.delete('/:id', async (req, res) => {
    try {
        const deletedSupplier = await Supplier.findByIdAndDelete(req.params.id);
        if (!deletedSupplier) return res.status(404).json({ error: "Supplier not found" });
        res.json({ message: "Supplier deleted successfully" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.get('/searchdate', async (req, res) => {
    const { startDate, endDate } = req.query;
    console.log('Start Date:', startDate, 'End Date:', endDate); // Debugging
    const query = {};
    if (startDate && endDate) {
      query.createdAt = { $gte: new Date(startDate), $lte: new Date(endDate) };
    }
    try {
      const suppliers = await Supplier.find(query).sort({ _id: -1 });
      res.json(suppliers);
    } catch (error) {
      console.error('Error:', error); // Log errors
      res.status(500).json({ error: 'Internal Server Error' });
    }
});



module.exports = router;