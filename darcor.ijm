filenm = File.openDialog("Pick image");
open(filenm);
imgtitle = getTitle();
imageCalculator("Subtract", imgtitle,"dark30sec8bin_avrg.tif");
run("Enhance Contrast", "saturated=0.35");