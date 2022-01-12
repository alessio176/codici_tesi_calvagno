%codice principale per fare il processing dei segnali acquisiti finora,
%cioè filtraggio passabanda (rimuovere drift e componenti alle frequenze
%oltre quelle di interesse, quindi dopo i 50/55 Hz) e calcolo dello spettro
%(PSD tradizionale) dei segnali dopo filtraggio.
clc
clear
close all

% parte di visualizzazione e processing dei segnali acquisiti

% load('data_2_Alberto_dx_4.mat');
%% new

opt.durata_EEG = 60; %durata della registrazione dell' EEG in s
opt.lista_canali = ["Cz","Oz","T7","T8"]; %vettore di stringhe in cui ho lista di canali usati, indicati col loro nome
%NB: la stringa i-esima si riferisce al canale i-esimo nel montaggio

%filtraggio passabasso con freq di tagio = 55 Hz.

opt.filtraggio.fc = 500; %freq di campionamento di enobio
opt.filtraggio.fn = 500/2; %freq di nyquist associata
opt.filtraggio.Wp = [2 50]/opt.filtraggio.fn; %banda passante
opt.filtraggio.Ws = [1 55]/opt.filtraggio.fn; %banda di stop
opt.filtraggio.Rp = 3; %ripple max ammesso in dB
opt.filtraggio.Rs = 40; %attenuazione richiesta nei limiti della banda di stop (Ws) in dB

d = dir(string(pwd)+"\acquisizioni\segnali da nic\*.easy"); %DA MODIFICARE!!!

mainFolder = pwd; %salvo il percorso della cartella principale (servirà dopo)

for i=1:size(d,1)

    tmp = split(d(i).name,".");
    nome = tmp{1}; %serve per salvare le figure

    %ottengo matrice dei segnali da easy2mat
    data = easy2mat(d(i).folder,d(i).name);
    %NB: di data mi interessano solo i primi 4 segnali (quindi le prime 4
    %righe della matrice).

    t = [0:size(data,2)-1].*(1/opt.filtraggio.fc); %creo asse dei tempi discreti
    
    %visualizzazione segnali originali
    figure
    for k = 1:4 %faccio dei subplot su quattro righe per poter vedere i 4 segnali di interesse
        subplot(4,1,k)
        plot(t,data(k,:))
        grid on
        title("Ch" +  opt.lista_canali(k) + " originale");
    end

    %se la cartella di destinazione dei risultati non dovesse esistere, la creo
    if ~exist("acquisizioni\originali\","dir")
        mkdir .\acquisizioni originali
    end

    %salvo il plot dei segnali originali
    cd(".\acquisizioni\originali\");
    saveas(gcf,nome + " orignale");
    cd(mainFolder);
    close(gcf);
 

    %filtraggio
    data_filt = filtra_segnali(data,opt);

    figure
    for k = 1:4 %faccio dei subplot su quattro righe per poter vedere i 4 segnali di interesse
        subplot(4,1,k)
        plot(t,data_filt(k,:))
        grid on
        title("Ch" +  opt.lista_canali(k) + " filtrato");
    end
   

    %se la cartella di destinazione dei risultati non dovesse esistere, la creo
    if ~exist("acquisizioni\filtrati\","dir")
        mkdir .\acquisizioni filtrati
    end

    %salvo il plot dei segnali filtrati
    cd(".\acquisizioni\filtrati\");
    saveas(gcf,nome + " filtrato");
    cd(mainFolder);
    close(gcf)

    %calcolo PSD (spettro)
    %calcolo la PSD in modo tradizionale tramite correlogramma.
    %Uso la versione polarizzata dello stimatore dell' autocorrelazione, in
    %quanto in questo modo ottengo una stima consistente (asintoticamente)
    %e inoltre quando calcolo la FFT di tale funzione inserisco
    %implicitamente una finestra triangolare, che in questo caso mi è utile
    %per via dei lobi laterali più piccoli rispetto alla finestra
    %rettangolare.
    
    %calcolo del numero di ritardi dell' autocorrelazione
    %----------------------------------------------------------------------
    %Il numero di ritardi da usare dipende dalla risoluzione spettrale
    %richiesta: ricorda che df*T=1 (df è risoluzione spettrale). In questo
    %caso è bene avere una df pari a 0.2 Hz, in modo da poter isolare bene
    %i picchi eventuali a 37 e 43 Hz (frequenze di stimolazione). 
    %
    %Se df = 0.2 Hz -> T = 1/0.2 s = 5 s che corrispondono ad un numero 
    %di ritardi pari a: N = T*fc = 5 s * 500 Hz = 2500; 
    %considerando che la funzione di correlazione ha lunghezza = 2*maxlag+1
    %ottengo: N = 2*maxlag+1 -> maxlag = (N-1)/2 = 1249.5; impongo una
    %lunghezza dispari, in modo da avere maxlag intero, quindi se N =2501,
    %ho: maxlag = (2501-1)/2 = 1250, a cui corrisponde una risoluzione
    %spettrale teorica di df = fc/N = 0.1999 che va bene ugualmente.
    %----------------------------------------------------------------------
    
    opt.psd.maxlag = 1250; %vedi commento sopra
    opt.psd.tipo_corr = 'biased';
    %il numero di punti su cui calcolare la FFT è la potenza di 2 appena
    % maggiore della lunghezza totale della funzione di autocorrelazione,
    % in modo da usare l' algoritmo FFT invece che DFT: questo mi porta ad 
    % avere una risoluzione spettrale APPARENTE migliore di quella teorica.
    opt.psd.NFFT = 2^nextpow2(2*opt.psd.maxlag+1);

    [data_psd,f] = calcola_psd(data_filt,opt);

    P = abs(data_psd); %calcolo modulo della FFT

    figure
    for k = 1:4 %faccio dei subplot su quattro righe per poter vedere i 4 spettri di interesse
        subplot(4,1,k)

        plot(f,P(k,:));
        title("Ch" +  opt.lista_canali(k) + " PSD - Modulo");
        grid on
        xline(37,'-','sx');
        xline(43,'-','dx');
    end
        %se la cartella di destinazione dei risultati non dovesse esistere, la creo
    if ~exist("acquisizioni\filtrati\","dir")
        mkdir .\acquisizioni filtrati
    end

    %salvo il plot dei segnali filtrati
    cd(".\acquisizioni\psd\");
    saveas(gcf,nome + " psd");
    cd(mainFolder);
    close(gcf)

end



