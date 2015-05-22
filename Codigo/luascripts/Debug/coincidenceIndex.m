function index = coincidenceIndex(ids1,ids2)
    if ids1(2) < ids1(1)
        aux = ids1(2);
        ids1(2) = 100 + ids1(1);
        ids1(1) = aux;
    end
    if ids2(2) < ids2(1)
        aux = ids2(2);
        ids2(2) = 100 + ids2(1);
        ids2(1) = aux;
    end
    
    cant1 = 1 + ids1(2) - ids1(1);
    cant2 = 1 + ids2(2) - ids2(1);
    total = 1 + max(ids1(2),ids2(2)) - min(ids1(1),ids2(1));
    index = (cant1 + cant2 - total) / 2;
end
