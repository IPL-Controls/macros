/*
 * Generic extension of single_fit_edge to work for a stack of images.
 * __author_	=	'Alireza Panna'
 * __version__	=	'1.0'
 * __status__   =   "Needs stress testing"
 * __date__		=	03/04/2015
 */
macro "stack_fit_edge"{
	Dialog.create(" Settings Menu");
	Dialog.addMessage("Update Scan settings:")
	Dialog.addNumber("start:", 0);
	Dialog.addNumber("end:", 0);
	Dialog.show();
	start=parseFloat(Dialog.getNumber());
	end=parseFloat(Dialog.getNumber());
	
	imgname=getTitle(); 
	print (imgname);
    roiname=Roi.getName;
    dir=getDirectory("image");
	y = newArray(nSlices);
    if (imgname=="stack"){
    	step=abs((end-start)/(nSlices-1));
    	for (i=1; i<=nSlices; i++){
    		setSlice(i);
    		d=runMacro("single_fit_edge");
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
		opt = -b/(2*c);
		f = File.open(dir+"EdgeWidths"+".txt");
    	print(f, "FWHM (pixel)"+"\t"+"z (mm)"); 
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
		}
    }
    else{
    	d=runMacro("single_fit_edge");
    }	
}