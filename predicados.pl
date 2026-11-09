:- consult('hechos.pl').
:- dynamic evento/3. 

tiene_acceso(Persona, Lugar) :-
    acceso(Persona, Lugar).

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


evidencias_de(Persona, ListaEvidencias) :-
    findall(Evidencia, corresponde(Evidencia, Persona), ListaEvidencias).

tiene_coartada(Persona) :-
    evento(_, LugarEvento, HoraEvento),
    testimonio(Persona, Lugar, Hora),
    estuvo(Persona, Lugar, Hora),
    Lugar \= LugarEvento,
    abs(Hora - HoraEvento) < 60.

tiene_contradiccion(Persona) :-
    testimonio(Persona, Lugar, Hora),
    \+ estuvo(Persona, Lugar, Hora).

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
    tiene_contradiccion(Persona),
    evento(_, LugarEvento, _),
    (tiene_acceso(Persona, LugarEvento) ; corresponde(_, Persona)).

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
    findall(Lugar-Hora, estuvo(Persona, Lugar, Hora), Movimientos),
    findall(LugarAcc, tiene_acceso(Persona, LugarAcc), Accesos),
    evidencias_de(Persona, Evidencias),
    nl,
    write('----------- Informe ------------'), nl,
    write('Persona: '), write(Persona), nl,
    write('Movimientos registrados: '), write(Movimientos), nl,
    write('Lugares con acceso: '), write(Accesos), nl,
    write('Evidencias relacionadas: '), write(Evidencias), nl,
    (tiene_coartada(Persona) -> write('Tiene coartada: Si'), nl ; write('Tiene coartada: No'), nl),
    (tiene_contradiccion(Persona) -> write('Tiene contradicciones: Si'), nl ; write('Tiene contradicciones: No'), nl).

posibles_responsables(Lista) :-
    setof(Persona, (persona(Persona), posible_sospechoso(Persona), \+ descartar(Persona)), Lista).

explicaciones(Persona, Explicacion) :-
    evento(_, LugarEvento, _),
    tiene_acceso(Persona, LugarEvento),
    atomic_list_concat(['Tenia acceso directo a la zona del evento: ', LugarEvento], Explicacion).

explicaciones(Persona, Explicacion) :-
    evento(_, LugarEvento, HoraEvento),
    estuvo_en_intervalo(Persona, LugarEvento, HoraEvento, 60),
    Explicacion = 'Estuvo cerca del lugar del evento alrededor de la hora del suceso'.

explicaciones(Persona, Explicacion) :-
    corresponde(Evidencia, Persona),
    evidencia(Evidencia, Lugar, _),
    atomic_list_concat(['Su evidencia (', Evidencia, ') fue encontrada en ', Lugar], Explicacion).

explicaciones(Persona, Explicacion) :-
    tiene_contradiccion(Persona),
    Explicacion = 'Presenta contradicciones entre su testimonio y los registros de movimiento'.

explicaciones(Persona, Explicacion) :-
    persona(Persona),
    \+ tiene_coartada(Persona),
    Explicacion = 'No posee una coartada valida para el momento del evento'.

explicaciones(Persona, Explicacion) :-
    descartar(Persona),
    Explicacion = 'Fue descartado porque su coartada es solida y verificable'.

resolver_caso :-
    write('    Reporte de investigacion'), nl,
    write('============================'), nl,
    write('Evento investigado:'), nl,
    evento(NombreEvento, LugarEvento, HoraEvento),
    write('- Nombre: '), write(NombreEvento), nl,
    write('- Lugar: '), write(LugarEvento), nl,
    write('- Hora: '), write(HoraEvento), nl, nl,
    write('POSIBLES RESPONSABLES:'), nl,
    write('----------------------------------------'), nl,
    posibles_responsables(ListaResponsables),
    (ListaResponsables = [] ->
        write('No se encontraron posibles responsables.'), nl
    ;
        forall(member(Persona, ListaResponsables),
            (write('PERSONA: '), write(Persona), nl,
            write('----------------------------------------'), nl,
            write('Evidencias relacionadas:'), nl,
            evidencias_de(Persona, ListaEvidencias),
            (ListaEvidencias = [] ->
                write('  Ninguna'), nl
            ;
                forall(member(Ev, ListaEvidencias), (write('  - '), write(Ev), nl))),
            write('Ubicacion y movimientos:'), nl,
            forall(estuvo(Persona, Lugar, Hora),
                (write('  - Estuvo en '), write(Lugar), write(' a las '), write(Hora), nl)),
            write('Accesos relevantes:'), nl,
            findall(LugarAcc, tiene_acceso(Persona, LugarAcc), AccesosLista),
            list_to_set(AccesosLista, AccesosUnicos),
            forall(member(LugarAcc, AccesosUnicos),
                (write('  - Tiene acceso a '), write(LugarAcc), nl)),
            write('Coartadas:'), nl,
            (tiene_coartada(Persona) ->
                write('  Posee coartada'), nl
            ;
                write('  No tiene coartada valida'), nl),
            write('Contradicciones:'), nl,
            (tiene_contradiccion(Persona) ->
                write('  Presenta contradicciones'), nl
            ;
                write('  No presenta contradicciones'), nl),
            write('Justificacion logica:'), nl,
            forall(explicaciones(Persona, Exp), (write('  - '), write(Exp), nl)),
            nl, write('========================================'), nl, nl))),
    write('Personas descartadas:'), nl,
    forall((persona(PersonaDescartada), descartar(PersonaDescartada)),
        (write('- '), write(PersonaDescartada), nl,
        forall(explicaciones(PersonaDescartada, ExpDesc), (write('  Razon: '), write(ExpDesc), nl)),
        nl)),
    write('========================================'), nl,
    write('Conclusion:'), nl,
    (ListaResponsables = [] ->
        write('No hay suficientes evidencias para determinar responsables.'), nl
    ;
        length(ListaResponsables, Cantidad),
        write('Se identificaron '), write(Cantidad), write(' posible(s) responsable(s).'), nl,
        write('Personas: '), write(ListaResponsables), nl),
    write('========================================'), nl.