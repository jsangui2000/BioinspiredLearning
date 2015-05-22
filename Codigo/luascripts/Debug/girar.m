function rotadas = girar(data,angulos)
    rotadas = [];
    for i=1:size(data,1)
        if angulos(i) < 0 
            sentido = -1;
        else
            sentido = 1;
        end
        giro = sentido*floor(abs(angulos(i))/pi*50 + 0.5);
        if giro < 0
            giro = giro + 100;
        end
        giro = 100 - giro;
        linea =[ data(i,101-giro:end),data(i,1:end-giro)];
        rotadas = [rotadas;linea];
    end

end