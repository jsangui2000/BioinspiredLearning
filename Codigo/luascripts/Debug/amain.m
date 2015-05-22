load 'coords';
lab8 = lab8();
minum = '1425329797.txt';
[ring,ringFiles] = loadVar('laser');
[reales,realesFiles] = loadVar('reales');
[headdir,headdirFiles] = loadVar('headdir');
[pos,posFiles] = loadVar('pos');

realesRotadas = girar(reales,-headdir);
realesCart = toCartessian(reales);
realesCartRotadas =toCartessian(realesRotadas);

realesRotadasP = filtroPicos(realesRotadas);
realesP = girar(realesRotadasP,headdir);
realesCartP = toCartessian(realesP);
realesCartRotadasP =toCartessian(realesRotadasP);

realesRotadasT = filtroTambaleo(realesRotadas);
realesT = girar(realesRotadasT,headdir);
realesCartT = toCartessian(realesT);
realesCartRotadasT =toCartessian(realesRotadasT);

realesRotadasTP = filtroPicos(realesRotadasT);
realesTP = girar(realesRotadasTP,headdir);
realesCartTP = toCartessian(realesTP);
realesCartRotadasTP =toCartessian(realesRotadasTP);


%
realesCartRotadasP;
ri = cat(2,realesCartRotadasP(:,2:100,:),realesCartRotadasP(:,1,:));
dif = ri - realesCartRotadasP;
dif2 = dif.* dif;
distanciasR = sqrt(dif2(:,:,1) + dif2(:,:,2));
angulosR = atan2(dif(:,:,2),dif(:,:,1));

realesCartP;
ri = cat(2,realesCartP(:,2:100,:),realesCartP(:,1,:));
dif = ri - realesCartP;
dif2 = dif.* dif;
distanciasN = sqrt(dif2(:,:,1) + dif2(:,:,2));
angulosN = atan2(dif(:,:,2),dif(:,:,1));



%%
name = 'conexos.avi';
doSave = true;
fromStart = true;
if doSave
    writerObj = VideoWriter(name);
    open(writerObj);
end
tocs = zeros(1,size(distanciasR,1));
posCalculada = zeros(size(pos));
mapaInit;
tablaMatch = struct;
tablaMatch.matches = [];
tablaMatch.id = 0;

tablaSeg = struct;
tablaSeg.seg1 = []
tablaSeg.con1 = []
tablaSeg.seg2 = []
tablaSeg.con2 = []
tablaSeg.seg3 = []
tablaSeg.con3 = []
tablaSeg.esquinas = []
tablaSeg.vec = []
tablaSeg.centros=[]
tablaSeg.sids=[]
tablaSeg.resol=[]


tablaMapas = struct();
tablaMapas.mapa =struct;
headdif = zeros(1,size(distanciasR,1));
posdif = zeros(1,size(distanciasR,1));

%%
%130-135
%500
%350-351
%731
%565
varPuntos = realesCartP;
tablaVieja = tablaMapas;
plotErrors = false;

if ~fromStart
    doSave =false;
    mapa = tablaMapas(160).mapa;
