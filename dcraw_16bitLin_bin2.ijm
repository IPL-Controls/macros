//Get File Directory and file names
dirSrc = getDirectory("Select Input Directory");
dirDest = getDirectory("Select Output Directory");
fileList = getFileList(dirSrc);
caption = "dcraw batch converter";
 
print(caption + " - Starting");
print("Reading from : " + dirSrc);
print("Writing to   : " + dirDest);
 
// Create output directory
File.makeDirectory(dirDest);
 
setBatchMode(true);
fileNumber = 0;
while (fileNumber < fileList.length) {
    id = fileList[fileNumber++];
 
    print(toString(fileNumber) + "/" + toString(fileList.length) + ": " + id);
 
    // Read input image
    run("DCRaw Reader...",
        "open=" + dirSrc + id + " " +
            "use_temporary_directory " +
            "white_balance=[None] " +
            "do_not_automatically_brighten " +
            "output_colorspace=[raw] " +
//            "document_mode " +
            "document_mode_without_scaling " +
            "read_as=[16-bit linear] " +
            "interpolation=[High-speed, low-quality bilinear] " +
//            "half_size " +
//            "do_not_rotate " +
//            "show_metadata" +
            "");
    idSrc = getImageID();
    run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
    run("32-bit");
    run("Square");
    run("Scale...", "x=0.5 y=0.5 width=2462 height=3689 interpolation=Bilinear average create title=binsqr");
    run("Square Root");
 
    // Save result
    saveAs("Tiff", dirDest + id);
 
    // Cleanup
    if (isOpen(idSrc)) {
        selectImage(idSrc);
        close();
    }
}
print(caption + " - Completed");
