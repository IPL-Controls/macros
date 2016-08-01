//Align the RZ and Y of a fitted edge to target values in param.txt.
// Y target and measured positions are all projected positions on the image in mm, at the center of the image width. 
//	HW 3/30/2015
////////////////////////////////////////////////////////////////////////////////
//Set up variables
	List.setList(runMacro("select_grating", List.getList));
 	grtnum=List.getValue("grtnum");
	ggrtnum=List.get("ggrtnum");

	filebase=List.get("filebase"); 
	itxtfile=List.get("itxtfile");
	ss_g_dist=List.getValue("ss_g_dist");
	foc_ss_dist = List.getValue("foc_ss_dist");
	cam_pixsize=List.getValue("cam_pixsize");
	ss_phos_dist=List.getValue("ss_phos_dist");
    mirror_rad=List.getValue("mirror_rad");
	sin_phos=List.getValue("sin_phos");
	cos_phos=List.getValue("cos_phos");
	RZ_targ = List.getValue("RZ_targ");
	Y_targ = List.getValue("Y_targ");

	RZmotname=List.get("RZmotname");
	RZmotstep=List.getValue("RZmotstep");
	Ymotstep = List.getValue("Ymotstep");
	RZmotval=List.getValue("RZmotval");
	Ymotval = List.getValue("Ymotval");

////////////////////////////////////////////////////////////////////////////////
height = getHeight();
width = getWidth();
orgimg = getTitle();

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
	ylab[i]=absyvals[i]*cam_pixsize*(-sin_phos)*scalef ; //in mm

	scalef=(ss_g_dist+foc_ss_dist)/(absyvals[i]*cam_pixsize*cos_phos+ss_phos_dist+foc_ss_dist);
	xlab[i]=(absxvals[i]-round(width/2))*cam_pixsize*scalef ; //in mm
	
}	
//Calculate a slope (d ylab/d xlab) by linear fitting;
Fit.doFit("Straight Line", xlab, ylab);
slope = Fit.p(1);

	//Calculate RZ angle in lab XY plane, CC from X axis, from -pi to pi
	RZval=atan(slope); //in radians
	RZvaldeg=RZval*180/PI;

//Calculate a Y offset in the image plane
Fit.doFit("Straight Line", absxvals, absyvals);
slopei = Fit.p(1);
yoffseti = Fit.p(0);

//Draw the fit line on image
	if(List.get("drawline")==true){
		selectWindow(orgimg);
		setColor("red");
		setLineWidth(4);
		drawLine(0, yoffseti+round(height/2), width, slopei*width+yoffseti+round(height/2));
	}
	//Calculate the Y position of the fit line on the image plane at center of image width, in mm, 
	//relative to the center of the image.
	yimgcntr = yoffseti*cam_pixsize*(-sin_phos); //in mm vertical image plane

	print("\\Clear");
	print("RZvaldeg="+toString(RZvaldeg, 7));
	print("Edge Y rel. to image center ="+toString(yimgcntr, 7));

	//Destination of RZ motor in degrees.
	RZmotdest= round((RZmotval+RZ_targ-RZval*180/PI)/RZmotstep)*RZmotstep;
	List.set("RZmotdest",RZmotdest);

		//Destination of Y motor in mm.
	scalef = ss_g_dist/ss_phos_dist;	
	Ymotdest= round((Ymotval+(Y_targ-yimgcntr)*scalef)/Ymotstep)*Ymotstep;
	List.set("Ymotdest",Ymotdest);


////////////////////////////////////////////////////////////////////////////////
//Move gratings

	List.set("movemot","RZmot");
	runMacro("move_motor", List.getList);

	List.set("movemot","Ymot");
	runMacro("move_motor", List.getList);

