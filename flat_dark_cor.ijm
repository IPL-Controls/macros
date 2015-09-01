// Select the file directories for the images to be corrected
// and the correction images.
/* 
 * Makes tiff stacks in batch mode.
 *  
 *  __author__			=	'Alejandro Morales'
 *  __status__          =   "stable"
 *  __date__            =   "8/31/15"
 *  __version__         =   "1.0"
 *  __to-do__			=   
 *  __update-log__		= 	8/24/15: First time push
 *  						8/31/15: Updated the user interface
 */

macro "dark_flat_cor" {

Dialog.create("Dark Flat Correction");
corrarray = newArray("Dark Correction", "Dark + Flat Correction", "Master Dark File Only", "Master Flat + Dark File Only");
Dialog.addRadioButtonGroup("Choose correction", corrarray 2, 1, "Dark Correction");
Dialog.show();
corrtype = Dialog.getRadioButton();

//
maindir = getDirectory("Choose the raw images folder");
if(corrtype == corrarray[1] || corrtype == corrarray[3]) {
	flatdir = getDirectory("Choose the flat field folder");
} 
darkdir = getDirectory("Choose the dark field folder");
exptdir = getDirectory("Choose the correction export folder");
start = getTime();
// Get the file lists inside of the respective directories.
mainlist = getFileList(maindir);
flatlist = getFileList(flatdir);
darklist = getFileList(darkdir);
setBatchMode(true);
for(i=0; i<flatlist.length; i++){
	open(flatdir+flatlist[i]);
}
run("Images to Stack", "name=FlatStack title=[] use");
for(i=0; i<darklist.length; i++){
	open(darkdir+darklist[i]);
}
run("Images to Stack", "name=DarkStack title=[] use");
run("Z Project...", "projection=[Average Intensity]");
darkID = getImageID();
close("DarkStack");
save(darkdir + "average_darkfield");
selectWindow("FlatStack");
run("Z Project...", "projection=[Average Intensity]");
flatID = getImageID();
close("FlatStack");
save(flatdir + "average_flatfield);
imageCalculator("subtract create 32-bit", flatID, darkID);
correctedflatID = getImageID();
selectImage(flatID);
close();
if(nResults > 0) {
	IJ.deleteRows(0, nResults);
}
run("Measure");
MeanFlat = getResult("Mean",0);
selectWindow("Results");
run("Close");
imageCalculator("divide create 32-bit", correctedflatID, correctedflatID);
run("Multiply...", "value=MeanFlat");
blankimageID = getImageID();
imageCalculator("divide create 32-bit", correctedflatID, blankimageID);
normcorrectedflatID = getImageID();
selectImage(blankimageID);
close();
selectImage(correctedflatID);
close();
for(i=0; i<mainlist.length; i++){
	if (!endsWith(mainlist[i], "/")) {
	showProgress(i, mainlist.length);
	open(maindir+mainlist[i]);
	imageID = getImageID();
	imageCalculator("subtract 32-bit", imageID, darkID);
	darkcorrimage = getImageID();
	selectImage(imageID);
    close();
	imageCalculator("divide 32-bit", darkcorrimage, normcorrectedflatID);
    //if(corrtype == corrarray[1]) {
    //save(exptdir + "flatdarkcorr" + mainlist[i]);
    //}
    save(exptdir + "flatdarkcorr" + mainlist[i]);
    close();
	}
}
selectImage(darkID);
close();
selectImage(normcorrectedflatID);
close();
print((getTime()-start)/1000 + " seconds");
}