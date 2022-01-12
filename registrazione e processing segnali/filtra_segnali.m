function data_filt = filtra_segnali(data,opt)
% data_filt = filtra_segnali(data,opt)
% 
% Funzione per filtrare i segnali, con un filtro IIR ellittico.
% input:
% data = segnali da filtrare, forniti come matrice NxM con N = numero di
% canali e M = numero di campioni temporali ottenuti (i segnali sono le
% righe della matrice).
% opt = struttura delle opzioni.
% output:
% data_filt = segnali filtrati, forniti come matrice con stesse dimensioni
% di data.

%inserire controllo sulla possibile simmetria di b (cioè filtro con fase
%lineare).

% [n,Wp] = cheb2ord(opt.filtraggio.Wp,opt.filtraggio.Ws,1,opt.filtraggio.Rs);
% [b,a] = cheby2(n,opt.filtraggio.Rs,opt.filtraggio.Ws);

[n,Wp] = ellipord(opt.filtraggio.Wp,opt.filtraggio.Ws,opt.filtraggio.Rp,opt.filtraggio.Rs);
[b,a] = ellip(n,opt.filtraggio.Rp,opt.filtraggio.Rs,opt.filtraggio.Wp);

%visualizzo filtro ottenuto
% figure
% freqz(b,a,512,opt.filtraggio.fc);

for i = 1:size(data,1)

    %fitraggio a doppia passata per annullare distorsione di fase.
    %NB: questo raddoppia l' attenuazione in banda di stop.
    data_filt(i,:) = filtfilt(b,a,double(data(i,:)));

end

end