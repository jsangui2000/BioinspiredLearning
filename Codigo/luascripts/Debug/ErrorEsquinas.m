mitan = @(t1,t2) (t1+t2)./(1-t1.*t2)
ftest = @(x) x.*mitan(tan(1/180*pi),0.5./x)
ft2 = @(op,x) ((op-0.5)./op).*x
mif = @(d) ft2(ftest(d),d)
figure(99)
mid = 0:0.05:2;
plot(mid,mif(mid))

180/pi*( atan(0.5./(mid - mif(mid)))    - atan(0.5./mid))

%%
figure(99)
clf
mitg = 0:3.6:86.4;
mit = (0:3.6:86.4)*pi/180;
mip = tan(mit)*0.5;
mid = mip(2:end) - mip(1:(end-1));
plot(mitg(1:end-1),mid,'.')
for i=1:(length(mitg)-1)
    text(mitg(i),mid(i),int2str(i))
end
ylim([0.03,0.5])
ylabel('errores')

%distancias
figure(100)

clf
plot(mitg,mip,'.')
for i=1:(length(mitg))
    text(mitg(i),mip(i),int2str(i))
end
ylim([0,2])
ylabel('distancias')


%%
[mm,mp] = max(mip(1:end-1).*(mid <0.05))


