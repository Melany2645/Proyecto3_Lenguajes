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