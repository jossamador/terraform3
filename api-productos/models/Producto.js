const mongoose = require('mongoose');

const productoSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: [true, 'El nombre del producto es obligatorio'], // Mensaje personalizado
    trim: true, // Elimina espacios al inicio y al final
    minlength: [3, 'El nombre debe tener al menos 3 caracteres'], // Longitud mínima
  },
  precio: {
    type: Number,
    required: [true, 'El precio del producto es obligatorio'],
    min: [0, 'El precio no puede ser negativo'], // Validación para evitar precios negativos
  },
  descripcion: {
    type: String,
    required: [true, 'La descripción del producto es obligatoria'],
    trim: true,
    maxlength: [200, 'La descripción no puede exceder los 200 caracteres'], // Longitud máxima
  },
}, { timestamps: true }); // Agrega campos de creación y actualización automáticamente

module.exports = mongoose.model('Producto', productoSchema);
