function res = intersectar (v1,m1,v2,m2)
    c = v1(2)-m1*v1(1);
    d = v2(2)-m2*v2(1);
    
    res = [(d-c)/(m1-m2) , (m1*d - m2*c)/(m1-m2)];
    

    
end