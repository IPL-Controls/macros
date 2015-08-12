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
var 
    window_type = "none",
    tolerance = 2,
;

requires("1.49i");
macro "single_fringe_visibility" {
	imgname = getTitle(); 
	// remove extension
	imgname_split = split(imgname,".");
    dir = getDirectory("image");
    // get input argument if any
	args = getArgument();
	ft_dim = newArray("x", "y");
	if (args == "") {
  		Dialog.create("Main Menu");
		Dialog.addNumber("Pixel Size:", 50, 3, 6,"um");
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
	// Define the sinusoidal fit function to use
		/* a = Amplitude
		 * b = 
		 * c = phase
		 * d = offset
		 */ 
  	sine_equation = "y = a + b * sin(x + c)";
  	initial_guesses = newArray(0, 0, 0);
  	Fit.doFit(sine_equation, x, y, initial_guesses);
  	Fit.plot();
  	
	findFringeVisibility(x, y, pixel_size);
	findFringeVisibilityAlt(x, y, pixel_size);
 //   close();
    
    // Do the Fourier transform  
    len = x.length;
    ft = Array.fourier(y, window_type);
    ft_x = newArray(lengthOf(ft));
    for (i = 0; i < lengthOf(ft); i++) {
    	ft_x[i] = i;
    } 
    Plot.create("Fourier amplitudes: " + window_type, "frequency bin", "amplitude (RMS)", ft_x, ft);
  	Plot.show();
  	ft_peak_position = Array.findMaxima(ft, tolerance);
	for(i = 0; i < lengthOf(ft_peak_position); i++) {
		temp = ft_peak_position[i];
	}
	h_0 = ft[ft_peak_position[0]];
	h_1 = ft[ft_peak_position[1]];
	fringe_visibility = h_1/h_0;
	print (h_0);
	print (h_1);
	print (fringe_visibility);
}
function findFringeVisibility(x_val, y_val, pix_size) {
	i_max = 0;
	i_min = 0;
	
	// find minimum and maximum positions
	min_loc = Array.findMinima(y_val, tolerance);
	max_loc = Array.findMaxima(y_val, tolerance);
	period = pix_size * (min_loc[0] - min_loc[1]);
	Array.sort(min_loc);
	Array.sort(max_loc);
//	print (lengthOf(max_loc));
//	Array.print(max_loc);
//	Array.print(min_loc);
	for (i = 0; i < lengthOf(max_loc); i++) {
    	i_max = i_max + y_val[max_loc[i]];
    } 
    i_max = i_max / lengthOf(max_loc);
    
	for (i = 0; i < lengthOf(min_loc); i++) {
    	i_min = i_min + y_val[min_loc[i]];
	}
	i_min = i_min / lengthOf(min_loc);
	fringe_visibility_1 = ( i_max - i_min ) / (2 * ( i_max + i_min ));
    print(fringe_visibility_1); 
}

function findFringeVisibilityAlt(x_val, y_val, pix_size) {
    deriv = newArray(x_val.length);
    max_loc_alt = newArray();
    min_loc_alt = newArray();
    
    i_max_alt = 0;
    i_min_alt = 0;
    for(i = 1; i < x_val.length - 1; i++) {
    	deriv[i] = (parseFloat(y_val[i+1]) - parseFloat(y_val[i-1]))/2;
    	// get extreme positions.
    	if ( ( deriv[i] < 0 && deriv[i - 1] >= 0)) {
    		max_loc_alt = Array.concat(max_loc_alt, y_val[i - 1]);
    	}
    	if ( ( deriv[i] >= 0 && deriv[i - 1] < 0 ) ) {
    		min_loc_alt = Array.concat(min_loc_alt, y_val[i - 1]);
    	}
    }
//	Array.print(max_loc_alt);
//	Array.print(min_loc_alt);
    for (i = 0; i < lengthOf(max_loc_alt); i++) {
    	i_max_alt = i_max_alt + y_val[max_loc_alt[i]];
    } 
    i_max_alt = i_max_alt / lengthOf(max_loc_alt);
    
	for (i = 0; i < lengthOf(min_loc_alt); i++) {
    	i_min_alt = i_min_alt + y_val[min_loc_alt[i]];
	}
	i_min_alt = i_min_alt / lengthOf(min_loc_alt);
//	print(i_min_alt);
//	print(i_max_alt);
	fringe_visibility_2 = ( i_max_alt - i_min_alt ) / (2 * ( i_max_alt + i_min_alt ));
	print (fringe_visibility_2);
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