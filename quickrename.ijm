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
 *  __update-log__		=   "7/8/16" changed the structure of the code
 *  						
 *  						
 *  						
 */
dir = getDirectory("Choose the images folder");
filelist = getFileList(dir);

Dialog.create("Quick file rename");
Dialog.addString("Original characters","");
Dialog.addString("New characters","")
Dialog.show
oldchar = Dialog.getString();
newchar = Dialog.getString();
 
for(i=0; i<filelist.length; i++)
	{
		newstring = replace(filelist[i],oldchar,newchar);
		File.rename(dir + filelist[i], dir + newstring);
	}