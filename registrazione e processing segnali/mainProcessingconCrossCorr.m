clc
clear
close all

%% OPZIONI

opt.durata_EEG = 60; %durata della registrazione dell' EEG in s
opt.lista_canali = ["Cz","Oz","T7","T8"]; %vettore di stringhe in cui ho lista di canali usati, indicati col loro nome
%filtraggio passabasso con freq di tagio = 55 Hz.

opt.filtraggio.fc = 500; %freq di campionamento di enobio
opt.filtraggio.fn = 500/2; %freq di nyquist associata
opt.filtraggio.Wp = [2 50]/opt.filtraggio.fn; %banda passante
opt.filtraggio.Ws = [1 55]/opt.filtraggio.fn; %banda di stop
opt.filtraggio.Rp = 3; %ripple max ammesso in dB
opt.filtraggio.Rs = 40; %attenuazione richiesta nei limiti della banda di stop (Ws) in dB
%opt nuove
opt.findsinamp.fc = 500;
opt.fc = 500;

%% start

%lettura files con segnali
d = dir("..\acquisizioni\segnali da nic\*.easy");

mainFolder = pwd; %salvo il percorso della cartella principale (servirà dopo)

 for i=1:size(d,1)
% i=1;

    tmp = split(d(i).name,".");
    nome = tmp{1}; %serve per salvare le figure

    %ottengo matrice dei segnali da easy2mat
    data = easy2mat(d(i).folder,d(i).name);

    %new
    data = data./1e3; %divido per 1000 in modo da avere come unità di misura i microvolt, invece dei nanovolt.
    %NB: di data mi interessano solo i primi 4 segnali (quindi le prime 4
    %righe della matrice).

    t = [0:size(data,2)-1].*(1/opt.filtraggio.fc); %creo asse dei tempi discreti

     %filtraggio
    data_filt = filtra_segnali(data,opt);

    %estrazione ampiezza sinusoide con metodo della cross correlazione
    %v. funzione FindSinAmpFunction.m
    freq = [37,43]; % 37 Hz = canale sx, 43 Hz = canale dx.
    colori = ["r","m","b","k"]; %colori per i vari plot sovrapposti
    figure

    for k=1:4 %mi servono solo i primi 4 canali di data
        sig = data(k,:); %prendo un segnale da data (una riga della matrice)
        contatore=1;
        for f = 1:2 % 37 Hz = canale sx, 43 Hz = canale dx.
            
            [amp_est,amp_est_new,ref1,ref2] = FindSinAmpFunction(opt,sig,freq(f));
            subplot(4,1,k)
            plot(t,amp_est,colori(contatore),"DisplayName","amp "+ num2str(freq(f)) +" Hz");
            contatore = contatore+1;
            hold on
            plot(t,amp_est_new,colori(contatore),"DisplayName","amp_new "+ num2str(freq(f)) +" Hz");
            contatore = contatore+1;
        end
        %gcf;
        title("Ch" +  opt.lista_canali(k) + " ampiezza armoniche");
        xlabel('tempo (s)');
        ylabel('amp stim (\muV)');
        grid on
        legend("AutoUpdate","on");
    end
         %se la cartella di destinazione dei risultati non dovesse esistere, la creo
    if ~exist("..\acquisizioni\ampiezza componenti\","dir")
        mkdir ("..\acquisizioni\ampiezza componenti");
    end

    %salvo il plot dei segnali filtrati
    cd("..\acquisizioni\ampiezza componenti\");
    saveas(gcf,nome + " findSinAmp");
    cd(mainFolder);
    close(gcf)

 end

%% Figure
% subplot(3,2,1);
% plot(t(t<=T),ref1);
% hold on;
% plot(t(t<=T),ref2);
% xlabel('time (s)');
% title('Reference signal')
% 
% subplot(3,2,2);
% [Pxx,f] = pwelch(sig-mean(sig),[],[],[],fs); %togliere sempre valore medio dal segnale per il calcolo di psd
% plot(f,Pxx);
% xlabel('frequency (Hz)');
% title('PSD')
% 
% subplot(3,1,2);
% plot(t,sig);
% xlabel('time (s)');
% title('signal');
% 
% subplot(3,1,3);
% plot(t,amp); 
% hold on;
% plot(t,amp_est,'r');
% xlabel('time (s)');
% title(['Amplitude of sinusoid of frequency ', num2str(freq), ' Hz'])
% plot(t,amp_est_new,'g','linewidth',1);
% legend("modulated amplitute","amplitude estimate","new estimate");