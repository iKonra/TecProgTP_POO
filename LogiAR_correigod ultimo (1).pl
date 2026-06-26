%TRANSPORTES
% transporte(ID, Tipo, CapacidadMaximaKg, Estado)


transporte(t1, camion, 5000, en_servicio).
transporte(t2, camion, 7000, en_servicio).
transporte(t3, barco, 25000, en_servicio).
transporte(t4,camion_sisterna, 18000, en_servicio).
transporte(t5, avion, 9000, fuera_de_servicio).
transporte(t6, avion, 12000, en_servicio).





%PAQUETES
% paquete(ID, Descripcion, PesoKg, PaisDestino)


paquete(p1, alimentos, 500, bolivia).
paquete(p2, quimicos, 300, argentina).
paquete(p3, alimentos, 200, uruguay).
paquete(p4, medicamentos, 50, paraguay).
paquete(p5, maquinaria, 500, mexico).
paquete(p6, libros, 40, peru).
paquete(p7, juguetes, 70, colombia).
paquete(p8, repuestos, 300, brasil).
paquete(p9, herramientas, 180, chile).
paquete(p10, computadoras, 250, uruguay).
paquete(p11, baterias, 150, mexico).
paquete(p12, bebidas, 90, peru).
paquete(p13, jetfuel, 15000, alemania).



% CONTENEDORES
% contenedor(ID, ListaPaquetes)


contenedor(c1, [p1]).
contenedor(c2, [p4, p5]).
contenedor(c3, [p6, p7, p8]).
contenedor(c4, [p9]).
contenedor(c5, [p10, p11, p12]).
contenedor(c6, [p13]).
contenedor(c7, [p1, p2]).



% DESPACHOS
% despacho(Fecha, Transporte, ListaContenedores)
% fecha(Dia, Mes, Anio)


despacho(fecha(10,5,2026), t1, [c1]).
despacho(fecha(12,5,2026), t3, [c2, c3]).
despacho(fecha(18,5,2026), t2, [c4]).
despacho(fecha(22,5,2026), t5, [c5]).







% Predicados auxiliares

peso_total([], 0).
peso_total([P|Resto], Total) :- 
    paquete(P, _, Peso, _),         %recorre la lista de paquetes y suma el peso 
    peso_total(Resto, SubTotal),    %(se obtiene el peso total del contenedor)
    Total is Peso + SubTotal.


descripciones([], []).
descripciones([P|Resto], [Desc|DescsResto]) :-    %recorre la lista de paquetes y construye 
    paquete(P, Desc, _, _),                       %una lista con todas las descripciones                      %(se obtiene la lista de descripciones de los paquetes del contenedor)
    descripciones(Resto, DescsResto).

no_contiene(_, []).
no_contiene(Elem, [Cab|Resto]) :-
    Elem \= Cab,
    no_contiene(Elem, Resto).                %veradero si el elemento no esta en la lista (Se usa en unas restricciones)



% Auxiliares de cisterna, unicos elementos a transportar
carga_permitida_cisterna(jetfuel).
carga_permitida_cisterna(lubricantes).

% Verificaciones de descripciones de elemetnos de cisterna
todos_permitidos_cisterna([]).
todos_permitidos_cisterna([D|Resto]) :-
    carga_permitida_cisterna(D),
    todos_permitidos_cisterna(Resto).

% Restricciones 

% 1. Aviones: No se pueden transportar baterias, ni elementos que las contengan.
contiene_baterias(computadoras).

es_peligroso_avion(baterias).
es_peligroso_avion(Elemento) :- contiene_baterias(Elemento).

carga_segura_avion([]).
carga_segura_avion([Cab|Resto]) :-
    \+ es_peligroso_avion(Cab), 
    carga_segura_avion(Resto).

restricciones_ok(avion, Paquetes) :-
    descripciones(Paquetes, Descs),
    carga_segura_avion(Descs).



% 2. Camiones Sisterna: Sólo transportan combustibles y lubricantes.
restricciones_ok(camion_sisterna, Paquetes) :-
    descripciones(Paquetes, Descs),
    todos_permitidos_cisterna(Descs).



% 3. Camiones: Además en Argentina la CNRT prohibe cargar “alimentos y químicos juntos” o 
% “animales y elementos tóxicos”. 
restricciones_ok(camion, Paquetes) :-
    descripciones(Paquetes, Descs),
    (no_contiene(alimentos, Descs), ! ; no_contiene(quimicos, Descs)),
    (no_contiene(animales, Descs), ! ; no_contiene(toxicos, Descs)).



% 4. Barcos: no hay restricciones más allá de las asociadas al peso de los contenedores.
restricciones_ok(barco, _).



puede_transportar(TransporteID, ContenedorID) :- %  Argumentos transporte y contenedor
    transporte(TransporteID, Tipo, CapacidadMax, en_servicio), % Verifica que no importa que transporte sea, si no que este en_servicio
    contenedor(ContenedorID, Paquetes), % Asocia que paquetes tiene el contenedor que se paso
    peso_total(Paquetes, PesoTotal), % Calcula el peso total de todos los paquetes
    PesoTotal =< CapacidadMax, % Si el peso total es menor o igual a la Capacidad Max
    restricciones_ok(Tipo, Paquetes). % Si las restricciones se pueden