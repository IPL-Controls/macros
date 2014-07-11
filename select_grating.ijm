
//This macro prompts the user for a grating, and then adds all of the information regarding that specific grating to generic variables
//Gets all parameters from param.txt as well as from the itxt file. 

macro "select_grating"{
	//check if this image has already been processed
	if(endsWith(substring(getTitle(), 0, lastIndexOf(getTitle(), ".")),"_prep")){
		 exit("Please select the original image");
	}
	//First get the data directory, original image name, filebase, and param file name and location.
	var dirname = replace(getDirectory("image"),"\\","\/"); //replace backslashes with forward slashes
	var imgfile = getInfo("image.filename");
	//var filebase=substring(getTitle(), 0, lastIndexOf(getTitle(), ".")); //Get basename of file before ".jpg", without dir.
	var dirname = "C:\\Fiji.app\\macros\\";
	var paramfile = dirname+"param.txt"; //full path of param.txt file.
	//Set the param file to the List
	List.setList(File.openAsString(paramfile)); //Load variables into List from param txt file
	//print (List.getList);
	//Now is a good time to confirm image coordinates mapping to lab coordinates
	if((List.get("imgXaxis") != "labX")||(List.get("imgYaxis") != "labY")){
		waitForUser("Sorry can only handle matched image and lab coordinates.");	
	}
	
	//Add general variables to the list
	List.set("dirname",dirname);
	//List.set("imgfile",imgfile);
//	List.set("filebase",filebase);
	//List.set("itxtfile",dirname+filebase+".txt"); //add name of text file produced automatically by epics containing motor positions to the List
	
	//Ask user which object to use and set ggrtnum depending on slit, grating or samplenewArray("Grating", "Slit", "Sample");
	Dialog.create("Selection");
	Dialog.addChoice("Select object", newArray("Grating", "Slit", "Sample"));
	Dialog.addChoice("Object Number", newArray(0,1,2));
	Dialog.addMessage("Align Single Mirror Options:");
	Dialog.addCheckbox("Draw Line", true);
	if(roiManager("count")>=2)
	{
		Dialog.addCheckbox("Use previous ROI", true);
	}
	else
	{
		List.set("useprevroi",false);
	}
	Dialog.show();	
	obj = Dialog.getChoice();
	num = parseInt(Dialog.getChoice());

	List.set("objNum", num);
	if(obj == "Grating")
	{
		ggrtnum = "g" + num;
		List.set("ggrtnum", ggrtnum);
	}
	else if(obj == "slit")
	{
		slitnum = "s" + num;
		List.set("ggrtnum", slitnum);
	}
	else
	{
		samplenum = "o" + num;
		List.set("ggrtnum", samplenum);
	}

//	print(List.get("ggrtnum"));
	List.set("drawline",Dialog.getCheckbox());
	C:\Fiji.app\macros
	if(roiManager("count")>=2){
		useprevroi=Dialog.getCheckbox(); 
		List.set("useprevroi",useprevroi);
		for(i =0; i<roiManager("count"); i++){
			List.set(call("ij.plugin.frame.RoiManager.getName", i),i);
		}
		//if the proper rois do no exist in the roiManager, useprevroi should be set to false 
		if(List.get("g"+grtnum+"edge")=="" || List.get("g"+grtnum+"refl")==""){
 			List.set("useprevroi",false);
 		}
	}
	//Make substitutions
	List.set("ss_g_dist",List.getValue("ss_g"+num+"_dist")); //In mm
	List.set("s0_g_dist", List.getValue("s0_g"+num+"_dist")); //In mm
	List.set("s2_g_dist", List.getValue("s2_g"+num+"_dist")); //In mm
	
	List.set("Y_targ", toString(List.getValue(ggrtnum+"_Y_targ"),8)); //In mm
	List.set("RX_targ", toString(List.getValue(ggrtnum+"_RX_targ"),8)); //In milliradians

	List.set("g_facing", List.get(ggrtnum+"_facing"));
	
	List.set("RXmotname", List.get(ggrtnum+"_RX_motor")); //EPICS PV name
	List.set("RZmotname", List.get(ggrtnum+"_RZ_motor"));  //EPICS PV name
	List.set("RYmotname", List.get(ggrtnum+"_RY_motor"));  //EPICS PV name
	List.set("Xmotname", List.get(ggrtnum+"_TX_motor")); //EPICS PV name
	List.set("Ymotname", List.get(ggrtnum+"_TY_motor")); //EPICS PV name
	List.set("Zmotname", List.get(ggrtnum+"_TZ_motor")); //EPICS PV name

	List.set("RXmotstep", toString(List.getValue(ggrtnum+"_RX_motor_step"),8)); //In degrees
	List.set("RZmotstep", toString(List.getValue(ggrtnum+"_RZ_motor_step"),8)); //In degrees
	List.set("RYmotstep", toString(List.getValue(ggrtnum+"_RY_motor_step"),8)); //In degrees
	List.set("Xmotstep", toString(List.getValue(ggrtnum+"_TX_motor_step"),8)); //In mm
	List.set("Ymotstep", toString(List.getValue(ggrtnum+"_TY_motor_step"),8)); //In mm
	List.set("Zmotstep", toString(List.getValue(ggrtnum+"_TZ_motor_step"),8)); //In mm

	//Get values from itxtfile
	itxtfile=List.get("itxtfile");
	imgstr = split(File.openAsString(itxtfile), "\n\r");


	motorarray=newArray("RXmot","RZmot","RYmot","Xmot","Ymot","Zmot");
	for(j=0;j<motorarray.length;j++){
		for(i=0;i<lengthOf(imgstr);i++){
			if(indexOf(imgstr[i], List.get(motorarray[j]+"name")) >= 0){
				strarr=split(imgstr[i], " \t");
//				List.set(motorarray[j]+"val", toString(parseFloat(strarr[lengthOf(strarr)-1]),8)); //In degrees
 
				List.set(motorarray[j]+"val", strarr[lengthOf(strarr)-1]); 
			}
		}
	}
//print(List.getValue("RXmotval"));	
//print(parseFloat(List.get("RXmotval")));
//print(d2s(parseFloat(List.get("RXmotval")),9));
	print(List.getList());

	return List.getList;
}