function [y_dx,y_sx] = suoni_v_2(opt)

% 1 = dx
% 2 = sx

fs = opt.fc_audio; %freq campionamento
T = opt.durata_audio; %durata brano
t=(0:1/fs:T-1/fs); 

x_sx=sin(2*pi*opt.freq_base_sx*t);
x_dx=sin(2*pi*opt.freq_base_dx*t);

freq1=opt.freq_rip_dx;
freq2=opt.freq_rip_sx;

%la funzione square genera l' onda con periodo 2pi, cioè frequenza = 1/2pi;
%se moltiplico l'asse dei tempi per 2*pi, ottengo una frequenza di 1, poi
%moltiplicando per freq1 ottengo la frequenza = freq1.
% t1=.5*(square(2*pi*freq1*t,2*freq1)+1); %<- alla fine onda quadra è tra [0,1]
% t2=.5*(square(2*pi*freq2*t,2*freq2)+1);


DC_sx = ((1/opt.freq_base_sx)*opt.N*opt.freq_rip_sx)*100;
DC_dx = ((1/opt.freq_base_dx)*opt.N*opt.freq_rip_dx)*100;

t_sx=.5*(square(2*pi*opt.freq_rip_sx*t,DC_sx)+1);
t_dx=.5*(square(2*pi*opt.freq_rip_dx*t,DC_dx)+1); %<- alla fine onda quadra è tra [0,1]


y_sx=x_sx.*t_sx;
y_dx=x_dx.*t_dx; % <- uso l' onda quadra come una maschera per dividere i vari beep


% plot(t,y_dx,'-r')
% hold
% plot(t,y_sx+2.1)
% plot(t,t_dx)
% plot(t,t_sx+2.1)


%NOTA BENE usando il comando square per generare l' onda quadra, posso
%gestire anche il tempo di pausa tra un beep e l' altro: duty cicle = 50%
%significa avere beep e pausa di uguale durata

end