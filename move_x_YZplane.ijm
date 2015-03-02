
macro "move_x"{
	//Check for point or box selection, if not exit
	if(!(selectionType()==0 || selectionType==10 )){
	exit("Selection must be a point or a rectangle");
	}

////////////////////////////////////////////////////////////////////////////////
//Set up variables
	//Prompt user for grating number and make appropriate substitutions in the list
 	List.setList(runMacro("select_grating", List.getList));
 	grtnum=List.getValue("grtnum");
	ggrtnum=List.get("ggrtnum");

	filebase=List.get("filebase"); 
	ss_g_dist=List.getValue("ss_g_dist");
	cam_pixsize=List.getValue("cam_pixsize");
	ss_phos_dist=List.getValue("ss_phos_dist");
	xpix_yz_plane = List.getValue("xpix_yz_plane"); //x position
		//of the YZ plane as it appears in the image, in pixels
		//relative to the edge of the FOV.
//	print("xpix_yz_plane "+xpix_yz_plane);
	
	Xmotname=List.get("Xmotname");
	Xmotval=List.getValue("Xmotval");
	Xmotstep=List.getValue("Xmotstep");

////////////////////////////////////////////////////////////////////////////////
//Calculate move
	
	if(selectionType()==10){
		getSelectionCoordinates(x,y);
		distFromYZPlane=xpix_yz_plane-x[0];
	}
	if(selectionType()==0){
		getSelectionBounds(x0,y0,width,height);
		distFromYZPlane=xpix_yz_plane-(x0+(width/2));
	}

	L_p=ss_phos_dist/ss_g_dist;
	distToMove=distFromYZPlane*cam_pixsize/L_p;
	Xmotdest=Xmotval+distToMove;

//print("Xmotdest "+Xmotdest);

	
	List.set("Xmotdest",Xmotdest);

	/*DEBUG
	print("distance from center in units is " + distToMove);
	print("current x motor value is " + Xmotval);
	print("destination is " + Xmotdest); 
	*/

////////////////////////////////////////////////////////////////////////////////
//Move gratings

	List.set("movemot","Xmot");
	runMacro("move_motor", List.getList);
}
