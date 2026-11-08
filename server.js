const express = require('express');
const { execSync } = require('child_process');
const path = require('path');
const app = express();

// Configurar para recibir JSON y servir la carpeta 'web'
app.use(express.json());
app.use(express.static('web'));

// Ruta que recibe los datos del formulario
app.post('/api/resolver', (req, res) => {
    const { nombre, lugar, hora } = req.body;
    
    // Consulta pura para Prolog (Sin librerías HTTP en Prolog)
    const consulta = `assertz(evento(${nombre}, ${lugar}, ${hora})), with_output_to(string(R), resolver_caso), write(R), halt`;
    
    try {
        // Ejecuta SWI-Prolog en segundo plano y captura lo que imprime
        // Nota: Asegúrate que 'swipl' esté en las variables de entorno de Windows
        const resultado = execSync(`swipl -f hechos.pl -f predicados.pl -g "${consulta}"`).toString();
        res.json({ resultado });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Iniciar el servidor en el puerto 3000
app.listen(3000, () => {
    console.log('✅ Servidor corriendo en http://localhost:3000');
});