end
fromStart = false;
last = 1;
for timeIndex=182%:size(distanciasR,1)
    timeIndex
    tic
    %mapa.pos = pos(j,:);
    [seg1,conectados1] = segmentar3(varPuntos(timeIndex,:,:),distanciasN(timeIndex,:),0.45,angulosN(timeIndex,:),(pi/2)/6,0.03,0.25*0.25);
    [seg2,conectados2] = procesarSegmentos2(seg1,conectados1,varPuntos(timeIndex,:,:),0.45,15/180*pi);
    [seg3,finales,vec,centros,sids,conectados,resol] = esquinas(varPuntos(timeIndex,:,:),seg2,conectados2,0.1,5/180*pi);
    tablaSeg(timeIndex).seg1 = seg1
    tablaSeg(timeIndex).con1 = conectados1
    tablaSeg(timeIndex).seg2 = seg2
    tablaSeg(timeIndex).con2 = conectados2
    tablaSeg(timeIndex).seg3 = seg3
    tablaSeg(timeIndex).con3 = conectados
    tablaSeg(timeIndex).esquinas = finales
    tablaSeg(timeIndex).vec = vec
    tablaSeg(timeIndex).centros=centros
    tablaSeg(timeIndex).sids=sids
    tablaSeg(timeIndex).resol=resol
    
    
    
    
    finales2 = finales
    
    
    sEncontrados = seg3;
    mapaReconocimiento;
    tablaMapas(timeIndex).mapa = mapa;
    
    toc
    tocs(timeIndex) =toc;
    1;
    figure(1)
    clf
    
    %'desp'
    %timeIndex
    
    headdif(timeIndex) = headdir(timeIndex) - mapa.headdir;
    if headdif(timeIndex) > pi
        headdif(timeIndex) = 2*pi - headdif(timeIndex);
    elseif headdif(timeIndex) <= -pi
        headdif(timeIndex) = -2*pi - headdif(timeIndex);
    end
    posdif(timeIndex) = norm(pos(timeIndex,:)-mapa.pos);
    
    girarX = [cos(headdir(timeIndex)),-sin(headdir(timeIndex))];
    girarY = [-girarX(2),girarX(1)];
    puntosRotados = zeros(2,100);
    puntosRotados(1,:) = varPuntos(timeIndex,:,1)*girarX(1) + varPuntos(timeIndex,:,2)*girarX(2);
    puntosRotados(2,:) = varPuntos(timeIndex,:,1)*girarY(1) + varPuntos(timeIndex,:,2)*girarY(2);
    puntosRotadosLab = puntosRotados;
    fh = myPlot(puntosRotados(1,:)+pos(timeIndex,1),puntosRotados(2,:)+pos(timeIndex,2),lab8,1,2,2,1);
    hold on
    plot(pos(timeIndex,1),pos(timeIndex,2),'rx')
    hold off
    
    if false
        myPlot(pos(timeIndex,1),pos(timeIndex,2),lab8,1,2,2,3);
        seg = seg1;
        hold on
        markerSize = 8;
        for i=1:size(seg,2)
            puntos = cell2mat(seg(i));
            puntosRotados = zeros(2,length(puntos));
            puntosRotados(1,:) = varPuntos(timeIndex,puntos,1)*girarX(1) + varPuntos(timeIndex,puntos,2)*girarX(2);
            puntosRotados(2,:) = varPuntos(timeIndex,puntos,1)*girarY(1) + varPuntos(timeIndex,puntos,2)*girarY(2);
            if mod(i,3) == 0
                plot(puntosRotados(1,:)+pos(timeIndex,1),puntosRotados(2,:)+pos(timeIndex,2),'-xk','LineWidth',3 )
            elseif mod(i,3) == 1
                plot(puntosRotados(1,:)+pos(timeIndex,1),puntosRotados(2,:)+pos(timeIndex,2),'-xr','LineWidth',3)
            else
                plot(puntosRotados(1,:)+pos(timeIndex,1),puntosRotados(2,:)+pos(timeIndex,2),'-xb','LineWidth',3)
            end
        end
        hold off
    else
        mapaPlot;
    end
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
    
    


    
    myPlot(pos(timeIndex,1),pos(timeIndex,2),lab8,1,2,2,2);
    seg = seg2;
    hold on
    markerSize = 8;
    for i=1:size(seg,2)
        puntos = cell2mat(seg(i));
        puntosRotados = zeros(2,length(puntos));
        puntosRotados(1,:) = varPuntos(timeIndex,puntos,1)*girarX(1) + varPuntos(timeIndex,puntos,2)*girarX(2);
        puntosRotados(2,:) = varPuntos(timeIndex,puntos,1)*girarY(1) + varPuntos(timeIndex,puntos,2)*girarY(2);
        if mod(i,3) == 0
            plot(puntosRotados(1,:)+pos(timeIndex,1),puntosRotados(2,:)+pos(timeIndex,2),'-xk','LineWidth',3 )
        elseif mod(i,3) == 1
            plot(puntosRotados(1,:)+pos(timeIndex,1),puntosRotados(2,:)+pos(timeIndex,2),'-xr','LineWidth',3)
        else
            plot(puntosRotados(1,:)+pos(timeIndex,1),puntosRotados(2,:)+pos(timeIndex,2),'-xb','LineWidth',3)
        end
    end
    hold off
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
    

    
    myPlot(puntosRotadosLab(1,:)+pos(timeIndex,1),puntosRotadosLab(2,:)+pos(timeIndex,2),lab8,1,2,2,4);
   
    hold on
    plot(pos(timeIndex,1),pos(timeIndex,2),'xg','MarkerSize',markerSize)
    markerSize = 10;
    girarX = girarX;
    girarY = girarY;
    
    puntosRotados = zeros(size(seg3));
    puntosRotados(:,[1,3]) = seg3(:,[1,3])*girarX(1) + seg3(:,[2,4])*girarX(2);
    puntosRotados(:,[2,4]) = seg3(:,[1,3])*girarY(1) + seg3(:,[2,4])*girarY(2);
    puntosRotados = puntosRotados;
    
    
    for findIndex = 1:size(puntosRotados,1)
        plot(puntosRotados(findIndex,[1,3])+pos(timeIndex,1),puntosRotados(findIndex,[2,4])+pos(timeIndex,2),'-ks','LineWidth',2)
        if finales2(findIndex,1)
            plot(puntosRotados(findIndex,1)+pos(timeIndex,1),[puntosRotados(findIndex,2)]+pos(timeIndex,2),'xr','Markersize', markerSize)
        else
            plot(puntosRotados(findIndex,1)+pos(timeIndex,1),[puntosRotados(findIndex,2)]+pos(timeIndex,2),'xb','Markersize', markerSize)
        end
        if finales2(findIndex,2)
            plot([puntosRotados(findIndex,3)]+pos(timeIndex,1),[puntosRotados(findIndex,4)]+pos(timeIndex,2),'xr','Markersize', markerSize )
        else
            plot([puntosRotados(findIndex,3)]+pos(timeIndex,1),[puntosRotados(findIndex,4)]+pos(timeIndex,2),'xb','Markersize', markerSize )
        end
        text((puntosRotados(findIndex,1)+puntosRotados(findIndex,3))/2+pos(timeIndex,1),(puntosRotados(findIndex,2)+puntosRotados(findIndex,4))/2+pos(timeIndex,2),num2str(findIndex))
        
        
    end
    
    plot(mapa.pos(1),mapa.pos(2),'x','Markersize', markerSize)
    
    hold off
    
