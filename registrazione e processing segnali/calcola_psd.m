function [data_psd,f] = calcola_psd(data,opt)
% [data_psd,f] = calcola_psd(data,opt)
% 
% Funzione per il calcolo della psd dei segnali, tramite correlogramma.
% input:
% data = segnali di cui calcolare la PSD come matrice NxM con N = numero di
% canali e M = numero di campioni temporali ottenuti (i segnali sono le
% righe della matrice).
% opt = struttura delle opzioni.
% output:
% data_psd = matrice che contiene la psd degli N segnali, calcolata tramite
% correlogramma. La psd è fornita senza la replica spettrale nelle
% frequenze negative.

fc = opt.filtraggio.fc; %freq di campionamento del segnale

for i = 1:size(data,1)
    x = data(i,:)-mean(data(i,:)); %rimuovere sempre valor medio per stima PSD tradizionale
    acs = xcorr(x,opt.psd.maxlag,opt.psd.tipo_corr);

    XX = fft(acs,opt.psd.NFFT);
    XX = XX(1:length(XX)/2+1);    %elimina la replica spettrale, cioè asse negativo di f

    data_psd(i,:) = XX;
end

% f = [0:length(XX)-1]/length(XX)*(fc/2); %creazione dell'asse delle frequenze
f = [0:fc/opt.psd.NFFT:fc/2]; %asse delle frequenze positive
%f = [0:opt.psd.NFFT/2].*fc/opt.psd.NFFT; %<- versione alternativa (è la stessa cosa)

end