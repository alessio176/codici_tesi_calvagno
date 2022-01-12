clc
clear 
close all

% parte di visualizzazione e processing dei segnali acquisiti 

% load('data_2_Alberto_dx_4.mat');
[data,file] = easy2mat;

%%filtraggio passabasso con freq di tagio = 55 Hz.

opt.filtraggio.fc = 500; %freq di campionamento di enobio
opt.filtraggio.fn = 500/2; %freq di nyquist associata
opt.filtraggio.Wp = 50/opt.filtraggio.fn; %banda passante
opt.filtraggio.Ws = 55/opt.filtraggio.fn; %banda di stop
opt.filtraggio.Rp = 3; %ripple max ammesso in dB
opt.filtraggio.Rs = 40; %attenuazione richiesta nei limiti della banda di stop (Ws) in dB

t = [0:size(data,2)-1].*(1/opt.filtraggio.fc); %creo asse dei tempi discreti

% 34280 indice dove parte il segnale utile
% plot(data(1,:));
% start_idx = 33899;
% start_idx = input('start_idx = ');

start_idx = 1;

figure
for i = 1:4 %faccio dei subplot su quattro righe per poter vedere i 4 segnali di interesse
    subplot(4,1,i)
    %plot(t,data(i,:))
    plot(t(start_idx:end),data(i,start_idx:end))
    title(['Ch ',num2str(i),' originale']);
end

%%
data_2 = data(:,start_idx:end);
t_2 = t(start_idx:end);

data_filt = filtra_segnali(data_2,opt);

figure
for i = 1:4 %faccio dei subplot su quattro righe per poter vedere i 4 segnali di interesse
    subplot(4,1,i)
    %plot(t,data(i,:))
    plot(t_2,data_filt(i,:));
    title(['Ch ',num2str(i),' filtrato']);

end

%% calcolo spettro del segnale 

data_fft = calcola_fft(data_filt);

n_fft = size(data_fft,2); %numero di punti su cui ho calcolato la FFT 
                          %(tiene conto dell' eventuale zero padding
                          %effettuato). 
%NOTA BENE: n_fft non coincide con la lunghezza dei segnali se è stato
%fatto zero padding per il calcolo della fft (con la funzione matlab fft).
%Ricorda che n_fft coincide con il numero di punti in cui si discretizza l'
%asse delle frequenze, e quando non coincide con la lunghezza dei segnali
%nel tempo è perchè stai ricorrendo alla risoluzione apparente, invece di
%quella teorica.

P = abs(data_fft); %calcolo modulo della FFT
P = P(:,1:n_fft/2+1); %elimino replica spettrale

fc = opt.filtraggio.fc;

f = [0:fc/n_fft:fc/2]; %asse delle frequenze positive
% f2 = [0:n_fft/2].*fc/n_fft; %<- versione alternativa (è la stessa cosa)

figure
for i = 1:4 %faccio dei subplot su quattro righe per poter vedere i 4 spettri di interesse
    subplot(4,1,i)
    
    plot(f,P(i,:));
    title(['Ch ',num2str(i),' FFT - modulo']);
    grid on
    xline(37,'-','sx');
    xline(43,'-','dx');

end