%      myPlot(pos(timeIndex,1),pos(timeIndex,2),lab8,1,2,2,4);
%     hold on
%     markerSize = 10;
%     for findIndex = 1:size(sEncontrados,1)
%         plot([sEncontrados(findIndex,1),sEncontrados(findIndex,3)]+mapa.pos(1),[sEncontrados(findIndex,2),sEncontrados(findIndex,4)]+mapa.pos(2),'-k','LineWidth',2)
%         if finales(findIndex,1)
%             plot(sEncontrados(findIndex,1)+pos(timeIndex,1),[sEncontrados(findIndex,2)]+pos(timeIndex,2),'xr','Markersize', markerSize)
%         else
%             plot(sEncontrados(findIndex,1)+pos(timeIndex,1),[sEncontrados(findIndex,2)]+pos(timeIndex,2),'xb','Markersize', markerSize)
%         end
%         if finales(findIndex,2)
%             plot([sEncontrados(findIndex,3)]+pos(timeIndex,1),[sEncontrados(findIndex,4)]+pos(timeIndex,2),'xr','Markersize', markerSize )
%         else
%             plot([sEncontrados(findIndex,3)]+pos(timeIndex,1),[sEncontrados(findIndex,4)]+pos(timeIndex,2),'xb','Markersize', markerSize )
%         end
%         text((sEncontrados(findIndex,1)+sEncontrados(findIndex,3))/2+pos(timeIndex,1),(sEncontrados(findIndex,2)+sEncontrados(findIndex,4))/2+pos(timeIndex,2),num2str(findIndex))
%         
%         
%     end
%     hold off
    
    
    
    if doSave
        frame = getframe(fh);
        writeVideo(writerObj,frame);
    end
    last = timeIndex;
end

if doSave
    close(writerObj);
end

if plotErrors 
    %
    figure(79)
    clf
    plot(headdif(1:last),'-x')
    figure(80)
    clf
    plot(posdif(1:last),'-x')
    %%
    figure(90)
    clf
    subplot(2,1,1)
    plot(headdir(1:last))
    subplot(2,1,2)
    deltaPos = [0,0;pos(2:end,:)-pos(1:end-1,:)]
    deltaPos = sqrt(sum(deltaPos.*deltaPos,2));
    plot(deltaPos,'-x')
    %%
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


