addpath('/home/ashish/Documents/MATLAB/audioread/');
inpPath = '/home/ashish/Documents/HTS-demo_CMU-ARCTIC-SLT/data/wavASH/';
outPath = '/home/ashish/Documents/HTS-demo_CMU-ARCTIC-SLT/data/wavASH16/';
Files = dir(inpPath);

count = 0 ;
for i = 1:size(Files,1)
        if(strcmp( regexp(Files(i).name,'wav','match'),'wav'))
            count = count + 1 ;
            fileName = Files(i).name; 
            [a,fs] = audioread(strcat(inpPath,fileName));
            a = resample(a,1,3);
            wavwrite(a,16000,strcat(outPath,fileName));
        end
end

