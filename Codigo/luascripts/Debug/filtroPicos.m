function filtrado = filtroPicos(ring)
    ringa = [ring(:,100),ring(:,1:99)];
    ringd = [ring(:,2:100),ring(:,1)];
    interpolated = (ringa+ringd)/2;
    replace = abs(ringd-ringa) < 0.1;
    filtrado = replace.*interpolated + ring .* (~replace);
end