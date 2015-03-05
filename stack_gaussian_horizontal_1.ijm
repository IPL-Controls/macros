/*
 * This is a generic extension of the macro single_gaussian_horizontal_1 to work for a stack of images. 
 * It outputs a text file containing the widths and the grating positions for each image in the stack and saves it to the image directory.
 * The user needs to provide the scan start and end positions and the macro assumes fixed scan steps based on the no of images
 * in the stack. If a stack is not open/present then it performs a gaussian fit for a single image. 
 * Further more it plots a 2nd order polynomial fit of width (sigma) vs. grating pos, 
 * finds the critical point (maxima or minima) and then asks to move the grating R_X motor to that point.
 * This macro can be used to find the central diffraction order by moving the Rx motor of G0 and G2.
 * NOTE: The fit only applies when grating Ry is 45 degrees. If this is changed you will need to change the fit order/type.
 *
 * __author_	=	'Alireza Panna'
 * __version__	=	'1.0'
 * __status__   =   "Ext.read("") does not work"
 * __date__		=	02/05/2015
 */
macro "stack_gaussian_horizontal"{
	
	run("EPICSIJ ");
	Dialog.create(" Settings Menu");
	Dialog.addNumber("Grating:", 0);
	// read scan IOC start and end values by default. This can be changed manually as well.
	Dialog.addMessage("Update Scan settings:")
	Dialog.addNumber("start:", Ext.read("IOC:scan1.P1SP"));
	Dialog.addNumber("end:", Ext.read("IOC:scan1.P1EP"));
	Dialog.show();
	grtnum=Dialog.getNumber();
	start=Dialog.getNumber();
	end=Dialog.getNumber();
	
	var paramfile = getDirectory("macros")+"param.txt"; // This should be in the macros folder by default.
	// Set the param file to the List
	List.setList(File.openAsString(paramfile));
	// Get Rx motor PV of selected grating.
	motor_pv=List.get("g"+grtnum+"_RX_motor");
	
	imgname=getTitle(); 
    roiname=Roi.getName;
    dir=getDirectory("image");
	y = newArray(nSlices);
    if (imgname=="stack"){
    	step=abs((end-start)/(nSlices-1));
    	for (i=1; i<=nSlices; i++){
    		setSlice(i);
    		d=runMacro("single_gaussian_horizontal_1");
    		y[i-1]=d;  
     		selectWindow(" Stack");
    		close();
     		}
    	}
    	x = newArray(nSlices);
		temp = start;
 		for(i=1; i<=x.length; i++){
     	  	x[i-1] = temp;
     	  	temp = temp+step;
 		}	 
	    // Try polynomial fit degree=2
 		Fit.doFit(1, x, y);
 		Fit.plot();
 		a = Fit.p(0);
		b = Fit.p(1);
		c = Fit.p(2);	// This is the width.
		opt = -b/2*c;
		f = File.open(dir+"G"+grtnum+"DiffWidths"+".txt");
    	print(f, "Width (pixel)"+"\t"+"R_x (deg)"); 
    	xx="";
    	yy="";
    	zz="";
    	z=0;
    	while(z<x.length){
    		xx=toString(x[z])+"\n";
    		yy=toString(y[z])+"\t";
    		zz = yy+xx;
    		z++;
	    	print(f, zz);
	    }
	    // Get current motor position
	    motor_curr = Ext.read(motor_pv+".RBV");
		// Ask Permission to move motor
		Dialog.create("Move "+grtnum+" motors?");
		Dialog.addMessage("Moving "+"G"+grtnum+ " R_x ("+ motor_pv+")"+" from "+motor_curr+" to "+opt+" degrees");
		Dialog.addCheckbox("Move?",true);
		Dialog.show();
		movemotors=Dialog.getCheckbox();
	
		if(movemotors==true){
			print ("Moving", motor_pv);
			Ext.write(motor_pv, opt);
			print ("Done Moving");
		}
    }
    else{
    	d=runMacro("single_gaussian_horizontal_1");
    }
//	selectWindow("Log");
//	run("Text...", "save=["+ dir+"G"+grtnum+"DiffWidths"+".csv]");
//	selectWindow("Log");
//	run("Close");
//	exec("open",  dir+"G"+grtnum+"DiffWidths"+".csv");
	
}