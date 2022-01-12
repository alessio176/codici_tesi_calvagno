clear
close all
clc
%fmincon %fminunc
%filtro spaziale = combinazione lineare dei vari canali ai vari istanti di
%tempo, cercando di ottimizzare i pesi di volta in volta


% parametri da scegliere: std del rumore Gaussiano, numero di cicli della
% sinusoide di riferimento e frequenza
sigma_noise=10;
number_cycles=8;
freq=12; 
freq_sig=12;

T=number_cycles/freq; %durata segnale di riferimento
fs=500; %freq di campionamento
t=0:1/fs:10; %asse dei tempi (per il segnale finale, quello corrotto)

% generazione del segnale
amp=2*sin(2*pi*.05*t).^10; % ampiezza della sinusoide, che suppongo essere variabile nel tempo
sigma=sigma_noise;
sig=sigma*randn(size(t)); %segnale rumore (gaussiano bianco)
[cMA,cAR]=notch(.01,1,freq_sig,1/fs);
sig=filtfilt(cMA,cAR,sig); % nota: qua tolgo la componente alla frequenza di interesse... 
sig=sig+amp.*sin(2*pi*freq_sig*t); % ...e poi metto una sinusoide pura (segnale: rumore + sinusoide)
%nota: la sinusoide aggiunta è modulata in ampiezza e ha freq costante pari
%a freq_sig (che in questo caso è uguale a freq di segnale di riferimento).

% stima dell'ampiezza della sinusoide di interesse
[amp_est,amp_est_new,ref1,ref2]=est_A(t,sig,freq,T,fs);

% Figure
subplot(3,2,1);
plot(t(t<=T),ref1);
hold on;
plot(t(t<=T),ref2);
xlabel('time (s)');
title('Reference signal')

subplot(3,2,2);
[Pxx,f] = pwelch(sig-mean(sig),[],[],[],fs); %togliere sempre valore medio dal segnale per il calcolo di psd
plot(f,Pxx);
xlabel('frequency (Hz)');
title('PSD')

subplot(3,1,2);
plot(t,sig);
xlabel('time (s)');
title('signal');

subplot(3,1,3);
plot(t,amp); 
hold on;
plot(t,amp_est,'r');
xlabel('time (s)');
title(['Amplitude of sinusoid of frequency ', num2str(freq), ' Hz'])
plot(t,amp_est_new,'g','linewidth',1);
legend("modulated amplitute","amplitude estimate","new estimate");

%% definizione delle funzioni
function [Amp_est,Amp_est_new,ref1,ref2]=est_A(t,sig,freq,T,fs)
% [Amp_est,Amp_est_new,ref1,ref2]=est_A(t,sig,freq,T,fs)
% 
% INPUT
% t, sig: time vector and signal to be processed
% freq: frequency of the sinusoidal component of interest
% T: duration of the reference sinusoid
% fs: sampling frequency
% OUTPUT
% Amp_est, Amp_est_new: amplitude of the sinusoid as a function of time 
% (two approaches are considered: 1. processing the raw data and 2. processing the data filtered around the frequency of interest)
% ref1,ref2: reference signals (sine and cosine functions with frequency equal to freq and duration T)

% Reference signals (a sine and a cosine, so that their sum accounts for both modulus and phase of the sinusoid to be found in the input signal)
ref1=sin(2*pi*freq*t(t<=T));
ref1=ref1/(std(ref1))^2;
ref2=cos(2*pi*freq*t(t<=T));
ref2=ref2/(std(ref2))^2;
NN=length(ref1);
% 2 approaches: 1. processing the raw data; 2. processing the component selected by a filter
% Amplitudes computed by cross-correlation
% 1. Processing the raw data
Amp_est1=conv(sig,fliplr(ref1)/NN,'same'); %perchè non usare direttamente xcorr?
Amp_est2=conv(sig,fliplr(ref2)/NN,'same');

% 2. the sinusoidal component is extracted from the signal
[cMA,cAR]=notch(.01,1,freq,1/fs);
sig_minus_sin=filter(cMA,cAR,sig);
sig_sin=sig-sig_minus_sin; %isolo la componente a frequenza freq (faccio una sorta di passabanda alla fine dei conti)
d=finddelay(sig,sig_sin);
sig_sin=circshift(sig_sin,-d);% delay is compensated (low performances if there is too much noise)
% cross-correlation of the filtered data and reference signals
Amp_est1_new=conv(sig_sin,fliplr(ref1)/NN,'same'); 
Amp_est2_new=conv(sig_sin,fliplr(ref2)/NN,'same');

% estimation of the modulus of the components with the 2 approaches
Amp_est=sqrt(Amp_est1.^2+Amp_est2.^2);
Amp_est_new=sqrt(Amp_est1_new.^2+Amp_est2_new.^2);
end

function [cMA,cAR]=notch(z,B,fc,T)
% [cMA,cAR]=notch(z,B,fc,T)
% 
% input parameters
%	z  (0.01) attenuazione minima alla frequenza fc
%	B  (2) larghezza di banda corrispondente alla attenuazione 0.707
% 	fc (50) frequenza di centro banda
% 	T  intervallo di campionamento
% output parameters
%	cMA  filter coefficients (MA part)
%	cAR  filter coefficients (AR part)


b=pi*B*T;
a=b*z;
c1=-2*(1-a)*cos(2*pi*fc*T);
c2=(1-a)^2;
c3=2*(1-b)*cos(2*pi*fc*T);
c4=-(1-b)^2;
cMA=[1 c1 c2];
cAR=[1 -c3 -c4];

end
