/* 
 *  Finds MTF and LSF from edge profile and offer a choice for either Gaussian
 *  or Lorentzian fit. Return the FWHM of the LSF profile. Adapted from macro 
 *  single_edge_horizontal.ijm. Works for both horizontal and vertical edges. 
 *  Works when image is open and roi is selected.
 *  
 *  __author__			=	'Alireza Panna'
 *  __status__          =   "stable"
 *  __date__            =   "2/27/15"
 *  __version__         =   "1.0"
 *  __to-do__			=				   
 *  __update-log__		= 	3/08/15: Now returns contrast information (edge response height) as area under gaussian LSF curve
 *  						3/10/15: added mtf capability, edge step height evaluation in terms of Lorentzian LSF fit area.
 *  						3/13/15: prints contrast count as well.
 *  						3/18/15: Decided not to normalize mtf for now. (Dr. Wens suggestion)
 *  						3/19/15: Added function makeFancy to make the mtf plots look nicer
 *  						3/25/15: Fixed normalization issue of mtf. Raw mtf should give proper contrast values now.
 *  						3/30/15: Added method for % roi selected in image to be printed in log
 *  						3/31/15: MTF is normalized now. 
 *  						5/05/15: Moved MTF algorithm to py script. Removed from here. 
 *  						5/29/15: Renamed return variables for better code reading. Macro also returns peak position now. 
 */
 
