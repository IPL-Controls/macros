//This version performs and iterative subtraction of successive dark-field frames to find the dark-field noise and
// averages all the dark-field frames. 
// AP
// 12/16/2014

macro "dark_field"{
	//Get File Directory and file names
	dirSrc = getDirectory("Select Dark-field Directory");
	fileList = getFileList(dirSrc);
	//Count number of dark field tiff files in source directory
	numTiff = 0;
	filenum = 0;
	while (filenum < fileList.length) {
    	id = fileList[filenum++];
    	if(endsWith(dirSrc + id, ".tiff") || endsWith(dirSrc + id, ".tif")){
        	numTiff++;
    	}
	}
	setBatchMode(true);
	for (tiffc=0; tiffc<numTiff; tiffc++){
		open(fileList[tiffc]);
		if(fileList[tiffc] == "dark_0.tif"){
			saveAs("Tiff", dirSrc+"dark_00.tif");
			File.delete(dirSrc+fileList[tiffc]);
		}
		if(fileList[tiffc] == "dark_1.tif"){
			saveAs("Tiff", dirSrc+"dark_01.tif");
			File.delete(dirSrc+fileList[tiffc]);
		}
		if(fileList[tiffc] == "dark_2.tif"){
			saveAs("Tiff", dirSrc+"dark_02.tif");
			File.delete(dirSrc+fileList[tiffc]);
		}
		if(fileList[tiffc] == "dark_3.tif"){
			saveAs("Tiff", dirSrc+"dark_03.tif");
			File.delete(dirSrc+fileList[tiffc]);
		}
		if(fileList[tiffc] == "dark_4.tif") {
			saveAs("Tiff", dirSrc+"dark_04.tif");
			File.delete(dirSrc+fileList[tiffc]);
		}
		if(fileList[tiffc] == "dark_5.tif"){
			saveAs("Tiff", dirSrc+"dark_05.tif");
			File.delete(dirSrc+fileList[tiffc]);
		}
		if(fileList[tiffc] == "dark_6.tif"){
			saveAs("Tiff", dirSrc+"dark_06.tif");
			File.delete(dirSrc+fileList[tiffc]);
		}
		if(fileList[tiffc] == "dark_7.tif"){
			saveAs("Tiff", dirSrc+"dark_07.tif");
			File.delete(dirSrc+fileList[tiffc]);
		}
		if(fileList[tiffc] == "dark_8.tif"){
			saveAs("Tiff", dirSrc+"dark_08.tif");
			File.delete(dirSrc+fileList[tiffc]);
		}
		if(fileList[tiffc] == "dark_9.tif"){
			saveAs("Tiff", dirSrc+"dark_09.tif");
			File.delete(dirSrc+fileList[tiffc]);
		}
		close();
	}
	fileList = getFileList(dirSrc);
	for (tiffc=0; tiffc<numTiff; tiffc++){
		if (startsWith(fileList[tiffc],  "dark")){
			open(fileList[tiffc]);
		}
	}
	//remove scale
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	tiffc = 0;
	dirDest = getDirectory("Select Output Directory");
	File.makeDirectory(dirDest);
	run("Set Measurements...", "  standard redirect=None decimal=6");
	for (i=0; i<numTiff/2; i++){
		imageCalculator("Subtract create 32-bit", fileList[tiffc], fileList[tiffc+1]);
		roiManager("Measure");
		getStatistics(stdDev);
		tiffc+=2;
		close();
	} 
	selectWindow("Results");'
	dark_stddev = newArray(nResults);
	row = "dark-field noise (DN)";
	for (i=0; i<nResults; i++) 
	{ 	dark_stddev[i] = getResult("StdDev", i)/sqrt(2);
     	row = row + ',' + dark_stddev[i]; 
  	} 
  	dark_stddev_stat = Array.getStatistics(dark_stddev, min, max, mean, stdDev);
  	File.append(row, dirDest + "darkflat_noise.csv"); 
	run("Images to Stack", "name=Stack title=[] use");
	run("Z Project...", "projection=[Sum Slices]");
	run("Divide...", "value="+numTiff);
	saveAs("Tiff", dirDest + "dark_sum");
	//Cleanup
	run("Clear Results");
    run("Close All");
    return toString(dark_stddev_stat[2] + " " + dirDest);

}	    

