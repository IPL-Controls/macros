/* Automated procedure for the calcium particle detection and measurements.
 * 
 * Report any bugs or questions to alegmoralesm@gmail.com
 *  
 *  __author__			=	'Alejandro Morales'
 *  __bug fixes__		= 	
 *  __status__          =   "stable" 

 *  __date__            =   "11/13/15"
 *  __version__         =   "1.0"
 *  __to-do__			=   work on error checking, 
 *  __update-log__		= 	
 *  						
 *  						
 *  						
 */

macro "ROI_particle_detection" {

setBatchMode(true); // Runs the process in the background
open(File.openDialog("Open the detection file"));
detectionID = getImageID();
selectImage(detectionID);
name = File.name;
roiManager("reset");
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
setBatchMode(false);

if(nResults > 0) 
	{
		IJ.deleteRows(0, nResults);
	}

a = newArray(roiManager("count"));
x = newArray(roiManager("count"));
y = newArray(roiManager("count"));
area = newArray(roiManager("count"));

for (i=0; i<roiManager("count"); i++) 
{ 
	roiManager("Select",i);
	roiManager("Measure");
	x[i] = getResult("X", i);
	y[i] = getResult("Y", i);
	area[i] = getResult("Mean", i);
}

run("Close");
close();
selectWindow(name);
roiManager("Show All with Labels");
setTool("rectangle");
waitForUser("Select main ROI");
p = 0;

for (i=0; i<roiManager("count"); i++)
{ 
	if (!Roi.contains(x[i],y[i])) 
		{
			a[p] = i;
			p = p + 1; 
		}
}

roiManager("Select",a);
roiManager("Select",a[p-1]);
roiManager("Delete");	

for (i=1; i<=roiManager("count"); i++) 
{
	roiManager("Select", i-1);
	roiManager("Rename", "ROI-" + i);
}
}