requires("1.49i");
macro "single_fit_edge" {
	imgname = getTitle(); 
	// remove .tif
	imgname_split = split(imgname,".");
    dir = getDirectory("image");
    // get input argument if any
	args = getArgument();
	if (args == "") {
		// Display dialog if fit and edge choice are not already pre-defined.
		fit_choice = newArray("Gaussian", "Lorentzian");
    	edge_choice = newArray("Horizontal", "Vertical");
  		Dialog.create("Menu");
		Dialog.addChoice("Choose Edge:", edge_choice, "Horizontal");
  		Dialog.addChoice("Choose Fit:", fit_choice, "Gaussian"); 
  		Dialog.show();
  		lsf_edge = Dialog.getChoice();
    	fit_func = Dialog.getChoice();
	}
	else {
		// use the setting from stack_fit_edge.ijm
		arr = split(args, " ");
		lsf_edge = arr[0];
    	fit_func = arr[1];
	}
	imgname = getTitle(); 
	// Remove scaling
	run("Set Scale...", "distance=0 global");
	// Find percent roi selected
	getSelectionBounds(upper_left_x, upper_left_y, width_roi, height_roi);
	width_image = getWidth();
	height_image = getHeight();
	area_image = width_image * height_image;
	area_roi = width_roi * height_roi;
	per_sel = (area_roi/area_image) * 100;
    // Plot ESF profile, get values and close profile
	if (lsf_edge == "Vertical") {
		setKeyDown("ctrl");
	}
	else {
    	setKeyDown("alt"); 
	}
	run("Plot Profile");
	Plot.getValues(x, y);
    close();
    // Get derivative (raw LSF) (y[i+1]-y[i-1])/2;    
    npts = x.length;
    deriv = newArray(npts);
    deriv_nocorr = newArray(npts);
    derivneg = newArray(npts);
    // force tails of LSF to go to 0 for finite roi
    deriv[0] = 0;
    deriv[npts-1] = 0;
    for(i = 1; i < npts - 1; i++) {
    	deriv[i] = (parseFloat(y[i+1]) - parseFloat(y[i-1]))/2;
    	deriv_nocorr[i]  = deriv[i];
    }
	// Linear baseline correction
    x0 = (x[1] + x[2] + x[3] + x[4])/4;
    deriv0 = (deriv[1] + deriv[2] + deriv[3] + deriv[4])/4;
    x1 = (x[npts - 2] + x[npts - 3] + x[npts - 4] + x[npts - 5])/4;
    deriv1 = (deriv[npts - 2] + deriv[npts - 3] + deriv[npts - 4] + deriv[npts - 5])/4;
    slope = (deriv1 - deriv0)/(x1 - x0);
    offset = (deriv0 * x1 - deriv1 * x0)/(x1 - x0);
    // Following is baseline corrected LSF
    for(i = 1; i < npts - 1; i++) {
    	deriv[i] = deriv[i] - offset - slope * x[i];
    }
    for(i = 1; i < npts - 1; i++) {
    	derivneg[i] = -deriv[i];
    }
    // write lsf results to file
	file_lsf = File.open(dir + "LSF" + imgname_split[0] + ".txt");
	print(file_lsf, "samples (n)" + "\t" + "Raw LSF (d(DN)/dn)"); 
    
    // LSF fitting routine (Always do gaussian fit and use gauss fit parameters to guess lorentzian fit parameters)
    deriv_gauss_fit = Fit.doFit("Gaussian", x, deriv);
    rsqpos = Fit.rSquared();   
    Fit.doFit("Gaussian", x, derivneg);
    rsqneg = Fit.rSquared();
    if(rsqpos > rsqneg) {
    	writeFile(file_lsf, x, deriv);
    	Fit.doFit("Gaussian", x, deriv);
    	off_g = Fit.p(0);
    	mean_g = Fit.p(2);
    	peak_g = Fit.p(1) - Fit.p(0);
    	width_g = Fit.p(3);
    	// LSF fwhm
    	FWHM_g = 2 * sqrt(2 * log(2)) * width_g;
    	// This is the contrast (I_max - I_min) in terms of ESF step height 
    	area_g = sqrt(2 * PI) * peak_g * width_g;
    }
	else {
		writeFile(file_lsf, x, derivneg);	
    	Fit.doFit("Gaussian", x, derivneg);
    	off_g = Fit.p(0);
    	mean_g = Fit.p(2);
    	peak_g = Fit.p(1) - Fit.p(0);
    	width_g = Fit.p(3);
    	// LSF fwhm
    	FWHM_g = 2 * sqrt(2 * log(2)) * width_g;
    	// This is the contrast (I_max - I_min) in terms of ESF step height 
    	area_g = sqrt(2 * PI) * peak_g * width_g;
    }           
    if (fit_func == "Gaussian") {
    	Fit.plot();
    	FWHM = FWHM_g;
    	AREA = abs(area_g);
    	MEAN = mean_g;
    	rename("LSF");
	}
	if (fit_func == "Lorentzian") {
	// Define the Lorentzian fit function to use
		/* a = Amplitude
		 * b = mean 
		 * c = FWHM
		 */ 
		Lorentzian = "y = (a/4)*(c*c)*(1/((x-b)*(x-b)+(c/2)*(c/2)))";
		// Calculate initial guesses. Currently getting guess from gaussian fit parameters.
     	initialGuesses = newArray(peak_g, mean_g, FWHM_g);
		Fit.doFit(Lorentzian, x, deriv, initialGuesses);
		rsqpos = Fit.rSquared();
		Fit.doFit(Lorentzian, x, derivneg, initialGuesses);
		rsqneg = Fit.rSquared();
    	if(rsqpos > rsqneg) {
    		Fit.doFit(Lorentzian, x, deriv, initialGuesses);
    	} 
    	else {
    		Fit.doFit(Lorentzian, x, derivneg, initialGuesses);
    	}    
    	Fit.plot();
    	rename("LSF");
    	peak_l = Fit.p(0);
    	mean_l = Fit.p(1);
    	FWHM_l = Fit.p(2);
    	area_l = (abs(peak_l) * abs(FWHM_l)) * ((PI/2));//-atan(-2*mean_l/abs(FWHM_l)));
    	FWHM = abs(FWHM_l);
    	AREA = abs(area_l);
    	MEAN = mean_l;
	}

	print(fit_func + " " + lsf_edge + " Edge FWHM" + ":", FWHM + " pixels");
	print("Contrast" + ":", AREA + " DN");
	print("ROI (W x H): " + toString(width_roi) + " x " + toString(height_roi) + " pixels"); 
	print(toString(per_sel) + " % " +  "of total image selected!");
	print("---------------------------------------------------------");
	fwhm_str = toString(FWHM, 4);
	contrast_str = toString(AREA, 4);
	mean_str = toString(MEAN, 4);
	// Return fwhm, area under lsf (edge step height) and peak position in pixels
	return fwhm_str + " " + contrast_str + " " + mean_str;		
}
// Makes the plots looks fancier
function makeFancy(x_val, y_val) {
        Plot.setLineWidth(2);
        Plot.setColor("red");
        Plot.add("circles", x_val, y_val);
        Plot.setColor("Gray");
        Plot.add("line", x_val, y_val);
}
// Seperate write to file routine
function writeFile(f, x, y) {
    xx = "";
    yy = "";
    zz = "";
    z = 0;
    while(z < x.length) {
    	xx = toString(x[z]) + "\t";
    	yy = toString(y[z]) + "\n";
    	zz = xx + yy;
    	z++;
	    print(f, zz);
	}
	File.close(f);
}