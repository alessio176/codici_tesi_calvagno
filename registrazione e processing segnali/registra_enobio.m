function data = registra_enobio(opt)

%data sarà una matrice NxM con N = num di canali (8, fisso) e M = numero
%di campioni nella finestra temporale desiderata (5 s di default)

%%%%%%% Global %%%%%%%

% Splash message
disp(' ')
disp('Starlab Enobio Matlab real-time interface')
disp(' ')

% Get user inputs
% Ip address

ip = opt.ip;

% Plot length

t_plot = opt.durata_EEG;

% If data should be recorded
% if_record = input('Record the whole enobio session in ''full_session''? (y/n, if empty, no): ','s');
% if (isempty(if_record) || ~strcmp(if_record, 'y'))
%     if_record = 0;        % Number of seconds of data to aquire
% else
%     if_record = 1;
% end

 if_record = false; %<- chiedere delucidazioni su questo flag!

 %NON MODIFICARE QUESTI PARAMETRI
p    = 1;          % Duration of the pause before acquisition (seconds, min 1s)
N    = 8;          % number of channels
bps  = 4;          % bytes per sample
Fs   = 500;        % Enobio's sampling rate
Ns   = 20;         % number of samples to read in the buffer each time (between 20 and 250)
buff = bps*Ns*N;   % Number of bytes to read in total for all channels
plotarray = int32(zeros(8,Fs*t_plot)); % Initialization of the array to plot the data
if if_record, full_session=zeros(8,1); end;
%%%%%%%%%%%%%%%%%%%%%%

% Create TCP/IP connection
import java.net.Socket
import java.io.*
import java.nio.*
sock=Socket(ip,1234); 
ch = channels.Channels.newChannel(sock.getInputStream);
bytes = ByteBuffer.allocate(buff);
bytes.order(ByteOrder.BIG_ENDIAN);

disp('Please wait...')
pause(p)
key = ' ';
figure

Data = zeros(N,Ns);

n_bytes = 0;
while(~strcmp(key, char(13)))
    n_bytes = n_bytes + ch.read(bytes);
    if n_bytes < buff
        continue;
    end
    n_bytes = 0;
    bytes.rewind;
    for i = 1:Ns
        for j = 1 : N
            Data(j, i) = bytes.getInt;
        end
    end
    bytes.rewind;

    % Fill the plot array
    plotarray = [plotarray(:,Ns+1:end) Data];
    
    if if_record, full_session = [full_session Data]; end
    
% Plot the all data (VERY CPU CONSUMING, generates big delay)
%     for k = [1:8]
%         subplot(8,1,k);
%         plot((1:Fs*t_plot)/Fs,plotarray(k,:));
%         ylabel(['Channel ' num2str(k)]);
%         if (k == 1)
%             title('Press enter to stop the acquisition (plot data available in the ''plotarray'' variable')
%         end
%     end

% Plot the 1 single channel data (CPU CONSUMING, but does not generate)

        plot((1:Fs*t_plot)/Fs,plotarray(1,:));
        ylabel(['Channel ' num2str(1)]);
        title('Press enter to stop the acquisition (plot data available in the ''plotarray'' variable')

    xlabel('time [s]');
   
    drawnow
    % Get the key to check if the plotting has to continue.
    key = get(gcf, 'CurrentCharacter');
end
disp('Done.')

data = plotarray;

% Clean up the connection
sock.close;
disp('Connection closed.')

end