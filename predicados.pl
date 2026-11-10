
% ************************Datos administrativos****************************
%  Nombre del proyecto: Academia de detectives
%  Archivo: predicados.pl
%  Autor: Melany Jirón, Josimar Spencer y Diego Castillo
%  Empresa: Instituto Tecnológico de Costa Rica
%  ******************************Descripción*****************************
%  Este archivo contiene los predicados que permiten analizar la información de los hechos 
%  y generar un informe de investigación sobre el evento de desaparición en el museo.
%  ******************************Versión*********************************
%  1.0 | 09 de noviembre de 2026 | Melany Jirón, Josimar Spencer y Diego Castillo
% *************************************************************************

:- consult('hechos.pl').
:- dynamic evento/3. 

% Recibe una persona y un lugar y vincula la regla 
% de que dicha persona tiene acceso a dicho lugar
tiene_acceso(Persona, Lugar) :-
    acceso(Persona, Lugar).

% Recibe una persona y un lugar y vincula la regla
% de que dicha persona tiene acceso a dicho lugar mediante un objeto
% Si la persona tiene acceso a un lugar mediante un objeto, se verifica si la persona puede utilizar dicho objeto.
tiene_acceso(Persona, Lugar) :-
    accesoPorObjeto(Lugar, Objeto),
    puede_utilizar_objeto(Persona, Objeto).


% Recibe una persona y un lugar y vincula la regla
% de que dicha persona estuvo en dicho lugar en un momento determinado
% Si la persona estuvo en un lugar, se verifica si la persona tiene acceso a dicho lugar.
puede_utilizar_objeto(Persona, Objeto) :-
    persona(Persona),
    ubicado(Objeto, Lugar),
    estuvo(Persona, Lugar, _).

% Recibe una persona, un lugar y un rango de tiempo
% se verifica si la persona estuvo en dicho lugar dentro del rango de tiempo especificado
%  
estuvo_en_intervalo(Persona, Lugar, Inicio, Fin) :-
    estuvo(Persona, Lugar, Hora),
    Hora >= Inicio,
    Hora =< Fin.

% Recibe una persona y devuelve una lista de evidencias relacionadas con dicha persona
%  
evidencias_de(Persona, ListaEvidencias) :-
    findall(Evidencia, corresponde(Evidencia, Persona), ListaEvidencias).

% Recibe una persona y verifica si tiene una coartada válida
% Toma en cuenta el evento principal, los movimientos de la persona y 
% su testimonio para determinar si tiene una coartada sólida.
tiene_coartada(Persona) :-
    evento(_, LugarEvento, HoraEvento),
    testimonio(Persona, Lugar, Hora),
    estuvo(Persona, Lugar, Hora),
    Lugar \= LugarEvento,
    abs(Hora - HoraEvento) < 60.

% Recibe una persona y verifica si tiene contradicciones en su testimonio
% Toma en cuenta el testimonio de la persona y los registros de movimiento para determinar si hay contradicciones.
tiene_contradiccion(Persona) :-
    testimonio(Persona, Lugar, Hora),
    \+ estuvo(Persona, Lugar, Hora).

% Recibe una persona y determina si es un posible sospechoso
% Se toma en cuenta si la persona estuvo en el lugar del evento, si tiene acceso al lugar del evento,
% si hay evidencia que la vincule con el evento o si tiene contradicciones en su testimonio.
% posible_sospechoso tiene tres reglas que permiten determinar si una persona es un posible sospechoso.
% Regla n° 1: Una persona es un posible sospechoso si hay evidencia que la vincule con el evento.
posible_sospechoso(Persona) :-
    persona(Persona),
    evento(_, LugarEvento, _),
    evidencia(Evidencia, LugarEvento, _),
    corresponde(Evidencia, Persona).

% Regla n° 2: Una persona es un posible sospechoso si estuvo en el lugar del evento y tiene acceso a dicho lugar.
posible_sospechoso(Persona) :-
    persona(Persona),
    evento(_, LugarEvento, HoraEvento),
    tiene_acceso(Persona, LugarEvento),
    estuvo(Persona, LugarEvento, HoraEvento).

