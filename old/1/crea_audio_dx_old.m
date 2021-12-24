function wavesynt = crea_audio_dx(opt)
%funzione secondaria che crea la traccia audio da mandare nel canale sinistro delle
%cuffie.

%N = Numero di campioni che compongono un periodo di sinusoide
% ( N = (1/freq_sinusoide) * freq_campionamento )
N = round( (1/opt.freq_base_dx) * opt.fc_audio); 

%uso l' oggetto di tipo audioOscillator per generare il beep fondamentale,
%in modo semplice e intuitivo.
osc = audioOscillator('SignalType','sine','Frequency',opt.freq_base_dx,...
    'SampleRate',opt.fc_audio,'OutputDataType','double',...
    'SamplesPerFrame', N);
%creo il segnale base chiamando osc(), e ottengo un vettore colonna, di
%lunghezza = osc.SamplesPerFrame (qui uso il valore di default di 512).
wavetable = [osc(); zeros(size(osc()))];
%NB: in questo caso la pausa tra un suono e l' altro ha la stessa durata
%del beep stesso -> probabile fattore da parametrizzare.

%questo oggetto permette di creare il segnale periodico ottenuto ripetendo
%il segnale base, fornito con il vettore wavetable. Frequency gestisce la
%frequenza di ripetizione dei singoli "beep", che sarà la base dello
%stimolo uditivo per ottenere sincronizzazione dell' EEG a questa frequenza
%(in questo caso 10 Hz, sono in banda alpha).
wavesynt = wavetableSynthesizer(wavetable,'Frequency',opt.freq_rip_dx,'SamplesPerFrame',N*2,...
    'SampleRate',opt.fc_audio);


release(osc);
end