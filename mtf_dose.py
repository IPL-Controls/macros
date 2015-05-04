# -*- coding: utf-8 -*-
"""
"""

__author__          =   "Alireza Panna"
__email__           =   "apanna1236@gmail.com"
__status__          =   "Development"
__date__            =   "05/01/15"
__version__         =   "1.0"

# global parameter variables
DOSIMETER_CALIBRATION = 1.272565431
CAM_PIXSIZE = 0.083
SOURCE_CAM_DISTANCE = 559.6
MAS = 2
MAS_TO_MGY_FACTOR = 88221.131539 * (1/SOURCE_CAM_DISTANCE**2) # mGy/mAs
GAIN = 6.224957 # e/DN
ANGLE = [10.0294, 15.0294, 20.0294, 30.0294, 4.1594, 5.0294] # current angles
DOSE = MAS * MAS_TO_MGY_FACTOR / DOSIMETER_CALIBRATION # mGy

import easygui
import numpy as np
import os
import matplotlib.pyplot as py
import Tkinter, tkFileDialog
import scipy.optimize, scipy.special, scipy.stats
import fits
import xlwt


book = xlwt.Workbook()
def output(filename, sheet, list1, list2):
    
    sh = book.add_sheet(sheet)
    print "Writing to", sheet
    for row, f in enumerate(list1):
        sh.write(row, 0, f)
    for row, m in enumerate (list2):
        sh.write(row, 1, m)
    
def lsf_fft(Fs, lsf):
        """
        Returns the modulation transfer function (MTF)
        Single sided Amplitude  spectrum of the LSF
        """
        # LSF signal
        fx = np.array(lsf)
        # Length of the signal
        n= len(fx)
        # x counts
        k = np.arange(n)
        # Sampling period
        T = n/Fs
        frq = k/T
        # One sided range
        frq = frq[range(n/2)]
        Fk = np.fft.fft(fx) 
#        print Fk
#        print abs(Fk)
#        print np.abs(Fk)
        Fk = Fk[range(n/2)]
        return np.abs(Fk), frq

# lets get the parameter file first
#param_file = easygui.fileopenbox("Select the parameter file")
#my_param_file = open(param_file, 'r')
#tit = []
#value = []
#for lines in my_param_file:
#    val = lines.split('=')
#    tit.append(val[0])
#    value.append(val[1].split('\n')[0])

# now for raw LSF file
root = Tkinter.Tk()
root.withdraw()
dirname = tkFileDialog.askdirectory(parent=root, initialdir="/", title='Select the MTF file directory')
# make a seperate results directory to save the final plot and raw data for debugging
save_dir = dirname + '/' + 'Results'
if not os.path.exists(save_dir):
    os.makedirs(save_dir)
my_files = []
for files in os.listdir(dirname):
    root, ext = os.path.splitext(files)
    if root.startswith('LSF') and ext == '.txt':
        my_files.append(files)

# open all files in directory.
my_raw_lsf = []
temp_raw_lsf = []
my_samples = []
my_corr_lsf = []
col = ['bo' ,'ro', 'ko', 'co', 'mo', 'yo', 'go', 'k^', 'g^']
col_fit = ['b-' ,'r-', 'k-', 'c-', 'm-', 'y-', 'g-', 'brown', 'orange']
my_corr_mtf = []
mtf_fit = []

