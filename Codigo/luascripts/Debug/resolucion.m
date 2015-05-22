function minD = resolucion(punto,ring,id)

    ang = atan2(punto(2),punto(1));
    ang = 51 + floor(50*ang/pi + 0.5);
    if ang > 100
        ang = ang - 100;
    end
    
    if nargin > 4
        if ang-id ~=0
            disp(ang-id)
            disp('error')
        end
        ang = id;
    end
    
    minD = 100000;
    for i=[-1,1]
        id = 1 + mod(ang+i-1,100);
        dx = ring(1,id,1) - punto(1);
        dy = ring(1,id,2) - punto(2);
        dist = sqrt(dx*dx+dy*dy);
        minD = min(dist,minD);
    end    
end