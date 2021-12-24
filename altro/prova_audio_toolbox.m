%prova di creazione di audio isocronici nelle cuffie/speaker del pc,
%tramite l' uso dei system object dell' audio toolbox.

clc
clear 
close all


%il tutto si basa sull' uso di wavetableSynthesizer e di audioOscillator.

%Prima creo la base del suono periodico da ripetere. Per fare ciò uso un
%oggetto audioOscillator per ottenere il suono base come vettore. Tramite
%il costruttore di tale oggetto posso settare le proprietà del suono base
%in modo intuitivo. 

osc = audioOscillator('SignalType','sine','Frequency',200,'SampleRate',10e3,'OutputDataType','double');

%creo il segnale base chiamando osc(), e ottengo un vettore colonna, di
%lunghezza = osc.SamplesPerFrame (qui uso il valore di default di 512).
wavetable = [osc(); zeros(size(osc()))]; 

%questo oggetto crea il canale di comunicazione con la scheda audio del
%computer (audio stream)
adW = audioDeviceWriter('Device','Speakers (Realtek High Definition Audio)',...
    'SampleRate',osc.SampleRate);
%     'ChannelMappingSource','Property','ChannelMapping',1); %<- da approfondire channel mapping


%     Approfondimento: NON è necessario cambiare il channelMappingSource,
%     per inviare il suono ai due canali separatamente si può lasciare
%     questo parametro in auto (default) e poi in fase di utilizzo metto
%     dentro le parentesi di adW una matrice invece che un vettore colonna:
%     con un imput con fomato matrice ogni colonna viene trattata come un
%     canale singolo, quindi in questo caso, usando una matrice con due
%     colonne, automaticamente gestisco canale sx e dx separatamente,
%     proprio come voglio fare; unica richiesta è che i due audio inviati
%     ai singoli canali abbiano stessa lunghezza (cioè stesso numero di
%     righe nelle due colonne da concatenare poi in un unica matrice).

%questo oggetto permette di creare il segnale periodico ottenuto ripetendo
%il segnale base, fornito con il vettore wavetable. Frequency gestisce la
%frequenza di ripetizione dei singoli "beep", che sarà la base dello
%stimolo uditivo per ottenere sincronizzazione dell' EEG a questa frequenza
%(in questo caso 10 Hz, sono in banda alpha). 

wavesynt = wavetableSynthesizer(wavetable,'Frequency',10,'SamplesPerFrame',osc.SamplesPerFrame*2,...
    'SampleRate',osc.SampleRate);

%questo oggetto serve per vedere il segnale periodico, come se usassi un
%oscilloscopio classico.
scope = timescope('SampleRate',osc.SampleRate,'ShowGrid',true,...
    'TimeSpanSource','auto', ...
    'YLimits',[-1.5,1.5], ...
    'TimeSpanOverrunAction','Scroll', ...
    'ShowGrid',true, ...
    'Title','Toni isocronici');
%     'TimeSpanSource','Property','TimeSpan',0.1,
%loop di stream audio
counter = 0; 

%%

while (counter < 1000)
% while true

    audio = wavesynt(); %creo un frame di segnale da mandare in output

    adW([zeros(size(audio)),audio]); %<- con questa istruzione invio il suono alla scheda audio,
    %grazie allo stream apposito creato (nota: in modo analogo posso
    %mandare il suono in una scheda audio esterna collegata al pc, o ad un
    %file; nei vari casi cambia solo il tipo di stream che creo, ma il
    %concetto è identico).

%      scope(audio); %visualizzo il segnale audio nell' oscilloscopio virtuale.

    counter = counter + 1; %incremento contatore per interrompere il while, prima o poi.
    %Nota importante: posso anche creare un while infinito e quindi inviare
    %all' infinito il suono alle cuffie: può essere utile per avere una BCI
    %che funziona fino a quando richiesto dall' utente, MA si creano questioni
    %non banali riguardo il costo computazionale ed eventuali blocchi del
    %sistema per un while infinito. 
end

%gli oggetti usati sono dei System object, ed è meglio usare questa
%funzione release per liberare il sistema dal loro controllo, ad es. per
%chiudere gli stream aperti (ricorda molto il memory leak del C++).

release(osc);
release(adW);
release(wavesynt);
release(scope);