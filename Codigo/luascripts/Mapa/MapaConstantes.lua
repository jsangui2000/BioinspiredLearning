local MapaConstantes = {}

--Algoritmo en general:
MapaConstantes.cantPuntos = 100

--Segmentacion Inicial
MapaConstantes.conexion = 0.45*0.45
MapaConstantes.maxError = 0.018
MapaConstantes.minDist = 0.25*0.25
MapaConstantes.minPuntos = 4

--Procesar Segmentos
MapaConstantes.anguloJuntar = 15/180 * math.pi

--Esquinas
MapaConstantes.radioEsquinas = 0.1
MapaConstantes.angParalelas = 5/180*math.pi


--Mapa->matchMejorArista
MapaConstantes.maxAngDif = 15*math.pi/180

--Mapa->matchAristas
MapaConstantes.toleranciaAngulo = 15*math.pi/180
MapaConstantes.toleranciaProyV = 0.45
MapaConstantes.toleranciaProyZMin = 0.2  --la tolerancia en z es esto mas el nivel del mapa
MapaConstantes.gradosTolerancia = 15
MapaConstantes.minAngIntersectar = math.cos(20/180*math.pi)





return MapaConstantes