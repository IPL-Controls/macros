# -*- coding: utf-8 -*-
"""
"""
__author__          =   "Alireza Panna"
__email__           =   "apanna1236@gmail.com"
__status__          =   "Stable"
__date__            =   "05/04/15"
__version__         =   "1.0"
   
CAM_PIXSIZE = 0.083
ANGLE = 90
DETECTOR = "Varian"

import easygui
import numpy as np
import os
import matplotlib.pyplot as py
import scipy.optimize, scipy.special, scipy.stats
import xlwt
from mpltools import color
from Tkinter import *
import tkSimpleDialog

class MyDialog(tkSimpleDialog.Dialog):
    """
    Displays dialog to get input parameters
    """
    def body(self, master):
        Label(master, text="Detector:").grid(row=0, sticky=W)
        Label(master, text="Pixel Size (mm):").grid(row=1, sticky=W)
        Label(master, text="Incidence angle (deg):").grid(row=2, sticky=W)
    
        self.e1 = Entry(master)
        self.e2 = Entry(master)
        self.e3 = Entry(master)
    
        self.e1.grid(row=0, column=1)
        self.e2.grid(row=1, column=1)
        self.e3.grid(row=2, column=1)
        
    def apply(self):
        global DETECTOR, ANGLE, CAM_PIXSIZE
        DETECTOR = self.e1.get()
        CAM_PIXSIZE = float(self.e2.get())
        ANGLE = float(self.e3.get())

"""
A gaussian peak with:
Offset                      : p[0]
baseline                    : p[1]
Amplitude                   : p[2]
Mean                        : p[3]
Standard deviation          : p[4]
"""
gaussian    =   lambda x, *p: -p[0]-p[1]*x+\
                              p[2]*np.exp(-(x-p[3])**2/(2*p[4]**2))

def write_excel(c, list1, list2, title):
    """
    Writes to excel (.xls) spreadsheet
    """
    if c != 0:
        c += 2*c  
    sh.write(0, c, title)
    sh.write(1, c, 'freq (1/mm)')
    sh.write(1, c+1, 'MTF')
    sh.write(1, c+2 ,  ' ')
    
    for row, f in enumerate(list1):
        sh.write(row + 2, c, f)
    for row, m in enumerate (list2):
        sh.write(row + 2, c + 1, m)
    
def lsf_fft(Fs, lsf):
    """
    Returns the modulation transfer function (MTF)
    Single sided Amplitude spectrum of the LSF
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
    Fk = Fk[range(n/2)]
    return np.abs(Fk), frq

if __name__ == '__main__':
    root = Tk()
    root.withdraw()
    MyDialog(root)   
    book = xlwt.Workbook()
    sht_name = DETECTOR + '_' + str(ANGLE)
    sh = book.add_sheet(sht_name)
    
    file_path = easygui.fileopenbox(msg='Select LSF file', title="", \
                                    default="", filetypes=["*.txt"])   
    dirname = file_path.rsplit('\\', 1)[0]
    fname = file_path.split('\\')[-1].split('.')[0]
    my_files = [file_path.split('\\')[-1]]
    save_dir = dirname + '/' + 'single_fit_mtf_results'

    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
        
    my_raw_lsf = []
    temp_raw_lsf = []
    my_samples = []
    my_corr_lsf = []
    mtf_fit = []

    # plot conditioning
    n_lines = len(my_files)
    color.cycle_cmap(n_lines)
    fig_final = py.figure('MTF Vs. frequency', dpi=80, facecolor="0.98")
    ax = fig_final.add_subplot(111)
    # Change color cycle specifically for `ax`
    color.cycle_cmap(n_lines, cmap='hot', ax=ax)

    for ct, i in enumerate(my_files):
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
            my_mtf, freq = lsf_fft(1/(float(CAM_PIXSIZE) * np.sin(ANGLE*np.pi/180)), my_raw_lsf)
        # switch to array         
        my_mtf = np.array(my_mtf)
        freq = np.array(freq)
        write_excel(ct, freq, my_mtf, sht_name) 
        # Estimate the intial guess for the fit functions
        sy = np.sum(my_mtf)
        mean = np.sum((my_mtf*freq)/sy)
        sig2 = np.sum((my_mtf/(sy))* \
                     (freq-mean)*(freq-mean))
        sig = np.sqrt(sig2)
        peak = my_mtf[np.argmax(my_mtf)]
        fwhm = np.abs(2*np.sqrt(2*np.log(2))*sig)
        # Gaussian fit
        p_guess = [0, 0, peak, mean, sig]
        try:
            popt, pcov = scipy.optimize.curve_fit(gaussian,\
            freq, my_mtf, p_guess, \
            maxfev=1000*(len(freq)+1))
        except:
            popt, pcov = p_guess, None
        for i in gaussian(freq, *popt):
            mtf_fit.append(i)
                          
        ax.plot(freq, my_mtf, 'k^')
        ax.plot(freq, np.array(mtf_fit), 'k-', \
        label= str(DETECTOR) + " " + str(ANGLE) + ' deg', linewidth = 1.75)  
        # clean up
        my_samples = []
        temp_raw_lsf = []
        my_raw_lsf = []   
        mtf_fit = []

    ax.legend(loc='upper right')
    ax.set_ylim(0, )
    ax.set_xlim(0, )
    ax.spines['right'].set_color('none')
    ax.spines['top'].set_color('none')
    ax.xaxis.set_ticks_position('bottom')
    ax.spines['bottom'].set_position(('axes', -0.0))
    ax.yaxis.set_ticks_position('left')
    ax.spines['left'].set_position(('axes', -0.0))
    ax.xaxis.grid(True, which='major', color='gray', linestyle='--')
    ax.yaxis.grid(True, which='major', color='gray', linestyle='--')
    ax.set_ylabel('MTF (a.u)', fontsize=14)
    ax.set_xlabel('f (cycles/mm)', fontsize=14)
    py.tight_layout()    
    fig_final.savefig(save_dir + '/' + fname.replace("LSF", "MTF") + '.tiff', \
                 bbox_inches='tight')
    book.save(save_dir + '/' + fname.replace("LSF", "MTF") + '.xls')
    print "Analysis Complete!"
    py.show()
    

