# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
"""
"""
# global variables
DOSIMETER_CALIBRATION = 1.272565431

__author__          =   "Alireza Panna"
__email__           =   "apanna1236@gmail.com"
__status__          =   "Development"
__date__            =   "05/01/15"
__version__         =   "1.0"

import easygui
import numpy as np
import os
import matplotlib.pyplot as py
from matplotlib.ticker import MaxNLocator
import Tkinter, tkFileDialog

# plot routine
fig_final = py.figure('MTF', dpi=80, facecolor="0.98")
ax = fig_final.add_subplot(111)

# lets get the parameter file first
param_file = easygui.fileopenbox("Select the parameter file")
my_param_file = open(param_file, 'r')
tit = []
value = []
for lines in my_param_file:
    val = lines.split('=')
    tit.append(val[0])
    value.append(val[1].split('\n')[0])

cam_pixsize = value[0]
source_cam_distance = value[1]
mAs_to_mGy = value[2]
mAs_mGy_conv_factor = 88221.131539 * (1/source_cam_distance**2)



# now for raw mtf file
root = Tkinter.Tk()
root.withdraw()
dirname = tkFileDialog.askdirectory(parent=root,initialdir="/",title='Select the MTF file directory')
print os.listdir(dirname)
my_files = []
for files in os.listdir(dirname):
    if files.split('.')[-1]  == 'txt' and files.split('.')[0] != 'param':
        my_files.append(files)

#bp = os.getcwd()
# make a seperate figures directory to save the final plot
#if not os.path.exists('Figures'):
#    os.makedirs('Figures')
    
# open all files in directory.
my_raw_mtf = []
temp_raw_mtf = []
my_freq = []
my_corr_mtf = []

for i in my_files:
    print "Opening", i
    my_file = open( dirname + '/' + str(i), 'r')
    for lines in my_file:
        my_freq.append((lines.split('\t')[0]))
        temp_raw_mtf.append(lines.split('\t')[1])
    
    my_file.close()
    # pop the headers
    temp_raw_mtf.pop(0)
    my_freq.pop(0)

    for lines in temp_raw_mtf:
        my_raw_mtf.append(float(lines.split('\n')[0]))
        
    for i in my_raw_mtf:
        my_corr_mtf.append(mAs*mAs_to_mGy*sin_phos)
    ax.plot(my_freq, my_raw_mtf, 'bo')

    my_freq = []
    temp_raw_mtf = []
    my_raw_mtf = []     
    
ax.spines['right'].set_color('none')
ax.spines['top'].set_color('none')
ax.xaxis.set_ticks_position('bottom')
ax.spines['bottom'].set_position(('axes', -0.0))
ax.yaxis.set_ticks_position('left')
ax.spines['left'].set_position(('axes', -0.0))
ax.xaxis.grid(False)
ax.yaxis.grid(False)
ax.set_ylabel('DTF (mGy)', fontsize=18)
ax.set_xlabel('f (cycles/mm)', fontsize=18)
py.tight_layout()      
py.show()       
#fig_final.savefig(bp+'\\'+'Figures\\' +'mtf_dose_compare' + '.tiff', \
#                 bbox_inches='tight')
print "Analysis Complete"



