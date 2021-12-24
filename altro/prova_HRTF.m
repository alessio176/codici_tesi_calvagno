clc
clear
close all

load 'ReferenceHRTF.mat' hrtfData sourcePosition

hrtfData = permute(double(hrtfData),[2,3,1]);

 sourcePosition = sourcePosition(:,[1,2]);

desiredAz = 30; %110
desiredEl = 0; %-45
desiredPosition = [desiredAz, desiredEl];

interpolatedIR  = interpolateHRTF(hrtfData,sourcePosition,desiredPosition, ...
                                  "Algorithm","VBAP");

leftIR = squeeze(interpolatedIR(:,1,:))';
rightIR = squeeze(interpolatedIR(:,2,:))';

fileReader = dsp.AudioFileReader('RockDrums-48-stereo-11secs.mp3');
deviceWriter = audioDeviceWriter('Device','Speakers (Realtek High Definition Audio)',...
    'SampleRate',fileReader.SampleRate);

leftFilter = dsp.FIRFilter('Numerator',leftIR);
rightFilter = dsp.FIRFilter('Numerator',rightIR);
while ~isDone(fileReader)
    audioIn = fileReader();
    
    leftChannel = leftFilter(audioIn(:,1));
    rightChannel = rightFilter(audioIn(:,2));
    
    deviceWriter([leftChannel,rightChannel]);
end


release(deviceWriter)
release(fileReader)
