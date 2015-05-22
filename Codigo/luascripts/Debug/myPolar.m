function [r1,r2] = myPolar(coords,data,mymax,fignum,filas,columnas,num)
    if nargin >= 4
        r1 = figure(fignum);
        if nargin > 4
            r2 = subplot(filas,columnas,num);
        end
    else
        r1 = figure;
    end
    
    
    h_fake = polar(coords,mymax*ones(size(coords)));
    hold on
    polar(coords,data);
    set(h_fake, 'Visible', 'Off');
    hold off
end