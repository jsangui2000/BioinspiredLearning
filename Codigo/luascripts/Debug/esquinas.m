function [segEncontrados,finales,vecs,centros,segids,resconexion,resol] = esquinas(puntos,segmentos,conexion,radio,maxangdif)
    vecs = zeros(length(segmentos),2);
    centros = zeros(length(segmentos),2);
    finales = zeros(length(segmentos),2);
    resol = zeros(length(segmentos),2);
    segids = zeros(length(segmentos),2);
    segEncontrados = zeros(length(segmentos),4);
    for i=1:length(segmentos)
        elementos = cell2mat(segmentos(i));
        segids(i,:) = [ elementos(1),elementos(end)];
        [centros(i,:),vecs(i,:)] = medianReglin(puntos,elementos);

    end
    
    for i=1:(length(segmentos)-1)
        %disp('mi i ')
        %disp(num2str(i))
        elementos = cell2mat(segmentos(i));
        angdif = abs(atan(vecs(i,2)/vecs(i,1)) -atan(vecs(i+1,2)/vecs(i+1,1)));
        if angdif > pi/2
            angdif = pi - angdif;
        end
        conexion(i) = conexion(i) && angdif > maxangdif;
        
        if conexion(i)
           inter = intersectar(centros(i,:),vecs(i,2)/vecs(i,1),centros(i+1,:),vecs(i+1,2)/vecs(i+1,1));
           segEncontrados(i,3:4) = inter;
           segEncontrados(i+1,1:2) = inter;
           finales(i,2) = true;
           finales(i+1,1) = true;
           resol(i,2) = 0;
           resol(i+1,1) = 0;
        else
           seg = cell2mat(segmentos(i));
           seg2 = cell2mat(segmentos(i+1));
           
           z1  = sum(centros(i,:).*[-vecs(i,2),vecs(i,1)]);
           v12 = puntos(1,seg(end),1)*vecs(i,1) + puntos(1,seg(end),2)*vecs(i,2);
           
           z2  = sum(centros(i+1,:).*[-vecs(i+1,2),vecs(i+1,1)]);
           v21 = puntos(1,seg2(1),1)*vecs(i+1,1) + puntos(1,seg2(1),2)*vecs(i+1,2);

           segEncontrados(i,3:4)   = z1*[-vecs(i,2),vecs(i,1)] + v12*vecs(i,:);
           segEncontrados(i+1,1:2) = z2*[-vecs(i+1,2),vecs(i+1,1)] + v21*vecs(i+1,:);
           
           %disp(strcat('segmento ',num2str(i)))
           oclusion = (1 + mod(seg2(1)-seg(end),100)) < 4;
           
           if oclusion
               if norm(segEncontrados(i,3:4)) < norm(segEncontrados(i+1,1:2))
                   %disp('esq2')
                   finales(i,2) = esEsquina(segEncontrados(i,3:4),puntos,radio,seg(end));
                   finales(i+1,1) = false;
               else
                   %disp('esq1 sig')
                   finales(i+1,1) = esEsquina(segEncontrados(i+1,1:2),puntos,radio,seg2(1));
                   finales(i,2) = false; 
               end
           else
               %disp('no ocluido')
               %seg = seg
               finales(i,2) = esEsquina(segEncontrados(i,3:4),puntos,radio,seg(end));
               finales(i+1,1) = esEsquina(segEncontrados(i+1,1:2),puntos,radio,seg2(1));
           end
           resol(i,2)   = resolucion(segEncontrados(i,3:4),puntos,seg(end));
           resol(i+1,1) = resolucion(segEncontrados(i+1,1:2),puntos,seg2(1));
        end
    end
    
   
    angdif = abs(atan(vecs(end,2)/vecs(end,1)) -atan(vecs(1,2)/vecs(1,1)));
    if angdif > pi/2
        angdif = pi - angdif;
    end
    
    if conexion(end) && angdif > maxangdif
       inter = intersectar(centros(end,:),vecs(end,2)/vecs(end,1),centros(1,:),vecs(end,2)/vecs(end,1));
       segEncontrados(end,3:4) = inter;
       segEncontrados(1,1:2) = inter;
       finales(end,2) = true;
       finales(1,1) = true;
       resol(end,2) = 0;
       resol(1,1) = 0;
    else
       seg = cell2mat(segmentos(end));
       seg2 = cell2mat(segmentos(1));
       
       z1  = sum(centros(end,:).*[-vecs(end,2),vecs(end,1)]);
       v12 = puntos(1,seg(end),1)*vecs(end,1) + puntos(1,seg(end),2)*vecs(end,2);

       z2  = sum(centros(1,:).*[-vecs(1,2),vecs(1,1)]);
       v21 = puntos(1,seg2(1),1)*vecs(1,1) + puntos(1,seg2(1),2)*vecs(1,2);

       segEncontrados(end,3:4)   = z1*[-vecs(end,2),vecs(end,1)] + v12*vecs(end,:);
       segEncontrados(1,1:2) = z2*[-vecs(1,2),vecs(1,1)] + v21*vecs(1,:);
       
       %disp(strcat('last'))
       oclusion = (1 + mod(seg2(1)-seg(end),100)) < 4;
       
       if oclusion
           if norm(segEncontrados(end,3:4)) < norm(segEncontrados(1,1:2))
               %disp('esq1')
               %'aca'
               finales(end,2) = esEsquina(segEncontrados(end,3:4),puntos,radio,seg(end));
               finales(1,1) = false;
           else
               %'aqui'
               %disp('esq sig')
               finales(end,2) = false; 
               finales(1,1) = esEsquina(segEncontrados(1,1:2),puntos,radio,seg2(1));
           end
       else
           %disp('no ocluido')
           finales(end,2) = esEsquina(segEncontrados(end,3:4),puntos,radio,seg(end));
           finales(1,1) = esEsquina(segEncontrados(1,1:2),puntos,radio,seg2(1));           
       end
       resol(end,2)   = resolucion(segEncontrados(end,3:4),puntos,seg(end));
       resol(1,1) = resolucion(segEncontrados(1,1:2),puntos,seg2(1));

    end
    resconexion = conexion;
    
end