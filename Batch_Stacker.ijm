/* 
 * Makes stacks in batch mode.
 *  
 *  __author__			=	'Alireza Panna'
 *  __status__          =   "stable"
 *  __date__            =   "6/29/15"
 *  __version__         =   "1.0"
 *  __to-do__			=	add progress bar  
 *  __update-log__		= 	6/29/15:  
 */
macro "Batch_Stacker" {
	// Get File Directory and file names
	dir_src = getDirectory("Select Dark-fields Directory");
	file_list = getFileList(dir_src);
//	run("Image Sequence...", "open="+dir_src+"file=(.tif) sort");
	// Count number of tiff files in source directory
	num_tiff = 0;
	file_num = 0;
	setBatchMode(true);
	while(file_num < file_list.length) {
    	id = file_list[file_num++];
    	if(endsWith(dir_src + id, ".tiff") || endsWith(dir_src + id, ".tif")) {
        	num_tiff++;
        	open(file_list[num_tiff]);
    	}
	}
	run("Images to Stack", "name=Stack title=[] use");
	dir_dest = getDirectory("Select Stack Output Directory");
	File.makeDirectory(dir_dest);
	saveAs("Tiff", dir_dest + "test""_avrg");
	// Cleanup
    run("Close All");
    print("--Completed");


}