name = 'conexos.avi';
doSave = true;
fromStart = true;
if doSave
    writerObj = VideoWriter(name);
    open(writerObj);
end
tocs = zeros(1,size(distancias,1));
posCalculada = zeros(size(pos));
mapaInit;
tablaMatch = struct;
tablaMatch.matches = [];
tablaMatch.id = 0;

tablaMapas = struct();
tablaMapas.mapa =struct;

%
%127
varPuntos = realesCartRotadasP;
%
if ~fromStart
    doSave =false;
    mapa = tablaMapas(920).mapa;
end
fromStart = false;
for timeIndex=1%:size(distancias,1)
    timeIndex
    tic
    %mapa.pos = pos(j,:);
    [seg1,conectados1] = segmentar2(varPuntos(timeIndex,:,:),distanciasR(timeIndex,:),0.45,angulosR(timeIndex,:),(pi/2)/3,0.01);
    [seg2,conectados2] = procesarSegmentos2(seg1,conectados1,varPuntos(timeIndex,:,:),0.45,15/180*pi);
    [seg3,finales,vec,centros,sids,conectados,resol] = esquinas(varPuntos(timeIndex,:,:),seg2,conectados2,0.1,5/180*pi);
    sEncontrados = seg3;
    %mapaReconocimiento;
    tablaMapas(timeIndex).mapa = mapa;
    
    toc;
    tocs(timeIndex) =toc;
    1;
    figure(2)
    clf
    
    %'desp'
    %timeIndex
    fh = myPlot(varPuntos(timeIndex,:,1)+pos(timeIndex,1),varPuntos(timeIndex,:,2)+pos(timeIndex,2),lab8,2,2,2,1);
    hold on
    plot(mapa.pos(1),mapa.pos(2),'rx')
    hold off
    
    
    myPlot(pos(timeIndex,1),pos(timeIndex,2),lab8,2,2,2,3);
    hold on
    for i=1:size(seg2,2)
        puntos = cell2mat(seg2(i));
        if mod(i,3) == 0
            plot(varPuntos(timeIndex,puntos,1),varPuntos(timeIndex,puntos,2),'-xk')
        elseif mod(i,3) == 1
            plot(varPuntos(timeIndex,puntos,1),varPuntos(timeIndex,puntos,2),'-xr')
        else
            plot(varPuntos(timeIndex,puntos,1),varPuntos(timeIndex,puntos,2),'-xb')%'LineWidth',1
        end
        text(varPuntos(timeIndex,puntos(1),1),varPuntos(timeIndex,puntos(1),2),num2str(i))
        
    end
    hold off
    
    
    %mapaPlot;
    

    
    myPlot(pos(timeIndex,1),pos(timeIndex,2),lab8,2,2,2,2);
    seg = seg2;
    hold on
    markerSize = 8;
    for i=1:size(seg,2)
        puntos = cell2mat(seg(i));
        if mod(i,3) == 0
            plot(varPuntos(timeIndex,puntos,1)+pos(timeIndex,1),varPuntos(timeIndex,puntos,2)+pos(timeIndex,2),'-xk','LineWidth',3 )
        elseif mod(i,3) == 1
            plot(varPuntos(timeIndex,puntos,1)+pos(timeIndex,1),varPuntos(timeIndex,puntos,2)+pos(timeIndex,2),'-xr','LineWidth',3)
        else
            plot(varPuntos(timeIndex,puntos,1)+pos(timeIndex,1),varPuntos(timeIndex,puntos,2)+pos(timeIndex,2),'-xb','LineWidth',3)
        end
    end
    hold off
    
    myPlot(pos(timeIndex,1),pos(timeIndex,2),lab8,2,2,2,4);
    hold on
    markerSize = 10;
    for findIndex = 1:size(seg3,1)
        plot([seg3(findIndex,1),seg3(findIndex,3)],[seg3(findIndex,2),seg3(findIndex,4)]+mapa.pos(2),'-k','LineWidth',2)
        if finales(findIndex,1)
            plot(seg3(findIndex,1),[seg3(findIndex,2)],'xr','Markersize', markerSize)
        else
            plot(seg3(findIndex,1),[seg3(findIndex,2)],'xb','Markersize', markerSize)
        end
        if finales(findIndex,2)
            plot([seg3(findIndex,3)],[seg3(findIndex,4)],'xr','Markersize', markerSize )
        else
            plot([seg3(findIndex,3)],[seg3(findIndex,4)],'xb','Markersize', markerSize )
        end
        text((seg3(findIndex,1)+seg3(findIndex,3))/2+pos(timeIndex,1),(seg3(findIndex,2)+seg3(findIndex,4))/2+pos(timeIndex,2),num2str(findIndex))
        
        
    end
    hold off
    
