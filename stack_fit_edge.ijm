/*
 * Generic extension of single_fit_edge to work for a stack of images.
 * 
 * __author_		=	'Alireza Panna'
 * __version__		=	'1.0'
 * __status__   	=   "stable"
 * __date__			=	03/04/2015
 * __to-do__		=	1. Change the fit order to third for better fitting.
 * __update-log__	=	3/09/2015: LSF and MTF plots are stacked and shown instead of closing them
 * 						3/10/2015: some code clean-up. 
 * 						3/11/2015: Scan settings are now read using epics plugin
 * 						3/13/2015: Scan step is also read from epics plugin, global variable for scan IOC
 */
 
// Global scan ioc pv name 
var SCAN_IOC = "ampstep:scan1";
macro "stack_fit_edge" {
	fit_choice = newArray("Gaussian", "Lorentzian");
    edge_choice = newArray("Horizontal", "Vertical");
    Dialog.create("Menu");
	Dialog.addChoice("Choose Edge:", edge_choice, "Horizontal");
    Dialog.addChoice("Choose Fit:", fit_choice, "Gaussian"); 
    Dialog.show();
    lsf_edge = Dialog.getChoice();
    fit_func = Dialog.getChoice();
    args = lsf_edge + " " + fit_func;
    
	imgname = getTitle(); 
    dir = getDirectory("image");
    if (imgname == "Stack"){
    	run("EPICSIJ ");
    	Dialog.create("Scan Settings");
		Dialog.addMessage("Update Scan settings:")
		// Use EPICS IJ plugin to read scan1 settings.
		Dialog.addNumber("start:", Ext.read(SCAN_IOC + ".P1SP"));
		Dialog.addNumber("end:", Ext.read(SCAN_IOC + ".P1EP"));
		Dialog.addNumber("step:", Ext.read(SCAN_IOC + ".P1SI"));
		Dialog.show();
		start = parseFloat(Dialog.getNumber());
		end = parseFloat(Dialog.getNumber());
		step = parseFloat(Dialog.getNumber());
		if (step == 0) {
    		step = abs((end - start)/(nSlices - 1));
		}
    	
    	y = newArray(nSlices);
    	x = newArray(nSlices);
    	p = newArray(nSlices);
    	// put all plots in their seperate respective stacks
    	mtf_stack = 0;
    	lsf_stack = 0;
    	for (i = 1; i <= nSlices; i++) {
    		setSlice(i);
    		d = runMacro("single_fit_edge", args);
    		selectWindow("MTF");
  	 		run("Copy");
  	 		w = getWidth;
  	 		h = getHeight;
  	 		close();
  	 		if (mtf_stack==0) {
            	newImage("MTF Plots", "8-bit", w, h, 1);
            	mtf_stack = getImageID;
        	} 
        	else {
            	selectImage(mtf_stack);
            	run("Add Slice");
        	}
        	run("Paste");
  	 		selectWindow("LSF");
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
    		y[i-1] = sp[0];
    		p[i-1] = sp[1];
    		selectImage(imgname);
     	}
		temp = start;
 		for(i = 1; i <= x.length; i++) {	
     	  	x[i-1] = temp;
     	  	temp = temp + step;
 		}	 
 		opt_fwhmz = plot2d(x, y);
 		opt_peakz = plot2d(x, p);
 		
		f = File.open(dir + "edge_widths_contrast" + ".txt");
    	print(f, "FWHM (pixel)" + "\t" + "Contrast (pixel)" + "\t" + "z (mm)"); 
    	writeFile(f, x, y, p);
	    print("Optimum z-position (mm) from fwhm:", opt_fwhmz);
	//    print("Optimum z-position (mm) from peak:", opt_peakz);
    }
    else {
    	d = runMacro("single_fit_edge", args);
    }	
}
// Seperate plotting routine for 2nd order fitting
function plot2d(x, val) {
	Fit.doFit(1, x, val);
 	Fit.plot();
 	a = Fit.p(0);
	b = Fit.p(1);
	c = Fit.p(2);	
	opt = -b/(2 * c);
	// return the critical point
	return opt;
}
// Seperate write to file routine
function writeFile(f, x, y, p) {
    xx = "";
    yy = "";
    pp = "";
    zz = "";
    z = 0;
    while(z < x.length) {
    	xx = toString(x[z]) + "\n";
    	yy = toString(y[z]) + "\t";
    	pp = toString(p[z]) + "\t";
    	zz = yy + pp + xx;
    	z++;
	    print(f, zz);
	}
	close();
}

