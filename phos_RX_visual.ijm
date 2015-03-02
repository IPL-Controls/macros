//********************************
//Align the RX angle of the phosphor to the focal plane.
//Have vertical lines on the left and right edges of the FOV. 
//Shift the right line near the left and see how parallel they are.
// hw 6/8/2014
//********************************

runMacro("keep_green_channel");
orgimg=getTitle();
run("Duplicate...", "title=temp");
run("Translate...", "x=-2270 y=0 interpolation=None");
imageCalculator("subtract create", orgimg,"temp");
rename(orgimg+"_RX");
selectWindow("temp");
close();
selectWindow(orgimg+"_RX");