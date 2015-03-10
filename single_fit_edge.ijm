/* 
 *  Finds LSF from edge profile and offer you a choice for either Gaussian
 *  or Lorentzian fit. Return the FWHM of the LSF profile. Adapted from macro 
 *  single_edge_horizontal.ijm
 *  
 *  __author__			=	'Alireza Panna'
 *  __status__          =   "stable"
 *  __date__            =   "2/27/15"
 *  __version__         =   "1.0"
 *  __to-do__			=	1. Get mtf to work right
 *  						2. Format code/comments etc.
 */
requires("1.49i");
macro "single_fit_edge"{
	// get input argument if any (currently provided by stack_fit_edge)
	args = getArgument();
	if (args == ""){
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
	else{
		arr = split(args," ");
		lsf_edge = arr[0];
    	fit_func = arr[1];
	}
	imgname = getTitle(); 
	// Remove scaling
	run("Set Scale...", "distance=0 global");
    roiname = Roi.getName;    
    // Plot ESF profile, get values and close profile
	if (lsf_edge == "Vertical"){
		setKeyDown("ctrl");
	}
	else{
    	setKeyDown("alt"); 
	}
	run("Plot Profile");
	Plot.getValues(x, y);
    close();
    // Get derivative (raw LSF) (y[i+1]-y[i-1])/2;    
    npts = x.length;
    deriv = newArray(npts);
    derivneg = newArray(npts);
    deriv[0] = 0;
    deriv[npts-1] = 0;
    for(i=1; i<npts-1; i++){
    	deriv[i] = (parseFloat(y[i+1])-parseFloat(y[i-1]))/2;
    }
	// Linear baseline correction
    x0 = (x[1]+x[2]+x[3]+x[4])/4;
    deriv0 = (deriv[1]+deriv[2]+deriv[3]+deriv[4])/4;
    x1 = (x[npts-2]+x[npts-3]+x[npts-4]+x[npts-5])/4;
    deriv1 = (deriv[npts-2]+deriv[npts-3]+deriv[npts-4]+deriv[npts-5])/4;
    slope = (deriv1-deriv0)/(x1-x0);
    offset = (deriv0*x1-deriv1*x0)/(x1-x0);
    // Following is baseline corrected LSF
    for(i=1; i<npts-1; i++){
    	deriv[i] = deriv[i]-offset-slope*x[i];
    }
    for(i=1; i<npts-1; i++){
    	derivneg[i] = -deriv[i];
    }
    // Now for mtf
    windowType="None"; //None, Hamming, Hann or Flattop
    mtf_arr = Array.fourier(deriv);
  	f = newArray(lengthOf(mtf_arr));
  	for (i=0; i<lengthOf(mtf_arr); i++){
   		 f[i] = i;
  	}
  	Plot.create("MTF", "frequency bin", "MTF", f, mtf_arr);
  	Plot.show();
    // LSF fitting routine (Always do gaussian fit and use gauss fit parameters to guess lorentzian fit parameters)
    Fit.doFit("Gaussian", x, deriv);
    rsqpos=Fit.rSquared();   
    Fit.doFit("Gaussian", x, derivneg);
    rsqneg=Fit.rSquared();
    if(rsqpos > rsqneg){
    	Fit.doFit("Gaussian", x, deriv);
    	mean_g = Fit.p(2);
    	peak_g = Fit.p(1)-Fit.p(0);
    	width_g = Fit.p(3);
    	// LSF fwhm
    	FWHM_g = 2*sqrt(2*log(2))*width_g;
    	// This is the contrast in terms of ESF step height 
    	area_g = sqrt(2*PI)*peak_g*width_g;
    }
	else{
    	Fit.doFit("Gaussian", x, derivneg);
    	mean_g = Fit.p(2);
    	peak_g = Fit.p(1)-Fit.p(0);
    	width_g = Fit.p(3);
    	FWHM_g = 2*sqrt(2*log(2))*width_g;
    	area_g = sqrt(2*PI)*peak_g*width_g;
    }           
    if (fit_func == "Gaussian"){
    	Fit.plot();
    	FWHM = FWHM_g;
    	AREA = abs(area_g);
    	rename("LSF");
	}
	if (fit_func == "Lorentzian"){
	// Define the Lorentzian fit function to use
		/* a = Amplitude
		 * b = mean 
		 * c = FWHM
		 */ 
		Lorentzian = "y = (a/4)*(c*c)*(1/((x-b)*(x-b)+(c/2)*(c/2)))";
		// Calculate initial guesses. Currently getting guess from gaussian fit parameters.
     	initialGuesses = newArray(peak_g, mean_g, FWHM_g);
		Fit.doFit(Lorentzian, x, deriv, initialGuesses);
		rsqpos=Fit.rSquared();
		Fit.doFit(Lorentzian, x, derivneg, initialGuesses);
		rsqneg=Fit.rSquared();
    	if(rsqpos > rsqneg){
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
    	FWHM = abs(FWHM_l);
    	// This needs to be changed.
    	AREA = abs(peak_l);
	}
	print(fit_func + " " + lsf_edge + " Edge FWHM"+":", FWHM);
	outstr = toString(FWHM, 4);
	outstr_1 = toString(AREA, 4);
	// Return fwhm and peak
	return outstr+" "+outstr_1;
}
