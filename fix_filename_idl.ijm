/* 
 *  Fixes file names for camera_eval.sav IDL script.
 *  
 *  __author__			=	'Alireza Panna'
 *  __status__          =   "stable"
 *  __date__            =   "6/29/15"
 *  __version__         =   "1.0"
 *  __to-do__			=	  
 *  __update-log__		= 	6/29/15:  
 */
macro "fix_filename_idl" {
	// Get flat field file directories and file names.
	dir_flat_0 = getDirectory("Select Flat-field_0 Directory");
	flat_0 = getFileList(dir_flat_0);
	dir_flat_1 = getDirectory("Select Flat-field_1 Directory");
	flat_1 = getFileList(dir_flat_1);
	// Get base path
	base_path = split(dir_flat_0, File.separator)
	dir_dest = "";
	fnum_0 = 0;
	fnum_1 = 0;
    base_path_ct = 0;
	// Make destination directory to save the renamed files.
	while (base_path_ct < base_path.length - 2)
	{
		dir_dest = dir_dest + base_path[base_path_ct++] + File.separator; 
	}
	dir_dest = dir_dest + base_path[base_path.length - 1] + "_QE";
	File.makeDirectory(dir_dest);
	// Re-save the flat-fields to a new directory with appended file names.
	setBatchMode(true);
	while (fnum_0 < flat_0.length) 
	{
    	id = flat_0[fnum_0++];
    	if(endsWith(dir_flat_0 + id, ".tiff") || endsWith(dir_flat_0 + id, ".tif"))
    	{   // remove .tif
			no_tif_ext_0 = split(id, ".");
			open(dir_flat_0 + id);
			{
				saveAs("Tiff", dir_dest + File.separator +  no_tif_ext_0[0] + "0");
			}
			close();
    	}
	}
	while (fnum_1 < flat_1.length) 
	{
    	id = flat_1[fnum_1++];
    	if(endsWith(dir_flat_1 + id, ".tiff") || endsWith(dir_flat_1 + id, ".tif"))
    	{   // remove .tif
        	no_tif_ext_1 = split(id, ".");
			open(dir_flat_1 + id);
			{
				saveAs("Tiff", dir_dest + File.separator + no_tif_ext_1[0] + "1");
			}
			close();	
    	}
	}
}