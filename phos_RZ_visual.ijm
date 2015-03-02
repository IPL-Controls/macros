//********************************
//Align the RY angle of the phosphor to the focal plane.
//Have horizontal lines near the top and bottom edges of the FOV. 
//Shift the bottom line up  near the top line, and see how parallel they are.
// hw 6/8/2014
//********************************
runMacro("keep_green_channel");
orgimg=getTitle();
run("Duplicate...", "title=temp");
run("Translate...", "x=0 y=-1820 interpolation=None");
imageCalculator("subtract create", orgimg,"temp");
rename(orgimg+"_RY");
selectWindow("temp");
close();
selectWindow(orgimg+"_RY");