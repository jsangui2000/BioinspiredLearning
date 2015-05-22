function [PO,v,errorMax] = maxMinReglin (puntos,ids)

    if length(ids)==2
        x = puntos(1,ids,1);
        y = puntos(1,ids,2);

        PO = [x(1),y(1)];
        v = [x(end)-x(1),y(end)-y(1)];
        v = v/norm(v);
        errorMax = 0;
    else
        figure(4)
        clf
        hold on
        %OBS se asume todos los vectores caen en un semiplano
        if length(size(puntos)) == 2
            P = puntos(ids,:);
        else
            P(:,1) = transpose(puntos(1,ids,1));
            P(:,2) = transpose(puntos(1,ids,2));
        end
        
        cantIds = length(ids);
        
        
        linvec = P(end-1,:) - P(1,:);
        tita0 = atan2(linvec(2),linvec(1));

        vecMin = P(2,:)-P(1,:);
        iMin = 1;
        jMin = 2;
        titaMin = atan2(vecMin(2),vecMin(1));
        
        vecMax = vecMin;
        iMax = 1;
        jMax = 2;
        titaMax = titaMin;
        
        plot(vecMin(1),vecMin(2),'x','MarkerSize',20)
        plot(0,0,'xg','MarkerSize',20)
        for j=3:cantIds
            for i=1:(j-1)
                dv = P(j,:)-P(i,:);
                plot(dv(1),dv(2),'x','MarkerSize',20)
                viscircles(dv/2,norm(dv)/2)
                
                
                titaV = atan2(dv(2),dv(1));
                
                if j==44
                    %text(dv(1),dv(2),strcat(num2str(i),',',num2str(j)))
                    iMax = iMax
                    jMax = jMax
                    i=i
                    j=j
                    titaMax = titaMax
                    titaV = titaV
                    titaVM = titaV-titaMax
                else
                    titaVM = titaV-titaMax;
                end
                if titaVM > pi
                    titaVM = titaVM - 2*pi;
                elseif titaVM <=-pi
                    titaVM = titaVM + 2*pi;
                end
                if titaVM > 0 || titaVM == 0 && norm(dv) > norm(vecMax)
                    
                    %cambio de vector max
                    vecMax = dv;
                    iMax = i;
                    jMax = j;
                    titaMax = titaV;
                else
                    titaVm = titaV-titaMin;
                    if titaVm > pi
                        titaVm = titaVm - 2*pi;
                    elseif titaVm <=-pi
                        titaVm = titaVm + 2*pi;
                    end
                    
                    if titaVm < 0 || titaVm ==0 && norm(dv) > norm(vecMin)
                        vecMin = dv;
                        iMin = i;
                        jMin = j;
                        titaMin = titaV;
                    end
                end
                    
            end
        end

        
%dados dos circulos que pasen por el 0 y no esten alineados, su inter sera:
%inter = centros(2,:)-centros(1,:);
% inter = 2*(centros(1,2)*centros(2,1)-centros(1,1)*centros(2,2))*[-inter(2),inter(1)]/(norm(inter)^2);
%para el caso nuestro, los centros son -vecMin/2 vecMax/2
        
        disp('final')
        iMin = iMin
        jMin = jMin
        iMax = iMax
        jMax = jMax


        plot([0,vecMax(1)],[0,vecMax(2)],'-xk','MarkerSize',20)
        plot([0,vecMin(1)],[0,vecMin(2)],'-xk','MarkerSize',20)
        viscircles(vecMax/2,norm(vecMax)/2,'EdgeColor','k')
        viscircles(vecMin/2,norm(vecMin)/2,'EdgeColor','k')
        
        vecMin = -vecMin;
        perpen = vecMax - vecMin;
        perpen = (vecMin(2)*vecMax(1)-vecMin(1)*vecMax(2))*[-perpen(2),perpen(1)]/(norm(perpen)^2);
        errorMax = norm(perpen)/2;
        v = [perpen(2),-perpen(1)]/(2*errorMax);
        PO = (P(iMin,:)+P(iMax,:))/2;
        
        hold off


    end
    
end
