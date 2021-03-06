/*
 * Generic extension of single_find_resolution.ijm to work for a single image or a stack of images. 
 * Works when a stack of images is already open and a roi is selected.
 * 
 * __author_		=	Alireza Panna
 * __version__		=	1.1
 * __status__   	=   stable
 * __date__			=	03/04/2015
 * __to-do__		=	add progress bar
 * __update-log__	=	08/10/16: Updated to work for profile or edge derivative fits depending on user choice. 
 * 								  Added option for Pseudo Voigt fitting. Fixed bug in stacking algorithm for fit
 * 								  plots. Update to 1.1 and renamed to stack_find_resolution from stack_find_edge.
 * 								  stack_find_edge is now deprecated.
 * 						08/11/16: Plot stack is now displayed in RGB.
 * 						09/23/16: Added peak height column to edge_widths_contrast.txt. Peak height is displayed as abs(peak).
 * 						10/30/16: Allow for roi xy translation for image stacks.
 * 						11/21/16: Fix bug in roi translation, save fit plots stack
 * 						11/29/16: (HW) Change ROI translate so that it is no longer relative	
 * 						           to previous image in stack. This also fixes a rounding error bug. 
 */
 
// Global scan ioc pv name 
var SCAN_IOC = "HPFI:SCAN:scan1";
macro "stack_find_resolution" {
	type_choice = newArray("Profile", "Edge");
	fit_choice = newArray("Gaussian", "Lorentzian", "Pseudo-Voigt");
    profile_choice = newArray("Horizontal", "Vertical");
    scan_choice = newArray("Yes", "No");
    epics_choice = newArray("Yes", "No");
  	args = "";
	imgname = getTitle(); 
	imgID = getImageID();
    dir = getDirectory("image");
    if (nSlices == 1) {
    	// no stack condition
  		d = runMacro("single_find_resolution", args);
  		sp = split(d, " ");
    	fwhm = sp[0];
    	contrast = sp[1];
    	mean = sp[2];
    	peak = sp[3];
    	fit_func = sp[4];
    	waitForUser("Information", fit_func + " Fit Completed");
    }
    else if (nSlices > 1) {
    	Dialog.create("Menu");
    	Dialog.addChoice("Fit type:", type_choice, "Profile");
		Dialog.addChoice("Profile Direction:", profile_choice, "Horizontal");
    	Dialog.addChoice("Fit Function:", fit_choice, "Gaussian"); 
    	Dialog.addChoice("Is this a Scan?", scan_choice, "No");
    	Dialog.addChoice("Use EPICSIJ?", epics_choice, "No");
    	Dialog.addNumber("ROI translate X", 0, 0, 5, "pixels");
    	Dialog.addNumber("ROI translate Y", 0, 0, 5, "pixels");
    	Dialog.show();
    
    	fit_type = Dialog.getChoice();
    	prof_dir = Dialog.getChoice();
    	fit_func = Dialog.getChoice();
    	is_scan = Dialog.getChoice();
    	is_epics = Dialog.getChoice();
    	roi_x = Dialog.getNumber();
 		roi_y = Dialog.getNumber();
 		args = fit_type + " " + prof_dir + " " + fit_func;
 		
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
    	peak = newArray(nSlices);
    	// put all plots in their seperate respective stacks
    	profile_stack = 0;
    	Roi.getBounds(upper_left_x, upper_left_y, width_roi, height_roi);
    	for (i = 1; i <=nSlices; i++) {
    		selectImage(imgname);
    		setSlice(i);
    		// translate roi
			Roi.move(upper_left_x + roi_x * (i-1), upper_left_y + roi_y * (i-1));
    		d = runMacro("single_find_resolution", args);
  	 		selectWindow(fit_func + " Fit");
  	 		w = getWidth;
  	 		h = getHeight;
  	 		run("Copy");
    		close();
        	if (profile_stack == 0) {
            	newImage(fit_func + " Fit Plots", "RGB", w, h, 1);
            	profile_stack = getTitle();
            	selectImage(profile_stack);
            	run("Paste");
        	} 
        	else {
            	selectImage(profile_stack);
            	run("Add Slice");
            	run("Paste");
        	}
        	
    		sp = split(d, " ");
    		fwhm[i-1] = sp[0];
    		contrast[i-1] = sp[1];
    		mean[i-1] = sp[2];
    		peak[i-1] = sp[3];
    		fit_func = sp[4];
    		selectImage(imgname);
    	}
		if (is_scan == "Yes") {
			// plot fwhm and contrast vs. scan axis
			opt_peakz = plot3d(z, contrast);
			close();
 			opt_fwhmz = plot3d(z, fwhm);	
 			print("Optimum position from fwhm:", opt_fwhmz);
		}
		// write results to file
		if (dir == getDirectory("imagej")) {
    		dir = getDirectory("Select Output Directory");
    	}
		f = File.open(dir + "edge_widths_contrast" + ".txt");
		print(f, "FWHM (pixel)" + "\t" + "Contrast (DN)" + "\t" + "Peak position (pixels)" + "\t"  + "Peak height (DN)" + "\t" + "Scan Axis"); 
    	writeFile(f, z, fwhm, contrast, mean, peak);
    	selectImage(fit_func + " Fit Plots");
    	saveAs("tiff", dir + File.separator + fit_func + " Fit Plots");
    	waitForUser("Information", fit_func + " Fits Completed");

    }
    else {
    	waitForUser("Unknown format!");
    }
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
function writeFile(f, x, y, p, m, a) {
    xx = "";
    yy = "";
    pp = "";
    mm = "";
    aa = "";
    zz = "";
    z = 0;
    while(z < x.length) {
    	xx = toString(x[z]) + "\n";
    	yy = toString(y[z]) + "\t";
    	pp = toString(p[z]) + "\t";
    	mm = toString(m[z]) + "\t";
    	aa = toString(a[z]) + "\t";
    	zz = yy + pp + mm + aa + xx;
    	z++;
	    print(f, zz);
	}
}