% Carga los hechos del caso.
:- consult('hechos.pl').

% Acceso directo.
tiene_acceso(Persona, Lugar) :-
    acceso(Persona, Lugar).

% Acceso mediante un objeto.
tiene_acceso(Persona, Lugar) :-
    accesoPorObjeto(Lugar, Objeto),
    puede_utilizar_objeto(Persona, Objeto).

puede_utilizar_objeto(Persona, Objeto) :-
    persona(Persona),
    ubicado(Objeto, Lugar),
    estuvo(Persona, Lugar, _).

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
    atom_concat('Fue descartado porque su coartada es solida y verificable', Explicacion). No newline at end of file