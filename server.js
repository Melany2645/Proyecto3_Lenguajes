const express = require('express');
const { execSync } = require('child_process');
const app = express();

app.use(express.json());
app.use(express.static('web'));

app.post('/api/resolver', (req, res) => {
    const { nombre, lugar, hora } = req.body;
    
    // PASO 1: Verificar si el evento existe en la base de conocimiento
    const consultaValidacion = `evento(${nombre}, ${lugar}, ${hora}), halt`;
    
    try {
        // Intentamos consultar si el evento existe
        execSync(`swipl -f hechos.pl -f predicados.pl -g "${consultaValidacion}"`);
        
        // PASO 2: Si el evento existe, ejecutar resolver_caso
        const consultaResolucion = `with_output_to(string(R), resolver_caso), write(R), halt`;
        const resultado = execSync(`swipl -f hechos.pl -f predicados.pl -g "${consultaResolucion}"`).toString();
        
        res.json({ resultado });
        
    } catch (error) {
        // Si el evento no existe, Prolog falla y caemos aquí
        const mensajeError = `El evento "${nombre}" en "${lugar}" a las ${hora} no existe en la base de conocimiento. Por favor, ingresa un evento válido.`;
        res.status(400).json({ error: mensajeError });
    }
});

app.listen(3000, () => {
    console.log(' Servidor corriendo en http://localhost:3000');
});