# plot routine
fig_final = py.figure('MTF', dpi=80, facecolor="0.98")
ax = fig_final.add_subplot(111)
ct = 0
for i in my_files:
    print "Opening", i
    my_file = open( dirname + '/' + str(i), 'r')
    for lines in my_file:
        my_samples.append((lines.split('\t')[0]))
        temp_raw_lsf.append(lines.split('\t')[1])
    my_file.close()
    # pop the headers
    temp_raw_lsf.pop(0)
    my_samples.pop(0)
    for lines in temp_raw_lsf:
        my_raw_lsf.append(float(lines.split('\n')[0]))
    # Varian 90 degree case
    if i == 'LSF50kV2s500mA90deg_000.txt':
        my_mtf, freq = lsf_fft(1/(0.083*np.sin(90*np.pi/180)), my_raw_lsf)
        MAS_TO_MGY_FACTOR = 88221.131539 * (1/399.64**2) # mGy/mAs
        dose = 1 * MAS_TO_MGY_FACTOR / 1.272565431 # mGy
        for var in my_mtf:
            my_corr_mtf.append((GAIN/((CAM_PIXSIZE * CAM_PIXSIZE * np.sin(90 * np.pi/180)) * dose * 1e3)) * var)
    # D800 back lit case
    elif i == 'LSF90degD800_DFCORR_50kV_ISO6400_D800_GdOs400_2x50mmAf2-0.txt':
        my_mtf, freq = lsf_fft(1/(0.01726 * np.sin(90*np.pi/180)), my_raw_lsf)
        for dbl in my_mtf:
            my_corr_mtf.append((0.057/((0.01726 * 0.01726 * np.sin(90 * np.pi/180))  * 0.0613 * 1e3)) * dbl)
        print my_corr_mtf
    # D800 front lit case
    elif i == 'LSF50kV5s1mAISO6400_10.txt' :
        my_mtf, freq = lsf_fft(1/(0.01726 * 3 * np.sin(4.13*np.pi/180)), my_raw_lsf)
        MAS_TO_MGY_FACTOR = 88221.131539 * (1/767**2) # mGy/mAs
        dose = 5 * MAS_TO_MGY_FACTOR / 1.272565431 # mGy
        for d1 in my_mtf:
            my_corr_mtf.append((0.057467768/((0.01726*3 * 0.01726*3 * np.sin(4.13 * np.pi/180)) * 0.5892 * 1e3)) * d1) 
    else:
        my_mtf, freq = lsf_fft(1/(CAM_PIXSIZE * np.sin(ANGLE[ct]*np.pi/180)), my_raw_lsf)
        for j in my_mtf:
            my_corr_mtf.append((GAIN/((CAM_PIXSIZE * CAM_PIXSIZE * np.sin(ANGLE[ct] * np.pi/180)) * DOSE * 1e3)) * j)
            
    my_corr_mtf = np.array(my_corr_mtf)
    freq = np.array(freq)
    output(save_dir + '/' + 'MTFResults', i.split('_')[0], freq, my_corr_mtf)
   
    # Estimate the intial guess for the fit functions
    sy = np.sum(my_corr_mtf)
    mean = np.sum((my_corr_mtf*freq)/sy)
    sig2 = np.sum((my_corr_mtf/(sy))* \
               (freq-mean)*(freq-mean))
    sig = np.sqrt(sig2)
    peak = my_corr_mtf[np.argmax(my_corr_mtf)]
    fwhm = np.abs(2*np.sqrt(2*np.log(2))*sig)
    p_guess = [0, 0, peak, mean, sig]
    try:
        popt, pcov = scipy.optimize.curve_fit(fits.gaussian,\
        freq, my_corr_mtf, p_guess, \
        maxfev=1000*(len(freq)+1))
    except:
        popt, pcov = p_guess, None
    for i in fits.gaussian(freq, *popt):
            mtf_fit.append(i)
    ax.plot(freq, my_corr_mtf, col[ct])
    ax.plot(freq, np.array(mtf_fit), col_fit[ct], label= str(my_files[ct].split('.')[0]), linewidth = 2)
    
    # clean up
    my_samples = []
    temp_raw_lsf = []
    my_raw_lsf = [] 
    my_corr_mtf = []    
    mtf_fit = []
    ct += 1

ax.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
ax.legend(loc='upper right')
ax.set_ylim(0, )
ax.spines['right'].set_color('none')
ax.spines['top'].set_color('none')
ax.xaxis.set_ticks_position('bottom')
ax.spines['bottom'].set_position(('axes', -0.0))
ax.yaxis.set_ticks_position('left')
ax.spines['left'].set_position(('axes', -0.0))
ax.xaxis.grid(False)
ax.yaxis.grid(False)
ax.set_ylabel('MTF (e/uGy/mm^2)', fontsize=14)
ax.set_xlabel('f (cycles/mm)', fontsize=14)
py.tight_layout()    
fig_final.savefig(save_dir + '/' + 'mtf_dose_compare' + '.tiff', \
                 bbox_inches='tight')
book.save(save_dir + '/' + 'MTFResults' + '.xls')
print "Analysis Complete"

