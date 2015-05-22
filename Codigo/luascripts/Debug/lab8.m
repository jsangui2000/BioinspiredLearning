function lab = lab8()
    lado = 0.5;
    mitad = lado/2;
    largo = 2;
    apotema = mitad / tan(22.5*pi/180);
    lab = zeros(25,2);
    lab(1:4,:) = [ apotema,-mitad; apotema + largo,-mitad;  apotema+largo,mitad ;apotema,mitad];
    for i=1:7
        for j=2:4
            lab(3*i+j,:) = [cos(45*i/180*pi)*lab(j,1)-sin(45*i/180*pi)*lab(j,2),...
                        sin(45*i/180*pi)*lab(j,1)+cos(45*i/180*pi)*lab(j,2)];
        end
    end
    load 'origen.txt'
    lab(:,1) = lab(:,1) - origen(1);
    lab(:,2) = lab(:,2) - origen(2);
end
