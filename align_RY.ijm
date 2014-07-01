/************************************************************
This macro currently only works for imgXaxis=labX,imgYaxis=labY.
 It requires a line selection over the edge of a gold strip reflection to be 
 aligned with lab Y. The starting and ending point of the line segment
 should fall on the ends of the gold strip reflection.
 
 It assumes that g0 and g2 faces positive labY, g1 faces negative labY.
 
 It needs the param.txt file in the image directory, and the txt file
 accompanying the image.
 
 The output string is 
 "RY_motor="+RYmotname+",RYmotval="+toString(RYmotval,7)+",RYmotdest="+toString(RYmotdest, 7)

hw 2014/3/4
************************************************************/
macro "align_RZ"{
	//Check for straight line selection, if not exit
	if(!(selectionType()==5 )){
		exit("Selection must be a straight line");
	}

////////////////////////////////////////////////////////////////////////////////
//Set up variables
	List.setList(runMacro("select_grating", List.getList));
 	grtnum=List.getValue("grtnum");
	ggrtnum=List.get("ggrtnum");

	filebase=List.get("filebase"); 
	ss_g_dist=List.getValue("ss_g_dist");
	cam_pixsize=List.getValue("cam_pixsize");
	ss_phos_dist=List.getValue("ss_phos_dist");
	mirror_rad=List.getValue("mirror_rad");
	sin_phos=List.getValue("sin_phos");
	cos_phos=List.getValue("cos_phos");

	RYmotname=List.get("RYmotname");
	RYmotstep=List.getValue("RYmotstep");
	RYmotval=List.getValue("RYmotval");

	g_facing=List.get("g_facing");

////////////////////////////////////////////////////////////////////////////////
//Calculate move

	//Get the starting and ending coords of the line selection
	getLine(x1, y1, x2, y2, lineWidth);

	//calculate the projected coordinates of the line segment in the XZ plane of the grating,
	// then rotation around RY, depending on the grating facing Y or -Y.
	scalef=ss_g_dist/(y1*cam_pixsize*cos_phos+ss_phos_dist);
	x1=x1*cam_pixsize*scalef ; //in mm
	scalef=ss_g_dist/(y2*cam_pixsize*cos_phos+ss_phos_dist);
	x2=x2*cam_pixsize*scalef ; //in mm
	z2=(y2-y1)/abs(y2-y1)*mirror_rad*1.5;
	z1 = 0;
	if(g_facing == "-Y"){RYval=atan((x2-x1)/(z2-z1));}
	if(g_facing == "Y"){RYval=-atan((x2-x1)/(z2-z1));}

	RYvaldeg=RYval*180/PI;
	//print("\\Clear");
	//print("RYval="+toString(RYvaldeg, 7));

	//Destination of RY motor in degrees.
	RYmotdest= round((RYmotval-RYval*180/PI)/RYmotstep)*RYmotstep;
	List.set("RYmotdest",RYmotdest);
////////////////////////////////////////////////////////////////////////////////
//Move gratings

	List.set("movemot","RYmot");
	runMacro("move_motor", List.getList);
}

