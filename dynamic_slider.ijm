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

macro "dynamic_slider" {
	image_stack = File.openDialog("Select Stack");
	path = File.directory;
    if (endsWith(image_stack, ".tif") || endsWith(image_stack, ".tiff")) { 
        setBatchMode(false);
        open(image_stack);
        if (nSlices == 1) {
        	exit("Stack Required!");
        }
        stack_title = getTitle();
        w = getWidth();
		h = getHeight();
		slider_y = h - 25;
		newImage("Untitled", "RGB white", w, 4, 1);
        bar_title = getTitle(); 
        selectWindow(stack_title);
        run("Add Image...", "image=" +toString(bar_title) + " x=0 y=" + toString(slider_y) +  " opacity=100");
        j = 0;
		for(i = 1; i <= nSlices; i++) { 
		    run("Select All"); 
        	setSlice(i); 
        	print(j);
			makeOval(j, slider_y-8 , 20, 20);
        	run("Set...", "value=255 slice");
        	j = j + w/nSlices;
        	
		}        
	//	saveAs("Tiff", path + "withSlider_" + image_name); 
      //  close();
    }
}