
////////////////////////////////////////////////////////////////////////////////
//Set up variables
	List.setList(runMacro("select_grating", List.getList));
 	grtnum=List.getValue("grtnum");
	ggrtnum=List.get("ggrtnum");

	filebase=List.get("filebase"); 
	itxtfile=List.get("itxtfile");
	ss_g_dist=List.getValue("ss_g_dist");
	cam_pixsize=List.getValue("cam_pixsize");
	ss_phos_dist=List.getValue("ss_phos_dist");
    	mirror_rad=List.getValue("mirror_rad");
	sin_phos=List.getValue("sin_phos");
	cos_phos=List.getValue("cos_phos");

	RZmotname=List.get("RZmotname");
	RZmotstep=List.getValue("RZmotstep");
	RZmotval=List.getValue("RZmotval");

////////////////////////////////////////////////////////////////////////////////
height = getHeight();

//Get the edge X, Y coordinates relative to corner of image.
xystr = runMacro("find_horizontal_edge", "npoints=6");
xstr = runMacro("get_valstr", "x=,"+xystr);
xstr=split(xstr,",\n\r");
npts = xstr.length;
absxvals = newArray(npts);
for(i=0;i<npts;i++){absxvals[i] = parseFloat(xstr[i]);}

ystr = runMacro("get_valstr", "y=,"+xystr);
ystr=split(ystr,",\n\r");
absyvals = newArray(npts);
for(i=0;i<npts;i++){absyvals[i] = parseFloat(ystr[i])-round(height/2);}
//Array.print(absxvals);
//Array.print(absyvals);

//Calculate physical X and Y coordinates

//Calculate move
	//calculate projected coordinates on the lab XY plane at grating
xlab = newArray(npts);
ylab = newArray(npts);
	
for(i=0;i<npts;i++) {
	scalef=ss_g_dist/(absyvals[i]*cam_pixsize*cos_phos+ss_phos_dist);
	xlab[i]=absxvals[i]*cam_pixsize*scalef ; //in mm
	ylab[i]=absyvals[i]*cam_pixsize*(-sin_phos)*scalef ; //in mm
}	
//Calculate a slope (d ylab/d xlab) by linear fitting;
Fit.doFit("Straight Line", xlab, ylab);
slope = Fit.p(1);
	//Calculate RZ angle in lab XY plane, CC from X axis, from -pi to pi
	RZval=atan(slope); //in radians
	RZvaldeg=RZval*180/PI;
	//print("\\Clear");
	//print("RZval="+toString(RZvaldeg, 7));

	//Destination of RZ motor in degrees.
	RZmotdest= round((RZmotval-RZval*180/PI)/RZmotstep)*RZmotstep;
	List.set("RZmotdest",RZmotdest);

////////////////////////////////////////////////////////////////////////////////
//Move gratings

	List.set("movemot","RZmot");
	runMacro("move_motor", List.getList);

