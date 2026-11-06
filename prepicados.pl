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




