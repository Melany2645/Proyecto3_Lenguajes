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
