function [procesados,nuevasConexiones] = procesarSegmentos2(segmentos,conectados,puntos,d,ang)
    procesados = {};
    ultimoArray = cell2mat(segmentos(1));
    conexionesIntermedias = [conectados(1)];
    cant = 0;
    for i=2:length(segmentos)
        elementos = cell2mat(segmentos(i));
        delta = puntos(1,elementos(end),:) - puntos(1,elementos(1),:);
        giro = atan2(delta(1,1,2),delta(1,1,1));
        
        delta = puntos(1,ultimoArray(end),:) - puntos(1,ultimoArray(1),:);
        mActual = atan2(delta(1,1,2),delta(1,1,1));

        %la pregunta es, lo uno al anterior o empiezo uno nuevo

        delta = puntos(1,elementos(1),:) - puntos(1,ultimoArray(end),:);
        delta = delta.*delta;
        dist = sqrt(delta(1) + delta(2));
        dif = abs(mActual-giro);
        if dif > pi
            dif = 2*pi-dif;
        end
        if (dist < d) && (dif < ang)
            ultimoArray = [ultimoArray,elementos];
            c1 = length(ultimoArray);
            c2 = length(elementos);

        else
            cant = cant + 1;
            procesados(cant) = {ultimoArray};
            ultimoArray = elementos;
        end
        conexionesIntermedias(cant+1) = conectados(i);


    end
    cant = cant + 1;
    procesados(cant) = {ultimoArray};
    nuevasConexiones = conexionesIntermedias;%(1:length(prcesados));
    
%     if ~isempty(procesados)
%         elementos = cell2mat(procesados(1));
%         delta = puntos(1,elementos(1),:) - puntos(1,ultimoArray(end),:);
%         delta = delta.*delta;
%         dist = sqrt(delta(1) + delta(2));
%         
%         delta = puntos(1,elementos(end),:) - puntos(1,elementos(1),:);
%         giro = atan2(delta(1,1,2),delta(1,1,1));
%         
%         delta = puntos(1,ultimoArray(end),:) - puntos(1,ultimoArray(1),:);
%         mActual = atan2(delta(1,1,2),delta(1,1,1));
% 
%         dif = abs(mActual-giro);
%         if dif > pi
%             dif = 2*pi-dif;
%         end
%         if (dist < d) && (dif < ang)
%             ultimoArray = [ultimoArray,elementos];
%             procesados(1) = {ultimoArray};
%         else
%             cant = cant + 1;
%             procesados(cant) = {ultimoArray};
%         end
%     end
    


    
%     
%     nuevasConexiones = [true];
%     procesados2 = {};
%     cant = 0;
%     valorInicial = true;
%     for i=1:length(procesados)
%        datos = cell2mat(procesados(i));
%        if length(datos) > 3
%            cant = cant +1;
%            procesados2(cant) = {datos};
%            nuevasConexiones(cant) = conexionesIntermedias(i);
%        else
%            if  cant>0
%                nuevasConexiones(cant) = nuevasConexiones(cant) && conexionesIntermedias(i);
%            else
%                valorInicial = valorInicial && conexionesIntermedias(i);
%            end
%            
%        end
%       
%     end
%     nuevasConexiones(end) = nuevasConexiones(end) && valorInicial;
%     
%     procesados = procesados2;
end