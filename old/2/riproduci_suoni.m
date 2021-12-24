function riproduci_suoni(opt)
%funzione principale da cui parte la riproduzione dei suoni, tramite un
%oggetto di tipo audioDeviceWriter, per inviare i toni isocronici ai due
%canali delle cuffie (sx e dx).

%questo oggetto crea il canale di comunicazione con la scheda audio del
%computer (audio stream)

% -------RENDERE LA SELEZIONE DEL DEVICE AUDIO GENERALE/AUTOMATICA.
% adW = audioDeviceWriter('Device','Speakers (Realtek High Definition Audio)',...
%     'SampleRate',opt.fc_audio);

lista_device_audio = getAudioDevices(audioDeviceWriter);

fprintf(1,'Selezionare device audio da utilizzare tramite numero corrispondente:\n');

for i = 1:size(lista_device_audio,2)
    fprintf(1,[num2str(i),' - ',lista_device_audio{i},'\n']);
end

flag = true;

while flag 
selezione_device = input(['Quale device utilizzare?\n[Valori possibili da 1 a ',...
    num2str(size(lista_device_audio,2)),']: ']);

flag = (selezione_device <= 0) || (selezione_device > size(lista_device_audio,2));
end

dev_audio = lista_device_audio{selezione_device};

%creazione oggetto audio device writer
adW = audioDeviceWriter('Device',dev_audio,...
    'SampleRate',opt.fc_audio);

%creazione oggetti wavetableSynthesizer tramite le funzioni secondarie
wavesynt_sx = crea_audio_unico(opt,'sx');
wavesynt_dx = crea_audio_unico(opt,'dx');

% scope = timescope('SampleRate',2*opt.fc_audio,...
%     'TimeSpanSource','Auto');

% di base vengono prodotti 1024 campioni ad ogni chiamata dei due
% WaveTableSyntetizer -> cioè ogni mandata del ciclo qui sotto crea un
% segnale audio lungo 1024 campioni; so che la freq di campionamento dell'
% audio è gestita dall' utente tramite opt.fc_audio. 

counter_max = round(opt.durata_audio/(wavesynt_dx.SamplesPerFrame/opt.fc_audio));


tic
for counter = 1:counter_max
    audio = [wavesynt_sx(), wavesynt_dx()];
    adW(audio);
%     pause(size(audio,1)/opt.fc_audio);
%     pause
%     scope(audio);
end

toc %<_ il tic - toc messi qui servono solo per verificare che effettivamente l' audio duri il numero di secondi 
%indicati dall' utente

release(adW);
release(wavesynt_dx);
release(wavesynt_sx);
% release(scope);

end