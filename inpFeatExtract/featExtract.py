import os
import sys
import math
import logging
import numpy as np
import struct 
from matplotlib import pyplot as pp
import pylab

ownDir = '/home/ashish/Documents/featDNN/'
festival_path_bin = '/usr/'
festival_path = '/home/ashish/Downloads/festival-master/'
hts_scripts_path = '/home/ashish/Documents/HTS-demo_CMU-ARCTIC-SLT/data/scripts/'

class Festival_features():
    def __init__(self, lname, feats_file=None):
        self._read_list(lname)
        if feats_file:
            self._read_list_header(hname)
    def _read_list(self, lname):
        ls = []
        cnt =0
        f= open(lname)
        for line in f:
            line = line[:-1]
            vals = self._read_line(line)
            ls.append(vals)
            cnt += 1
        ls_np = np.zeros((len(ls), len(ls[0])), 'object')
        i=0
        for ln in ls:
            j=0
            for o in ln: 
                ls_np[i,j] = o
                j+=1
            i+=1
            
        cats = [0,1,2,3,4, 7,8, 10,11, 25, 29,31,39, 47]
        ordinals = range(ls_np.shape[1])
        dims = []
        dicts = []
        for i in cats:
            ordinals.remove(i)
            dims.append(len(np.unique(ls_np[:, i])))
            if 'x' in ls_np[:, i]:
                dims[-1] -= 1
            unq = np.unique(ls_np[:, i])
            unq = unq.tolist()
            if 'x' in unq:
                unq.remove('x')
            unq=np.array(unq)
            d = {}
            for j in range(len(unq)):
                d[unq[j]] = j
            dicts.append(d)
        dicts[-1]['H*H%'] = 4
        dims[-1] += 1
        dimension = sum(dims) + len(ordinals)
        # print dimension
        # print dicts
        # print cats
        # print ordinals
        # print dims
        self.dimension = dimension
        self.dicts = dicts
        self.cats = cats
        self.ordinals = ordinals
        self.dims = dims
        self._convert_line_to_array(line)
        pass
    def _read_line(self, line):
        chars = ['^', '-', '+', '=', '@', '_', '/', ':', '&', '#', '$', '!', ';', '|']
        inx=['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
        
        #line = line[:-1]
        line=line.replace('L-', 'L*')
        line=line.replace('H-', 'H*')

        for c in chars:
            line=line.replace(c, ',')
        vals=line.split(',')
        for j in inx:
            vals.remove(j)
       
        return vals
            
    def _convert_line_to_array(self, line):
        vals=self._read_line(line)
        one_hot_data = np.zeros((1,self.dimension), dtype=float)
        cnt = 0
        for i in self.ordinals:
            if vals[i] is 'x':
                one_hot_data[0, cnt] = 0
            else:
                one_hot_data[0, cnt] = np.int(vals[i])
            cnt += 1
        for i in range(len(self.cats)):
            #print i
            one_hot_data[0, cnt:cnt+self.dims[i]] = 0
            if vals[self.cats[i]] is 'x':
                one_hot_data[0, cnt:cnt+self.dims[i]] = 1
            else:
                one_hot_data[0, cnt+self.dicts[i][vals[self.cats[i]]]] = 1
            cnt += self.dims[i]
            
        return one_hot_data
    def _read_list_header(self, hname):
        f= open(hname)
        cats = []
        for line in f:
            line = line[:-1]
            if line.startswith('#  '):
                prev_name = line
            if line.startswith('    printf ') and len(line) > len('    printf "@"')+1:
                cats.append(prev_name)
        self.label_name = cats    
            
    def convert_lab(self, lab_name):
        data = np.zeros((0, self.dimension), dtype=float)
        f= open(lab_name)
        for line in f:
            line = line[:-1]
            v = self._convert_line_to_array(line)
            data = np.r_[data, v]
        return data
    def convert_lab_time(self, lab_name):
        data = np.zeros((0, self.dimension), dtype=float)
        f= open(lab_name)
        time = [0]
        for line in f:
            line = line[:-1]
            st = int(line[:11])
            en = int(line[11:22])
            time.append(en/10000000.0)
            line = line[22:]
            v = self._convert_line_to_array(line)
            data = np.r_[data, v]
        return data
    def convert_lab_time_mono(self, lab_name):
        f= open(lab_name)
        time = [0]
        for line in f:
            line = line[:-1]
            nums = line.split(' ')
            st = int(nums[0])
            en = int(nums[1])
            time.append(en/10000.0)
        return np.array(time)
 
#Get full context label file and forced aligned phones file
#full lab stored at  ownDir+'tmp/tmp.full.lab'
#frame aligned file at ownDir+'tmp/tmp.aligned.lab' 
def Festival_fx(text):
    """ 
    generate contextual features from a given tesxt string
    input: text (string)
    output: feature file name (string)
    """
    # generate .utt 
    # execComm = "echo '(load \"/usr/share/festival/clunits_build.scm\")\n(utt.save (SynthText \""+text+"\") \""+ownDir+"tmp/tmp.utt\")' > "+ownDir+"tmp/tmp.scp"
    # # execComm = "echo '(utt.save (SynthText \""+text+"\") \""+ownDir+"tmp/tmp.utt\")' > "+ownDir+"tmp/tmp.scp"
    # os.system(execComm)
    # os.system(festival_path_bin+'bin/festival --script '+ownDir+'tmp/tmp.scp')
    # os.system('rm '+ownDir+'tmp/tmp.scp')
    
    ## Force align the phones with frame using HSMMAlign
    ## check the training log for the same  

    # generate features from .utt
    genFeats = festival_path + "examples/dumpfeats -eval "+hts_scripts_path+"extra_feats.scm -relation Segment -feats "+hts_scripts_path+"label.feats -output "+ownDir+"tmp/tmp.feat "+ownDir+"tmp/tmp.utt"
    os.system(genFeats)

    # generate .lab (contextual features) from features computed from the previous step
    os.system('awk -f '+hts_scripts_path+'label-full.awk '+ownDir+'tmp/tmp.feat > '+ownDir+'tmp/tmp.full.lab')
    os.system('awk -f '+hts_scripts_path+'label-mono.awk '+ownDir+'tmp/tmp.feat > '+ownDir+'tmp/tmp.mono.lab')
    # os.system('rm -f '+ownDir+'tmp/tmp.feat')

    return ownDir+'tmp/tmp.full.lab',ownDir+'tmp/tmp.aligned.lab'

def generateFrameFeats(data,time):
    """
    Create frames here and extract data for individual frames
    """
    feats = []
    for i in range(0,len(time)-1):
        frames = (time[i+1]-time[i])/5
        for j in range(0,int(frames)):
            frameFeats = data[i].tolist()

            #Three features for position coding
            pos = j/float(frames)
            frameFeats.append(pos)
            frameFeats.append(math.sin((pos*math.pi)/2))
            frameFeats.append(math.cos((pos*math.pi)/2))

            #Duration of the current phone
            frameFeats.append(time[i+1]-time[i])

            #Now appending complete vector
            feats.append(frameFeats)
    print "Textual features genearated. Frames ",len(feats)
    return feats

#gets all the files from directory and store features for all those
def trainLinguisticFeats(fullDir,alignDir,outDir):

    #Saving the features generated to python array
    ff=Festival_features(lname, hname)
    data = ff.convert_lab_time(fullDir)
    time = ff.convert_lab_time_mono(alignDir)

    ## Frame alignment 
    feats = generateFrameFeats(data,time)
    np.savetxt(outDir,feats)
    return

##########################################################
## Main Programm starts Here
##########################################################
hname = '/home/ashish/Documents/HTS-demo_CMU-ARCTIC-SLT/data/scripts/label-full.awk'
lname = '/home/ashish/Documents/HTS-demo_CMU-ARCTIC-SLT/data/lists/full.list'
args = sys.argv

#training Phase 
#input argument train
if args[1] == 'train':
    fullDir = args[2]
    alignDir = args[3]
    outDir = args[4]
    trainLinguisticFeats(fullDir,alignDir,outDir)
else:
    print "Please input a test sentence"
    # sentence =  raw_inpu  t();
    sentence = "Author of the danger trail, Philip Steels, etc."
    a = Festival_fx(sentence);
    print "label file is stored at : "+a[0]
    print "aligned lab file is stored at : "+a[1]

    #Saving the features generated to python array
    ff=Festival_features(lname, hname)
    data = ff.convert_lab_time(a[0])
    time = ff.convert_lab_time_mono(a[1])

    #Featues for full-context lab
    np.savetxt(ownDir+'data.txt',data)
    np.savetxt(ownDir+'time.txt',time)
    print "No of phones - "+str(data.shape[0])
    pp.imshow(data)
    pp.savefig(ownDir+'feats.png')
    # pylab.show()

    ## Frame alignment 
    feats = generateFrameFeats(data,time)
    np.savetxt(ownDir+'feats.txt',feats)





