
macro "Rodbard Fit selection" {
     if (!(selectionType()==0 || selectionType==5 || selectionType==6))
       exit("Line or Rectangle Selection Required");
     
     //setBatchMode(true);


     //Plot profile and do the fit
     run("Plot Profile");
     Plot.getValues(x, y);
     close();
     Fit.doFit("Rodbard", x, y);
    
     //set fit results to a,b,c,d
     a = Fit.p(0);
     b = Fit.p(1);
     c = Fit.p(2); // this describes the middle of the edge
     d = Fit.p(3);

     //Get the selection bounds
     Roi.getBounds(Xc,Yc,Wc,Hc);

    //Determine the absolute position
     W = getWidth();
     abspos = c + Xc-round(W/2);

    //The x range between 25% and 75% of the step height is c*(3^(1/b)-(1/3)^(1/b))
    //Assuming this relative range is from a Gauss integral fit, then when fitting the
    //derivative of the step to a Gauss function, the FWHM of the Gaussian fit is fitwidth
    //below.

     pow1= pow(3,(1/b));
     pow2= pow((1/3),(1/b));
     fitWidth= 1.7456*c * ( pow1 - pow2);


     //Print the results
     print("=======Rodbard Fit=======");
     print("Relative position=" + d2s(c,6));
     print("Absolute position=" + abspos);
     print("Fit Width=" + fitWidth);

     //This code prints all fit parameters
     //for (j=0; j<Fit.nParams; j++)
     //print("   p["+j+"]="+d2s(Fit.p(j),6));

}
