% The input file is a wav file 
% Output file will a feature file
function y = outFeats(inpFile,outFile)
    addpath('/home/ashish/Documents/MATLAB/audioread/');

    %% MFCC features - 40
    [mfcc,~,q,~] = mfcc_straight(inpFile);
    f0 = q.f0 ;
    feats = [mfcc,f0];
    feats1 = deltas(feats,3);
    feats2 = deltas(feats1,3);
    featsAll = [feats feats1 feats2];
    save(outFile,'featsAll');
    y = 1 ;
    clear all;
end