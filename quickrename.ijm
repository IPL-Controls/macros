/* Quick renaming tool for files.
 * 
 * Report any bugs or questions to alegmoralesm@gmail.com
 *  
 *  __author__			=	'Alejandro Morales'
 *  __bug fixes__		= 	
 *  __status__          =   "stable" 

 *  __date__            =   "7/6/16"
 *  __version__         =   "1.0"
 *  __to-do__			=   work on error checking 
 *  __update-log__		= 
 *  						
 *  						
 *  						
 */
 
 dir = "K:\\VPFI\\d20160706_NewGratingDriftTest\\NegativetoPositive\\2cmStepsize0pt2\\";
filelist = getFileList(dir);

for(i=0; i<filelist.length; i++)
	{
		print(filelist[i]);
	}

waitForUser("Is the file order correct");

for(i=0; i<filelist.length; i++)
	{
		File.rename(dir + "0pt2stepsize_0" + (i+1) + ".tif", dir + filelist[i])
	}