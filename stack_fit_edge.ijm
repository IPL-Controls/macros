/*
 * Generic extension of single_fit_edge to work for a stack of images.
 * 
 * __author_	=	'Alireza Panna'
 * __version__	=	'1.0'
 * __status__   =   "stable"
 * __date__		=	03/04/2015
 */
macro "stack_fit_edge"{
	fit_choice = newArray("Gaussian", "Lorentzian");
    edge_choice = newArray("Horizontal", "Vertical");
    Dialog.create("Menu");
	Dialog.addChoice("Choose Edge:", edge_choice, "Horizontal");
    Dialog.addChoice("Choose Fit:", fit_choice, "Gaussian"); 
    Dialog.show();
    lsf_edge = Dialog.getChoice();
    fit_func = Dialog.getChoice();
    args = lsf_edge+" "+fit_func;
    
	imgname = getTitle(); 
    dir = getDirectory("image");
    if (imgname == "stack"){
    	Dialog.create("Scan Settings");
		Dialog.addMessage("Update Scan settings:")
		Dialog.addNumber("start:", 0);
		Dialog.addNumber("end:", 0);
		Dialog.show();
		start = parseFloat(Dialog.getNumber());
		end = parseFloat(Dialog.getNumber());
    	step = abs((end-start)/(nSlices-1));
    	y = newArray(nSlices);
    	x = newArray(nSlices);
    	for (i=1; i<=nSlices; i++){
    		setSlice(i);
    		y[i-1] = runMacro("single_fit_edge", args);
    		rename("image"+"_"+toString(i));
     		selectWindow("image"+"_"+toString(i));
    		close();
     	}
    	
		temp = start;
 		for(i=1; i<=x.length; i++){	
     	  	x[i-1] = temp;
     	  	temp = temp+step;
 		}	 
	    // Try polynomial fit degree=2
 		Fit.doFit(1, x, y);
 		Fit.plot();
 		rename("FWHM (pixels) Vs. z (mm)");
 		a = Fit.p(0);
		b = Fit.p(1);
		c = Fit.p(2);	
		opt = -b/(2*c);
		f = File.open(dir+"EdgeWidths"+".txt");
    	print(f, "FWHM (pixel)"+"\t"+"z (mm)"); 
    	xx = "";
    	yy = "";
    	zz = "";
    	z = 0;
    	while(z<x.length){
    		xx = toString(x[z])+"\n";
    		yy = toString(y[z])+"\t";
    		zz = yy+xx;
    		z++;
	    	print(f, zz);
	    }
	    print("Optimum z-position (mm):", opt);
    }
    else{
    	d = runMacro("single_fit_edge", args);
    }	
}