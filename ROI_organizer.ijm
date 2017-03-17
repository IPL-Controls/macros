/* Automated procedure for reorganizing the ROI's for the 3-by-3 lenses into descending order from the lef to to the right and from the top to the bottom.
 * 
 * Report any bugs or questions to alegmoralesm@gmail.com
 *  
 *  __author__			=	'Alejandro Morales'
 *  __bug fixes__		= 	
 *  __status__          =   "stable" 

 *  __date__            =   "3/17/17"
 *  __version__         =   "1.0"
 *  __to-do__			=   work on error checking, 
 *  __update-log__		= 	
 *  						
 *  						
 *  						
 */

n = roiManager("count");
run("Set Measurements...", "area mean min centroid redirect=None decimal=3");
X = newArray(roiManager("count"));
Y = newArray(roiManager("count"));
Height = getHeight();
Width = getWidth();
m = 1;

if (nResults > 0) 
{
   IJ.deleteRows(0, nResults);
}

for (i=0; i<n; i++) 
{
	roiManager("Select", i);
	roiManager("measure");
	X[i] = round(getResult("X", i));
	Y[i] = round(getResult("Y", i));	
}

for (j=0; j<=3; j++) 
{
	for (k=0; k<=3; k++) 
		{
			for (l=0; l<n; l++) 
				{
					if (Y[l] > Height*(j/3) && Y[l] < Height*((j+1)/3))
						{
							if (X[l] > Width*(k/3) && X[l] < Width*((k+1)/3))
								{	
									roiManager("Select", l);
									roiManager("Rename", m);
									m += 1;
								}
						}
				}
		}
}

roiManager("Sort");
roiManager("Show None");
roiManager("Show All");
