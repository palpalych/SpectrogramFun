%% Investigating the Handel dataset

clear all; close all; clc

% Load dataset
load handel
v = y'/2;
t = (1:length(v))/Fs;
n = length(v);
L = n/Fs;

% Basic look at dataset
% figure(1)
% plot(t,v);
% xlabel('Time [sec]');
% ylabel('Amplitude');
% title('Signal of Interest, v(n)');

%p8 = audioplayer(v,Fs);
%playblocking(p8);

% 1/L because we are looking at frequencies instead of steps
k=(1/L)*[0:n/2 -n/2:-1];
ks=fftshift(k);
tslide=0:0.1:9;

% What is the effect of different scaling factors?
figure(1);
scalings = [1 10 100 1000 10000 100000];
for j = 1:length(scalings)
    scaling = scalings(j);
    Sgt_spec = Specto(@GaborFilter, v, t, tslide, scaling);
    subplot(2,3,j);
    pcolor(tslide,ks,Sgt_spec.'), 
    shading interp 
    set(gca,'Ylim',[0 3000],'Fontsize',[14]) 
    xlabel('Time [sec]');
    ylabel('Frequency');
    title(strcat('Scaling Factor:', num2str(scaling)));
    colormap(hot)
end

% What is the effect of different sampling rates?
figure(2);
bestScaling = 1000;
sampling = [0.05 0.5 3];
for j = 1:length(sampling)
    sampleRate = sampling(j);
    tslide=0:sampleRate:9;
    Sgt_spec=Specto(@GaborFilter, v, t, tslide, bestScaling);
    subplot(1,3,j);
    pcolor(tslide,ks,Sgt_spec.'), 
    shading interp 
    set(gca,'Ylim',[0 3000],'Fontsize',[14]) 
    xlabel('Time [sec]');
    ylabel('Frequency');
    title(strcat('Sampling Rate:', num2str(sampleRate)));
    colormap(hot)
end

% How does a Mexican Hat Filter look in comparison?
tslide=0:0.1:9;
figure(3);
scalings = [0.05];
for j = 1:length(scalings)
    scaling = scalings(j);
    Sgt_spec = Specto(@MexicanHatFilter, v, t, tslide, scaling);
    %subplot(2,3,j);
    pcolor(tslide,ks,Sgt_spec.'), 
    shading interp 
    set(gca,'Ylim',[0 3000],'Fontsize',[14]) 
    xlabel('Time [sec]');
    ylabel('Frequency');
    title('Mexican Hat Filter');
    colormap(hot)
end

% How does a Step Filter look in comparison?
tslide=0:0.1:9;
figure(4);
scalings = [0.1];
for j = 1:length(scalings)
    scaling = scalings(j);
    Sgt_spec = Specto(@StepFilter, v, t, tslide, scaling);
    %subplot(2,3,j);
    pcolor(tslide,ks,Sgt_spec.'), 
    shading interp 
    set(gca,'Ylim',[0 3000],'Fontsize',[14]) 
    xlabel('Time [sec]');
    ylabel('Frequency');
    title('Step Filter');
    colormap(hot)
end

% Plot the best Step Filter alone for a deeper look into frequencies
figure(5)
scaling = 0.1;
Sgt_spec = Specto(@StepFilter, v, t, tslide, scaling);
pcolor(tslide,ks,Sgt_spec.'), 
shading interp 
set(gca,'Ylim',[0 3000],'Fontsize',[14]) 
xlabel('Time [sec]');
ylabel('Frequency');
title(strcat('Scaling Factor:', num2str(scaling)));
colormap(hot)

% We're always seeing some interesting behaviors at around 550 Hz and
% around 1100 Hz, we can hone in on those and listen to them

% original for reference
p8 = audioplayer(v,Fs);
playblocking(p8);

% around 550 sounds like the main choir
tau = 0.00005;
volumeScale = 10;
filter = volumeScale * exp(-tau*((ks - 550).^2));
newV = ifft(fftshift(fftshift(fft(v)).*filter));
p8 = audioplayer(newV,Fs);
playblocking(p8);

% around 1150 that sounds like the sopranos hitting high notes or it is the
% timbre
tau = 0.00005;
volumeScale = 10;
filter = volumeScale * exp(-tau*((ks - 1150).^2));
newV = ifft(fftshift(fftshift(fft(v)).*filter));
p8 = audioplayer(newV,Fs);
playblocking(p8);

% this sounds like one of the base instruments
tau = 0.00005;
volumeScale = 10;
filter = volumeScale * exp(-tau*((ks - 200).^2));
newV = ifft(fftshift(fftshift(fft(v)).*filter));
p8 = audioplayer(newV,Fs);
playblocking(p8);

% Sanity check - what are the effects of applying a filter on the
% Spectogram?
figure(6)
scaling = 0.1;
Sgt_spec = Specto(@StepFilter, newV, t, tslide, scaling);
pcolor(tslide,ks,Sgt_spec.'), 
shading interp 
set(gca,'Ylim',[0 3000],'Fontsize',[14]) 
xlabel('Time [sec]');
ylabel('Frequency');
title(strcat('Effects of filter on Spectogram'));
colormap(hot)

%% Investigating "Mary had a little lamb" on piano dataset

clear all; close all; clc

tr_piano=16; % record time in seconds
y=audioread('music1.wav'); Fs=length(y)/tr_piano;
y = y';

% Basic look at dataset
plot((1:length(y))/Fs,y);
xlabel('Time [sec]'); ylabel('Amplitude');
title('Mary had a little lamb (piano)'); drawnow
p8 = audioplayer(y,Fs); playblocking(p8);

n = length(y);
t = (1:n)/Fs;
k=(1/tr_piano)*[0:(n/2-1) -n/2:-1];
ks=fftshift(k);
tslide=linspace(0, tr_piano, 50);

% First lets figure out a good scaling factor
figure(3);
scalings = [100 1000 10000];
for j = 1:length(scalings)
    scaling = scalings(j);
    Sgt_spec = Specto(@GaborFilter, y, t, tslide, scaling);
    subplot(1,3,j);
    pcolor(tslide,ks,Sgt_spec.'), 
    shading interp 
    set(gca,'Ylim',[0 3000],'Fontsize',[14]) 
    xlabel('Time [sec]');
    ylabel('Frequency');
    title(strcat('Scaling Factor:', num2str(scaling)));
    colormap(hot)
end

% Scaling factor 1000 looks best
bestScaling = 1000;

% Now we want to filter for particular notes. Looking at the image from
% scaling factor 1000 it seems that we have 3 notes between 250 and 350 Hz
figure(5)
tslide=linspace(0, tr_piano, 100);
scaling = bestScaling;
Sgt_spec = Specto(@GaborFilter, y, t, tslide, scaling);
pcolor(tslide,ks,log(Sgt_spec.')), 
shading interp 
set(gca,'Ylim',[0 3000],'Fontsize',[14]) 
xlabel('Time [sec]');
ylabel('Frequency');
title('Mystery Tune on Piano');
colormap(hot)

% Since we know the general range of every note (C: ~261 Hz, D: ~290 Hz, 
% E: ~329 Hz), we almost don't even need to run any additional analysis to
% extract the notes being played. But lets put a small filter around
% every note and extract the data
tau = 0.1;
volumeScale = 10;
Cfilter = volumeScale * exp(-tau*((ks - 261).^2));
Cs = ifft(fftshift(fftshift(fft(y)).*Cfilter));
Dfilter = volumeScale * exp(-tau*((ks - 290).^2));
Ds = ifft(fftshift(fftshift(fft(y)).*Dfilter));
Efilter = volumeScale * exp(-tau*((ks - 329).^2));
Es = ifft(fftshift(fftshift(fft(y)).*Efilter));

% Look at what the signal looks like post filter
figure(5)
tslide=linspace(0, tr_piano, 100);
scaling = bestScaling;

Sgt_spec = Specto(@GaborFilter, Es, t, tslide, scaling);
subplot(3,1,1);
pcolor(tslide,ks,Sgt_spec.'), 
shading interp 
set(gca,'Ylim',[200 350],'Fontsize',[14]) 
xlabel('Time [sec]');
ylabel('Frequency');
title('Filter for Es');
colormap(hot)

Sgt_spec = Specto(@GaborFilter, Ds, t, tslide, scaling);
subplot(3,1,2);
pcolor(tslide,ks,Sgt_spec.'), 
shading interp 
set(gca,'Ylim',[200 350],'Fontsize',[14]) 
xlabel('Time [sec]');
ylabel('Frequency');
title('Filter for Ds');
colormap(hot)

Sgt_spec = Specto(@GaborFilter, Cs, t, tslide, scaling);
subplot(3,1,3);
pcolor(tslide,ks,Sgt_spec.'), 
shading interp 
set(gca,'Ylim',[200 350],'Fontsize',[14]) 
xlabel('Time [sec]');
ylabel('Frequency');
title('Filter for Cs');
colormap(hot)

%% Investigating "Mary had a little lamb" on recorder dataset
clear all; close all; clc

tr_rec=14; % record time in seconds
y=audioread('music2.wav'); Fs=length(y)/tr_rec;
y = y';
figure(1)

% Basic look at dataset
plot((1:length(y))/Fs,y);
xlabel('Time [sec]'); ylabel('Amplitude');
title('Mary had a little lamb (recorder)');
p8 = audioplayer(y,Fs); playblocking(p8);

n = length(y);
t = (1:n)/Fs;
k=(1/tr_rec)*[0:(n/2-1) -n/2:-1];
ks=fftshift(k);
tslide=linspace(0, tr_rec, 50);

% First lets figure out a good scaling factor
figure(3);
scalings = [100 1000 10000];
for j = 1:length(scalings)
    scaling = scalings(j);
    Sgt_spec = Specto(@GaborFilter, y, t, tslide, scaling);
    subplot(1,3,j);
    pcolor(tslide,ks,Sgt_spec.'), 
    shading interp 
    set(gca,'Ylim',[0 3000],'Fontsize',[14]) 
    xlabel('Time [sec]');
    ylabel('Frequency');
    title(strcat('Scaling Factor:', num2str(scaling)));
    colormap(hot)
end

% Scaling factor 1000 looks best
bestScaling = 1000;

% Now we want to filter for particular notes. Looking at the image from
% scaling factor 1000 it seems that we have 3 notes between 750 and 1100 Hz
figure(4)
tslide=linspace(0, tr_rec, 100);
scaling = bestScaling;
Sgt_spec = Specto(@GaborFilter, y, t, tslide, scaling);
pcolor(tslide,ks,log(Sgt_spec.')), 
shading interp 
set(gca,'Ylim',[0 13000],'Fontsize',[14]) 
xlabel('Time [sec]');
ylabel('Frequency');
title('Mystery Tune on Recorder');
colormap(hot)