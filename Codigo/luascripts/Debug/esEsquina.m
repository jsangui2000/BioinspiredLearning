function esquina = esEsquina(punto,ring,radio,id)

    ang = atan2(punto(2),punto(1));
    ang = 51 + floor(50*ang/pi + 0.5);
    if ang > 100
        ang = ang - 100;
    end
    
    if nargin > 3
%         if ang-id ~=0
%             disp('error')
%             disp(ang-id)
%         end
        ang = id;
        punto(1) = ring(1,ang,1);
        punto(2) = ring(1,ang,2);
    end
    
    total = 0;
    punto = punto;
    for i=[-1,1]
        id = 1 + mod(ang+i-1,100);
        dx = ring(1,id,1) - punto(1);
        dy = ring(1,id,2) - punto(2);
        dist = sqrt(dx*dx+dy*dy);
        if dist < radio
           total = total + 1;
        end
    end
    
    %diLoES = total > 0
    esquina = total > 0;
        
    
end