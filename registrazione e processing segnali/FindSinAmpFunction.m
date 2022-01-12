%fmincon %fminunc
%filtro spaziale = combinazione lineare dei vari canali ai vari istanti di
%tempo, cercando di ottimizzare i pesi di volta in volta


% parametri da scegliere: std del rumore Gaussiano, numero di cicli della
% sinusoide di riferimento e frequenza
function [Amp_est,Amp_est_new,ref1,ref2] = FindSinAmpFunction(opt,sig,freq)
% Input:
% opt = struttura contenente le opzioni;
% sig = segnale da analizzare (già caricato su matlab tramite file .mat o
% easy2mat);
% freq = frequenza della sinusoide di cui si vuole determinare ampiezza
% dentro il segnale sig.
% Output:
% Amp_est, Amp_est_new = amplitude of the sinusoid as a function of time 
% (two approaches are considered: 1. processing the raw data and 2. processing the data filtered around the frequency of interest)
% ref1,ref2 = reference signals (sine and cosine functions with frequency equal to freq and duration T)


%numero di cicli di sinusoide che costituiscono il segnale di riferimento.
%nota: se il numero di cili è troppo basso, ottengo una sinusoide troppo
%troncata agli estremi, nel senso che il segnale di riferimento che avrò
%ala fine avrà moltre altre frequenze oltre a quella propria della
%sinusoide (ricorda che un segnale sinusoidale ha una precisa frequenza sol
%quando è definito da -inf a +inf); 
%se il numero di cicli è troppo alto, si ottiene una buona discriminazione
%della frequenza in questione, ma a scapito della risoluzione temporale,
%cioè riuscirò a vedere le variazioni dell' ampiezza dell' armonica
%nascosta con una cadenza ridotta. 
number_cycles=8; 

T=number_cycles/freq; %durata segnale di riferimento in secondi
fs=opt.findsinamp.fc; %freq di campionamento di sinusoide (ma anche di segnale)
t = [0:length(sig)-1].*(1/opt.fc); %creo asse dei tempi discreti
% t=0:1/fs:10; %asse dei tempi (per il segnale finale, quello corrotto)

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

%% definizione delle funzioni ausiliarie

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

