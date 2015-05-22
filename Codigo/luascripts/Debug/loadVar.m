function [r1,f] = loadVar(name)
    mystr = strcat(name,'*');
    f = dir(mystr);
    r1 = load(f(end).name);
end