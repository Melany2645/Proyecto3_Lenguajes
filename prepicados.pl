evidencias_de(Persona, Evidencia) :- 
    findall(Evidencia, corresponde(Evidencia, Persona), Evidencias),
    member(Evidencia, Evidencias).

tiene_coartada(Persona) :-
    evento(_, LugarEvento, Hora),
    testimonio(Persona, Lugar, Hora),
    estuvo(Persona, Lugar, Hora),
    Lugar \= LugarEvento.

tiene_contradiccion(Persona) :- 
    testimonio(Persona, Lugar, Hora),
    not(estuvo(Persona, Lugar, Hora)).

posible_sospechoso(Persona) :-
    persona(Persona),
    evento(_, LugarEvento, _),
    evidencia(Evidencia, LugarEvento, _),
    corresponde(Evidencia, Persona).

posible_sospechoso(Persona) :-
    persona(Persona),
    evento(_, LugarEvento, HoraEvento),
    tiene_acceso(Persona, LugarEvento),
    estuvo(Persona, LugarEvento, HoraEvento).

posible_sospechoso(Persona) :-
    persona(Persona),
    tiene_contradiccion(Persona).

% Regla para ver si una persona tiene o no evidencias relacionadas a un caso

evidencia_en_evento(Persona) :-
    persona(Persona),
    evento(_, LugarEvento, _),
    evidencia(Evidencia, LugarEvento, _),
    corresponde(Evidencia, Persona).

descartar(Persona) :-
    persona(Persona),
    tiene_coartada(Persona),
    \+ tiene_contradiccion(Persona),
    \+ evidencia_en_evento(Persona).

investigar(Persona) :-
    persona(Persona),

    findall(Lugar_Hora, estuvo(Persona, Lugar, Hora), Movimientos),
    findall(Lugar, tiene_acceso(Persona, Lugar), Accesos),
    evidencias_de(Persona, Evidencias),

    nl,
    write("-----------Informe------------"), nl,
    write("Persona: "), write(Persona), nl,
    write("Movimientos registrados: "), write(Movimientos), nl,
    write("Lugares con acceso: "), write(Accesos), nl,
    write("Evidencias relacionadas: "), write(Evidencias), nl,

    write("Tiene coartada: "), (tiene_coartada(Persona) -> write("Sí") ; write("No")), nl,
    write("Tiene contradicciones: "), (tiene_contradiccion(Persona) -> write("Sí") ; write("No")), nl,

    write("------------------------------")
