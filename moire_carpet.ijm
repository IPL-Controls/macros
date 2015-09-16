/* 
 * For making fringe maps.
 *  
 *  __author__			=	'Alireza Panna'
 *  __status__          =   "stable"
 *  __date__            =   "8/28/15"
 *  __version__         =   "1.0"
 *  __to-do__			=   
 *  __update-log__		= 	
 */

var mean_slice_list = newArray();

macro "moire_carpet" {
	image_stack = File.openDialog("Select Stack");
	path = File.directory;
    if (endsWith(image_stack, ".tif") || endsWith(image_stack, ".tiff")) { 
        setBatchMode(true);
        open(image_stack);
        if (nSlices == 1) {
        	exit("Stack Required!");
        }
        w = getWidth();
		h = getHeight();
        title = getTitle();  
        for(i = 1; i <= nSlices; i++) { 
          run("Select All"); 
          setSlice(i); 
          getStatistics(area, mean);
          mean_slice_list = Array.concat(mean_slice_list, mean);  // ---> mean of each image in stack
        }  
    }
    stack_list_stats = Array.getStatistics(mean_slice_list, min, max, mean, stdDev);
    mean_of_stack = stack_list_stats[2]; // ---> mean of the mean of all images in stack
    print (mean_of_stack);
	setBatchMode(true);
    for(i = 1; i <= nSlices; i++) { 
        new_file = getInfo("slice.label"); 
        new_title = new_file; 
        run("Select All"); 
        setSlice(i); 
        image_name = getInfo("slice.label");
        run("Copy"); 
        newImage("Untitled", bitDepth() + "Black", w, h, 1); 
        run("Paste"); 
        run("Split Channels");
        close("Untitled");
        run("Images to Stack", "name=Stack title=[] use");
		run("32-bit");
		run("Divide...", "value="+d2s(mean_slice_list[i-1], 6)+" stack");
		run("Multiply...", "value="+d2s(mean_of_stack, 6) + " stack");
		run("8-bit");
		run("Stack to RGB");
		close("Stack");
        saveAs("Tiff", path + "norm_" + image_name); 
        close();
    }
    // Convert the new images into stack.
 //   runMacro("Batch_Stacker");
}