////////////////////////////////////////////////////////////////////////////////
//Check for nef files with missing tif files, and move those nef files to the tifmissing folder.
//HW 9/21/2014 
////////////////////////////////////////////////////////////////////////////////

macro "tifmissing" {
dir = getDirectory("Choose the raw data directory:"); 
//print(dir);
tifmsdir = dir+"tifmissing"+File.separator;
//print(tifmsdir);
File.makeDirectory(tifmsdir);

allfiles = getFileList(dir); 
//print("n of files"+allfiles.length);

for (i=0; i<allfiles.length; i++) { 

	if (endsWith(allfiles[i], ".nef")){ //find the nef files
		index2 = lastIndexOf(allfiles[i], ".nef");
//		print(index2);
		tiffile = substring(allfiles[i], 0, index2)+".tif";
//		print(dir+tiffile);
		if(File.exists(dir+tiffile) != 1){ //tif file does not exist
			File.rename(dir + allfiles[i],tifmsdir+allfiles[i]); //move the nef to tiffmissing dir	
		}
                                        
	} 
} //End all file loop
print("tiffmissing done!");
}