function conexos = conexos(distancias,medida)
    resFila = {[1]};
    cant = 1;
    for i=1:99
       if distancias(i) < medida
           resFila(cant) = {[cell2mat(resFila(cant)),i+1]};
       else
           cant = cant+1;
           resFila(cant) = {[i+1]};
       end
    end
    if cant > 1 && distancias(100) < medida
        resFila(1) = {[cell2mat(resFila(cant)),cell2mat(resFila(1))]};
        resFila(cant) = [];
    end
    
    conexos = resFila;
end