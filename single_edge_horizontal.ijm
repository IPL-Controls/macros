//Do a differential along Y, then plot the vertical profile and do a
//Gaussian fit. Return the gaussian peak as the edge position.
//Return position relative to the (0,0) corner of the image in which
//ROI is made.

macro "single_edge_horizontal"{
	imgname=getTitle(); 
    roiname=Roi.getName;

    //Plot profile and get values, close profile
    setKeyDown("alt"); 
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
    }

//Linear baseline correction
    x0=(x[1]+x[2]+x[3]+x[4])/4;
    deriv0=(deriv[1]+deriv[2]+deriv[3]+deriv[4])/4;
    x1=(x[npts-2]+x[npts-3]+x[npts-4]+x[npts-5])/4;
    deriv1=(deriv[npts-2]+deriv[npts-3]+deriv[npts-4]+deriv[npts-5])/4;

    slope = (deriv1-deriv0)/(x1-x0);
    offset = (deriv0*x1-deriv1*x0)/(x1-x0);

    for(i=1;i<npts-1;i++){deriv[i]=deriv[i]-offset-slope*x[i];}
    for(i=1;i<npts-1;i++){derivneg[i]=-deriv[i];}
    
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
