ti = 9; %time index
mips = realesCartP(ti,:,:);  %puntos del tiempo
hd = headdir(ti);
s1 = cell2mat(seg1(2)) 
ss1 = s1(1:end);
[mp,mv,mz] = medianReglin(mips,ss1)
per = [-mv(2),mv(1)];
np = norm(per)
z = sum(mp.*per)


figure(101)
clf
mxs = mips(1,ss1,1);
mys = mips(1,ss1,2);

for i=1:length(mxs)
    mz = mxs(i)*per(1)+mys(i)*per(2) -z
end

hold on
plot(mxs,mys,'-x','MarkerSize',6)

minmxs = min(mxs);
maxmxs = max(mxs);
linea = [minmxs, (z-per(1)*minmxs)/per(2)   ;  maxmxs, (z-per(1)*maxmxs)/per(2)   ];


plot(linea(:,1),linea(:,2),'-xr')




hold off



















%%

mx = mips(1,s1,1);
my = mips(1,s1,2);
mdx = mx(2:end) - mx(1:end-1);
mdy = my(2:end) - my(1:end-1);
mds = sqrt(mdx.*mdx + mdy.*mdy);

mdx = mdx(mds~=0)

mdy = mdy(mds~=0);
mds = mds(mds~=0)

mvx = mean(mdx./mds);
mvy = mean(mdy./mds);

%titas = atan2(dy,dx);
%mtita = median(titas);

V = [mean(mx),mean(my)]
m = mvy/mvx

figure(88)
plot(mx,my)
xlim([-3,3])
ylim([-3,3])

figure(89)
plot(mx,my)

