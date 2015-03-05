run("Clear Results");
run("Set Measurements...", "  mean redirect=None decimal=6");
height=getHeight();
width=getWidth();
makeRectangle(round(width/3),round(height/8),width/3,height/4);
run("Measure");
makeRectangle(round(width/4),round(height*3/8),width/2,height/4);
run("Measure");
makeRectangle(round(width/3),round(height*5/8),width/3,height/4);
run("Measure");

meas=newArray(nResults);
for (i=0;i<nResults;i++){
	meas[i] = getResult("Mean", i); 
}
selectWindow("Results");
run("Close");
Array.print(meas);

