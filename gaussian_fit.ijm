
macro "Gaussian Fit selection" {
     if (!(selectionType()==0 || selectionType==5 || selectionType==6))
       exit("Line or Rectangle Selection Required");
     
     //setBatchMode(true);
          
     //Plot profile and do the fit
     run("Plot Profile");
     Plot.getValues(x, y);
     close();
     Fit.doFit("Gaussian", x, y);
     
     //Get the selection bounds
     Roi.getBounds(Xc,Yc,Wc,Hc);
     
     //set fit results to a,b,c,d
     a = Fit.p(0);
     b = Fit.p(1);
     c = Fit.p(2); // this describes the middle of the curve
     d = Fit.p(3);

     //Determine the absolute position
     W = getWidth();
     abspos = c + Xc-round(W/2);

     //Determine the width of the fit according to  2*sqrt(2*nat_log(2))*d
     fitWidth = 2 * sqrt( 2 * log(2) ) * d;

 
     //Print the results
     print("=======Gaussian Fit=======");
     print("Relative position=" + d2s(c,6));
     print("Absolute position=" + abspos);
     print("Fit Width=" + fitWidth);
     
     //This code prints all fit parameters
     //for (j=0; j<Fit.nParams; j++)
     //print("   p["+j+"]="+d2s(Fit.p(j),6));

}