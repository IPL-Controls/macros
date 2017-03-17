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