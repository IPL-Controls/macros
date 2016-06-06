/* Automated procedure for the phase drift correction and new ROI corner calculation.
 * 
 * Report any bugs or questions to alegmoralesm@gmail.com
 *  
 *  __author__			=	'Alejandro Morales'
 *  __bug fixes__		= 	
 *  __status__          =   "stable" 

 *  __date__            =   "05/18/16"
 *  __version__         =   "2.0"
 *  __to-do__			=   work on error checking, 
 *  __update-log__		= 	save the ROI's in the ROI manager
 *  						
 *  						
 *  						
 */


file = File.openDialog("Open the refDFCOR_***.tif file");
File.makeDirectory(File.getParent(file) + "\\PhaseTest");
openpath = File.getParent(file) + "\\PhaseTest\\";
filename = 415;

setBatchMode(true);
for (i=0; i<50; i++) 
{
run("Close All");
open(file);
makeRectangle(0, filename +i*1, 1634, 180);
run("Crop");
run("Duplicate...", " ");
run("Duplicate...", " ");
run("Duplicate...", " ");
run("Duplicate...", " ");
run("Images to Stack", "name=Stack title=[] use");
run("Make Montage...", "columns=1 rows=5 scale=1");
save(openpath + toString(filename+i*1) + "y_" + toString(i) + ".tif");
run("Close All");
}

setBatchMode(false);
run("Image Sequence...", "open=[" + openpath + toString(filename) + "y.tif"+ "] sort");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel global");
run("Enhance Contrast", "saturated=0.35");