/* Automated procedure for the calcium particle detection and measurements.
 * 
 * Report any bugs or questions to alegmoralesm@gmail.com
 *  
 *  __author__			=	'Alejandro Morales'
 *  __bug fixes__		= 	
 *  __status__          =   "stable" 

 *  __date__            =   "11/13/15"
 *  __version__         =   "2.0"
 *  __to-do__			=   work on error checking, 
 *  __update-log__		= 	"12/8/15" Added the data collection side and bug tested. AM
 *  						
 *  						
 *  						
 */

macro "ROI_particle_detection" {

roiManager("reset");
run("ROI Manager...");

setBatchMode(true); // Runs the process in the background
open(File.openDialog("Open the detection file"));
detectionID = getImageID();
selectImage(detectionID);
name = File.name;

//makePoint(0, 0);
//roiManager("Add");
run("Duplicate...", "Gauss Filter");
gaussID = getImageID();
run("Gaussian Blur...", "sigma=25");
imageCalculator("subtract create 32-bit", detectionID, gaussID);
filteredID = getImageID();
close("Gauss Filter");
selectImage(detectionID)
setBatchMode("show");
selectImage(filteredID);
setBatchMode("show");
run("Threshold...");
waitForUser("Select threshold settings");
//setBatchMode("show");
run("Analyze Particles...");
//analyzedID = getImageID();
//close("filteredID");
//close("analyzedID");
//selectImage(detectionID);
//setBatchMode(false);

if (nResults > 0) 
{
   IJ.deleteRows(0, nResults);
}

a = newArray(roiManager("count"));
x = newArray(roiManager("count"));
y = newArray(roiManager("count"));

for (i=0; i<roiManager("count"); i++) 
{ 
	roiManager("Select",i);
	roiManager("Measure");
	x[i] = getResult("X", i);
	y[i] = getResult("Y", i);
}

run("Close");
close();
selectWindow(name);
setBatchMode("show");
roiManager("Show All with Labels");
setTool("rectangle");
waitForUser("Select main ROI");
setBatchMode("hide");
p = 0;

for (i=0; i<roiManager("count"); i++)
{ 
	if (!Roi.contains(x[i],y[i])) 
		{
			a[p] = i;
			p = p + 1; 
		}
}

roiManager("Deselect");
roiManager("Select",a);
roiManager("Select",a[p]);
roiManager("Delete");

for (i=1; i<=roiManager("count"); i++)
{
	roiManager("Select", i-1);
	roiManager("Rename", "ROI-" + i);
}

Number = newArray(roiManager("count"));
Area = newArray(roiManager("count"));
MeanInt = newArray(roiManager("count"));
RefInt = newArray(roiManager("count"));
ShortAx = newArray(roiManager("count"));
LongAx = newArray(roiManager("count"));

if (nResults > 0) 
{ 
   IJ.deleteRows(0, nResults);
}


for (i=0; i<roiManager("count"); i++)
{
	roiManager("Select", i);
//	run("Fit Ellipse");
 	run("Set Measurements...", "area mean centroid fit redirect=None decimal=3");
	run("Measure");
	Number[i] = i + 1;
	Area[i] = getResult("Area", i);
	MeanInt[i] = getResult("Mean",i);
	LongAx[i] = getResult("Major", i);
	ShortAx[i] = getResult("Minor", i);
}

IJ.deleteRows(0, nResults);
num = roiManager("count");
for (i=0; i<num; i++)
{
	roiManager("Select", i);
	run("Select Bounding Box");
	roiManager("Add");
	roiManager("Select", newArray(i,num));
	roiManager("XOR");
	run("Measure");
	RefInt[i] = getResult("Mean",i);
	roiManager("Deselect");
 	roiManager("Select", num);
	roiManager("Delete");
}

run("Close");
Array.show("Measurements", Number, Area, MeanInt, RefInt, ShortAx,LongAx);
//savepath = getDirectory("Choose a folder to save the results in");
//saveAs("Measurements", savepath + "Measurements.xls");
setBatchMode(false);

}