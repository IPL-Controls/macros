//This version performs and iterative subtraction of successive dark-field frames to find the dark-field noise and
// averages all the dark-field frames. 
// AP
// 12/17/2014


macro "flat_field"{
	val = runMacro("dark_field");
	args = split(val, " ");
	dark_noise_mean = args[0];
	dirdarkSum = args[1];
	//Get File Directories and file names
	dirFlat_0 = getDirectory("Select Flat-field-0 Directory");
	flat_0 = getFileList(dirFlat_0);
	dirFlat_1 = getDirectory("Select Flat-field-1 Directory");
	flat_1 = getFileList(dirFlat_1);
	dark_sum = getFileList(dirdarkSum);
	dirDest = getDirectory("Select Output Directory");
	File.makeDirectory(dirDest);
	
	numTiff = 0;
	filenum = 0;
	
	while (filenum < flat_0.length) 
	{
    	id = flat_0[filenum++];
    	if(endsWith(dirFlat_0 + id, ".tiff") || endsWith(dirFlat_0 + id, ".tif"))
    	{
        	numTiff++;
    	}
	}
	setBatchMode(true);
	for (tiffc=0; tiffc<numTiff; tiffc++)
	{
		open(dirFlat_0 + flat_0[tiffc]);
		if(flat_0[tiffc] == "flat_0.tif")
		{
			saveAs("Tiff", dirFlat_0 + "flat_00.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_1.tif")
		{
			saveAs("Tiff", dirFlat_0 + "flat_01.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_2.tif")
		{
			saveAs("Tiff", dirFlat_0 + "flat_02.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_3.tif")
		{
			saveAs("Tiff", dirFlat_0 + "flat_03.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_4.tif")
		{
			saveAs("Tiff", dirFlat_0 + "flat_04.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_5.tif")
		{
			saveAs("Tiff", dirFlat_0 + "flat_05.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_6.tif")
		{
			saveAs("Tiff", dirFlat_0 + "flat_06.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_7.tif")
		{
			saveAs("Tiff", dirFlat_0 + "flat_07.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_8.tif")
		{
			saveAs("Tiff", dirFlat_0 + "flat_08.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		if(flat_0[tiffc] == "flat_9.tif")
		{
			saveAs("Tiff", dirFlat_0 + "flat_09.tif");
			File.delete(dirFlat_0 + flat_0[tiffc]);
		}
		close();
	}
	flat_0 = getFileList(dirFlat_0);
	for (tiffc=0; tiffc<numTiff; tiffc++)
	{
		open(dirFlat_1 + flat_1[tiffc]);
		if(flat_1[tiffc] == "flat_0.tif")
		{
			saveAs("Tiff", dirFlat_1 + "flat_00.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_1.tif")
		{
			saveAs("Tiff", dirFlat_1 + "flat_01.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_2.tif")
		{
			saveAs("Tiff", dirFlat_1 + "flat_02.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_3.tif")
		{
			saveAs("Tiff", dirFlat_1 + "flat_03.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_4.tif")
		{
			saveAs("Tiff", dirFlat_1 + "flat_04.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_5.tif")
		{
			saveAs("Tiff", dirFlat_1 + "flat_05.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_6.tif")
		{
			saveAs("Tiff", dirFlat_1 + "flat_06.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_7.tif")
		{
			saveAs("Tiff", dirFlat_1 + "flat_07.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_8.tif")
		{
			saveAs("Tiff", dirFlat_1 + "flat_08.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		if(flat_1[tiffc] == "flat_9.tif")
		{
			saveAs("Tiff", dirFlat_1 + "flat_09.tif");
			File.delete(dirFlat_1 + flat_1[tiffc]);
		}
		close();
	}
	flat_1 = getFileList(dirFlat_1);
	for (i=0; i<dark_sum.length; i++)
	{
    	if(endsWith(dirdarkSum + dark_sum[i], ".tiff") || endsWith(dirdarkSum + dark_sum[i], ".tif"))
    	{
        	open(dirdarkSum + File.separator + dark_sum[i]);
        	did = getImageID();
    	}
	}
	run("Set Measurements...", "  standard redirect=None decimal=6");
	for (tiffc=0; tiffc<numTiff; tiffc++)
	{
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
	row = "flat-field noise (DN)";
	flat_stddev = newArray(nResults);
	pho_shot_noise = newArray(nResults);
	for (i=0; i<nResults; i++) 
	{ 
		flat_stddev[i] = getResult("StdDev", i)/sqrt(2);
		pho_shot_noise[i] = sqrt(flat_stddev[i] * flat_stddev[i] - dark_noise_mean * dark_noise_mean);
    	row =  row + ',' + flat_stddev[i]; 
  	} 
  	File.append(row, dirDest + "darkflat_noise.csv"); 
	run("Clear Results");
	run("Set Measurements...", "  mean redirect=None decimal=6");
	for (tiffc = 0; tiffc < numTiff; tiffc++)
	{
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
	row = "FPN corrected  mean flat signal (DN)";
	flat_mean = newArray(nResults);
	for (i = 0; i < nResults; i++) 
	{ 
		flat_mean[i] = getResult("Mean", i);
    	row = row +  "," + flat_mean[i]; 
  	} 
    File.append(row, dirDest + "darkflat_noise.csv"); 
    row = "Photon Shot Noise (DN)";
	for (i = 0; i < nResults; i++) 
	{ 
    	row = row +  "," + pho_shot_noise[i]; 
  	} 
    File.append(row, dirDest + "darkflat_noise.csv");
    pho_shot_var = newArray(pho_shot_noise.length);
	row = "Photon Shot Variance (DN^2)";
	for (i = 0; i < pho_shot_noise.length; i++) 
	{ 	
		pho_shot_var[i] = pho_shot_noise[i] * pho_shot_noise[i];
    	row = row +  "," + pho_shot_var[i]; 
  	} 
  	File.append(row, dirDest + "darkflat_noise.csv");
  	setBatchMode(false);
	Fit.doFit("Straight Line", pho_shot_var, flat_mean);
	
	row = "Gain (e/DN)" + "," + d2s(Fit.p(1),6);
	File.append(row, dirDest + "darkflat_noise.csv");

	// Clean-up
	run("Clear Results");
	IJ.run("Close All", "");
	Fit.plot();
	print(" - Completed");
}