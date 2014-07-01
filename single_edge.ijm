//Works when selection is already made on uncropped image, returns single edge peak from x profile of image.
//Input string is ____________
//Output is absolute peak position
//Directly compute X derivative.
//Gaussian fit can only fit positive peaks. Fit both positive
// and negative derivatives to gaussian, then pick the one with higher
// R^2. HW 4/11/2014 

macro "single_edge"{
    //Get original ROI and image information
	imgname=getTitle(); 
    roiname=Roi.getName;
    Roi.getBounds(Xc,Yc,Wc,Hc);
    W = getWidth();

    //Duplicate ROI to new cropped window and run find edges
    run("Duplicate...", "title=cropped.jpg");
//    run("Find Edges");

    //Plot profile and get values, close profile
    run("Select All");
    run("Plot Profile");
    Plot.getValues(x, y);
    close();

    //Get derivative (y[i+1]-y[i-1])/2;    
    npts = x.length;
    deriv = newArray(npts);
    derivneg = newArray(npts);
    deriv[0] = 0;
    deriv[npts-1] = 0;
    for(i=1;i<npts-1;i++){deriv[i]=(parseFloat(y[i+1])-parseFloat(y[i-1]))/2;
    	derivneg[i]=-deriv[i];
    }


    //Do the fit and plot, leaving window open with renamed title
    Fit.doFit("Gaussian", x, deriv);
    rsqpos=Fit.rSquared();   
    Fit.doFit("Gaussian", x, derivneg);
    rsqneg=Fit.rSquared();
    if(rsqpos > rsqneg){Fit.doFit("Gaussian", x, deriv);} else {
    Fit.doFit("Gaussian", x, derivneg);}    
    Fit.plot;
    rename(roiname+" "+imgname);
  
     //set fit results to a,b,c,d
    a = Fit.p(0);
    b = Fit.p(1);
    c = Fit.p(2); // this describes the middle of the curve
    d = Fit.p(3);   

    //This code prints all fit parameters
    //for (j=0; j<Fit.nParams; j++)
    //print("   p["+j+"]="+d2s(Fit.p(j),6));

    //Determine the absolute position within the original image
    abspos = c+ Xc - round(W/2);

    //Determine the width of the fit according to  2*sqrt(2*nat_log(2))*d
    fitWidth = 2 * sqrt( 2 * log(2) ) * d;
     
	/*
    profile = getProfile();
    xpos=newArray(0, c);
	ypos=newArray(0, b);
	Plot.create("Profile", "X", "Value", profile);  
	Plot.setColor("red");
	Plot.setLineWidth(2);
    Plot.add("crosses", xpos, ypos);
 	Plot.show;
 	*/
    //Print the results
    /*
    print("=======Gaussian Fit=======");
    print("Relative position=" + d2s(c,6));
    print("Absolute position=" + abspos);
    print("Fit Width=" + fitWidth);
    */
    //close find edges window and select window that was selected when macro was called
    selectWindow("cropped.jpg");
    close();
    selectWindow(imgname);

    return toString(abspos,2);
}