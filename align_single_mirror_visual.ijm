
macro "mirror_edge_abs"{

////////////////////////////////////////////////////////////////////////////////
//Set up variables and prep image
	//Prompt user for grating number and make appropriate substitutions in the list
 	List.setList(runMacro("select_grating", List.getList));
 	grtnum=List.getValue("grtnum");
	filebase=List.get("filebase"); 

	//Prep image by rotating according to param file, keeping green channel. 
	//This renames the image to filebase+"_rotated_green.jpg"
	//Test if one already exists in background, if it does select it and skip this step.
	if(!isOpen(filebase+"_green.jpg")){
		runMacro("prepare_image");
	}
	else{
		selectWindow(filebase+"_green.jpg");
	}

////////////////////////////////////////////////////////////////////////////////
//Make Selections and determine pixel positions of edge and reflection
 


	//get selection boxes for edge and reflection
	waitForUser("Select g"+grtnum+" edge with a point");
	getSelectionCoordinates(x,y);
	List.set("edgeabsx",y[0]);
	

	waitForUser("Select g"+grtnum+" reflection with a point");
	getSelectionCoordinates(x,y);
	List.set("reflabsx",y[0]);


////////////////////////////////////////////////////////////////////////////////
//Calculate rx y inci and move motors

	//Calculate rx y inci angle and update the list
	List.setList(runMacro("calc_RX_Y_incAngl", List.getList)); 
	//Prompt to move motors and update the list
	List.setList(runMacro("set_motors", List.getList));

////////////////////////////////////////////////////////////////////////////////
//Log the results to the table
	row=nResults;
	setResult("Img Name",row,filebase);
	setResult("Mirror",row,"g"+grtnum);
	setResult("Inci",row,List.getValue("inciAngl"));
	setResult("RX",row,List.getValue("RXval"));
	setResult("Y",row,List.getValue("Yval"));
	setResult("RXmotVal",row,List.getValue("RXmotval"));
	setResult("YmotVal",row,List.getValue("Ymotval"));
	updateResults();

	//here would be good place to auto save log to file if desired
	
	outstr = "null";
	return outstr;
}
