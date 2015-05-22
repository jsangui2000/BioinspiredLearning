%sEncontrados;
%sTrasladados;
%finales;
%conectados;
%seg2
%sids
%finales

%j = iteracion en la que estoy 
%posCalculada   array size(pos)

%sTrasladados
%actividad

%matchAristas
%matchPuntos

%vec

mapa.activos = struct;
mapa.cantActivos = length(matchAristas);
mapa.idMayorActividad = 0;
mapa.mayorActividad = 0;

modificados = [];
cantModificados = 0;
vec= vec

'update';
idAnterior = 0;
matchAristas = matchAristas
matchPuntos = matchPuntos
for i=1:length(matchAristas)
    iAnterior = 1+mod(i-2,length(matchAristas));
    iSiguiente = 1+mod(i,length(matchAristas));
    
    if matchAristas(i) == 0
        'creo';
        idArista = mapa.cantAristas + 1;
        mapa.cantAristas = idArista;
        mapa.aristas(idArista).vdir = vec(i,:);
        mapa.aristas(idArista).perpen = [-vec(i,2),vec(i,1)];
        mapa.aristas(idArista).v1min = realmax;
        mapa.aristas(idArista).v2max = -realmax;
        matchAristas(i) = idArista;
        idAngulo = mapa.conversor(vec(i,:));
        mapa.aristas(idArista).idAngulo = idAngulo;
        
        if matchPuntos(i,1)==0
            idPunto1 = mapa.cantPuntos+1;
            matchPuntos(i,1) = idPunto1;
            mapa.cantPuntos = idPunto1;
            mapa.puntos(idPunto1).certeza = realmax; %mapa.nivel + resol(i,1); %deberia ser infinito
            mapa.puntos(idPunto1).terminal = false;%finales(i,1);
            mapa.puntos(idPunto1).coords = sTrasladados(i,1:2);
            mapa.puntos(idPunto1).asig =0;
            mapa.puntos(idPunto1).aant =0;
            mapa.puntos(idPunto1).fijo =false;
            if conectados(iAnterior)
                matchPuntos(iAnterior,2) = idPunto1;
                
            end
            cantModificados = cantModificados + 1;
            modificados(cantModificados) = idPunto1;
            
        else
            idPunto1 = matchPuntos(i,1);
        end
        
        if matchPuntos(i,2)==0
            idPunto2 = mapa.cantPuntos+1;
            matchPuntos(i,2) = idPunto2;
            mapa.cantPuntos = idPunto2;
            mapa.puntos(idPunto2).certeza = realmax; %mapa.nivel + resol(i,2); %deberia ser infinito
            mapa.puntos(idPunto2).terminal = false;%finales(i,2);
            mapa.puntos(idPunto2).coords = sTrasladados(i,3:4);
            mapa.puntos(idPunto2).asig =0;
            mapa.puntos(idPunto2).aant =0;
            mapa.puntos(idPunto2).fijo =false;
            if conectados(i)
                matchPuntos(iSiguiente,1) =idPunto2;
            end
            cantModificados = cantModificados + 1;
            modificados(cantModificados) = idPunto2;
            
        else
            idPunto2 = matchPuntos(i,2);
        end

        
        
        %vdir = mapa.puntos(idPunto2).coords - mapa.puntos(idPunto1).coords;
        %disp('creo vdir')
        vdir = vec(i,:);
        vdir = vdir / norm(vdir);
        idAngulo =  mapa.conversor(vdir);
        mapa.hashAngulo(idAngulo).aristas = [mapa.hashAngulo(idAngulo).aristas,idArista];
        
        perpen = [-vdir(2),vdir(1)]/norm(vdir);
        mapa.aristas(idArista).perpen = perpen;
        mapa.aristas(idArista).vdir = vdir;
        mapa.aristas(idArista).tita = atan2(vdir(2),vdir(1));
        mapa.aristas(idArista).ids = [idPunto1,idPunto2];
        mapa.aristas(idArista).z = sum(perpen.*sTrasladados(i,1:2)); % mapa.puntos(idPunto2).coords);
        mapa.aristas(idArista).v1min = realmax;%sum(vdir.*sTrasladados(i,1:2));
        mapa.aristas(idArista).v2max = -realmax;%sum(vdir.*sTrasladados(i,3:4));

    else
        idArista = matchAristas(i);
        idAngulo = mapa.conversor(mapa.aristas(idArista).vdir);
        idPunto1 = matchPuntos(i,1);
        idPunto2 = matchPuntos(i,2);
    end
    
    'obtained data';
    x1 = mapa.puntos(idPunto1).coords;
    x2 = mapa.puntos(idPunto2).coords;
    
    
    mapa.activos(i).idArista = idArista;
    mapa.aristas(idArista).pointIds = sids(i,:);
    mapa.activos(i).actividad = actividad(i);
    if mapa.mayorActividad < actividad(i)
        mapa.idMayorActividad = i;
        mapa.mayorActividad = actividad(i);
    end
        

    
    certeza1 = (mapa.nivel + resol(i,1) < mapa.puntos(idPunto1).certeza) && mapa.puntos(idPunto1).terminal;
    'resol:';
    resol(i,1);
    if certeza1
        %disp('certeza1')
        proyVmin = sum(mapa.aristas(idArista).vdir.*sTrasladados(i,1:2));
        if proyVmin< mapa.aristas(idArista).v1min && ~mapa.puntos(idPunto1).fijo %&& mapa.puntos(idPunto1).aant==0
            %mapa.puntos(idPunto1).coords = sTrasladados(i,1:2);
            mapa.puntos(idPunto1).coords = mapa.aristas(idArista).perpen * mapa.aristas(idArista).z +...
                                           mapa.aristas(idArista).vdir   * proyVmin;
            if cantModificados==0 || modificados(cantModificados)~= idPunto1
                cantModificados = cantModificados +1;
                modificados(cantModificados) = idPunto1;
            end
        end
        mapa.puntos(idPunto1).certeza    = mapa.nivel + resol(i,1);
    elseif ~mapa.puntos(idPunto1).terminal
        %disp('acomodo1')
        i;
        mvvec = vec(i,:);
        mvvdir = mapa.aristas(idArista).vdir;
        proyVmin = sum(mapa.aristas(idArista).vdir.*sTrasladados(i,1:2));
        
        %if proyVmin< mapa.aristas(idArista).v1min
        %if mapa.nivel + resol(i,1) <= mapa.puntos(idPunto1).certeza
            if proyVmin< mapa.aristas(idArista).v1min  && ~mapa.puntos(idPunto1).fijo %&& mapa.puntos(idPunto1).aant==0
                %mapa.puntos(idPunto1).coords = sTrasladados(i,1:2);
                mapa.puntos(idPunto1).coords = mapa.aristas(idArista).perpen * mapa.aristas(idArista).z +...
                                               mapa.aristas(idArista).vdir   * proyVmin;
                if cantModificados==0 || modificados(cantModificados)~= idPunto1
                    cantModificados = cantModificados +1;
                    modificados(cantModificados) = idPunto1;
                end
            end
            mapa.puntos(idPunto1).certeza    = mapa.nivel + resol(i,1);
        %end
        certeza1 = true;
    else
        %disp('ninguna1')
    end
    mapa.puntos(idPunto1).terminal = finales(i,1) || mapa.puntos(idPunto1).terminal;

             
    if mapa.puntos(idPunto1).aant == 0
        mapa.puntos(idPunto1).aant =  idAnterior;
    end
    if mapa.puntos(idPunto1).asig == 0
        mapa.puntos(idPunto1).asig = idArista;
    end
    
    %'aca';
    %punto 'derecho'
    
    
    certeza2 = (mapa.nivel+resol(i,2) < mapa.puntos(idPunto2).certeza) && mapa.puntos(idPunto2).terminal;
    if certeza2
        %disp('certeza2')
        proyVmax = sum(mapa.aristas(idArista).vdir.*sTrasladados(i,3:4));
        if proyVmax > mapa.aristas(idArista).v2max  && ~mapa.puntos(idPunto2).fijo %&& mapa.puntos(idPunto2).asig==0
            %mapa.puntos(idPunto2).coords = sTrasladados(i,3:4);
            mapa.puntos(idPunto2).coords = mapa.aristas(idArista).perpen * mapa.aristas(idArista).z +...
                                           mapa.aristas(idArista).vdir   * proyVmax;
            if cantModificados==0 || modificados(cantModificados)~= idPunto2
                cantModificados = cantModificados +1;
                modificados(cantModificados) = idPunto2;
            end
        end
        mapa.puntos(idPunto2).certeza    = mapa.nivel + resol(i,2);
    elseif ~mapa.puntos(idPunto2).terminal
        %disp('acomodo2')
        %i
        mvvec= vec(i,:);
        mvvdir= mapa.aristas(idArista).vdir;
        proyVmax = sum(mapa.aristas(idArista).vdir.*sTrasladados(i,3:4));
        mapa.aristas(idArista).v2max;
        %if proyVmax > mapa.aristas(idArista).v2max
        %if mapa.nivel+resol(i,2) <= mapa.puntos(idPunto2).certeza
            if proyVmax > mapa.aristas(idArista).v2max  && ~mapa.puntos(idPunto2).fijo %&& mapa.puntos(idPunto2).asig==0
                %mapa.puntos(idPunto2).coords = sTrasladados(i,3:4);
                perp(i,:) = mapa.aristas(idArista).perpen;
                para(i,:) = mapa.aristas(idArista).vdir;
                mapa.puntos(idPunto2).coords = mapa.aristas(idArista).perpen * mapa.aristas(idArista).z +...
                                               mapa.aristas(idArista).vdir   * proyVmax;
                if cantModificados==0 || modificados(cantModificados)~= idPunto2
                    cantModificados = cantModificados +1;
                    modificados(cantModificados) = idPunto2;
                end
            end
            mapa.puntos(idPunto2).certeza    = mapa.nivel + resol(i,2);
        %end
        certeza2 = true;
    else
        %disp('ninguna2');
    end
    mapa.puntos(idPunto2).terminal = finales(i,2) || mapa.puntos(idPunto2).terminal;

    
    x3 = mapa.puntos(idPunto1).coords;
    x4 = mapa.puntos(idPunto2).coords;
    
    if mapa.puntos(idPunto2).aant == 0
        mapa.puntos(idPunto2).aant = idArista;
    end
    %mapa.puntos(idPunto2).asig = se setea en la siguiente, todavia no
    %tengo este dato

