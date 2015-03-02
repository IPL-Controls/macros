//Get Input Settings
Dialog.create("DCRaw Batch");
Dialog.addCheckbox("Doc Mode w/o Scaling", false);
Dialog.addCheckbox("Bin Image", true);
Dialog.addNumber("Bin X/Y:", 2);
Dialog.addCheckbox("Convert to 32bit", false);
Dialog.show();
doc = Dialog.getCheckbox();
bin = Dialog.getCheckbox();
conv = Dialog.getCheckbox();
binnum = Dialog.getNumber();
filetype = Dialog.getChoice();

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

//Setup Doc mode
if (doc){
      docmode="document_mode_without_scaling ";
         } 
else{
      docmode="";
}

//Run the batch loop
while (fileNumber < fileList.length) {
    id = fileList[fileNumber++];

    if(endsWith(dirSrc + id, ".nef")){
        print(toString(fileNumber) + "/" + toString(numNefs) + ": " + id);
        // Read input image
        run("DCRaw Reader...",
            "open=[" + dirSrc + id + "] " +
            "use_temporary_directory " +
            "white_balance=[None] " +
            "do_not_automatically_brighten " +
            "output_colorspace=[raw] " +
            //"document_mode " +
            docmode +
            "read_as=[16-bit linear] " +
            "interpolation=[High-speed, low-quality bilinear] " +
            //"half_size " +
            //"do_not_rotate " +
            //"show_metadata" +
            "");
        idSrc = getImageID();

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
 	
 	// Save result
        saveAs("Tiff", dirDest + id);

        // Cleanup
        if (isOpen(idSrc)) {
            selectImage(idSrc);
            close();
            }   
    }    
}
print(caption + " - Completed");
