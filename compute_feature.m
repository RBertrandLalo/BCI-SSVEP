function [ features ] = compute_feature(signal, f_etude)
% extrait les caracteristiques d'un signal
% le signal est donné sous la forme d'une matrice Nt*Ne
% features est le vecteur caractéristique de dimension Ne

Ne = size(signal,1);
features = zeros(1,Ne);

for i=1:Ne
    
% periodogramme de Welsh
Fs = 256;

Nf = 4096*4;                             % nombre de points de calcul de la fft. il faut Nf > length(signal) sinon fft() tronque le signal
axe_freq_total = (0:1/Nf:(1-1/Nf))*Fs;   % fft calcule la DSP sur [0 Fs]
axe_freq = axe_freq_total(1:Nf/2+1);     % pwelch calcule la DSP sur [0 Fs/2]

temps_fen = 2; % temps d'une fenêtre de calcul (2 sec...)
fen = temps_fen * Fs;
temps_noverlap = 1; % temps en commun pour deux fenêtres successives (1 sec...)
noverlap = temps_noverlap * Fs;

PW = pwelch(signal(i,:)',fen,noverlap,Nf);

% ième feature
% fondamental seulement
features(i) = sum(  PW( (f_etude-1)*(Nf/2+1)/(Fs/2):(f_etude+1)*(Nf/2+1)/(Fs/2)  ).^2      );

end

end



