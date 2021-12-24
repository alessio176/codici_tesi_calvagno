%%% enobio_TCP_IP_IP_real_time
%%% Plot Real-Time Enobio data into Matlab via TCP/IP.
%%% Version 1.0
%%% Tested on Matlab r2009b

%%% Copyright (c) 2010,
%%% By E. Motte, A. Riera and J. Acedo Starlab Barcelona S.L.
%%% All rights reserved.

%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are
%%% met:
%%%    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
%%%    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
%%%    * Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
%CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
%INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
%MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
%BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
%EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
%TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
%DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
%ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
%TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
%THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
%SUCH DAMAGE.

clear all

%%%%%%% Global %%%%%%%

% Splash message
disp(' ')
disp('Starlab Enobio Matlab real-time interface')
disp(' ')

% Get user inputs
% Ip address
ip = input('Please type the ip address of the ENOBIO TCP Server (if empty, 127.0.0.1): ', 's');
if isempty(ip)
%     ip = '192.168.1.10';
ip = '169.254.192.167';% Default to home ip address
end

% Plot length
t_plot = input('Please specify the number of seconds of data to plot (if empty, 5s): ','s');
if isempty(t_plot)
    t_plot = '5';        % Number of seconds of data to aquire
end
t_plot = str2double(t_plot);

% If data should be recorded
if_record = input('Record the whole enobio session in ''full_session''? (y/n, if empty, no): ','s');
if (isempty(if_record) || ~strcmp(if_record, 'y'))
    if_record = 0;        % Number of seconds of data to aquire
else
    if_record = 1;
end

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
    
    if if_record, full_session = [full_session Data];, end;
    
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



% Clean up the connection
sock.close;
%disp('Connection closed.')

