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
 *  __to-do__			=	1. There is an issue with the zero-frequency value of the MTF (at least I think its an issue)  
 *  						   
 *  __update-log__		= 	3/08/15: Now returns contrast information (edge response height) as area under gaussian LSF curve
 *  						3/10/15: added mtf capability, edge step height evaluation in terms of Lorentzian LSF fit area.
 *  						3/13/15: prints contrast count as well.
 *  						3/18/15: Decided not to normalize mtf for now. (Dr. Wens suggestion)
 *  						3/19/15: Added function makeFancy to make the mtf plots look nicer
 *  						3/25/15: Fixed normalization issue of mtf. Raw mtf should give proper contrast values now.
 *  						3/30/15: Added method for % roi selected in image to be printed in log
 *  						3/31/15: MTF is normalized now. 
 */
requires("1.49i");
macro "single_fit_edge" {
	// get input argument if any
	args = getArgument();
	if (args == "") {
		// Display dialog if fit and edge choice are not already pre-defined.
		fit_choice = newArray("Gaussian", "Lorentzian");
    	edge_choice = newArray("Horizontal", "Vertical");
  		Dialog.create("Menu");
		Dialog.addChoice("Choose Edge:", edge_choice, "Horizontal");
  		Dialog.addChoice("Choose Fit:", fit_choice, "Gaussian"); 
  		// This is only used to generate MTF x-axis in cycles/mm
  		Dialog.addNumber("Image Pixel Size (um)", 32.5);
  		Dialog.show();
  		lsf_edge = Dialog.getChoice();
    	fit_func = Dialog.getChoice();
    	pix_size = parseFloat(Dialog.getNumber());
	}
	else {
		// use this setting for Find_Edge_Resolution.ijm
		arr = split(args, " ");
		lsf_edge = arr[0];
    	fit_func = arr[1];
    	pix_size = 0;
	}
	imgname = getTitle(); 
	// Remove scaling
	run("Set Scale...", "distance=0 global");
	getSelectionBounds(upper_left_x, upper_left_y, width_roi, height_roi);
	width_image = getWidth();
	height_image = getHeight();
//	center_image_x = width_image/2;
//	center_image_y = height_image/2
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
    derivneg = newArray(npts);
    // force tails of LSF to go to 0 for finite roi
    deriv[0] = 0;
    deriv[npts-1] = 0;
    for(i = 1; i < npts - 1; i++) {
    	deriv[i] = (parseFloat(y[i+1]) - parseFloat(y[i-1]))/2;
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
    // LSF fitting routine (Always do gaussian fit and use gauss fit parameters to guess lorentzian fit parameters)
    deriv_gauss_fit = Fit.doFit("Gaussian", x, deriv);
    rsqpos = Fit.rSquared();   
    Fit.doFit("Gaussian", x, derivneg);
    rsqneg = Fit.rSquared();
    if(rsqpos > rsqneg) {
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
    	Fit.doFit("Gaussian", x, derivneg);
    	off_g = Fit.p(0);
    	mean_g = Fit.p(2);
    	peak_g = Fit.p(1) - Fit.p(0);
    	width_g = Fit.p(3);
    	FWHM_g = 2 * sqrt(2 * log(2)) * width_g;
    	area_g = sqrt(2 * PI) * peak_g * width_g;
    }           
    if (fit_func == "Gaussian") {
    	Fit.plot();
    	FWHM = FWHM_g;
    	AREA = abs(area_g);
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
	}
	// Now for mtf
    windowType = "None"; // None, Hamming, Hann or Flattop
    // create the function from the fit estimates:
    len = 128;
  	windowType="None";  //None, Hamming, Hann or Flattop
  	x_mtf = newArray(len);
  	a_mtf = newArray(len);
  for (i = 0; i < len; i++) {
    x_mtf[i] = i;
    a_mtf[i] = off_g + (peak_g ) * exp(-(i- mean_g) * (i - mean_g)/(2 * width_g * width_g));
  }
    // This performs a 1D fast hartley transform. Should be fine since we require |MTF| only
    // and the LSF is real-valued.
    mtf_arr = Array.fourier(a_mtf, windowType);
    mtf_norm = newArray(mtf_arr.length);
    mtf_arr_stat = Array.getStatistics(mtf_arr, min, max, mean, stdDev);
    mtf_arr_max = mtf_arr_stat[1]/sqrt(2);
    
  	f = newArray(lengthOf(mtf_arr));
  	for (i = 0; i < lengthOf(mtf_arr); i++) {
  		// mtf_norm[i] = mtf_arr[i]/mtf_arr_max;
  		 mtf_norm[i] =  (len * mtf_arr[i]/(sqrt(2)))/(len * mtf_arr_max);
  		 if (pix_size != 0) {
  		 	// Sampling period
  			T = len/(1/(pix_size * 0.001)); //T=len/w
   		 	f[i] = i/T;
  		 }
  		 else {
  		 	f[i] = i/len;
  		 }
  	}
  	if (pix_size != 0) {
  		Plot.create("MTF", "frequency (cycles/mm)", "MTF", f, mtf_norm); 
  		makeFancy(f, mtf_norm);
  	}
  	else {
  		Plot.create("MTF", "frequency bin", "MTF", f, mtf_norm);
  		makeFancy(f, mtf_norm);
  	}
  	Plot.show();
	
	print(fit_func + " " + lsf_edge + " Edge FWHM" + ":", FWHM + " pixels");
	print("Contrast" + ":", AREA + " DN");
	print("ROI (W x H): " + toString(width_roi) + " x " + toString(height_roi) + " pixels"); 
	print(toString(per_sel) + " % " +  "of total image selected!");
	print("---------------------------------------------------------");
	outstr = toString(FWHM, 4);
	outstr_1 = toString(AREA, 4);
	// Return fwhm and area under lsf (edge step height)
	return outstr + " " + outstr_1;
}
// Makes the plots looks fancier
function makeFancy(x_val, y_val) {
        Plot.setLineWidth(2);
        Plot.setColor("red");
        Plot.add("circles", x_val, y_val);
        Plot.setColor("Gray");
        Plot.add("line", x_val, y_val);
}
// Some notes:
// 1. Since LSF is gaussian (real and even), the fourier transform is also real and even.
// 2. Array.Fourier() does a 1D Fast Hartley transform H(f),which has a real kernel (cas(wx))
// 3. Need to convert Hartley to Fourier and then take amplitude only. To do this use the
//	  relation:
//    F(f) = (H(f) + H(-f))/2 + i(H(f) - H(-f))/2 with H(f) = H(-f) 
//    So F(f) = H(f) (Same as fourier for real and even signals) 
      	
 