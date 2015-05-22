function polar =toPolar(data)
    r = sqrt(data(:,1).*data(:,1)+data(:,2).*data(:,2));
    ang = atan2(data(:,2),data(:,1));
    polar = [r,ang];
end