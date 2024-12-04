// Importaciones
const express = require('express'); // Framework para el servidor
const mongoose = require('mongoose'); // Conexión a MongoDB
const dotenv = require('dotenv'); // Manejo de variables de entorno

// Configuración de variables de entorno
dotenv.config();

// Inicialización de la aplicación
const app = express();
const PORT = process.env.PORT || 4000;

// Middleware para parsear JSON
app.use(express.json());

// Conexión a MongoDB
mongoose
  .connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log('Conectado a MongoDB');
  })
  .catch((err) => {
    console.error('Error al conectar a MongoDB:', err);
  });

// Importar y usar las rutas después de inicializar app
const productoRoutes = require('./routes/productoRoutes');
app.use('/api/productos', productoRoutes);

// Ruta base para pruebas
app.get('/', (req, res) => res.send('API de Productos'));

// Inicia el servidor y escucha en todas las interfaces (0.0.0.0)
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor en ejecución en el puerto ${PORT}`);
});
