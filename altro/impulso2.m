function z = impulso2(time,freq)

z = sin(2*pi*freq.*time);

index = round(length(z)/2);
z(index:end) = 0;

end
