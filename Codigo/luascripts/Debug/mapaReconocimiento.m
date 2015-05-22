%sEncontrados;
%finales;
%conectados;
%seg2
%sids
%vec
%centros
%sids

%j = iteracion en la que estoy 
%posCalculada   array size(pos)


actividad = sids(:,2) - sids(:,1);
actividad(actividad>0) = actividad(actividad>0) + 1;
actividad(actividad<0) = 101 + actividad(actividad<0) ;
actividad = actividad;

matchAristas = zeros(1,size(sids,1));
matchPuntos = zeros(length(matchAristas),2);

sTrasladados = sEncontrados;
vecOriginal = vec;



%aca se debería setear la posicion y la dir de la cabeza (por ahora solo
%la pos)

%si el mapa no esta vacío:
if mapa.cantPuntos~=0 
    %hago reconocimiento de las cosas encontradas
    
    %mapa.activos(i).idArista
    %mapa.activos(i).pointIds
    %mapa.cantActivos
    
    %obtengo arista importante y la traslado -(mapa.pos + estimacion):
    importante = mapa.aristas(mapa.activos(mapa.idMayorActividad).idArista);
    %disp('antes')
    angI = importante.tita - mapa.headdir;
    %disp('desp')
    
    if angI <= -pi
        angI = angI + 2*pi;
    elseif angI > pi
        angI = angI - 2*pi;
    end
    
    %matcheo primer arista para obtener delta angulo
    matchActivity = -100;
    idMatch = -1;
    deltaHeaddir = 0;
    maxAngDif = 15*pi/180;
    
    for i =1:length(matchAristas)
        
        %reviso angulo
        %disp('ang')
        ang = atan2(vec(i,2),vec(i,1));
        angdif = abs(ang - angI);
        if angdif > pi
            angdif = 2*pi - angdif;
        end
        %disp('tad')
        %disp(num2str(angdif))
        'aca';
        if angdif < maxAngDif
            'entre';
            %aca si necesito separar mas deberia rotar el segmento
            %importante
            %luego calcular zIgirado,proyIP1,proyIP2,proyCP1,proyCP2
            %observar z y proys no cambian por rotaciones
            %por lo tanto calcular z y proys con sus respectivas vdir y
            %perpen

            ci = coincidenceIndex(sids(i,:),importante.pointIds);
            if ci < -50
                ci = ci + 50;
            end
            if ci > matchActivity
                matchActivity = ci;
                deltaHeaddir = angI - ang;
                idMatch = i;
                matchingAng = ang;
 
