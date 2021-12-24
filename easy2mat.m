function data = easy2mat(path,file)
% data = easy2mat(path,file)
% 
% Funzione che legge un file .easy fornito dal NIC come matrice
% utilizzabile in matlab direttamente.
% input:
% path = percorso (relativo o assoluto) di dove si trova il file .easy da
% aprire.
% file = nome del file .easy da aprire.
% output:
% data = la matrice di segnali, NxM con N = num di canali di enobio (8) e M =
% numero di campioni prelevati.


% [file,path] = uigetfile("C:\Users\Alessio\Documents\NIC\*.easy");
% [file,path] = uigetfile(string(pwd)+"\acquisizioni\*.easy");


A = readlines(fullfile(path,file),'EmptyLineRule','skip','WhitespaceRule','trim');

for i=1:size(A,1)

    tmp(i,:) = sscanf(A(i),'%d',8);

end

data = tmp';

end