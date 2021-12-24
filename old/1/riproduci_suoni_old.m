function riproduci_suoni(opt)
%funzione principale da cui parte la riproduzione dei suoni, tramite un
%oggetto di tipo audioDeviceWriter, per inviare i toni isocronici ai due
%canali delle cuffie (sx e dx).

%questo oggetto crea il canale di comunicazione con la scheda audio del
%computer (audio stream)

adW = audioDeviceWriter('Device','Speakers (Realtek High Definition Audio)',...
    'SampleRate',opt.fc_audio);

% adW = audioDeviceWriter('SampleRate',opt.fc_audio);

wavesynt_sx = crea_audio_sx(opt);
wavesynt_dx = crea_audio_dx(opt);

% di base vengono prodotti 1024 campioni ad ogni chiamata dei due
% WaveTableSyntetizer -> cioè ogni mandata del ciclo qui sotto crea un
% segnale audio lungo 1024 campioni; so che la freq di campionamento dell'
% audio è gestita dall' utente tramite opt.fc_audio. 

counter_max = round(opt.durata_audio/(wavesynt_dx.SamplesPerFrame/opt.fc_audio));

tic
for counter = 1:counter_max
    audio = [wavesynt_sx(), wavesynt_dx()];
    adW(audio);
end

toc %<_ il tic - toc messi qui servono solo per verificare che effettivamente l' audio duri il numero di secondi 
%indicati dall' utente

release(adW);
release(wavesynt_dx);
release(wavesynt_sx);

end