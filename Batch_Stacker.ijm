/* 
 * Makes tiff stacks in batch mode.
 *  
 *  __author__			=	'Alireza Panna'
 *  __status__          =   "stable"
 *  __date__            =   "8/06/15"
 *  __version__         =   "1.0"
 *  __to-do__			=   
 *  __update-log__		= 	8/07/15: Added progress bar  
 */
macro "Batch_Stacker" {
	open_as_image_sequence();
}

function open_as_image_sequence() {
	// Get File Directory and file names
	dir_src = getDirectory("Select Input Directory");
	file_list = getFileList(dir_src);
	setBatchMode(true);
    id = file_list[file_list.length - 1];
	run("Image Sequence...", "open="+dir_src+File.separator+"file=.tif sort");
	saveAs("Tiff", dir_src + "STK" + id);
	// Cleanup
    run("Close All");
}