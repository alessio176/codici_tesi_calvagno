function wavesynt = crea_audio_unico(opt,lato)
% wavesynt = crea_audio_unico(opt,lato)
% 
% Funzione secondaria che crea gli oggetti utili per ottenere le tracce
% audio nei due canali delle cuffie.
% Input: 
% - opt = struttura delle opzioni per le funzioni; questa funzione usa i
% seguenti campi di opt: 
%   • fc_audio = frequenza di campionamento dei segnali audio creati;
%   • freq_base = frequenza delle sinusoidi che costituiscono il singolo
%   beep dei toni isocronici (corrisponde al tono del beep);
%   • freq_rip_dx = frequenza di ripetizione dei toni isocronici della
%   cuffia destra;
%   • freq_rip_sx = frequenza di ripetizione dei toni isocronici della
%   cuffia sinistra;
% - lato = stringa scalare o vettore di caratteri che indica per quale lato
% delle cuffie generare il suono; valori possibili = 'dx', 'sx'.
% Output: 
% - wavesynt = oggetto di tipo wavetableSynthesizer, usato per generare il
% suono da inivare nelle cuffie.

%controllo validità lato
switch lato
    case "sx"
        %lato sx
        freq_rip = opt.freq_rip_sx; 
    case "dx"
        %lato dx
        freq_rip = opt.freq_rip_sx; 
    otherwise
    error('Valore invalido per "lato": valori possibili "sx" o "dx"');
end

%controllo validità opt
if ~(isfield(opt,'fc_audio') && isfield(opt,'freq_base') && ...
        isfield(opt,'freq_rip_sx') && isfield(opt,'freq_rip_dx'))
    error('Struttura delle opzioni (opt) incompleta, vedi help della funzione');
end

%N = Numero di campioni che compongono un periodo di sinusoide
% ( N = (1/freq_sinusoide) * freq_campionamento )
N = round( (1/opt.freq_base) * opt.fc_audio); 

%uso l' oggetto di tipo audioOscillator per generare il beep fondamentale,
%in modo semplice e intuitivo.
osc = audioOscillator('SignalType','sine','Frequency',opt.freq_base,...
    'SampleRate',opt.fc_audio,'OutputDataType','double',...
    'SamplesPerFrame', N);

%creo il segnale base chiamando osc(), e ottengo un vettore colonna, di
%lunghezza = osc.SamplesPerFrame.
wavetable = [osc(); zeros(size(osc()))];

%NB: in questo caso la pausa tra un suono e l' altro ha la stessa durata
%del beep stesso -> probabile fattore da parametrizzare.

%questo oggetto permette di creare il segnale periodico ottenuto ripetendo
%il segnale base, fornito con il vettore wavetable. Frequency gestisce la
%frequenza di ripetizione dei singoli "beep", che sarà la base dello
%stimolo uditivo per ottenere sincronizzazione dell' EEG a questa frequenza
%(in questo caso 10 Hz, sono in banda alpha).

wavesynt = wavetableSynthesizer(wavetable,'Frequency',freq_rip,'SamplesPerFrame',N*2,...
    'SampleRate',opt.fc_audio);


release(osc);
end