%             proy1 = sum(sTrasladados(i,1:2).*maxArista.vdir);
%             proy2 = sum(sTrasladados(i,3:4).*maxArista.vdir);
%             if (proy1 > maxArista.v1min - maxDist &&...
%                proy1 < maxArista.v2max + maxDist ||...
%                proy2 > maxArista.v1min - maxDist &&...
%                proy2 < maxArista.v2max + maxDist) &&...
%                abs(sum(sTrasladados(i,3:4).*vec(i,:))-maxArista.z) < maxdist
%                 
%                 if actividad(i) > matchActivity
%                     matchActivity = actividad(i);
%                     deltaAng = maxArista.tita - ang;
%                 end
            end
        end
    end
    
    
    idMatch;
    if idMatch ==-1
        disp('error no match')
        error('error no match ang')
    else
        disp(strcat('dirmatchON',...
                   num2str(mapa.activos(mapa.idMayorActividad).idArista),...
                   '/',...
                   num2str(idMatch)))
    end
    tablaMatch(timeIndex).id = idMatch;
    
    
    deltaHeaddir;
    mapa.headdir =  importante.tita - matchingAng;%   mapa.headdir + deltaHeaddir;
    if mapa.headdir <= -pi
        mapa.headdir = mapa.headdir + 2*pi;
    elseif mapa.headdir > pi
        mapa.headdir = mapa.headdir - 2*pi;
    end
    %giro y luego traslado vectores:
    
    giroX = [cos(mapa.headdir),-sin(mapa.headdir)];
    giroY = [-giroX(2),giroX(1)];
    
    %roto encontrados
    sRotados = sEncontrados;
    sRotados(:,[1,3]) = sEncontrados(:,[1,3])*giroX(1) +sEncontrados(:,[2,4])*giroX(2);
    sRotados(:,[2,4]) = sEncontrados(:,[1,3])*giroY(1) +sEncontrados(:,[2,4])*giroY(2);
    sRotados;
    
    cmRotados = centros;
    cmRotados(:,1) = centros(:,1)*giroX(1) +centros(:,2)*giroX(2);
    cmRotados(:,2) = centros(:,1)*giroY(1) +centros(:,2)*giroY(2);
    cmRotados;
    
    %matcheo todas las aristas considerando el angulo obtenido
    toleranciaAngulo = 15*pi/180;
    toleranciaProyV = 0.45;
    toleranciaProyZ = 0.2 + mapa.nivel;
    for i=1:length(matchAristas)
        
        %matchLevel = 0;
        
        vec(i,:);
        vec(i,:) = [sum(giroX.*vec(i,:)),sum(giroY.*vec(i,:))];
        
        proyI = sum(vec(i,:).*(mapa.pos+sRotados(i,1:2)));
        proyD = sum(vec(i,:).*(mapa.pos+sRotados(i,3:4)));
        
        angId = mapa.conversor(vec(i,:));
        idChecks = mapa.hashAngulo(angId).aristas;
        for iang=1:15
            idAnt=1+mod(angId-1-iang,360);
            idSig=1+mod(angId-1+iang,360);
            idChecks = [idChecks,mapa.hashAngulo(idAnt).aristas...
                                ,mapa.hashAngulo(idSig).aristas];
        end
        idChecks;
        
                
        ang = atan2(vec(i,2),vec(i,1));
              
        for j = idChecks
            checkArista = mapa.aristas(j);
            angdif = abs(ang - checkArista.tita);
            if angdif > pi
                angdif = 2*pi - angdif;
            end
            
            proyZ1  = sum(checkArista.perpen.*(mapa.pos+sRotados(i,1:2)));
            proyZ2  = sum(checkArista.perpen.*(mapa.pos+sRotados(i,3:4)));
            
            
            checkArista.z;
            checkArista.v1min;
            checkArista.v2max;
            angdif;
            if angdif < toleranciaAngulo                     
                if (proyI > checkArista.v1min - toleranciaProyV &&...
                    proyI < checkArista.v2max + toleranciaProyV ||...
                    proyD > checkArista.v1min - toleranciaProyV &&...
                    proyD < checkArista.v2max + toleranciaProyV) &&...
                    (abs(proyZ1-checkArista.z) < toleranciaProyZ ||...
                    abs(proyZ2-checkArista.z) < toleranciaProyZ)
                
                    %disp(strcat('match ',num2str(i), ' ', num2str(j)));

                    matchAristas(i) = j;
                    matchPuntos(i,:) = mapa.aristas(j).ids;
                    tablaMatch(timeIndex).matches(i) = j;
                    break;
                end
            end     
        end
    end
    
    matchAristas
    %paso por aristas, intersecto con siguiente si en el mapa dos aristas
    %que vi como separadas estan juntas, calculo vector posicion respecto a
    %cada punto y considero
    mejorCerteza = realmax; %(mejor cuanto mas cerca del cero)

    sumaAngulo = 0;
    sumaActividad = 0;
    idMejorPunto = 0;
    idMejorArista =0;
    
    minActividad = 3;
    certezaMapa = 0;
    mejorCerteza = realmax;
    'conec';
    conectados
    sRotados = sRotados
    for i=1:(length(matchAristas)-1)
        if matchAristas(i)~=0
            %primero me fijo si debe intersectar arista con siguiente
            %basado en mapa:
            
            if ~conectados(i) && matchAristas(i+1)~=0 &&...
               matchAristas(i+1)==...
               mapa.puntos(mapa.aristas(matchAristas(i)).ids(2)).asig
           
               %calculo interseccion:
               sRotados(i+1,1:2) = intersectar(cmRotados(i,:),vec(i,2)/vec(i,1),cmRotados(i+1,:),vec(i+1,2)/vec(i+1,1));
               sRotados(i,3:4) = sRotados(i+1,1:2);
               finales(i,2) = true;
               finales(i+1,1) = true;
               conectados(i) = true;
               resol(i,2) = 0;
               resol(i+1,1) = 0;    
            elseif conectados(i)
                if matchAristas(i+1) ==0
                    matchPuntos(i+1,1) = matchPuntos(i,2);
                elseif mapa.puntos(mapa.aristas(matchAristas(i)).ids(2)).asig ==0 
                    'pinter'
                    matchAristas(i)
                    matchAristas(i+1)
                    pinter= intersectar(mapa.puntos(matchPuntos(i,2)).coords    ,mapa.aristas(matchAristas(i)).vdir(2)/mapa.aristas(matchAristas(i)).vdir(1) ,...
                                        mapa.puntos(matchPuntos(i+1,1)).coords  ,mapa.aristas(matchAristas(i+1)).vdir(2)/mapa.aristas(matchAristas(i+1)).vdir(1));
                    certezaP1 = mapa.puntos(matchPuntos(i,2)).certeza;
                    certezaP2 = mapa.puntos(matchPuntos(i+1,1)).certeza;
                    if certezaP1 < certezaP2
                        %es mejor P1
                        'uno'
                        pinter
                        mapa.puntos(matchPuntos(i,2)).asig = matchAristas(i+1);
                        mapa.puntos(matchPuntos(i,2)).coords = pinter;
                        mapa.aristas(matchAristas(i+1)).ids(1) = matchPuntos(i,2);
                        matchPuntos(i+1,1) = matchPuntos(i,2);
                    else
                        %es mejor P2
                        'dos'
                        mapa.puntos(matchPuntos(i+1,1)).aant = matchAristas(i);
                        mapa.puntos(matchPuntos(i+1,1)).coords = pinter;
                        mapa.aristas(matchAristas(i)).ids(2) = matchPuntos(i+1,1);
                        matchPuntos(i,2) = matchPuntos(i+1,1);
                    end
                        
                end
                
            end
            
            aristaMapa = mapa.aristas(matchAristas(i));
            anguloA =  aristaMapa.tita - atan2(vec(i,2),vec(i,1));%   mapa.headdir + deltaHeaddir;
            if anguloA <= -pi
                anguloA = anguloA + 2*pi;
            elseif anguloA > pi
                anguloA = anguloA - 2*pi;
            end
            anguloA = anguloA;
            
            sumaActividad = sumaActividad + actividad(i)+minActividad;
            sumaAngulo = sumaAngulo + (actividad(i)+minActividad)*anguloA;
            
            
        elseif matchAristas(i+1)~=0 && conectados(i)
            matchPuntos(i,2) = matchPuntos(i+1,1);
        end
    end

    
    if matchAristas(end)~=0
    %primero me fijo si debe intersectar arista con siguiente
    %basado en mapa:
        %matchPuntos(end,:) = mapa.aristas(matchAristas(end)).ids;
        if ~conectados(end) && matchAristas(1)~= 0 &&...
           matchAristas(1)==...
           mapa.puntos(mapa.aristas(matchAristas(end)).ids(2)).asig

           %calculo interseccion:
           sRotados(1,1:2) = intersectar(cmRotados(end,:),vec(end,2)/vec(end,1),cmRotados(1,:),vec(1,2)/vec(1,1));
           sRotados(end,3:4) = sRotados(1,1:2);
           finales(end,2) = true;
           finales(1,1) = true;
           conectados(end) = true;
           resol(end,2) = 0;
           resol(1,1) = 0;
        elseif conectados(end)
            if matchAristas(1) ==0
                matchPuntos(1,1) = matchPuntos(end,2);
            elseif mapa.puntos(mapa.aristas(matchAristas(end)).ids(2)).asig ==0 
                pinter= intersectar(mapa.puntos(matchPuntos(end,2)).coords,mapa.aristas(matchAristas(end)).vdir(2)/mapa.aristas(matchAristas(end)).vdir(1) ,...
                                    mapa.puntos(matchPuntos(1,1)).coords  ,mapa.aristas(matchAristas(1)).vdir(2)/mapa.aristas(matchAristas(1)).vdir(1));
                certezaP1 = mapa.puntos(matchPuntos(end,2)).certeza;
                certezaP2 = mapa.puntos(matchPuntos(1,1)).certeza;
                if certezaP1 < certezaP2
                    %es mejor P1
                    mapa.puntos(matchPuntos(end,2)).asig = matchAristas(1);
                    mapa.puntos(matchPuntos(end,2)).coords = pinter;
                    mapa.aristas(matchAristas(1)).ids(1) = matchPuntos(end,2);
                    matchPuntos(1,1) = matchPuntos(end,2);
                else
                    %es mejor P2
                    mapa.puntos(matchPuntos(1,1)).aant = matchAristas(end);
                    mapa.puntos(matchPuntos(1,1)).coords = pinter;
                    mapa.aristas(matchAristas(end)).ids(2) = matchPuntos(1,1);
                    matchPuntos(end,2) = matchPuntos(1,1);
                end

            end

        end

        aristaMapa = mapa.aristas(matchAristas(end));
        anguloA =  aristaMapa.tita - atan2(vec(end,2),vec(end,1));%   mapa.headdir + deltaHeaddir;
        if anguloA <= -pi
            anguloA = anguloA + 2*pi;
        elseif anguloA > pi
            anguloA = anguloA - 2*pi;
        end
        anguloA = anguloA;

        sumaActividad = sumaActividad + actividad(end) + minActividad;
        sumaAngulo = sumaAngulo + (actividad(end)+minActividad)*anguloA;
        

    elseif matchAristas(1)~=0 && conectados(end)
            matchPuntos(end,2) = matchPuntos(1,1);        
    end
    
    
        
    conectados;
    sRotados = sRotados
    
    deltahd = sumaAngulo/sumaActividad;
    deltahd = 0;
    
    mapa.headdir = mapa.headdir + deltahd; 
    if mapa.headdir <= -pi
        mapa.headdir = mapa.headdir + 2*pi;
    elseif mapa.headdir >pi
        mapa.headdir = mapa.headdir - 2*pi;
    end
    
    giroX = [cos(deltahd),-sin(deltahd)];
    giroY = [-giroX(2),giroX(1)];
    
    %roto encontrados
    sRotados2 = sRotados;
    sRotados(:,[1,3]) = sRotados2(:,[1,3])*giroX(1) +sRotados2(:,[2,4])*giroX(2);
    sRotados(:,[2,4]) = sRotados2(:,[1,3])*giroY(1) +sRotados2(:,[2,4])*giroY(2);
    sRotados;
    
    cmRotados2 = cmRotados;
    cmRotados(:,1) = cmRotados2(:,1)*giroX(1) +cmRotados2(:,2)*giroX(2);
    cmRotados(:,2) = cmRotados2(:,1)*giroY(1) +cmRotados2(:,2)*giroY(2);
    cmRotados;
    
    for i=1:length(matchAristas)
        vec(i,:) = [sum(giroX.*vec(i,:)),sum(giroY.*vec(i,:))];
    end
    
    sRotados = sRotados
    
    
    deltaVFalsos = [];
    matchAristas = matchAristas
    for ida1=1:(length(matchAristas)-1)
        if matchAristas(ida1)~=0
            for ida2= 2:length(matchAristas)
                sum(vec(ida1,:).*vec(ida2,:))
                matchAristas(ida2)~=0
                vec(ida1,:).*vec(ida2,:)
                abs(sum(vec(ida1,:).*vec(ida2,:)))
                cos(20/180*pi)
                
                if matchAristas(ida2)~=0 && (abs(sum(vec(ida1,:).*vec(ida2,:))) < cos(20/180*pi))
                    iObs  = intersectar(sRotados(ida1,1:2),vec(ida1,2)/vec(ida1,1),sRotados(ida2,1:2),vec(ida2,2)/vec(ida2,1));
                    aristai = mapa.aristas(matchAristas(ida1));
                    aristaj = mapa.aristas(matchAristas(ida2));
                    puntoi = mapa.puntos(aristai.ids(1)).coords;
                    puntoj = mapa.puntos(aristaj.ids(1)).coords;
                    iReal = intersectar(puntoi,aristai.vdir(2)/aristai.vdir(1),puntoj,aristaj.vdir(2)/aristaj.vdir(1));
                    deltaVFalsos = [deltaVFalsos;iReal-iObs];
                end
            end
        end
    end
    
    
    
    certezaMinima = 1000; %0.07
    sumaInvCerteza = 0;
    sumaPosiciones = [0,0];
    deltaVes = [];
    for i=1:(length(matchAristas)-1)

        if matchAristas(i)~=0
            aristaMapa = mapa.aristas(matchAristas(i));


            puntoMapa = mapa.puntos(aristaMapa.ids(2));
            puntoCerteza = puntoMapa.certeza + resol(i,2);
            if puntoMapa.terminal && finales(i,2)
                
                
                
                posRealPunto = mapa.puntos(matchPuntos(i,2)).coords;
                posObservada = sRotados(i,3:4);
                pesoPunto = 1/(puntoCerteza+certezaMinima);
                sumaInvCerteza = sumaInvCerteza + pesoPunto;
                sumaPosiciones = sumaPosiciones + pesoPunto*(posRealPunto - posObservada);
                certezaMapa = certezaMapa + pesoPunto*puntoCerteza;
                
                disp(strcat('punto ',num2str(i),'/2'));
                posRealPunto = posRealPunto
                posObservada = posObservada
                deltaV = posRealPunto - posObservada
                deltaVes = [deltaVes;deltaV];
                
    
                if puntoCerteza < mejorCerteza
                %mejorCerteza = puntoCerteza;
                    idMejorPunto = aristaMapa.ids(2);
                    idMejorArista = i;
                    izqOder = [3,4];
                end
            end
            
            if ~conectados(i) && matchAristas(i+1)~=0
                aristaMapa = mapa.aristas(matchAristas(i+1));
                puntoMapa = mapa.puntos(aristaMapa.ids(1));
                puntoCerteza = puntoMapa.certeza + resol(i+1,1);
                if puntoMapa.terminal && finales(i+1,1) %&& puntoCerteza < mejorCerteza
                    posRealPunto = mapa.puntos(matchPuntos(i+1,1)).coords;
                    posObservada = sRotados(i+1,1:2);
                    pesoPunto = 1/(puntoCerteza+certezaMinima);
                    sumaInvCerteza = sumaInvCerteza + pesoPunto;
                    sumaPosiciones = sumaPosiciones + pesoPunto*(posRealPunto - posObservada);
                    certezaMapa = certezaMapa + pesoPunto*puntoCerteza;
                    
                    
                    disp(strcat('punto ',num2str(i+1),'/1'));
                    posRealPunto = posRealPunto
                    posObservada = posObservada
                    deltaV = posRealPunto - posObservada
                    deltaVes = [deltaVes;deltaV];
                    
                    if puntoCerteza < mejorCerteza
                        mejorCerteza = puntoCerteza;
                        idMejorPunto = aristaMapa.ids(1);
                        idMejorArista = i+1;
                        izqOder = [1,2];
                    end
                end 
            end
        end

    end
    
    if matchAristas(end)~=0
        aristaMapa = mapa.aristas(matchAristas(end));
      
        puntoMapa = mapa.puntos(aristaMapa.ids(2));
        puntoCerteza = puntoMapa.certeza + resol(end,2);
        if puntoMapa.terminal && finales(end,2) %&& puntoCerteza < mejorCerteza
            posRealPunto = mapa.puntos(matchPuntos(end,2)).coords;
            posObservada = sRotados(end,3:4);
            pesoPunto = 1/(puntoCerteza+certezaMinima);
            sumaInvCerteza = sumaInvCerteza + pesoPunto;
            sumaPosiciones = sumaPosiciones + pesoPunto*(posRealPunto - posObservada);
            certezaMapa = certezaMapa + pesoPunto*puntoCerteza;
            
            
            disp(strcat('punto ',num2str(length(matchAristas)),'/2'));
            posRealPunto = posRealPunto
            posObservada = posObservada
            deltaV = posRealPunto - posObservada
            deltaVes = [deltaVes;deltaV];
            
            if puntoCerteza < mejorCerteza
                mejorCerteza = puntoCerteza;
                idMejorPunto = aristaMapa.ids(2);
                idMejorArista = length(matchAristas);
                izqOder = [3,4];
            end
        end
        
        if ~conectados(end) && matchAristas(1)~=0
            aristaMapa = mapa.aristas(matchAristas(1));
            puntoMapa = mapa.puntos(aristaMapa.ids(1));
            puntoCerteza = puntoMapa.certeza + resol(1,1);
            if puntoMapa.terminal && finales(1,1) %&& puntoCerteza < mejorCerteza
                posRealPunto = mapa.puntos(matchPuntos(1,1)).coords;
                posObservada = sRotados(1,1:2);
                pesoPunto = 1/(puntoCerteza+certezaMinima);
                sumaInvCerteza = sumaInvCerteza + pesoPunto;
                sumaPosiciones = sumaPosiciones + pesoPunto*(posRealPunto - posObservada);
                certezaMapa = certezaMapa + pesoPunto*puntoCerteza;
                
                
                disp(strcat('punto ',num2str(1),'/1'));
                posRealPunto = posRealPunto
                posObservada = posObservada
                deltaV = posRealPunto - posObservada
                deltaVes = [deltaVes;deltaV];
                
                if puntoCerteza < mejorCerteza
                    mejorCerteza = puntoCerteza;
                    idMejorPunto = aristaMapa.ids(1);
                    idMejorArista = 1;
                    izqOder = [1,2];
                end
            end 
        end
    end
        
    
     
    mapa.nivel = certezaMapa /sumaInvCerteza;
       
    %mapa.pos = posRealPunto - posObservada;
    sumaInvCerteza = sumaInvCerteza;
    sumaPosiciones = sumaPosiciones;
    mapa.pos = sumaPosiciones / sumaInvCerteza;
    
    mapa.pos = median(deltaVes);
    if length(deltaVFalsos)~=0
        deltaVes = deltaVes
        mapa.pos = median(deltaVFalsos);
    end
    mapa.pos;
    