%     if certeza1 || certeza2
%         disp('p2,p1')
%         mapa.puntos(idPunto2).coords
%         mapa.puntos(idPunto1).coords
%         vdir = mapa.puntos(idPunto2).coords - mapa.puntos(idPunto1).coords;
%         vdir = vdir / norm(vdir)
%         vdir;
%         mapa.conversor(vdir);
%         nuevoIdAngulo =  mapa.conversor(vdir);
%         if nuevoIdAngulo ~= idAngulo
%             mapa.hashAngulo(idAngulo).aristas = mapa.hashAngulo(idAngulo).aristas(mapa.hashAngulo(idAngulo).aristas~=idArista);
%             mapa.hashAngulo(nuevoIdAngulo).aristas = [mapa.hashAngulo(nuevoIdAngulo).aristas,idArista];
%         end
%         perpen = [-vdir(2),vdir(1)]/norm(vdir);
%         mapa.aristas(idArista).perpen = perpen;
%         mapa.aristas(idArista).vdir = vdir;
%         mapa.aristas(idArista).vdir
%         mapa.aristas(idArista).tita = atan2(vdir(2),vdir(1));
%         mapa.aristas(idArista).ids = [idPunto1,idPunto2];
%         mapa.aristas(idArista).z = sum(perpen.*mapa.puntos(idPunto2).coords);
%         mapa.aristas(idArista).v1min = sum(vdir.*mapa.puntos(idPunto1).coords);
%         mapa.aristas(idArista).v2max = sum(vdir.*mapa.puntos(idPunto2).coords);
%     end
    
    
    if conectados(i)
        idAnterior = idArista;
    else
        idAnterior = 0;
    end
    
    x5 = mapa.puntos(idPunto1).coords;
    x6 = mapa.puntos(idPunto2).coords;
    %disp('fin')
    
    
