% Cargar la base de conocimiento
:- consult('hechos.pl').

% tiene_acceso(+Persona, +Lugar)
% Determina si una persona tiene acceso directo a un lugar segun los permisos registrados.

tiene_acceso(Persona, Lugar) :-
    acceso(Persona, Lugar).

% Determina si una persona estuvo en un lugar dentro de un intervalo de tiempo.

estuvo_en_intervalo(Persona, Lugar, Inicio, Fin) :-
    estuvo(Persona, Lugar, Hora),
    Hora >= Inicio,
    Hora =< Fin.


% Josimar

posibles_responsables(Lista) :-
    findall(Persona, (persona(Persona), posible_sospechoso(Persona), \+ descartar(Persona)), Lista).

explicaciones(Persona, Explicacion) :-
    evento(_, LugarEvento, _),
    tiene_acceso(Persona, LugarEvento),
    atom_concat('Tenia acceso directo a la zona del evento: ', LugarEvento, Explicacion).

explicaciones(Persona, Explicacion) :-
    evento(_, LugarEvento, HoraEvento),
    estuvo_en_intervalo(Persona, LugarEvento, HoraEvento, 60),
    atom_concat('Estuvo cerca del lugar del evento alrededor de la hora del suceso', Explicacion).

explicaciones(Persona, Explicacion) :-
    corresponde(Evidencia, Persona),
    evidencia(Evidencia, Lugar, _),
    atomic_list_concat(['Su evidencia (', Evidencia, ') fue encontrada en ', Lugar], Explicacion).

explicaciones(Persona, Explicacion) :-
    tiene_contradiccion(Persona),
    atom_concat('Presenta contradicciones entre su testimonio y los registros de movimiento', Explicacion).

explicaciones(Persona, Explicacion) :-
    persona(Persona),
    \+ tiene_coartada(Persona),
    atom_concat('No posee una coartada valida para el momento del evento', Explicacion).

explicaciones(Persona, Explicacion) :-
    descartar(Persona),
    atom_concat('Fue descartado porque su coartada es solida y verificable', Explicacion).