%     idMejorPunto;
%     idMejorArista;
%     izqOder;
%     posRealPunto = mapa.puntos(idMejorPunto).coords;
%     posObservada = sRotados(idMejorArista,izqOder);
%     mapa.pos = posRealPunto - posObservada;
%     mapa.nivel = mejorCerteza;
    
    sTrasladados(:,[1,3]) = sRotados(:,[1,3]) + mapa.pos(1);
    sTrasladados(:,[2,4]) = sRotados(:,[2,4]) + mapa.pos(2);
    conectados = conectados
    sRotados = sRotados
    sTrasladados = sTrasladados
    
    
      
    'aca';
    mapaUpdate;
else
    mapa.headdir = mapa.headdir
    mapa.pos = mapa.pos
    giroX = [cos(mapa.headdir),-sin(mapa.headdir)];
    giroY = [-giroX(2),giroX(1)];
    
    %roto encontrados
    sRotados = sEncontrados;
    sRotados(:,[1,3]) = sEncontrados(:,[1,3])*giroX(1) +sEncontrados(:,[2,4])*giroX(2);
    sRotados(:,[2,4]) = sEncontrados(:,[1,3])*giroY(1) +sEncontrados(:,[2,4])*giroY(2);
    sTrasladados = sRotados
    
    vec = sTrasladados(:,3:4) - sTrasladados(:,1:2);
    nvec = sqrt(sum(vec.*vec,2));
    nvec = [nvec,nvec];
    vec = vec./nvec;
    
    %en el caso que esta vacío, no reconozco nada seteo
    %seteo pos
    
    
    
    mapaUpdate;
end



