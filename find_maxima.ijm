//Input string is "Title = imgName".
//	Output string is "X = xcoord[0], Y = ycoord[0], Peakval = peakvalue[0],
//	X = xcoord[1], Y = ycoord[1], Peakval = peakvalue[1]".
//	hw 2-26-2014
macro "find_maxima"{
argstr = getArgument();
imgName = runMacro("get_valstr", "Title,"+argstr);

selectWindow(imgName);

run("Duplicate...", "title=tmp_img");

run("Clear Results"); 

run("Find Maxima...", "noise=10 output=[Point Selection]");
getSelectionCoordinates(xcoords, ycoords); 
nmaxima = xcoords.length;
peakvals = newArray(nmaxima);

makeSelection("point",xcoords, ycoords); 
run("Set Measurements...", " mean"); 
run("Measure");

for (i=0;i<nResults;i++){
	peakvals[i] = getResult("Mean", i); 
}

outstr = "X="+xcoords[0]+",Y="+ycoords[0]+",Peakval="+peakvals[0]
for (i=1;i<nResults;i++){
	outstr += ",X="+xcoords[i]+",Y="+ycoords[i]+",Peakval="+peakvals[i]; 
}
//print(outstr);
selectWindow("Results");
run("Close");
selectWindow("tmp_img");
close();
return outstr;
}
