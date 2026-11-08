
% Personas involucradas
persona(juan).
persona(mateo).
persona(carla).
persona(diego).
persona(vanessa).

% Lugares del museo
lugar(entrada, "Entrada principal del museo.").
lugar(biblioteca, "Biblioteca del museo.").
lugar(laboratorio, "Laboratorio de restauracion.").
lugar(bodega, "Bodega de almacenamiento.").
lugar(oficina, "Oficina administrativa.").

% Objetos
objeto(llave_maestra).
objeto(tarjeta_laboratorio).
objeto(documento).
objeto(caja_herramientas).

% Accesos autorizados
acceso(juan, biblioteca).
acceso(juan, oficina).
acceso(mateo, entrada).
acceso(mateo, bodega).
acceso(carla, laboratorio).
acceso(carla, biblioteca).
acceso(diego, entrada).
acceso(diego, biblioteca).
acceso(vanessa, oficina).

% Accesos mediante objetos
accesoPorObjeto(bodega, llave_maestra).
accesoPorObjeto(laboratorio, tarjeta_laboratorio).

% Registro de movimientos (hora HHMM)
estuvo(juan, entrada, 1900).
estuvo(juan, biblioteca, 1930).
estuvo(mateo, entrada, 1910).
estuvo(mateo, bodega, 1950).
estuvo(carla, biblioteca, 1920).
estuvo(carla, laboratorio, 1955).
estuvo(diego, entrada, 1900).
estuvo(diego, biblioteca, 1940).
estuvo(vanessa, oficina, 1900).

% Evento principal
evento(desaparicion, bodega, 2000).

% Evidencias encontradas
evidencia(huella, bodega, 1955).
evidencia(llave, bodega, 1950).
evidencia(documento, oficina, 1930).

% Relacion entre evidencias y personas
corresponde(huella, mateo).
corresponde(llave, mateo).
corresponde(documento, juan).

% Testimonios
testimonio(mateo, entrada, 1955).
testimonio(carla, biblioteca, 1955).
testimonio(juan, biblioteca, 1930).

% Ubicacion de objetos
ubicado(llave_maestra, oficina).
ubicado(tarjeta_laboratorio, biblioteca).