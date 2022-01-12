clc
clear
close all

%% RIPRODURRE SUONO E CONDIZIONI SPERIMENTALI DELL' ARTICOLO DEI COREANI 
% ( Classification of selective attention to auditory stimuli: Toward vision-free
% brain–computer interfacing - D.-W. Kim et al. / Journal of Neuroscience Methods 197 (2011) 180–185)


%% opzioni per la generazione del suono

opt.fc_audio = 45e3; %frequenza di campionamento dei due segnali audio
opt.freq_base_sx = 2500;
opt.freq_base_dx = 1000;
% opt.freq_base = 2500; %<- attenzione: nell' articolo usano frequenze diverse per canale sx e dx
opt.freq_rip_sx = 37; %37
opt.freq_rip_dx = 43; %43
opt.N = 20; %numero di cicli di sinusoide da includere in ogni beep (cioè dentro T_on dell' onda quadra)
opt.durata_audio = 50;
%% opzioni per la registrazione dell' EEGta

opt.durata_EEG = 60; %durata della registrazione dell' EEG in s
opt.lista_canali = ["Cz","Oz","T7","T8"]; %vettore di stringhe in cui ho lista di canali usati, indicati col loro nome
%NB: la stringa i-esima si riferisce al canale i-esimo nel montaggio
opt.CMS = "F4"; %posizione dove ho messo il riferimento (provvisorio)
opt.DRL = "F3"; %posizione dove ho messo il DRL (provvisorio)
opt.ip = '169.254.192.167';  %ip di riferimento per la comunicazione con enobio (vedi su NIC2 tale valore)
% '192.168.1.14';
%% start

[y_dx,y_sx] = suoni_v_4(opt);

% y_dx = zeros(size(y_sx));
% y_sx = zeros(size(y_dx));

Y2 = audioplayer([y_dx;y_sx],opt.fc_audio);
% Y2 = audioplayer([y_sx],opt.fc_audio);
% Y2 = audioplayer([y_dx],opt.fc_audio);

play(Y2);

% stop_audio = input('Inserisci s per fermare il suono: ','s');
% if stop_audio == 's'
%     stop(Y2);
% end

%%
% data = registra_enobio(opt);
% disp('data ok');

%% Parte 2 - processing EEG 

%%filtraggio passabasso con freq du tagio = 55 Hz.

% opt.filtraggio.fc = 500; %freq di campionamento di enobio
% opt.filtraggio.fn = 500/2; %freq di nyquist associata
% opt.filtraggio.Wp = 50/fn; %banda passante
% opt.filtraggio.Ws = 55/fn; %banda di stop
% opt.filtraggio.Rp = 3; %ripple max ammesso in dB
% opt.filtraggio.Rs = 40; %attenuazione richiesta nei limiti della banda di stop (Ws) in dB


% data_filt = filtra_segnali(data,opt);
% 
% data_fft = calcola_fft(data_filt);
% 
% L = size(data,2);
% 
% P2 = abs(data_fft/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% 
% f = Fs*(0:(L/2))/L;



