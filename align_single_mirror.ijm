
//Only handles image XY axes = lab XY axes. HW 4/11/2014

macro "mirror_edge_abs"{

////////////////////////////////////////////////////////////////////////////////
//Set up variables and prep image
	//Prompt user for grating number and make appropriate substitutions in the list
 	List.setList(runMacro("select_grating", List.getList));
 	grtnum=List.getValue("grtnum");
	filebase=List.get("filebase"); 

	//Prep image by rotating according to param file, keeping green channel. 
	//This renames the image to filebase+"_green.jpg"
	//Test if one already exists in background, if it does select it and skip this step.
	
	//runMacro("prepare_image");
	if(!isOpen(filebase+"_prep.jpg")){
		runMacro("prepare_image");
	}
	else{
		selectWindow(filebase+"_prep.jpg");
	}

	imgheight = getHeight();
////////////////////////////////////////////////////////////////////////////////
//Make Selections and determine pixel positions of edge and reflection

	if(List.get("useprevroi")==false){
		//delete old values if there are any
		if(List.get("g"+grtnum+"edge")!=""){
			roiManager("select",List.getValue("g"+grtnum+"edge"));
			roiManager("Delete");
		}
		if(List.get("g"+grtnum+"refl")!=""){
			roiManager("select",List.getValue("g"+grtnum+"refl")-1);
			roiManager("Delete");
		}

		//get selection boxes for edge and reflection
		waitForUser("Select g"+grtnum+" edge");
		Roi.setName("g"+grtnum+"edge");
		roiManager("add");

		waitForUser("Select g"+grtnum+" reflection");
		Roi.setName("g" +grtnum+"refl");
		roiManager("add");
		roiManager("Show all with labels");
	}

	for(i =0; i<roiManager("count"); i++){
			roiManager("select", i);
			List.set(Roi.getName, i);
	}
	//Get edgeabsx position from the first selection and update list
	roiManager("select",List.getValue("g"+grtnum+"edge"));
	edgeabsx = parseFloat(runMacro("single_edge_horizontal"))-round(imgheight/2);
//Debug
//edgeabsx = 99.06;
//Debug end
	List.set("edgeabsx", toString(edgeabsx,2));

	//Get reflabsx position from the second selection and update list
	roiManager("select",List.getValue("g"+grtnum+"refl"));
	reflabsx = parseFloat(runMacro("single_gaussian_horizontal"))-round(imgheight/2);
	if(List.get("drawline")==true){
		setColor("red");
		setLineWidth(4);
		drawLine(0, reflabsx+(getHeight()/2), getWidth(), reflabsx+(getHeight()/2));
		drawLine(0, edgeabsx+(getHeight()/2), getWidth(), edgeabsx+(getHeight())/2);
	}

//Debug
//reflabsx = 9.12;
//Debug end
	List.set("reflabsx", toString(reflabsx,2));
	
	print("edgeabsx is " + toString(edgeabsx, 2));
	print("reflabsx is " + toString(reflabsx, 2));
////////////////////////////////////////////////////////////////////////////////
//Calculate rx y inci and move motors

	//Calculate rx y inci angle and update the list
	List.setList(runMacro("calc_RX_Y_incAngl", List.getList)); 

////////////////////////////////////////////////////////////////////////////////
//Log the results to the table
	row=nResults;
	setResult("Img Name",row,filebase);
	setResult("Mirror",row,"g"+grtnum);
	setResult("Inci",row,List.getValue("inciAngl"));
	setResult("Y",row,List.getValue("Yval"));
	setResult("RX",row,List.getValue("RXval"));	
	setResult("RXmotVal",row,List.getValue("RXmotval"));
	setResult("YmotVal",row,List.getValue("Ymotval"));
	updateResults();
	
	//Prompt to move motors and update the list
	List.setList(runMacro("set_motors", List.getList));


	//here would be good place to auto save log to file if desired
	
	outstr = "null";
	return outstr;
}
