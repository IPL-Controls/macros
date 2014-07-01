//Macro that returns vertical edge points along a box selection.
//Called as runMacro("find_horizontal_edge", "npoints=#"),
//npoints is the number of desired points along the edge. HW 2014/4/10
macro "find_horizontal_edge" {
argStr = getArgument();
nsections = runMacro("get_valstr","npoints=,"+argStr);
nsections = parseInt(nsections);

Roi.getBounds(Xc0,Yc0,Wc0,Hc0); //Get the position of the rect. ROI.	

run("Duplicate...", "title=cropped");

//Use green channel only.
runMacro("keep_green_channel");
greenimg = getTitle();

width = getWidth();
height = getHeight();
resstr = "";
Hc = height;
Wc = round(width/nsections);

//Divide the ROI into horizontal sections
for(i=0;i<nsections;i++)
{
	Xc = round(i*width/nsections);
	Yc = 0;
	makeRectangle(Xc,Yc,Wc,Hc);
	edgey=runMacro("single_edge_horizontal");
	edgey=parseFloat(edgey)+Yc0;
	x=Xc+round(Wc/2);
	resstr = resstr+"x="+toString(x)+",y="+toString(edgey, 2)+",";		
}
//print(resstr);

selectWindow(greenimg);
close();
return resstr;
}
