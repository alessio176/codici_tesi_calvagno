function data_fft =  calcola_fft(data)
% input:
% data = segnali di cui calcolare la fft come matrice NxM con N = numero di
% canali (8) e M = numero di campioni temporali ottenuti (i segnali sono le
% righe della matrice).
% output:
% data_fft = matrice che contiene la fft degli N segnali. La fft è fornita
% come double sided, cioè è presente la replica spettrale per frequenze
% negative.


L = size(data,2); %numero di campioni di tutto il segnale

n = 2^nextpow2(L); %OPZIONALE: posso fare zero padding per avere un numero
                  %di campioni che sia una potenza di 2 esatta e quindi usare la FFT invece che DFT.

% for i = 1:size(data,1)

    data_fft = fft(data,n,2); 


% end