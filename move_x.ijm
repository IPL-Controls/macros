
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
	
	Xmotname=List.get("Xmotname");
	Xmotval=List.getValue("Xmotval");
	Xmotstep=List.getValue("Xmotstep");
	imageCenter=getWidth()/2;

////////////////////////////////////////////////////////////////////////////////
//Calculate move
	
	if(selectionType()==10){
		getSelectionCoordinates(x,y);
		distFromCenter=imageCenter-x[0];
	}
	if(selectionType()==0){
		getSelectionBounds(x0,y0,width,height);
		distFromCenter=imageCenter-(x0+(width/2));
		
/*		print("x0,y0 " + x0, y0);
		print("width" + width);
		print("imageCenter " + imageCenter); 
*/	
	}

	L_p=ss_phos_dist/ss_g_dist;
	distToMove=distFromCenter*cam_pixsize/L_p;
	Xmotdest=Xmotval+distToMove;
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
