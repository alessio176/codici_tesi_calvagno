function square_wv = my_square_wave(time,DC,T)
% 
%square_wv = my_square_wave(time,DC,T)
% 
%Genera un' onda quadra compresa in [0,1], con duty cycle fisso.
%input:
%time = asse dei tempi discretizzato con frequenza di campionamento 
%costante (vettore riga o colonna);
%DC = duty cicle percentuale (numero compreso tra 0 e 100, scalare);
%T = periodo dell' onda quadra (scalare);
%output:
%square_wv = onda quadra (vettore riga);


%fonte: https://it.mathworks.com/matlabcentral/answers/21057-square-wave?s_tid=srchtitle

% RESOLUTION = 1000;   %whatever is appropriate
% DUTYCYCLE = 0.73;    %e.g. 73% on, 27% off
% NUMBEROFCYCLES = 18;  %as appropriate
% basepulse = ones(1,RESOLUTION);
% squarepulse = basepulse;
% squarepulse(floor(DUTYCYCLE * RESOLUTION) + 1 : end) = 0;
% wavetrain = repmat(squarepulse, 1, NUMBEROFCYCLES);

fc = 1/(time(2)-time(1)); %freq di campionamento con cui è stato creato l' asse dei tempi t (deve essere costante per tutto time!)
resolution = round(T*fc); %numero di campioni di un impulso di onda quadra (e quindi in un periodo dell'onda finale).

base_pulse = ones(1,resolution); %inizializzo impulso base AD UNO
square_pulse = base_pulse;
square_pulse(ceil(DC/100*T*fc)+2:end) = 0; %metto gli 0 dopo il T_on fino alla fine dell' impulso
%EDIT: faccio partire gli 0 da un campione dopo del dovuto (nota il +2
%invece del +1), poichè la sinusoide che andrà ad occupare tale spazio è
%lunga un campione in più per includere pure lo 0 negli N cicli interi.

num_cicli_tot = ceil(length(time)/resolution); %numero di cicli di onda quadra da generare
square_wv = repmat(square_pulse,1,num_cicli_tot); %ecco l' onda quadra vera e propria
%(in sostanza concateno square_pulse un numero di volte parti a cicli_tot);

square_wv(length(time)+1:end) = []; %taglio in modo becero tutto ciò che cade fuori l' asse dei tempi definito

end