%      myPlot(pos(timeIndex,1),pos(timeIndex,2),lab8,1,2,2,4);
%     hold on
%     markerSize = 10;
%     for findIndex = 1:size(sEncontrados,1)
%         plot([sEncontrados(findIndex,1),sEncontrados(findIndex,3)]+mapa.pos(1),[sEncontrados(findIndex,2),sEncontrados(findIndex,4)]+mapa.pos(2),'-k','LineWidth',2)
%         if finales(findIndex,1)
%             plot(sEncontrados(findIndex,1)+pos(timeIndex,1),[sEncontrados(findIndex,2)]+pos(timeIndex,2),'xr','Markersize', markerSize)
%         else
%             plot(sEncontrados(findIndex,1)+pos(timeIndex,1),[sEncontrados(findIndex,2)]+pos(timeIndex,2),'xb','Markersize', markerSize)
%         end
%         if finales(findIndex,2)
%             plot([sEncontrados(findIndex,3)]+pos(timeIndex,1),[sEncontrados(findIndex,4)]+pos(timeIndex,2),'xr','Markersize', markerSize )
%         else
%             plot([sEncontrados(findIndex,3)]+pos(timeIndex,1),[sEncontrados(findIndex,4)]+pos(timeIndex,2),'xb','Markersize', markerSize )
%         end
%         text((sEncontrados(findIndex,1)+sEncontrados(findIndex,3))/2+pos(timeIndex,1),(sEncontrados(findIndex,2)+sEncontrados(findIndex,4))/2+pos(timeIndex,2),num2str(findIndex))
%         
%         
%     end
%     hold off
    
    
    
    if doSave
        frame = getframe(fh);
        writeVideo(writerObj,frame);
    end
end
if doSave
    close(writerObj);
end


%%
name = 'segmentos.avi';
writerObj = VideoWriter(name);
open(writerObj);
for k = 1:size(ring,1)
    fh = myPlot(realesCartRotadasP(k,:,1)+pos(k,1),realesCartRotadasP(k,:,2)+pos(k,2),lab8,74,1,2,2);
    hold on
    plot(pos(k,1),pos(k,2),'rx')
    hold off
    
    subplot(2,2,1);    
    plot(distancias(k,:),'-x');
    ylim([0,2.5]);
    
    subplot(2,2,3)
    plot(angulos(k,:),'-x');
    ylim([-pi,pi]);

    
    frame = getframe(fh);
    writeVideo(writerObj,frame);
    
end
close(writerObj);




%%
[policy,pf] = loadVar('aa');


%% --plot
myPlot(realesCartRotadas(1,:,1)+pos(1,1),realesCartRotadas(1,:,2)+pos(1,2),lab8,74,1,1,1)

%% --video
name = 'recorrido.avi';
writerObj = VideoWriter(name);
open(writerObj);
for k = 1:size(ring,1)
    myPlot(realesCartRotadas(k,:,1)+pos(k,1),realesCartRotadas(k,:,2)+pos(k,2),lab8,74,1,2,1);
    fh = myPlot(realesCartRotadasP(k,:,1)+pos(k,1),realesCartRotadasP(k,:,2)+pos(k,2),lab8,74,1,2,2);
    frame = getframe(fh);
    writeVideo(writerObj,frame);
    
end
close(writerObj);


%% grafica polar
var = realesFiltrados;
iter = 1;
myPolar(coords,var(iter,:),5,1000)

