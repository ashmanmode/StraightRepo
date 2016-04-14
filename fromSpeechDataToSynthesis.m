function synthOutStructure = fromSpeechDataToSynthesis(x,fs)
synthOutStructure.procedureName = 'fromSpeechDataToSynthesis';
x = x(:,1);
r = exF0candidatesTSTRAIGHTGB(x,fs);
x = removeLF(x,fs,r.f0,r.periodicityLevel);
r = exF0candidatesTSTRAIGHTGB(x,fs);
rc = r;
rc = autoF0Tracking(r,x);
rc.vuv = refineVoicingDecision(x,rc);

q = aperiodicityRatio(x,rc,1);

f = exSpectrumTSTRAIGHTGB(x,fs,q);

STRAIGHTobject.waveform = x;
STRAIGHTobject.samplingFrequency = fs;
STRAIGHTobject.refinedF0Structure.temporalPositions = r.temporalPositions;
STRAIGHTobject.SpectrumStructure.spectrogramSTRAIGHT = f.spectrogramSTRAIGHT;
STRAIGHTobject.refinedF0Structure.vuv = rc.vuv;
f.spectrogramSTRAIGHT = unvoicedProcessing(STRAIGHTobject);

synthOutStructure.synthOutStructure = exTandemSTRAIGHTsynthNx(q,f);
