function [ DSP,axe_freq] = create_dsp(signal)
%Cette fonction crée un vecteur correspondant au spectre de puissance
%moyenné sur toutes les électrodes du signal
%donné en argument sous la forme d'un signal NexNt
%La sortie est un vecteur de longueur Nf

Ne = size(signal,1);
PW=[];

% periodogramme de Welsh
Fs = 256;
Nf = 4096*4; % nombre de points de calcul de la fft. il faut Nf > length(signal) sinon fft() tronque le signal

axe_freq_total = (0:1/Nf:(1-1/Nf))*Fs;   % fft calcule la DSP sur [0 Fs]
axe_freq = axe_freq_total(1:Nf/2+1);     % pwelch calcule la DSP sur [0 Fs/2]

temps_fen = 2; % temps d'une fenêtre de calcul (2 sec...)
fen = temps_fen * Fs;
temps_noverlap = 1; % temps en commun pour deux fenêtres successives (1 sec...)
noverlap = temps_noverlap * Fs;

for i=1:Ne
    
PW = horzcat(PW,pwelch(signal(i,:)',fen,noverlap,Nf));

end

DSP=mean(PW,2); 

end

