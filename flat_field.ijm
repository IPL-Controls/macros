//This version performs and iterative subtraction of successive dark-field frames to find the dark-field noise and
// averages all the dark-field frames. 
// AP
// 12/17/2014

runMacro("dark_field");
macro "flat_field"{
	//Get File Directories and file names
	
	dirFlat_0 = getDirectory("Select Flat-field-0 Directory");
	flat_0 = getFileList(dirFlat_0);
	
	dirFlat_1 = getDirectory("Select Flat-field-1 Directory");
	flat_1 = getFileList(dirFlat_1);
	
	dirdarkSum = getDirectory("Select Dark-sum-Output Directory");
	dark_sum = getFileList(dirdarkSum);

	dirDest = getDirectory("Select data output Directory");
	File.makeDirectory(dirDest);
	
	numTiff = 0;
	filenum = 0;
	
	while (filenum < flat_0.length) {
    	id = flat_0[filenum++];
    	if(endsWith(dirFlat_0 + id, ".tiff") || endsWith(dirFlat_0 + id, ".tif")){
        	numTiff++;
    	}
	}
	setBatchMode(true);
	for (tiffc=0; tiffc<numTiff; tiffc++){
		open(dirFlat_0 + flat_0[tiffc]);
		if(flat_0[tiffc] == "flat_0.tif"){
			saveAs("Tiff", dirFlat_0 + "flat_00.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_1.tif"){
			saveAs("Tiff", dirFlat_0 + "flat_01.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_2.tif"){
			saveAs("Tiff", dirFlat_0 + "flat_02.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_3.tif"){
			saveAs("Tiff", dirFlat_0 + "flat_03.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_4.tif"){
			saveAs("Tiff", dirFlat_0 + "flat_04.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_5.tif"){
			saveAs("Tiff", dirFlat_0 + "flat_05.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_6.tif"){
			saveAs("Tiff", dirFlat_0 + "flat_06.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_7.tif"){
			saveAs("Tiff", dirFlat_0 + "flat_07.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_8.tif"){
			saveAs("Tiff", dirFlat_0 + "flat_08.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_9.tif"){
			saveAs("Tiff", dirFlat_0 + "flat_09.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
			close();
	}
	flat_0 = getFileList(dirFlat_0);

	for (tiffc=0; tiffc<numTiff; tiffc++){
		open(dirFlat_1 + flat_1[tiffc]);
		if(flat_1[tiffc] == "flat_0.tif"){
			saveAs("Tiff", dirFlat_1 + "flat_00.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_1.tif"){
			saveAs("Tiff", dirFlat_1 + "flat_01.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_2.tif"){
			saveAs("Tiff", dirFlat_1 + "flat_02.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_3.tif"){
			saveAs("Tiff", dirFlat_1 + "flat_03.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_4.tif"){
			saveAs("Tiff", dirFlat_1 + "flat_04.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_5.tif"){
			saveAs("Tiff", dirFlat_1 + "flat_05.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_6.tif"){
			saveAs("Tiff", dirFlat_1 + "flat_06.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_7.tif"){
			saveAs("Tiff", dirFlat_1 + "flat_07.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_8.tif"){
			saveAs("Tiff", dirFlat_1 + "flat_08.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_9.tif"){
			saveAs("Tiff", dirFlat_1 + "flat_09.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
			close();
	}
	flat_1 = getFileList(dirFlat_1);
	
	for (i=0; i<dark_sum.length; i++){
    	if(endsWith(dirdarkSum + dark_sum[i], ".tiff") || endsWith(dirdarkSum + dark_sum[i], ".tif")){
        	open(dirdarkSum + File.separator + dark_sum[i]);
        	did = getImageID();
    	}
	}
	run("Set Measurements...", "  standard redirect=None decimal=6");
	for (tiffc=0; tiffc<numTiff; tiffc++){
		open(dirFlat_0 + File.separator + flat_0[tiffc]);
		id1 = getImageID();
		open(dirFlat_1 + File.separator + flat_1[tiffc]);
		id2 = getImageID();
		imageCalculator("Subtract create 32-bit", id1, id2);
		roiManager("Measure");
		getStatistics(stdDev);
		close();
	}
	selectWindow("Results");
	saveAs("Measurements", dirDest + "flat_noise.csv");
	run("Clear Results");
	run("Set Measurements...", "  mean redirect=None decimal=6");
	for (tiffc=0; tiffc<numTiff; tiffc++){
		open(dirFlat_0 + File.separator + flat_0[tiffc]);
		id1 = getImageID();
		open(dirFlat_1 + File.separator + flat_1[tiffc]);
		id2 = getImageID();
		imageCalculator("Average create 32-bit", id1, id2);
		imageCalculator("Subtract create 32-bit", "Result of " + flat_0[tiffc], did);
		roiManager("Measure");
		getStatistics(mean);
		close();
	}
	selectWindow("Results");
	saveAs("Measurements", dirDest + "flat_corr_mean.csv");
	// Clean-up
    run("Close All");
	print(" - Completed");
}