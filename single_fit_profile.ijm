/* 
 * Fits a single profile to gaussian & lorentzian curve 
 * 
 *  __author__			=	'Alireza Panna'
 *  __status__          =   "stable"
 *  __date__            =   "8/16/16"
 *  __version__         =   "1.0"
 *  __to-do__			=				   
 *  __update-log__		= 	8/16/16:
 */
 
requires("1.49i");
macro "single_fit_profile" {
	imgname = getTitle(); 
	// remove .tif
	imgname_split = split(imgname,".");
    dir = getDirectory("image");
    // get input argument if any
	args = getArgument();
	if (args == "") {
		// Display dialog if fit and edge choice are not already pre-defined.
		fit_choice = newArray("Gaussian", "Lorentzian");
    	profile_choice = newArray("Horizontal", "Vertical");
  		Dialog.create("Menu");
		Dialog.addChoice("Profile Direction:", profile_choice, "Horizontal");
  		Dialog.addChoice("Fit Function:", fit_choice, "Gaussian"); 
  		Dialog.show();
  		prof_dir = Dialog.getChoice();
    	fit_func = Dialog.getChoice();
	}
	else {
		// use the setting from stack_fit_profile.ijm
		arr = split(args, " ");
		prof_dir = arr[0];
    	fit_func = arr[1];
	}
	selectImage(imgname);
	if selectionType() != 0 || selectionType() != 5 || selectionType() != 7 {
		
	}
	// Remove scaling
	run("Set Scale...", "distance=0 global");
	// Find percent roi selected
	getSelectionBounds(upper_left_x, upper_left_y, width_roi, height_roi);
	width_image = getWidth();
	height_image = getHeight();
	area_image = width_image * height_image;
	area_roi = width_roi * height_roi;
	per_area = (area_roi/area_image) * 100;
    // Plot profile, get values and close profile
	if (prof_dir == "Vertical") {
		setKeyDown("alt");
	}
	else {
    	setKeyDown("ctrl"); 
	}
	run("Plot Profile");
	Plot.getValues(x, y);
	close();
	//Do linear baseline correction.
    npts = x.length;
    x0=(x[0]+x[1]+x[2]+x[3]+x[4])/5;
    y0=(y[0]+y[1]+y[2]+y[3]+y[4])/5;
    x1=(x[npts-1]+x[npts-2]+x[npts-3]+x[npts-4]+x[npts-5])/5;
    y1=(y[npts-1]+y[npts-2]+y[npts-3]+y[npts-4]+y[npts-5])/5;
    // fitting routine (Always do gaussian fit and use gauss fit parameters to guess lorentzian fit parameters)
    slope = (y1-y0)/(x1-x0);
    offset = (y0*x1-y1*x0)/(x1-x0);
    y_corr = newArray(y.length);
    ny = newArray(y.length);
    ny_corr = newArray(y.length);
    for(i = 0; i < npts; i++) {
    	y_corr[i]=y[i]-offset-slope*x[i];
    }
    for(i = 0; i < npts; i++) {
    	ny_corr[i] = -y_corr[i];
    	ny[i] = -y[i];
    }
    Fit.doFit("Gaussian", x, y_corr);
    rsqpos=Fit.rSquared();   
    Fit.doFit("Gaussian", x, ny_corr);
    rsqneg=Fit.rSquared();
    if(rsqpos > rsqneg) {
    	Fit.doFit("Gaussian", x, y);
    } 
    else {
    	Fit.doFit("Gaussian", x, ny);
    }    
    off_g = Fit.p(0);
    mean_g = Fit.p(2);
    peak_g = Fit.p(1) - Fit.p(0);
    width_g = Fit.p(3);
    // profile fwhm
    FWHM_g = 2 * sqrt(2 * log(2)) * width_g;
    area_g = sqrt(2 * PI) * peak_g * width_g;           
    if (fit_func == "Gaussian") {
    	Fit.plot();
    	FWHM = FWHM_g;
    	AREA = abs(area_g);
    	MEAN = mean_g;
    	rename("Fit");
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
		Fit.doFit(Lorentzian, x, y_corr, initialGuesses);
		rsqpos = Fit.rSquared();
		Fit.doFit(Lorentzian, x, ny_corr, initialGuesses);
		rsqneg = Fit.rSquared();
    	if(rsqpos > rsqneg) {
    		Fit.doFit(Lorentzian, x, y_corr, initialGuesses);
    	} 
    	else {
    		Fit.doFit(Lorentzian, x, ny_corr, initialGuesses);
    	}    
    	Fit.plot();
    	rename("Fit");
    	peak_l = Fit.p(0);
    	mean_l = Fit.p(1);
    	FWHM_l = Fit.p(2);
    	area_l = (abs(peak_l) * abs(FWHM_l)) * ((PI/2));//-atan(-2*mean_l/abs(FWHM_l)));
    	FWHM = abs(FWHM_l);
    	AREA = abs(area_l);
    	MEAN = mean_l;
	}

	print(fit_func + " " + prof_dir + " Profile FWHM" + ":", FWHM + " pixels");
	print("Contrast" + ":", AREA + " DN");
	print("ROI (W x H): " + toString(width_roi) + " x " + toString(height_roi) + " pixels"); 
	print(toString(per_area) + " % " +  "of total image selected!");
	print("---------------------------------------------------------");
	fwhm_str = toString(FWHM, 4);
	contrast_str = toString(AREA, 4);
	mean_str = toString(MEAN, 4);
	// Return fwhm, area under lsf (edge step height) and peak position in pixels
	return fwhm_str + " " + contrast_str + " " + mean_str;		
}