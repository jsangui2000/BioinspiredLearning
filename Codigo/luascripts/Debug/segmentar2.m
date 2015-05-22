function [segmentos,conectados] = segmentar2(puntos,distancias,medida,angulos,ang,angLejos)
    
    ultimoID = 1;
    while(distancias(ultimoID)<medida)
        ultimoID = ultimoID+1;
    end

    i = 1 + mod(ultimoID,100);

    resFila = {};
    ids = [i];
    cant = 0;
    cantIds = 1;
    nuevo = true;
    conectados = [];
    pendant = false;

    while i ~=ultimoID
       j = 1 + mod(i,100);
       if distancias(i) < medida
           if nuevo
               ids = [ids,j];
               nuevoAngulo = angulos(i);
               primero = angulos(i);
               nuevo = false;
               cantIds = 2;
               dx = puntos(1,j,1) - puntos(1,i,1);
               dy = puntos(1,j,2) - puntos(1,i,2);
               dv = [dy,-dx]/norm([dx,dy]);
               dz = puntos(1,j,1)*dv(1) + puntos(1,j,2)*dv(2);
           else
               difAnguloN = abs(nuevoAngulo-angulos(i));
               difAnguloP = abs(primero - angulos(i));
               if difAnguloN > pi
                   difAnguloN = 2*pi - difAnguloN;
               end
               if difAnguloP > pi
                   difAnguloP = 2*pi - difAnguloP;
               end
               z = puntos(1,j,1)*dv(1) + puntos(1,j,2)*dv(2);
               if abs(z-dz) > angLejos
                   [centro,vec] = linreg(puntos,ids);
                   dv = [-vec(2),vec(1)];
                   dz = dv(1)*centro(1)+dv(2)*centro(2);
                   z = puntos(1,j,1)*dv(1) + puntos(1,j,2)*dv(2);
               end
               
               
               if abs(z-dz) < angLejos && difAnguloP < ang %&& difAnguloN < ang % 
                   ids = [ids,j];
                   cantIds = cantIds + 1;
                   
                   nuevoAngulo = atan2(puntos(1,j,2)-puntos(1,ids(1),2),...
                                       puntos(1,j,1)-puntos(1,ids(1),1));
               else
                   %'termine segmento junto'
                   if cantIds > 3
                       %'agrego'
                       if pendant
                           %'habia pendiente'
                           conectados(cant) = true;
                       end
                       cant = cant+1;
                       resFila(cant) = {ids};
                       pendant = true;
                       %'queda pendiente'
                       
                       if cant == 1
                           primerID = ids(1);
                       end
                       ids = [j];
                       nuevo = true;
                   elseif cantIds>2
                       i = ids(2);
                       j = ids(3);
                       ids = [i,j];
                   else
                       ids = [j];
                       nuevo = true;
                   end
                   
                   
                   dx = puntos(1,j,1) - puntos(1,i,1);
                   dy = puntos(1,j,2) - puntos(1,i,2);
                   dv = [dy,-dx]/norm([dx,dy]);
                   dz = puntos(1,j,1)*dv(1) + puntos(1,j,2)*dv(2);
                   
                   nuevoAngulo = angulos(i);
                   primero = nuevoAngulo;
                   cantIds = 2;
               end
           end
       else
           %'termine segmento separado'
           if cantIds > 3
               %'agrego'
               if pendant 
                   %'habia pendiente'
                   conectados(cant) = true;
               end
               cant = cant+1;
               resFila(cant) = {ids};
               conectados(cant) = false;
               if cant == 1
                   primerID = ids(1);
               end
           elseif pendant
               %'no agregue pero habia pendiente'
               conectados(cant) = false;
           end
           pendant = false;
           ids = [j];
           nuevo = true;
           cantIds = 1;
           %'no quedan pendientes'
       end
       i = j;
    end
    
    
    if length(ids) > 3
        if pendant 
           conectados(cant) = true;
        end
        cant = cant + 1;
        resFila(cant) = {ids};
        
        %como agregue tengo que ver si el ultimo segmento esta conectado al
        %primero
        conectados(cant) = false;
    elseif pendant
        conectados(cant) = false;
    end
    
    segmentos = resFila;
end