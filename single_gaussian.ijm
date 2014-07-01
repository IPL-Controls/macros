//Works when selection is already made on uncropped image, returns single gaussian peak from x profile of image.
//Input string is ____________
//Output is absolute peak position

macro "single_gaussian"{
 
    imgname=getTitle(); 
    roiname=Roi.getName;

    //Plot profile and get values, close profile
    run("Plot Profile");
    Plot.getValues(x, y);
    close();

    //Do the fit and plot, leaving window open with renamed title
    Fit.doFit("Gaussian", x, y);
    Fit.plot;
    rename(roiname+" "+imgname);
  
    //set fit results to a,b,c,d
    a = Fit.p(0);
    b = Fit.p(1);
    c = Fit.p(2); // this describes the middle of the curve
    d = Fit.p(3);

    //Get the selection bounds
    selectWindow(imgname);
    Roi.getBounds(Xc,Yc,Wc,Hc);
     
    //Determine the absolute position
    W = getWidth();
    abspos = c + Xc-round(W/2);

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
    //This code prints all fit parameters
    //for (j=0; j<Fit.nParams; j++)
    //print("   p["+j+"]="+d2s(Fit.p(j),6));

	outstr = toString(abspos,2);
	return outstr;
}
