/* 
 * Saves the DICOM files in a specific folder into another folder.
 *  
 *  __author__			=	'Alejandro Morales'
 *  __status__          =   "stable"
 *  __date__            =   "9/1/15"
 *  __version__         =   "1.0"
 *  __to-do__			=   
 *  __update-log__		= 	
 */

// Select the file directory for the DICOM images to be sorted from
/* file = File.openDialog("Choose file");
dir = File.directory;*/
dir = getDirectory("Choose folder with DICOM files");
list = getFileList(dir);

// Select the new file directory for the DICOM images to be saved
newdir = getDirectory("Choose output folder");

setBatchMode(true); // runs the process in the background
	
	for (i=0; i< list.length; i++) {  
		// Iterates through all the DICOM files in the folder
		// and copies them to the new folder
		if(endsWith(list[i], "dcm")) {
		path = dir + list[i];
		newpath = newdir + list[i];
        showProgress(i, list.length);
        File.copy(path,newpath);
		}
	}
	