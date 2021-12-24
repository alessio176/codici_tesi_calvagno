clc
clear
close all

%esempio di uso di pulstran con impulso creato tramite prototipo

fnx = @(x,fn) sin(2*pi*fn*x).*exp(-fn*abs(x));

ffs = 1000;
tp = 0:1/ffs:1;

pp = fnx(tp,30);

figure
plot(tp,pp)
xlabel('Time (s)')
ylabel('Waveform')

fs = 2e3;
t = 0:1/fs:1.2;

d = 0:1/3:1;
dd = [d;4.^-d]';

d2 = [0,0.1,0.2,0.3,0.4];

z = pulstran(t,[0,0.6],pp,ffs);

figure
plot(t,z)
xlabel('Time (s)')
ylabel('Waveform')

y = pulstran(t,d2,fnx,30);

figure
plot(t,y)
xlabel('Time (s)')
ylabel('Waveform')