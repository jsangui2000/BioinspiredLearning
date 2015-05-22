subplot(2,2,3);

myPlot(mapa.pos(1),mapa.pos(2),lab8,1,2,2,3);
hold on
for i=1:mapa.cantAristas
    mapa.aristas(i);
    p1 = mapa.puntos(mapa.aristas(i).ids(1)).coords;
    p2 = mapa.puntos(mapa.aristas(i).ids(2)).coords;
    plot([p1(1),p2(1)],[p1(2),p2(2)],'-x','MarkerSize',8)
    text((p1(1)+p2(1))/2,(p1(2)+p2(2))/2,num2str(i))
end

for i=1:mapa.cantActivos
    idArista = mapa.activos(i).idArista;
    p1 = mapa.puntos(mapa.aristas(idArista).ids(1)).coords;
    p2 = mapa.puntos(mapa.aristas(idArista).ids(2)).coords;
    %plot([p1(1),p2(1)],[p1(2),p2(2)],'-xr','MarkerSize',8)
end


xlim([-1.5,5])
ylim([-1.5,5]);

hold off


%%
% figure(48)
% clf
% hold on
% vectores = [2,2;-0.5,2];
% vectores(2,:) = vectores(2,:)/2;
% %vectores(3,:) = vectores(1,:) - vectores(2,:);
% centros = vectores/2;
% inter = centros(2,:)-centros(1,:);
% inter = 2*(centros(1,2)*centros(2,1)-centros(1,1)*centros(2,2))*[-inter(2),inter(1)]/(norm(inter)^2);
% 
% normas = sqrt(sum(centros.*centros,2));
% viscircles(centros,normas);
% viscircles(-centros,normas);
% for i = 1:size(centros,1)
%      plot([0,vectores(i,1)],[0,vectores(i,2)],'-x')
% end
% plot(inter(1),inter(2),'x','MarkerSize',8)
% hold off

%%
% mp = [0,0;0.1,0.1;2.9,-0.1;3,0]
% figure(49)
% clf
% hold on
% plot(mp(:,1),mp(:,2),'x','MarkerSize',8);
% [mP0,mv,mErrorMax] = maxMinReglin(mp,1:4)
% xmin = min(mp)
% xmax = max(mp)
% 
% per = [-mv(2),mv(1)];
% z = sum(per.*mP0);
% 
% linea = [xmin(1),  (z-per(1)*xmin(1))/per(2)  ; xmax(1), (z-per(1)*xmax(1))/per(2)   ];
% 
% plot(linea(:,1),linea(:,2),'-xr')
% xlim([xmin(1)-0.1,xmax(1)+0.1]);
% ylim([xmin(2)-0.1,xmax(2)+0.1]);
% hold off
% 
% z = sum(per.*mP0)
% for i=1:size(mp,1)
%    zs = sum(mp(i,:).*per) 
%     
% end