end
for i=1:length(matchAristas)
    if conectados(i)
        mapa.puntos(matchPuntos(i,2)).fijo = true;
    end
end

if conectados(end)
    if mapa.puntos(matchPuntos(end,2)).asig ==0
        mapa.puntos(matchPuntos(end,2)).asig = matchAristas(1);
    end
    if mapa.puntos(matchPuntos(1,1)).aant ==0
        mapa.puntos(matchPuntos(1,1)).aant = matchAristas(end);
    end
end

for i=modificados   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for idArista = [mapa.puntos(i).aant,mapa.puntos(i).asig]
        idArista = idArista
        if idArista~= 0
            aids = mapa.aristas(idArista).ids
            idPunto1 = aids(1)
            idPunto2 = aids(2)

            disp('p2,p1')
            mapa.puntos(idPunto2).coords
            mapa.puntos(idPunto1).coords
            vdir = mapa.puntos(idPunto2).coords - mapa.puntos(idPunto1).coords;
            vdir = vdir / norm(vdir)
            vdir;
            mapa.conversor(vdir);
            nuevoIdAngulo =  mapa.conversor(vdir);
            if nuevoIdAngulo ~= mapa.aristas(idArista).idAngulo
                mapa.hashAngulo(mapa.aristas(idArista).idAngulo).aristas = mapa.hashAngulo(mapa.aristas(idArista).idAngulo).aristas(mapa.hashAngulo(mapa.aristas(idArista).idAngulo).aristas~=idArista);
                mapa.hashAngulo(nuevoIdAngulo).aristas = [mapa.hashAngulo(nuevoIdAngulo).aristas,idArista];
                mapa.aristas(idArista).idAngulo = nuevoIdAngulo;
            end
            perpen = [-vdir(2),vdir(1)]/norm(vdir);
            mapa.aristas(idArista).perpen = perpen;
            mapa.aristas(idArista).vdir = vdir;
            mapa.aristas(idArista).vdir
            mapa.aristas(idArista).tita = atan2(vdir(2),vdir(1));
            mapa.aristas(idArista).ids = [idPunto1,idPunto2];
            mapa.aristas(idArista).z = sum(perpen.*mapa.puntos(idPunto2).coords);
            mapa.aristas(idArista).v1min = sum(vdir.*mapa.puntos(idPunto1).coords);
            mapa.aristas(idArista).v2max = sum(vdir.*mapa.puntos(idPunto2).coords);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    
end
