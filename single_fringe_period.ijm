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
    window_type = "None",
    tolerance = 3,
;
requires("1.49i");
macro "single_fringe_period" {
	imgname = getTitle(); 
	// remove extension
	imgname_split = split(imgname,".");
    dir = getDirectory("image");
    // get input argument if any
	args = getArgument();
	freq_dim = newArray("x", "y");
  	Dialog.create("Main Menu");
	Dialog.addNumber("Pixel Size:", 47.733, 3, 6,"um");
	Dialog.addChoice("Fringe Frequency axis:",freq_dim, "x");
  	Dialog.show();
  	pixel_size = Dialog.getNumber();
  	freq_dim_choice  = Dialog.getChoice();
  	fringe_period = newArray(nSlices)
	for (i = 1; i <= nSlices; i++) {
		// Remove scaling
		setSlice(i);
		run("Set Scale...", "distance=0 global");
		type = selectionType();
		// If none, no line or no rectangle ROI selected then make one for full image.
		if (type != 0 && type != 5 && type == -1) {
			makeRectangle(0, 0, getWidth(), getHeight());
		}
    	// Plot x profile, get values and close profile
		if (freq_dim_choice == "x") {
			setKeyDown("ctrl");
		}
		else if (freq_dim_choice == "y") {
    		setKeyDown("alt"); 
		}
		run("Plot Profile");
		Plot.getValues(x, y);
		close();
		// return location of maximum
		max_loc = Array.findMaxima(y, tolerance);
		Array.sort(max_loc);
	//	Array.print(max_loc);
		temp_period = max_loc[lengthOf(max_loc) - 1] - max_loc[0];
		period = temp_period /(0.5*lengthOf(max_loc));
		print (period);
		max_loc = newArray();
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