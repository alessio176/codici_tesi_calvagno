% ----------------------
% TEST Sound Simulations
% ----------------------
% ----------------------
clc
clear
close all

% Segnale sinusoidale
Fs=8000;
Ts=20;
t=(0:1/Fs:Ts); 
freq_sound_1=150;
freq_sound_2=150;
x1=sin(2*pi*freq_sound_1*t);
x2=sin(2*pi*freq_sound_2*t);

% Segnale porta
freq1=10;
freq2=25;
t1=.5*(square(2*pi*freq1*t,2*freq1)+1);
t2=.5*(square(2*pi*freq2*t,2*freq2)+1);

% Finestratura con segnale di tipo porta
y1=x1.*t1;
y2=x2.*t2;
plot(t,y1,'-r')
hold
plot(t,y2+2.1)

% Segnali sovrapposti
Y1 = audioplayer(y1+y2, Fs);
% segnali in stereo
Y2 = audioplayer([y1;y2], Fs);
%play(Y1)
play(Y2)



