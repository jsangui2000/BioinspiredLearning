load 'coords';
%
ringfiles = dir('laser*');
%
ring = load(ringfiles(end).name);
%distancia = load('distancia1421102239.txt' );
%headdir = load('headdir1421102239.txt');
%dir = load('dir1421102239.txt');
%
num = 0;
%%mess = importdata('messages1421102239.txt');
%n = mess.data;

linCoords = [0:99]*100/99;

r_max = 1.5;
%

ringnum=179

difference = [zeros(1,100);ring(2:end,:) - ring(1:end-1,:)];
%
%%
ringnum = ringnum+1
figure
%plot(difference(:,ringnum),'-x')

%% tratamiento 1, si diferencia es menor a constate uso valor nuevo sino uso valor viejo

nuevoring = zeros(size(ring));
nuevoring(1,:) = ring(1,:);
nv = abs(difference) < 0.2;
ov = ~ nv;
for i=2:(size(ring,1))
    nuevoring(i,:) =    nv(i,:).*ring(i,:) + ov(i,:).*nuevoring(i-1,:);
end

%% filtro picos
ringa = [ring(:,100),ring(:,1:99)];
ringd = [ring(:,2:100),ring(:,1)];
interpolated = (ringa+ringd)/2;
replace = abs(ringd-ringa) < 0.1;

ringp = replace.*interpolated + ring .* (~replace);
differencep = [zeros(1,100);ringp(2:end,:) - ringp(1:end-1,:)];


% filtro tambaleo
ringt = zeros(size(ring));
ringt(1,:) = ring(1,:);

accdiff = zeros(1,100);
timer = zeros(1,100);
for i=2:size(ring,1)
    difference = ring(i,:)-ringt(i-1,:);
    
    m = abs(difference) > 0.1;
    ma = [m(100),m(1:99)];
    maa = [ma(100),ma(1:99)];
    md = [m(2:100),m(1)];
    mdd = [md(2:100),md(1)];
    replace = (m + m.*ma + m.*ma.*maa + m.*md + m.*md.*mdd) > 2;
    
    timer = timer + (timer==0).*replace * 4;
    timer = max(0,timer-1);
  
    accumulate = accdiff ~= 0;
    accumulate = accumulate | ~accumulate.*replace;
    
    accdiff = accdiff +  difference.*accumulate;
    replace = abs(accdiff) > 0.1;
    accdiff = replace.*accdiff;
    
    replace = timer > 0;
    
    ringt(i,:) = ring(i,:).*(~replace) + ringt(i-1,:).*replace;
end

% ambos filtros
% ringtp = zeros(size(ring));
% ringtp(1,:) = ringp(1,:);
% 
% for i=2:size(ring,1)
%     difference = ringp(i,:)-ringp(i-1,:);
%     
%     m = abs(difference) > 0.1;
%     ma = [m(100),m(1:99)];
%     maa = [ma(100),ma(1:99)];
%     md = [m(2:100),m(1)];
%     mdd = [md(2:100),md(1)];
%     replace = (m + m.*ma + m.*ma.*maa + m.*md + m.*md.*mdd) > 2;
%     ringtp(i,:) = ringp(i,:).*(~replace) + ringtp(i-1,:).*replace;
% end

ringa = [ringt(:,100),ringt(:,1:99)];
ringd = [ringt(:,2:100),ringt(:,1)];
interpolated = (ringa+ringd)/2;
replace = abs(ringd-ringa) < 0.1;

ringtp = replace.*interpolated + ringt .* (~replace);

%% video con nuevoring

difference = [zeros(1,100);ring(2:end,:)-ring(1:(end-1),:)]
fh = figure;
set(gca,'nextplot','replacechildren');
set(gcf,'Renderer','zbuffer');
name = ringfiles(end).name;
name = strcat('nuevo',name(1:end-4),'.avi');
writerObj = VideoWriter(name);
open(writerObj);
for k = 1:size(ring,1)
    
    subplot(1,3,3)
    plot(difference(k,:),'-x')
    ylim([-0.6,0.6])
    
    subplot(2,3,1)
    h_fake = polar(coords,r_max*ones(size(coords)));
    hold on
    h = polar(coords,ring(k,:));
    set(h_fake, 'Visible', 'Off');
    hold off
    
    subplot(2,3,2)
    h_fake = polar(coords,r_max*ones(size(coords)));
    hold on
    h = polar(coords,ringp(k,:));
    set(h_fake, 'Visible', 'Off');
    hold off
    
    subplot(2,3,4)
    h_fake = polar(coords,r_max*ones(size(coords)));
    hold on
    h = polar(coords,ringt(k,:));
    set(h_fake, 'Visible', 'Off');
    hold off
    
    subplot(2,3,5)
    h_fake = polar(coords,r_max*ones(size(coords)));
    hold on
    h = polar(coords,ringtp(k,:));
    set(h_fake, 'Visible', 'Off');
    hold off
    
    
    
    
    
    %u.Value = k;
    %M(k) = getframe(gcf);
    frame = getframe(fh);
    writeVideo(writerObj,frame);
    
end
close(writerObj);






%% guarda video
figure
set(gca,'nextplot','replacechildren');
set(gcf,'Renderer','zbuffer');
name = ringfiles(end).name;
name = strcat(name(1:end-4),'.avi');
writerObj = VideoWriter(name);
open(writerObj);

for k = 1:size(ring,1)
    
    h_fake = polar(coords,r_max*ones(size(coords)));
    hold on
    h = polar(coords,ring(k,:));
    set(h_fake, 'Visible', 'Off');
    hold off
    
    %u.Value = k;
    %M(k) = getframe(gcf);
    frame = getframe
    writeVideo(writerObj,frame);
end
close(writerObj);
%%
%figure
%axes('Position',[-1.5 1.5 -1.5 1.5])
movie(M,1)

%%
paso = 1;

%%
paso = -1;

%%
num = 500
%%


num = num + paso

%num2 = n(num)
num2 = num

%
figure(100)
h_fake = polar(coords,r_max*ones(size(coords)));
hold on
h = polar(coords,ring(num2,:));
set(h_fake, 'Visible', 'Off');
hold off

%%
figure(2)
h = polar(coords,headdir(num2,:));


figure(3)
plot(linCoords,distancia(num2,:))

figure(4)
h = polar(coords,dir(num2,:));


%%
load 'coords';
patronesfiles = dir('patronwall*');
walls = load(patronesfiles(end).name);
num = 0;
linCoords = [0:99]*100/99;
r_max = 1.5;
cant = size(walls,1);
plotnum = ceil(sqrt(cant))

figure
for i=0:(plotnum-1)
    for j=1:plotnum
        id = i*plotnum + j
        if id <= cant
            subplot(plotnum,plotnum,id)
            h_fake = polar(coords,r_max*ones(size(coords)));
            hold on
            h = polar(coords,walls(id,:));
            set(h_fake, 'Visible', 'Off');
            hold off
        end
    end
end

%%
vcfiles = dir('velcambio*');
vc = load(vcfiles(end).name);
figure(1000)
plot(vc(:,1),'-x')

%
figure(1001)
plot(vc(:,2),'-x')







