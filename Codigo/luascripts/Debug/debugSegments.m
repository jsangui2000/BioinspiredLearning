
ti = 560;
segNum = 3;

mips = realesCartP(ti,:,:);
hd = headdir(ti);
ps = pos(ti,:);

s1 = cell2mat(seg2(segNum));
ss1 = s1(1:end);
[mp,mv,mz] = medianReglin(mips,ss1)
per = [-mv(2),mv(1)];
z = sum(mp.*per);


mxs = mips(1,ss1,1);
mys = mips(1,ss1,2);

%xrot = 
%yrot = 

ang1 = atan2(mys(2)-mys(1),mxs(2)-mxs(1))/pi*180
ang2 = atan2(mys(3)-mys(2),mxs(3)-mxs(2))/pi*180

%




figure(101)
clf
hold on
plot(mxs,mys,'-x','MarkerSize',6)

%%

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