%% video
myfile = realesFiles;
myname = 'reales'
%fh = figure;
%set(gca,'nextplot','replacechildren');
%set(gcf,'Renderer','zbuffer');

name = myfile(end).name;
name = strcat('vid',name,'.avi');
writerObj = VideoWriter(name);
open(writerObj);
for k = 1:size(ring,1)
    myPolar(coords,realesRotadas(k,:),5,1000,1,2,1);
    fh = myPolar(coords,realesRotadasTP(k,:),5,1000,1,2,2);
    frame = getframe(fh);
    writeVideo(writerObj,frame);
    
end
close(writerObj);

%%
num = 0;
%%mess = importdata('messages1421102239.txt');
%n = mess.data;
linCoords = [0:99]*100/99;

difference = [zeros(1,100);ring(2:end,:) - ring(1:end-1,:)];
%

%% tratamiento 1, si diferencia es menor a constate uso valor nuevo sino uso valor viejo

nuevoring = zeros(size(ring));
nuevoring(1,:) = ring(1,:);
nv = abs(difference) < 0.2;
ov = ~ nv;
for i=2:(size(ring,1))
    nuevoring(i,:) =    nv(i,:).*ring(i,:) + ov(i,:).*nuevoring(i-1,:);
end

%% filtro picos
data = reales
datap = filtroPicos(data)
datat = filtroTambaleo(data)
datatp = filtroPicos(datat)

%% video con nuevoring

difference = [zeros(1,100);data(2:end,:)-data(1:(end-1),:)];
figure(50)
name = ringFiles(end).name;
name = strcat('nuevo',name(1:end-4),'.avi');
writerObj = VideoWriter(name);
open(writerObj);
for k = 1:size(ring,1)
    
    subplot(1,3,3);
    plot(difference(k,:),'-x');
    ylim([-0.6,0.6]);
    
    myPolar(coords,data(k,:),5,50,2,3,1);
    myPolar(coords,datap(k,:),5,50,2,3,2);
    myPolar(coords,datat(k,:),5,50,2,3,4);
    fh = myPolar(coords,datatp(k,:),5,50,2,3,5);

    frame = getframe(fh);
    writeVideo(writerObj,frame);
    
end
close(writerObj);






%% guarda video
figure
set(gca,'nextplot','replacechildren');
set(gcf,'Renderer','zbuffer');
name = ringfiles(end).name;
name = strcat(name(1:end-4),'.avi');
writerObj = VideoWriter(name);
open(writerObj);

for k = 1:size(ring,1)
    
    h_fake = polar(coords,r_max*ones(size(coords)));
    hold on
    h = polar(coords,ring(k,:));
    set(h_fake, 'Visible', 'Off');
    hold off
    
    %u.Value = k;
    %M(k) = getframe(gcf);
    frame = getframe
    writeVideo(writerObj,frame);
end
close(writerObj);
%%
%figure
%axes('Position',[-1.5 1.5 -1.5 1.5])
movie(M,1)

%%
paso = 1;

%%
paso = -1;

%%
num = 500
%%


num = num + paso

%num2 = n(num)
num2 = num

%
figure(100)
h_fake = polar(coords,r_max*ones(size(coords)));
hold on
h = polar(coords,ring(num2,:));
set(h_fake, 'Visible', 'Off');
hold off

%%
figure(2)
h = polar(coords,headdir(num2,:));


figure(3)
plot(linCoords,distancia(num2,:))

figure(4)
h = polar(coords,dir(num2,:));


%%
load 'coords';
patronesfiles = dir('patronwall*');
walls = load(patronesfiles(end).name);
num = 0;
linCoords = [0:99]*100/99;
r_max = 1.5;
cant = size(walls,1);
plotnum = ceil(sqrt(cant))

figure
for i=0:(plotnum-1)
    for j=1:plotnum
        id = i*plotnum + j
        if id <= cant
            subplot(plotnum,plotnum,id)
            h_fake = polar(coords,r_max*ones(size(coords)));
            hold on
            h = polar(coords,walls(id,:));
            set(h_fake, 'Visible', 'Off');
            hold off
        end
    end
end

%%
vcfiles = dir('velcambio*');
vc = load(vcfiles(end).name);
figure(1000)
plot(vc(:,1),'-x')

%
figure(1001)
plot(vc(:,2),'-x')







