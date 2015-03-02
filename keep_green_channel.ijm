//Takes a jpg image, keeps the green channel, and display it
//	with auto-adjusted contrast.
// HW 2014-2-25
macro keep_green_channel{
imgName=getTitle(); 
//baseNameEnd=indexOf(imgName, ".jpg"); 
//baseName=substring(imgName, 0, baseNameEnd); 

run("Split Channels"); 
selectWindow(imgName + " (blue)"); 
close();
selectWindow(imgName + " (red)"); 
close();
selectWindow(imgName + " (green)"); 
run("32-bit");
run("Enhance Contrast", "saturated=0.35");
rename(imgName);
}
