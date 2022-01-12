function [y_dx,y_sx] = suoni_v_4(opt)
%fa lo stesso della funzione suoni_v_2 ma qui prima genero l' onda quadra e
%dentro ogni fase di on dell' onda creo N cicli di sinusoide. Questo serve
%per fare in modo che ad ogni fase di on non ci sia sfasamento dell' onda,
%ovvero che in quel punto l' onda inizi a metà ciclo, a causa del fatto che
%la frequenza di base non è esattamente multiplo della frequenza dell' onda
%quadra. Insomma, è meglio avere tutti i beep identici, non solo come
%suono, ma anche come segnale di origine.


fs = opt.fc_audio; %freq campionamento
T = opt.durata_audio; %durata brano
t=[0:1/fs:T-1/fs]; 

%% creazione onda quadra

%DC calcolato in modo da avere N cicli interi di sinusoide in T_on;
%DC = T_on/T = T_on * PRF = (N * T_sin) * PRF = (N * 1/f_sin) * PRF;
DC_sx = ((1/opt.freq_base_sx)*opt.N*opt.freq_rip_sx)*100; %<- DC dato come percentuale
DC_dx = ((1/opt.freq_base_dx)*opt.N*opt.freq_rip_dx)*100;

%il periodo dell' onda quadra è uguale all' inverso della PRF (pulse
%repetition frequency, cioè la frequenza con cui si ripetono i beep).
%La funzione square genera l' onda con periodo 2pi, cioè frequenza = 1/2pi;
%se moltiplico l'asse dei tempi per 2*pi, ottengo una frequenza di 1, poi
%moltiplicando per freq1 ottengo la frequenza = freq1.

% quadra_sx=.5*(square(2*pi*opt.freq_rip_sx*t,DC_sx)+1);
% quadra_dx=.5*(square(2*pi*opt.freq_rip_dx*t,DC_dx)+1); %<- alla fine onda quadra è tra [0,1]

%MATLAB NON CREA UN DUTY CYCLE VERAMENTE COSTANTE -> LO PUOI VERIFICARE CON
%dutycyle(quadra_sx). E quindi ricorro ad una funzione creata ad hoc che
%genera l' onda quadra in [0,1] con duty cycle fisso e personalizzabile.

quadra_sx=my_square_wave(t,DC_sx,1/opt.freq_rip_sx);
quadra_dx=my_square_wave(t,DC_dx,1/opt.freq_rip_dx);

%% creazione sinusoidi (dove l' onda quadra è on)

%inizializzazione segnali dei beep
y_sx=zeros(size(quadra_sx));
y_dx=zeros(size(quadra_dx));

%N periodi di onda durano N*T_sin secondi ==> tale intervallo è costituito
%da M campioni con M = (N*T_sin)*fs (fs è la freq di campionamento).
beep_sx = sin(2*pi*opt.freq_base_sx*t(1:round(opt.N*(1/opt.freq_base_sx)*fs)+1));%<- il +1 ci vuole per includere lo 0 nel ciclo finale
beep_dx = sin(2*pi*opt.freq_base_dx*t(1:round(opt.N*(1/opt.freq_base_dx)*fs)+1));


%% riempimento sinusoide SX 
differenza_sx = diff(quadra_sx);
differenza_sx(end+1) = 0;

verso_alto_sx = find(differenza_sx==1);
verso_basso_sx = find(differenza_sx==-1);%<- questi due vettori differiscono esattamente per un elemento come lunghezza;
%questo perchè l' onda parte dal livello alto e quindi ho una transizione
%verso il basso in più rispetto a quelle verso l' alto.

% riempio la parte iniziale dell' onda quadra (dove all' inizio vale 1)
y_sx(1:verso_basso_sx(1)) = beep_sx;
verso_basso_sx = verso_basso_sx(2:end); %tolgo il primo elemento per allinearmi all' altro vettore come elementi

for i = 1:length(verso_alto_sx)

    y_sx(verso_alto_sx(i):verso_basso_sx(i)-1) = beep_sx;

end

%% riempimento sinusoide DX

differenza_dx = diff(quadra_dx);
differenza_dx(end+1) = 0;

verso_alto_dx = find(differenza_dx==1);
verso_basso_dx = find(differenza_dx==-1);%<- questi due vettori differiscono esattamente per un elemento come lunghezza;
%questo perchè l' onda parte dal livello alto e quindi ho una transizione
%verso il basso in più rispetto a quelle verso l' alto.

% riempio la parte iniziale dell' onda quadra (dove all' inizio vale 1)
y_dx(1:verso_basso_dx(1)) = beep_dx;
verso_basso_dx = verso_basso_dx(2:end); %tolgo il primo elemento per allinearmi all' altro vettore come elementi

for i = 1:length(verso_alto_dx)

    y_dx(verso_alto_dx(i):verso_basso_dx(i)-1) = beep_dx;

end


end