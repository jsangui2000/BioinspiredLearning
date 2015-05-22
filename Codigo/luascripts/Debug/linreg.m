function [P,v] = linreg (puntos,ids)
    x = puntos(1,ids,1);
    y = puntos(1,ids,2);

    P = [x(1),y(1)];
    v = [x(end)-x(1),y(end)-y(1)];
    v = v/norm(v);
end
