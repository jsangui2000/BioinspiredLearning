function res = toCartessian(data)
    [filas,columnas] = size(data);
    step = 2*pi / columnas;
    angulos = ones(filas,1)*(-pi + (0:columnas-1)*step);
    res = zeros(filas,columnas,2);
    res(:,:,1) = data.*cos(angulos);
    res(:,:,2) = data.*sin(angulos);

end