% mostrar tabla aristas y puntos para un index
clc
myIndex = 221
myMap = tablaMapas(myIndex).mapa;

myPoints = [];
for i=1:length(myMap.puntos)
    myPoints = [myPoints;myMap.puntos(i).coords];
end

myAristas = [];
for i=1:length(myMap.aristas)
    myAristas = [myAristas;myMap.puntos(myMap.aristas(i).ids(1)).coords,myMap.puntos(myMap.aristas(i).ids(2)).coords];
end
    
myPoints = myPoints
myAristas = myAristas

%% load lua struct
seg3lua = struct;
cant = 1388
for i=1:cant
   seg3lua(i).seg = load(strcat('seg3/seg',num2str(i),'.txt'));
   seg3lua(i).vec = load(strcat('seg3/vec',num2str(i),'.txt'));
   seg3lua(i).perpen = load(strcat('seg3/perpen',num2str(i),'.txt'));
   seg3lua(i).conex = load(strcat('seg3/conex',num2str(i),'.txt'));
end

%% load ids
for i=1:cant
    seg3lua(i).ids = struct;
    cantids = load(strcat('seg3/ids/ids',num2str(i),'-cant','.txt')); 
    for j=1:cantids
        seg3lua(i).ids(j).ids = load(strcat('seg3/ids/ids',num2str(i),'-',num2str(j),'.txt'));
    end
    
end

%% check ids

for i=1:cant
    for j=1:length(seg3lua(i).ids)
        if ~isequal(seg3lua(i).ids(j).ids,cell2mat(tablaSeg(i).seg2(j)))
            disp(i)
            %seg3lua(i).ids(j).ids
            %cell2mat(tablaSeg(i).seg2(j))
        end
    end
end


%% check conexion


for i=1:cant
    if ~isequal(seg3lua(i).conex, tablaSeg(i).con3)
        disp(i)
        seg3lua(i).conex
        tablaSeg(i).con3
    end
end

%% check segmentos
%dif de 1 mm: muchos
for i=1:cant
    if isequal(size(seg3lua(i).seg),size(tablaSeg(i).seg3))
        if ~all(all((abs(seg3lua(i).seg - tablaSeg(i).seg3)) <= 0.001))
            %disp('not equal')
            %disp(i)
            %abs(seg3lua(i).seg - tablaSeg(i).seg3)
        end
    else
        disp('dim missmatch')
        disp(i)
        
    end
end

%% check vecs
for i=1:cant
    if isequal(size(seg3lua(i).seg),size(tablaSeg(i).seg3))
        if ~all(all((abs(seg3lua(i).vec - tablaSeg(i).vec)) <= 0.075))
            %disp('not equal')
            disp(i)
            abs(seg3lua(i).vec - tablaSeg(i).vec)
        end
    else
        disp('dim missmatch')
        disp(i)
    end
end


%% check perpen
for i=1:cant
    if isequal(size(seg3lua(i).seg),size(tablaSeg(i).seg3))
        if ~all(all((abs(seg3lua(i).perpen - tablaSeg(i).perpen)) <= 0.001))
            disp('not equal')
            disp(i)
            abs(seg3lua(i).perpen - tablaSeg(i).perpen)
        end
    else
        disp('dim missmatch')
        disp(i)
        
    end
end
    
    
%%
ind = 182
mids = 71:76;
mpuntos = realesCartP(ind,:,:);
[mcentro,mvec,mmaxD] = medianReglin(mpuntos,mids)
mdv = mpuntos(1,mids(end),:) - mpuntos(1,mids(1),:)
mdist = sum(mdv.*mdv)

%%
mpuntosX = mpuntos(1,71:77,1)
mpuntosY = mpuntos(1,71:77,2)
