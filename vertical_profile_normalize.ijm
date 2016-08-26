/* 
 *  __author__			=	Alireza Panna
 *  __status__          =   stable
 *  __date__            =   8/25/16
 *  __version__         =   1.0
 *  __to-do__			=				   
 *  __update-log__		= 
 *  					=  
 */

requires("1.49i");
macro "vertical_profile_normalize" {
	// Select the image and get the directory
    image_0 = File.openDialog("Pick an image *_");
    temp = split(File.nameWithoutExtension, "_");
    image_0_noext = "";
    for(i = 0; i < lengthOf(temp) - 1; i++) {
    	image_0_noext = image_0_noext + temp[i]; 
    }
    var image_dir = File.directory;
    Dialog.create("");
    Dialog.addNumber("Set polynomial order:", 5);
    Dialog.show();
    fit_order = Dialog.getNumber();
    setBatchMode(false);
	// Get all files in that directory. 
	fileList = getFileList(image_dir); 
    var image_names = newArray();
	// Open images in  a virtual stack using regex i.e. if file name contains _[counter]
	run("Image Sequence...", "open=[&image_0]"+"file=(^" + image_0_noext + "_[0-9]) sort use");
	// Remove scaling
	run("Set Scale...", "distance=0 global");
	rename("Stack");
	num_images = nSlices;
	// Save all file names into an array
	for (i = 1; i <= nSlices; i++) {
		setSlice(i);
		image_names = Array.concat(image_names, getInfo("slice.label"));
	}
	close()
		open("C:\\Users\\Ali\\Desktop\\New folder_2\\CRP40kV40W2sFV_007.tif"); 
		width = getWidth();
		height = getHeight();
		makeRectangle(0, 0, width, height);
		// Plot x profile, get values and close profile
		setKeyDown("alt");
		run("Plot Profile");
		Plot.getValues(x, y);
		npts = x.length;
		close();
		Fit.doFit(2, x, y);
    	rsqpos=Fit.rSquared();
    	Fit.plot();
    	Plot.getValues(x, y);
    	fit_y = newArray(x.length);
    	for (j = 0; j < x.length; j++) {
    		fit_y[j] = Fit.f(y[j]);
    	}
    	print(fit_y.length);
    	Array.resample(fit_y, npts);
		//newImage("blank.tif", "32-bit black", width, height, 1);
		//run("Set...", "value=1");
    	imm = 'CRP40kV40W2sFV_007.tif';
    	selectImage(imm);
    	getStatistics(area, mean, min, max, std, histogram)
    	for(w = 0; w < width; w++) { 
			for(h = 0; h < height; h++) { 
				pix = getPixel(w, h);
				val = parseFloat(pix*fit_y[h]);
				setPixel(w, h, val); 
			} 
		}
}

function saveTiff (num_tiff, flag) {
	for (tiffc = 1; tiffc <= num_tiff; tiffc++) {
		if (flag == 0) {
			saveAs("Tiff", image_dir + "CRP" + image_names[num_tiff-tiffc]);
			close();
		}
		else if(flag == 1) {
			saveAs("Tiff", image_dir + "CRPDFCOR" + image_names[num_tiff-tiffc]);
			close();
		}
		else if (flag == 2) {
			saveAs("Tiff", image_dir + "CRPFFCOR" + File.name);
			close();
		}
		else {
			saveAs("Tiff", image_dir + "CRP" + File.name);
			close();
		}	
	} 
}