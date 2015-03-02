//This version takes the raw data in document mode and then extracts only the green pixels from the 
// RG
// GB 
// quadrants using the translate and scale trick suggested by Han. It inherently bins by two and then further bins the image by the user selected value.
// It saves all nefs from a folder as tiffs, removes their scales, and saves the metadata from the DCRaw macro in their images. 
// AG and HW 
// 7/25/2014
//V5 9/28/2014

//Get binning in the X and Y directions beyond the initial 2x2 bin for green only.
Dialog.create("DCRaw Batch v4");
Dialog.addMessage("Bin factor after binX2 from raw");
Dialog.addString("Bin X, Y:", "");
Dialog.show();
binstr = split(Dialog.getString(), ",");
binx = parseInt(binstr[0]);
biny = parseInt(binstr[1]);

//Get File Directory and file names
dirSrc = getDirectory("Select Input Directory");
dirDest = getDirectory("Select Output Directory");
fileList = getFileList(dirSrc);
caption = "dcraw_v5";


//Count number of NEF files in source directory
numNefs = 0;
filenum = 0;
while (filenum < fileList.length) {
    id = fileList[filenum++];
    if(endsWith(dirSrc + id, ".nef") || endsWith(dirSrc + id, ".NEF")){
        numNefs++;
    }
}    
print(numNefs + " out of " +  fileList.length + " files are NEF");
print(caption + " - Starting");
print("Reading from : " + dirSrc);
print("Writing to   : " + dirDest);
 
// Create output directory
File.makeDirectory(dirDest);
setBatchMode(true);
fileNumber = 0;

//Run the batch loop
nefc = 0;
while (fileNumber < fileList.length) {
    id = fileList[fileNumber++];

//Dcraw reads in the raw pixel data.
    if(endsWith(dirSrc + id, ".nef") || endsWith(dirSrc + id, ".NEF")){
    	nefc+=1;
    	print("\\Clear");
        print(toString(nefc) + "/" + toString(numNefs) + ": " + id);
        // Read input image
        run("DCRaw Reader...",
            "open=[" + dirSrc + id + "] " +
            "use_temporary_directory " +
            "white_balance=[None] " +
            "do_not_automatically_brighten " +
            "output_colorspace=raw document_mode " +
            "document_mode_without_scaling " +
             "read_as=[16-bit linear] " +
            "interpolation=[High-speed, low-quality bilinear] " +
            "show_metadata"+
            "");
        metadata= getInfo("log");
        idSrc = getImageID();
        width = getWidth();
        height = getHeight();
	scwidth = toString(round(width/2));
	scheight = toString(round(height/2));

//Use only the green pixels (RGGB) and average into a bin 2 image
	run("Duplicate...", "title=" + id + "g1.tiff");
	run("Duplicate...", "title=" + id + "g2.tiff");
	
	selectWindow(id + "g1.tiff");
	run("Translate...", "x=-1 y=0 interpolation=None");
	run("Scale...", "x=0.5 y=0.5 width=["+scwidth+"]height=["+scheight+"]interpolation=None create title=["+id + "g1scale.tiff]");
	run("32-bit");
	
	selectWindow(id + "g2.tiff");
	run("Translate...", "x=0 y=-1 interpolation=None");
	run("Scale...", "x=0.5 y=0.5 width=["+scwidth+"] height=["+scheight+"]interpolation=None create title=["+id+ "g2scale.tiff]");
	run("32-bit");
		
	imageCalculator("Add create", id + "g2scale.tiff",id + "g1scale.tiff");
	run("Bin...", "x=" + binx + " y=" + biny + " bin=Average");
	
	//remove scale
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	setMetadata("Info", metadata);
        saveAs("Tiff", dirDest + id);

    //Cleanup windows
    close();
    selectWindow(id + "g1.tiff");
    close();
    selectWindow(id + "g2.tiff");
    close();
    selectWindow(id + "g1scale.tiff");
    close();
    selectWindow(id + "g2scale.tiff");
    close();
    selectImage(idSrc);
    close();
        
    }    
}
print(caption + " - Completed");
