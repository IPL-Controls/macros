//Merge RGB channels by root mean squared. HW 5/6/2014
macro merge_RGB{
run("RGB Stack");
stackName = getTitle();
run("32-bit");
run("Square", "stack");
run("Z Project...", "start=1 stop=3 projection=[Average Intensity]");
run("Square Root");
run("Enhance Contrast", "saturated=0.35");
mergedName=getTitle();
selectWindow(stackName);
close();
selectWindow(mergedName);
rename("RGBmerged_"+stackName);
}