% Regla n° 3: Una persona es un posible sospechoso si tiene contradicciones en su testimonio y 
% tiene acceso al lugar del evento o corresponde a una evidencia encontrada en el lugar del evento.
posible_sospechoso(Persona) :-
    persona(Persona),
    tiene_contradiccion(Persona),
    evento(_, LugarEvento, _),
    (tiene_acceso(Persona, LugarEvento) ; corresponde(_, Persona)).

% Este predicado determina si una persona tiene evidencia relacionada con el evento
% tomando en cuenta la evidencia encontrada en el lugar del evento y si corresponde a la persona.
evidencia_en_evento(Persona) :-
    persona(Persona),
    evento(_, LugarEvento, _),
    evidencia(Evidencia, LugarEvento, _),
    corresponde(Evidencia, Persona).

% Este predicado descarta a una persona como sospechosa si tiene una coartada válida,
% no tiene contradicciones en su testimonio y no tiene evidencia relacionada con el evento.
descartar(Persona) :-
    persona(Persona),
    tiene_coartada(Persona),
    \+ tiene_contradiccion(Persona),
    \+ evidencia_en_evento(Persona).

% Aquí se define el predicado investigar/1, que genera un informe detallado sobre una persona específica.
% Aquí se recopilan los movimientos, accesos, evidencias, coartadas y contradicciones de la persona para presentar un informe completo.
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

% Este predicado genera una lista de personas que son posibles responsables del evento, tomando en cuenta si son posibles sospechosos y no han sido descartadas.
% 
posibles_responsables(Lista) :-
    setof(Persona, (persona(Persona), posible_sospechoso(Persona), \+ descartar(Persona)), Lista).

% Regla n° 1: Este predicado genera explicaciones lógicas para cada persona, basadas en su relación con el evento, sus movimientos, accesos, evidencias y contradicciones.
% Además este predicado esta hecho en 7 reglas.
explicaciones(Persona, Explicacion) :-
    evento(_, LugarEvento, _),
    tiene_acceso(Persona, LugarEvento),
    atomic_list_concat(['Tenia acceso directo a la zona del evento: ', LugarEvento], Explicacion).

% Regla n° 2: Este predicado genera una explicación para una persona que estuvo en el lugar del evento durante un intervalo de tiempo específico.
%
explicaciones(Persona, Explicacion) :-
    evento(_, LugarEvento, HoraEvento),
    estuvo_en_intervalo(Persona, LugarEvento, HoraEvento, 60),
    Explicacion = 'Estuvo cerca del lugar del evento alrededor de la hora del suceso'.

% Regla n° 3: Este predicado genera una explicación para una persona que tiene evidencia relacionada con el evento.
explicaciones(Persona, Explicacion) :-
    corresponde(Evidencia, Persona),
    evidencia(Evidencia, Lugar, _),
    atomic_list_concat(['Su evidencia (', Evidencia, ') fue encontrada en ', Lugar], Explicacion).

% Regla n° 4: Este predicado genera una explicación para una persona que tiene contradicciones en su testimonio.
explicaciones(Persona, Explicacion) :-
    tiene_contradiccion(Persona),
    Explicacion = 'Presenta contradicciones entre su testimonio y los registros de movimiento'.

% Regla n° 5: Este predicado genera una explicación para una persona que no tiene una coartada válida.
explicaciones(Persona, Explicacion) :-
    persona(Persona),
    \+ tiene_coartada(Persona),
    Explicacion = 'No posee una coartada valida para el momento del evento'.

% Regla n° 6: Este predicado genera una explicación para una persona que ha sido descartada.
explicaciones(Persona, Explicacion) :-
    descartar(Persona),
    Explicacion = 'Fue descartado porque su coartada es solida y verificable'.

% Este predicado genera un informe completo de investigación sobre el evento, incluyendo los posibles responsables, 
% sus evidencias, movimientos, accesos, coartadas y contradicciones.
% 
resolver_caso :-
    write('    Reporte de investigacion     '), nl,
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