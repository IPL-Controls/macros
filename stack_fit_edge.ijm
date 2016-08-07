/*
 * Generic extension of single_fit_edge to work for a single image or a stack of images. 
 * Works when a stack of images is already open and a roi is selected.
 * 
 * __author_		=	'Alireza Panna'
 * __version__		=	'1.0'
 * __status__   	=   "stable"
 * __date__			=	03/04/2015
 * __to-do__		=	add progress bar
 * __update-log__	=	3/09/15: LSF and MTF plots are stacked and shown instead of closing them
 * 						3/10/15: some code clean-up. 
 * 						3/11/15: Scan settings are now read using epics plugin
 * 						3/13/15: Scan step is also read from epics plugin, global variable for scan IOC
 * 						3/18/15: Added conditions for generic stack of images but without any sort of scan 
 * 						3/19/15: Changed FWHM vs. pos (mm) fit to third order.
 * 						3/31/15: start and stop are not global variables anymore.
 * 						4/18/15: Changed user dialog display so that only one dialog shows.
 * 						5/05/15: Removed MTF related dialog and stack displays. 
 * 						5/29/15: peak position is also written to txt file. race condition in fit3d if scan step = 0
 */
 
// Global scan ioc pv name 
var SCAN_IOC = "HPFI:SCAN:scan1";
macro "stack_fit_edge" {
	fit_choice = newArray("Gaussian", "Lorentzian");
    edge_choice = newArray("Horizontal", "Vertical");
    scan_choice = newArray("Yes", "No");
    epics_choice = newArray("Yes", "No");
    mtf_norm_choice = newArray("Yes", "No");
    sine_angle = 0;
    pix_size = 0;
    
    Dialog.create("Menu");
	Dialog.addChoice("Choose Edge:", edge_choice, "Horizontal");
    Dialog.addChoice("Choose Fit:", fit_choice, "Gaussian"); 
    Dialog.addChoice("Is this a Scan?", scan_choice, "Yes");
    Dialog.addChoice("Use EPICSIJ?", epics_choice, "No");
    Dialog.show();
    lsf_edge = Dialog.getChoice();
    fit_func = Dialog.getChoice();
    is_scan = Dialog.getChoice();
    is_epics = Dialog.getChoice();
  
	imgname = getTitle(); 
    dir = getDirectory("image");

    args = lsf_edge + " " + fit_func;
    
    if (imgname == "Stack" || nSlices > 1) {    	
    	// array for scan axis
    	z = newArray(nSlices);
    	if (is_scan == "Yes") {
    		Dialog.create("Scan Settings");
			Dialog.addMessage("Update Scan settings:")
			if (is_epics == "Yes") {
				// Use EPICS IJ plugin to read scan1 settings.
				run("EPICSIJ ");
				Dialog.addNumber("start:", Ext.read(SCAN_IOC + ".P1SP"));
				Dialog.addNumber("end:", Ext.read(SCAN_IOC + ".P1EP"));
				Dialog.addNumber("step:", Ext.read(SCAN_IOC + ".P1SI"));
			}
			else {
				Dialog.addNumber("start:", 0);
				Dialog.addNumber("end:", 0);
				Dialog.addNumber("step:", 0);
			}
			Dialog.show();
			start = parseFloat(Dialog.getNumber());
			end = parseFloat(Dialog.getNumber());
			step = parseFloat(Dialog.getNumber());
			if (step == 0) {
    			step = abs((end - start)/(nSlices - 1));
			}
			// Create the scan axis
			temp = start;
 			for(i = 1; i <= z.length; i++) {	
     	  		z[i-1] = temp;
     	  		temp = temp + step;
 			}	 
    	}
    	else {
    		// no scan but still a stack 
    		for(i = 1; i <= z.length; i++) {	
     	  		z[i-1] = "N/A";
 			}	 	
    	}
    	fwhm = newArray(nSlices);
    	contrast = newArray(nSlices);
    	mean = newArray(nSlices);
    	// put all plots in their seperate respective stacks
    	lsf_stack = 0;
    	for (i = 1; i <= nSlices; i++) {
    		setSlice(i);
    		d = runMacro("single_fit_edge", args);
  	 		selectWindow("LSF");
  	 		w = getWidth;
  	 		h = getHeight;
  	 		run("Copy");
    		close();
        	if (lsf_stack==0) {
            	newImage("LSF Plots", "8-bit", w, h, 1);
            	lsf_stack = getImageID;
        	} 
        	else {
            	selectImage(lsf_stack);
            	run("Add Slice");
        	}
        	run("Paste");
    		sp = split(d, " ");
    		fwhm[i-1] = sp[0];
    		contrast[i-1] = sp[1];
    		mean[i-1] = sp[2];
    		selectImage(imgname);
     	}	
		if (is_scan == "Yes") {
			// plot fwhm and contrast vs. scan axis
			opt_peakz = plot3d(z, contrast);
			close();
 			opt_fwhmz = plot3d(z, fwhm);	
 			print("Optimum z-position (mm) from fwhm:", opt_fwhmz);
		}
		// write results to file
		f = File.open(dir + "edge_widths_contrast" + ".txt");
		print(f, "FWHM (pixel)" + "\t" + "Contrast (pixel)" + "\t" + "Peak position (pixel)" + "\t" + "z (mm)"); 
    	writeFile(f, z, fwhm, contrast, mean);
    }
    else {
    	// no stack condition
    	d = runMacro("single_fit_edge", args);
    }
    setBatchMode("exit and display");
	waitForUser("Information", " Edge Fit Completed");
}
// Seperate plotting routine for 2nd order fitting
function plot3d(z, val) {
	Fit.doFit(2, z, val);
 	Fit.plot();
 	a = Fit.p(0);
	b = Fit.p(1);
	c = Fit.p(2);
	d = Fit.p(3);	
	// Find critical point as long as not imaginary
	if ((4* c * c - 12 * b * d) >= 0) {
		opt_pos = (-2 * c + 2 * sqrt(c * c - 3 * b * d))/(6 * d);
		opt_neg = (-2 * c - 2 * sqrt(c * c - 3 * b * d))/(6 * d);
		// Case 1
		if (start > end) {
			if (opt_pos <= start && opt_pos >= end) {
				opt = opt_pos;
			}
			else {
				opt = opt_neg;
			}
		}
		// Case 2
		else if (start < end) {
			 if (opt_pos >= start && opt_pos <= end) {
				opt = opt_pos;
			}
			else {
				opt = opt_neg;
			}
		}
	}
	else {
		opt = "NAN";
	}	
	if(step == 0) {
		opt = 0;
	}
	// return the critical point
	return opt;
}
// Seperate write to file routine
function writeFile(f, x, y, p, m) {
    xx = "";
    yy = "";
    pp = "";
    mm = "";
    zz = "";
    z = 0;
    while(z < x.length) {
    	xx = toString(x[z]) + "\n";
    	yy = toString(y[z]) + "\t";
    	pp = toString(p[z]) + "\t";
    	mm = toString(m[z]) + "\t";
    	zz = yy + pp + mm + xx;
    	z++;
	    print(f, zz);
	}
}
