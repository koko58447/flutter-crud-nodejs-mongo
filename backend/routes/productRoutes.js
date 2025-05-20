const express = require('express');
const Product = require('../models/Product'); // Import the Product model
const Supplier = require('../models/Supplier'); // Supplier model

const router = express.Router();

// Create a new product
router.post('/', async (req, res) => {
    try {
        const product = new Product(req.body);
        const savedProduct = await product.save();
        res.status(201).json(savedProduct);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Get all products
router.get('/', async (req, res) => {
    try {
        const products = await Product.find();
        res.status(200).json(products);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API to join products and suppliers
router.get('/productsupplier', async (req, res) => {
    try {
      const productsWithSuppliers = await Product.aggregate([
        {
          $lookup: {
            from: 'suppliers', // Collection name for suppliers
            localField: 'supplierid', // Field in products
            foreignField: '_id', // Field in suppliers
            as: 'supplierDetails', // Output array field
          },
        },
        {
          $unwind: '$supplierDetails', // Flatten the supplierDetails array
        },
      ]);
      res.status(200).json(productsWithSuppliers);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch data' });
    }
  });
  
// Get a single product by ID
router.get('/:id', async (req, res) => {
    try {
        const product = await Product.findById(req.params.id);
        if (!product) {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.status(200).json(product);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update a product by ID
router.put('/:id', async (req, res) => {
    try {
        const updatedProduct = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedProduct) {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.status(200).json(updatedProduct);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Delete a product by ID
router.delete('/:id', async (req, res) => {
    try {
        const deletedProduct = await Product.findByIdAndDelete(req.params.id);
        if (!deletedProduct) {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.status(200).json({ message: 'Product deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});






module.exports = router;