/* 
 *  Finds FV
 *  
 *  __author__			=	'Alireza Panna'
 *  __status__          =   "development"
 *  __date__            =   "8/10/15"
 *  __version__         =   "1.0"
 *  __to-do__			=				   
 *  __update-log__		= 	
 */
 
requires("1.49i");
macro "single_fringe_visibility" {
	imgname = getTitle(); 
	// remove .tif
	imgname_split = split(imgname,".");
    dir = getDirectory("image");

    ft_dim = newArray("x", "y");
    // get input argument if any
	args = getArgument();
	if (args == "") {
  		Dialog.create("Main Menu");
		Dialog.addNumber("Pixel Size:", 50, 6, 6,"um");
		Dialog.addChoice("FT dimension:",ft_dim, "x");
  		Dialog.show();
  		pixel_size = Dialog.getNumber();
  		ft_dim_choice  = Dialog.getChoice();
	}
	else {
		// use the setting from stack_fit_edge.ijm
		arr = split(args, " ");
		pixel_size = arr[0];
    	ft_dim_choice = arr[1];
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
	
    // Plot x profile, get values and close profile
	if (ft_dim_choice == "x") {
		setKeyDown("ctrl");
	}
	else if (ft_dim_choice == "y") {
    	setKeyDown("alt"); 
	}
	run("Plot Profile");
	Plot.getValues(x, y);
    close();
    
    // Get derivative (raw LSF) (y[i+1]-y[i-1])/2;    
    len = x.length;
    window_type = "none";
    
    ft = Array.fourier(y, window_type);
    ft_x = newArray(lengthOf(ft));
    for (i = 0; i < lengthOf(ft); i++) {
    	ft_x[i] = i;
    } 
    
    Plot.create("Fourier amplitudes: "+window_type, "frequency bin", "amplitude (RMS)", ft_x, ft);
  	Plot.show();
  	run("Find Peaks", "min._peak_amplitude=5 min._peak_distance=0 min._value=NaN max._value=NaN list");
//	saveAs("Results", "/Path/to/Output/Directory/Plot Values.csv");
	run("Close");

  	fhtSize = 2*lengthOf(ft_x);
  	
  /*  // force tails of LSF to go to 0 for finite roi
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
	}*/

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