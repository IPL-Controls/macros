/* 
 *  Fixes file names for camera_eval.sav IDL script.
 *  
 *  __author__			=	'Alireza Panna'
 *  __status__          =   "stable"
 *  __date__            =   "6/29/15"
 *  __version__         =   "1.0"
 *  __to-do__			=	clean up  
 *  __update-log__		= 	6/29/15:  
 */
macro "fix_filename_camera_eval" {
	// Get File Directories and file names
	dir_flat_0 = getDirectory("Select Flat-field-0 Directory");
	flat_0 = getFileList(dir_flat_0);
	dir_flat_1 = getDirectory("Select Flat-field-1 Directory");
	flat_1 = getFileList(dir_flat_1);
	// Make output directory to save the renamed files.
	// Get base path/dir
	base_path = split(dir_flat_0, File.separator)
	dir_dest = "";
	for(i = 0; i < base_path.length; i++) 
	{
		if (i < base_path.length - 2)
		{
			dir_dest = dir_dest + base_path[i] + File.separator; 
		}
		last_element = base_path[i];
	}
	dir_dest = dir_dest + last_element + "_QE";
	File.makeDirectory(dir_dest);
	numTiff = 0;
	filenum = 0;
	
	while (filenum < flat_0.length) 
	{
    	id = flat_0[filenum++];
    	if(endsWith(dir_flat_0 + id, ".tiff") || endsWith(dir_flat_0 + id, ".tif"))
    	{
        	numTiff++;
    	}
	}
	setBatchMode(true);
	for (tiffc=0; tiffc<numTiff; tiffc++)
	{
		// remove .tif
		no_tif_ext_0 = split(flat_0[tiffc], ".");
		open(dir_flat_0 + flat_0[tiffc]);
		{
			saveAs("Tiff", dir_dest + File.separator +  no_tif_ext_0[0] + "0");
		}
		close();
		no_tif_ext_1 = split(flat_1[tiffc], ".");
		open(dir_flat_1 + flat_1[tiffc]);
		{
			saveAs("Tiff", dir_dest + File.separator + no_tif_ext_1[0] + "1");
		}
		close();		
	}
	
}