clc
clear
close all

% codice di esempio per creare toni isocronici e suoni binaurali. 
%per un spiegazione di come sono fatti questi due suoni guarda qui:
% https://www.mindamend.com/brainwave-entrainment/isochronic-tones/

%% Toni isocronici 

%si tratta di un suono costituito da vari pacchetti di onde sonore, dove
%ogni pacchetto si ripete ad una frequenza precisa (es. 10 Hz), in base a
%quale frequenza voglio sincronizzare l' attività cerebrale. Il segnale è
%costituito da una sinusoide che viene modulata in ampiezza, in modo che
%ogni pacchetto abbia ampiezza crescente e decrescente, e tra i pacchetti
%si ha ampiezza nulla: il risultato che si sente è un tono che
%ripetutamente viene acceso e spento, alla frequenza prevista (es. 10 Hz).
%Nella forma base tali toni sono uguali per entrambe le orecchie, ma si
%possono mandare toni diversi alle due orecchie, cioè due "treni di
%pacchetti" che abbiano frequenza di ripetizione diversa, es 10 Hz a sx e
%20 Hz a dx, ricordando che la sincronizzazione avverrà nella corteccia
%uditiva primaria controlaterale all' orecchio interessato (ricorda che la
%corteccia uditiva primaria si trova nel lobo temporale).

%parto dal caso base, in cui la sinusoide NON è modulata in ampiezza.
fs = 10e3; %freq di campionamento 10 kHz
T = 10; %durata totale del brano 10 s.
t = [0:1/fs:T-1/fs]; %vettore dei tempi 

d = [0:1/10:10]; % freq ripetizione di impulso = 10 Hz

freq_sin = 200; %frequenza sinusoide nell' impulso
freq_camp_imp = 100e3; %freq campionamento dell' impulso
t_imp = [0:1/freq_camp_imp:0.1]; %asse dei tempi dell' impulso. arriva ad 0.1 s

s = impulso2(t_imp,freq_sin);

% y = pulstran(t,[0,1,2],s,1000);
y = pulstran(t,d,s,freq_camp_imp);

figure
plot(t,y);
xlabel('Tempo (s)');
ylabel('Segnale (u.a.)');

figure
plot(t_imp,s);

% prova
pause
obj = audioplayer(y,fs);
playblocking(obj);

% for i = 1:2
%     playblocking(obj);
% end


% sound(y,fs);
% sound([y,y,y],4*fs);
% pause
% for i = 1:2
% sound(y,fs);
% pause(3.2);
% end








