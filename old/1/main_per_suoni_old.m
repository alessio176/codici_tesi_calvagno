%codice principale da cui parte la gestione dei due canali audio cioè
%canale sx e dx delle cuffie da cui partono le due tracce audio che sono la
%sorgente dello stimolo per guidare la BCI.
clc
clear
close all

opt.fc_audio = 8e3; %frequenza di campionamento dei due segnali audio
opt.freq_base_sx = 200;
opt.freq_rip_sx = 21;
opt.freq_base_dx = 200;
opt.freq_rip_dx = 47;
opt.durata_audio = 10; %durata audio in s.

% wavesynt_sx = crea_audio_sx(opt);
% wavesynt_dx = crea_audio_dx(opt);

riproduci_suoni(opt);
