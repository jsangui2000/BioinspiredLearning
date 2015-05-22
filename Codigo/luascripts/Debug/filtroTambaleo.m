function filtrado = filtroTambaleo(ring)
    ringt = zeros(size(ring));
    ringt(1,:) = ring(1,:);

    timer = zeros(1,100);
    for i=2:size(ring,1)
        difference = ring(i,:)-ringt(i-1,:);

        m = abs(difference) > 0.1;
        ma = [m(100),m(1:99)];
        maa = [ma(100),ma(1:99)];
        md = [m(2:100),m(1)];
        mdd = [md(2:100),md(1)];
        replace = (m + m.*ma + m.*ma.*maa + m.*md + m.*md.*mdd) > 2;

        timer = timer + (timer==0).*replace * 5;
        timer = max(0,timer-1);

        replace = timer > 0;

        ringt(i,:) = ring(i,:).*(~replace) + ringt(i-1,:).*replace;
    end
    filtrado = ringt;
end