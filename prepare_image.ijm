//Prepares an image for generic rgbh processing by rotating it according to param file, and selecting the green channel only.
//Works on a fresh image, assuming param txt file exists in the same directory
//If image XY axes are the same as lab XY axes, do not rotate. HW 4/11/2014
macro "prepare_image"{
	
	//import variables
	//First get the data directory, original image name, filebase, and param file name and location.
	var dirname = replace(getDirectory("image"),"\\","\/"); //replace backslashes with forward slashes
	var imgfile = getInfo("image.filename");
	var filebase=substring(getTitle(), 0, lastIndexOf(getTitle(), ".")); //Get basename of file before ".jpg", without dir.
	var paramfile = dirname+"param.txt"; //full path of */param.txt file.
	
	//Set the param file to the List
	List.setList(File.openAsString(paramfile));//Load variables into List from param txt file
	List.set("itxtfile",dirname+filebase+".txt"); //add name of text file produced automatically by epics containing motor positions to the List
	
	//Full image x and y size after appropriate rotation.
	var xdim = -1;
	var ydim = -1;
	//low x and low y corner of the crop after rotation.
	var x0 = -1;
	var y0 = -1;
	//crop box size after rotation.
	var bxdim = -1;
	var bydim = -1;
	var edgeabsx = -1;  //Absolute pixel pos of mirror edge
	var reflabsx = -1; //Absolute pixel pos of reflection peak

	//Get the image size and selection box stuff
	xdimorg = getWidth();
	ydimorg = getHeight();
	getSelectionBounds(x0org, y0org, bxdimorg, bydimorg);
	xdim = xdimorg;
	ydim = ydimorg;
	x0 = x0org;
	y0 = y0org;
	bxdim = bxdimorg;
	bydim = bydimorg;
	//Open new copy of image so that we mantain an untouched version in background for convenience 
	run("Duplicate...", "title="+filebase+"_temp.jpg");

	//Get the physical axes of the X and Y axes of the image from paramstr.
	//Rotate image to fit imgxaxis = labY, imgyaxis = -labX 
	if((List.getValue("imgXaxis") != "labX")&&(List.getValue("imgYaxis") != "labY")){ //only alternative
		exit("Can only handle image XY axes = lab XY axes!");
		}

	//If the image is RGB, keep the green channel. 
	if(bitDepth==24){
		runMacro("keep_green_channel");
	}
	//run("Gaussian Blur...", "sigma=2");
	rename(filebase+"_prep.jpg");


}
