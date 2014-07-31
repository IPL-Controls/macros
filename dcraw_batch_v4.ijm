//This version takes the raw data in document mode without any scaling
//etc, and does an RMS averaging over either 2x2
// blocks or higher, then write back to a floating tiff file. 
// 4/30/2014
//V4 Keep only green channel, before binning. 7/25/2014


//Get Input Setting
Dialog.create("DCRaw Batch v2");
Dialog.addMessage("Bin factor must be an even number!");
//Dialog.addCheckbox("Doc Mode w/o Scaling", false);
//Dialog.addCheckbox("Bin Image", true);
Dialog.addNumber("Bin X/Y:", 2);
//Dialog.addCheckbox("Convert to 32bit", false);
Dialog.show();
//doc = Dialog.getCheckbox();
//bin = Dialog.getCheckbox();
//conv = Dialog.getCheckbox();
binnum = Dialog.getNumber();
//filetype = Dialog.getChoice();

//Get File Directory and file names
dirSrc = getDirectory("Select Input Directory");
dirDest = getDirectory("Select Output Directory");
fileList = getFileList(dirSrc);
caption = "dcraw batch converter";


//Count number of NEF files in source directory
numNefs = 0;
filenum = 0;
while (filenum < fileList.length) {
    id = fileList[filenum++];
    if(endsWith(dirSrc + id, ".nef")){
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

/*
//Setup Doc mode
if (doc){
      docmode="document_mode_without_scaling ";
         } 
else{
      docmode="";
}
*/

//Run the batch loop
nefc = 0;
while (fileNumber < fileList.length) {
    id = fileList[fileNumber++];

//Dcraw reads in the raw pixel data.
    if(endsWith(dirSrc + id, ".nef")){
    	nefc+=1;
        print(toString(nefc) + "/" + toString(numNefs) + ": " + id);
        // Read input image
        run("DCRaw Reader...",
            "open=[" + dirSrc + id + "] " +
            "use_temporary_directory " +
            "white_balance=[None] " +
            "do_not_automatically_brighten " +
            "output_colorspace=raw " +
            //"document_mode_without_scaling " + 
            "read_as=[16-bit linear] " +
            "interpolation=[High-speed, low-quality bilinear] " +
            "do_not_rotate " +
            //"show_metadata" +
            "");

           run("Stack to Images");
           selectWindow("Red");
           close();
           selectWindow("Blue");
           close();
           selectWindow("Green");

        idSrc = getImageID();

//Do scaling
	width = getWidth();
	height = getHeight();
	scwidth = toString(round(width/binnum));
	scheight = toString(round(height/binnum));
	scalef = toString(1.0/binnum, 3);
	run("32-bit");
	run("Scale...", "x="+scalef+" y="+scalef+" width="+scwidth+" height="+scheight+" interpolation=None average create title=tempimg");       
/*
        //Only preserve green channel if document mode is NOT selected
	if (doc){
           } 
	else{
           run("Stack to Images");
           selectWindow("Green");
	   }
         
        //Bin and convert to 32bit if applicable
        if (bin) {
            run("Bin...", "x=" + binnum + " y=" + binnum + " bin=Average");
            }   
        if (conv) {
            run("32-bit");
            }   
*/ 	
 	// Save result
        saveAs("Tiff", dirDest + id);

        // Cleanup
        if (isOpen(idSrc)) {
            selectImage(idSrc);
            close();
            }
        if (isOpen("tempimg")) {
            selectImage("tempimg");
            close();
            }
    }    
}
print(caption + " - Completed");
