//Works when selection is already made on uncropped image, returns single gaussian peak from x profile of image.
//Input string is ____________
//Output is absolute peak position relative to (0,0) corner of image.
//Do profile in Y direction. 

macro "single_gaussian_horizontal"{
	imgname=getTitle(); 
    roiname=Roi.getName;

    //Plot profile and get values, close profile
    setKeyDown("alt"); 
    run("Plot Profile");
    Plot.getValues(x, y);
    close();

//Do linear baseline correction of curve
    npts = x.length;
    x0=(x[0]+x[1]+x[2]+x[3]+x[4])/5;
    y0=(y[0]+y[1]+y[2]+y[3]+y[4])/5;
    x1=(x[npts-1]+x[npts-2]+x[npts-3]+x[npts-4]+x[npts-5])/5;
    y1=(y[npts-1]+y[npts-2]+y[npts-3]+y[npts-4]+y[npts-5])/5;

    slope = (y1-y0)/(x1-x0);
    offset = (y0*x1-y1*x0)/(x1-x0);

    for(i=0;i<npts;i++){y[i]=y[i]-offset-slope*x[i];}

    negy = newArray(y.length);
    for(i=0;i<npts;i++){negy[i]=-y[i];}
    
/*    
    //Do the fit and plot, leaving window open with renamed title
    Fit.doFit("Gaussian", x, y);
    Fit.plot;
    rename(roiname+" "+imgname);
*/
    //Do the fit and plot, leaving window open with renamed title
    Fit.doFit("Gaussian", x, y);
    rsqpos=Fit.rSquared();   
    Fit.doFit("Gaussian", x, negy);
    rsqneg=Fit.rSquared();
    if(rsqpos > rsqneg){Fit.doFit("Gaussian", x, y);} else {
    Fit.doFit("Gaussian", x, negy);}    
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
    Height = getHeight();
    abspos = c + Yc;

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
    
    print("=======Gaussian Fit=======");
    print("Relative position=" + d2s(c,6));
    print("Absolute position=" + abspos);
    print("Fit Width=" + fitWidth);
    print("Max=" + b);
    //This code prints all fit parameters
    //for (j=0; j<Fit.nParams; j++)
    //print("   p["+j+"]="+d2s(Fit.p(j),6));

	outstr = toString(abspos,2);
	return outstr;
}
