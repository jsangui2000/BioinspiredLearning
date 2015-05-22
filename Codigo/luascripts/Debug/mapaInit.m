mapa = struct;
mapa.puntos = struct;           %tabla de coordenadas
%mapa.puntos(i).coords              coord x del punto
%mapa.puntos(i).asig              id arista siguiente
%mapa.puntos(i).aant              id arista anterior
%mapa.puntos(i).terminal        booleano, indica si es el fin del segmento
%mapa.puntos(i).certeza
%mapa.puntos(i).fijo

mapa.cantPuntos = 0;




mapa.aristas = struct;          %tabla de id de puntos
%mapa.aristas(i).ids =[id1,id1] %puntos aristas ordenados en sentid antihorario
%mapa.arista(i).perpen =[v1,v2] %vector perpendicular a la arista
%mapa.arista(i).z               %curva de nivel de la recta
%mapa.arista(i).vdir            %dir de la recta unitario
%mapa.arista(i).v1min = vdir * p1
%mapa.arista(i).v2max = vdir * p2
%mapa.arista(i).tita = atan2(z(2),z
%mapa.aristas(i).pointIds        ids cuando esta activa
mapa.cantAristas = 0;
mapa.hashAngulo = struct;
for i=1:360
    mapa.hashAngulo(i).aristas = [];
end
mapa.conversor = @(vdir) 180 + ceil( 180*atan2(vdir(2),vdir(1))/pi);


mapa.activos = struct;
%mapa.activos(i).idArista

%mapa.activos(i).actividad
%mapa.mayorActividad
%mapa.idMayorActividad
%mapa.cantActivos


mapa.pos = [0,0];
mapa.headdir = headdir(1);
mapa.nivel = 0; %indica el mayor nivel de certeza utilizado, cuanto mas alto menos certeza