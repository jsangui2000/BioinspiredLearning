function [PO,v,errorMax] = medianReglin (puntos,ids)

    simpleRegLinCount =5 ;
    if length(ids)<=simpleRegLinCount
        x = puntos(1,ids,1);
        y = puntos(1,ids,2);

        PO = [x(1),y(1)];
        v = [x(2)-x(1),y(2)-y(1)];
        v = v/norm(v);
        perpen = [-v(2),v(1)];
        errorMax = 0;
        z0 = sum(PO.*perpen);
        for i=3:length(ids)
            errorMax = max(errorMax,abs(x(i)*perpen(1)  +y(i)*perpen(2) -z0 ));         
        end
    else
        %OBS se asume todos los vectores caen en un semiplano
        if length(size(puntos)) == 2
            P = puntos(ids,:);
        else
            P(:,1) = transpose(puntos(1,ids,1));
            P(:,2) = transpose(puntos(1,ids,2));
        end
        
        %disp('aqui')
        linvec = P(end-1,:) - P(1,:);
        tita0 = atan2(linvec(2),linvec(1));
        
        cantIds = length(ids);
        vecdifs = [];
        titas = [];
        for j=2:cantIds
            for i=1:(j-1)
                vecdif = P(j,:)-P(i,:);
                titaV = atan2(vecdif(2),vecdif(1))-tita0;
                if titaV > pi
                    titaV = titaV - 2*pi;
                elseif titaV <=-pi
                    titaV = titaV + 2*pi;
                end
                    
                titas = [titas,titaV];
            end
        end
        
        dir = median(titas) + tita0;
        v = [cos(dir),sin(dir)];
        perpen = [-v(2),v(1)];
        
        zetas = zeros(1,length(ids));
        for i =1:length(ids)
            zetas(i) = sum(P(i,:).*perpen);
        end
        mzeta = median(zetas);
        
        errorMax = max(abs(zetas-mzeta));
        PO = mzeta*perpen;
        


    end
    
end
