 /* 
 *  This macro performs the same function as crop_images.sav
 *  
 *  __author__			=	'Alireza Panna'
 *  __status__          =   "stable"
 *  __date__            =   "03/01/15"
 *  __version__         =   "1.0"
 *  __to-do__			=	 
 *  __update-log__		= 	3/12/15: code clean-up
 *  						3/14/15: added functionality to remember last crop setting
 *  						4/18/15: Fixed off by one issue in crop
 */
 
macro "crop_images" {
	// Open the first image file in the sequence.
    image_0 = File.openDialog("Pick an image *_0");
    // Seperate the file name and the complete path name
    img_0 = File.name;
    delimiter = "_0.tif";
    temp_img = replace(img_0, delimiter, "");
    image_dir =  File.directory;
	// Get all files in that directory. 
	fileList = getFileList(image_dir);
	// Create an array to match nth sequence image with 0th 
    image_n = newArray();
    num_images = 0;
	for (i = 0; i < fileList.length; i++) {
		if (startsWith(fileList[i], temp_img)) {
			image_n = Array.concat(image_n, fileList[i]);
			num_images  = num_images+1;
		}
	}
	// Count number of uncropped tiff files in source directory
	for (i = 0; i < num_images; i++) {
		// Check if dark field is in the source directory. If exists save.
		if (startsWith(fileList[i], "dark")) {
			dark_field = fileList[i];
		}
		else {
			dark_field = "";
		}
		// Check if flat field is in the source directory. If exists save. 
		if (startsWith(fileList[i], "flat")) {
			flat_field = fileList[i];
		}
		else {
			flat_field = "";
		}
	}
	numTiff = 0;
	filenum = 0;
	// Ask for dark correction
	Dialog.create("");
	Dialog.addNumber("Set DF correction setting (0-none, 1-dark only, 2-dark & flat):", 0);
	Dialog.show();
	df_corr = Dialog.getNumber();
	// Create Crop roi based on co-ordinates or make custom roi
	Dialog.create("");
	Dialog.addMessage("Set upperleft X, Y and lowerright X, Y (0 for previous setting):")
	Dialog.addNumber("upperleft X:", 0);
	Dialog.addNumber("upperleft Y:", 0);
	Dialog.addNumber("lowerright X:", 0);
	Dialog.addNumber("lowerright Y:", 0);
	Dialog.show();

	upper_left_x = Dialog.getNumber();
	upper_left_y = Dialog.getNumber();
	lower_right_x = Dialog.getNumber();
	lower_right_y = Dialog.getNumber();

	dir = getDirectory("macros");
	// First do exception case i.e. no crop area + no crop restore file. Create dummy file for next run and exit
	if (upper_left_x == 0 && upper_left_y == 0 && lower_right_x == 0 && lower_right_y == 0 && File.exists(dir + "cropcorners" + ".txt") == 0) {
		File.saveString(toString(0) + " " + toString(0) + " " + toString(0) + " " + toString(0), dir + "cropcorners" + ".txt");
		exit("Area selection is required");
	}
	else if (File.exists(dir + "cropcorners" + ".txt")) {
		coords = File.openAsString(dir + "cropcorners" + ".txt");
		// Restore last crop settings from file if crop co-ordinates are 0.
		if (upper_left_x == 0 && upper_left_y == 0 && lower_right_x == 0 && lower_right_y == 0) {
			all_coords = split(coords, " ");
			// If crop restore file is 0 then exit with error message
			if (parseInt(all_coords[0]) == 0 && parseInt(all_coords[1]) == 0 && parseInt(all_coords[2]) == 0 && parseInt(all_coords[3]) == 0) {
				exit("Area selection is required");
			}
			else {
				upper_left_x = parseInt(all_coords[0]);
				upper_left_y = parseInt(all_coords[1]);
				lower_right_x = parseInt(all_coords[2]);
				lower_right_y = parseInt(all_coords[3]);
			}
		}	
	}
	// Write to file if crop co-ordinates are not 0
	if (upper_left_x != 0 && upper_left_y != 0 && lower_right_x != 0 && lower_right_y != 0) {
		File.saveString(toString(upper_left_x) + " " + toString(upper_left_y) + " " + toString(lower_right_x) + " " + toString(lower_right_y), dir + "cropcorners" + ".txt");
	}
	// If set as 0 then open first image for roi selection.
	for (tiffc = 0; tiffc < num_images; tiffc++) {
		open(image_n[tiffc]);
		// Remove scale
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		if (df_corr == 1) {
			if (dark_field != "") {
				// Perform dark correction only
				imageCalculator("Subtract create 32-bit", dark_field, image_n[tiffc]);
				runCrop(upper_left_x, upper_left_y, lower_right_x, lower_right_y);
				saveAs("Tiff", image_dir + "CRPDFCOR" + image_n[tiffc]);
				close();
			}
			else {
				runCrop(upper_left_x, upper_left_y, lower_right_x, lower_right_y);
				saveAs("Tiff", image_dir + "CRP" + image_n[tiffc]);
				close();
			}
		}
		else if (df_corr == 0) {
			// No correction
			runCrop(upper_left_x, upper_left_y, lower_right_x, lower_right_y);
			saveAs("Tiff", image_dir + "CRP" + image_n[tiffc]);
			close();
		}
		else if (df_corr == 2) {
			if (flat_field != "" && dark_field != "") {
				// Perform dark-flat correction (I-D/F-D)
				den = imageCalculator("Subtract create 32-bit", dark_field, flat_field);
				num = imageCalculator("Subtract create 32-bit", dark_field, image_n[tiffc]);
				imageCalculator("Divide create 32-bit", num, den);
				runCrop(upper_left_x, upper_left_y, lower_right_x, lower_right_y);
				saveAs("Tiff", image_dir + "CRP" + image_n[tiffc]);
				close();
			}
		}
	}
}
function runCrop (ulx, uly, lrx, lry) {
	makeRectangle(ulx, uly, lrx - ulx + 1, lry - uly + 1); 
	run("Crop");
}


