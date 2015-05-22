function [r1,r2] = myPlot(x,y,lab,fignum,filas,columnas,num,circulos)
	if nargin >= 4
        r1 = figure(fignum);
        if nargin > 4
            r2 = subplot(filas,columnas,num);
        end
    else
        r1 = figure;
    end
    
    
    plot(lab(:,1),lab(:,2),'-');
    hold on
    if nargin > 7
        viscircles(lab,circulos*ones(size(lab,1),1))
    end
    plot(x,y,'gx-','Markersize',8);
    hold off
    
    xlim([-1.5,5])
    ylim([-1.5,5])
    
end

