if (nResults > 0) 
{
   IJ.deleteRows(0, nResults);
}
//ROIseq = Array.getSequence(roiManager("count"));
//roiManager("Select", ROIseq);
BX = newArray(roiManager("count"));
BY = newArray(roiManager("count"));
Width = newArray(roiManager("count"));
Height = newArray(roiManager("count"));
Area = newArray(roiManager("count"));
roiManager("Deselect");
run("Set Measurements...", "area mean standard bounding redirect=None decimal=2");
roiManager("Measure");
for (i=0; i<roiManager("count"); i++) 
{
Area[i] = getResult("Area",i);
BX[i] = getResult("BX", i);
BY[i] = getResult("BY", i);
Width[i] = getResult("Width", i);
Height[i] = getResult("Height", i);
}
Array.show(Area,BX,BY,Width,Height);
for (i=0; i<roiManager("count"); i++) 
{
TotalPixels += Area[i];
}
print(TotalPixels);
m = 0;
PixCoordX = newArray(TotalPixels);
PixCoordY = newArray(TotalPixels);
for (n=0; n<BX.length; n++) 
{
	roiManager("Select", n);
	for (y=0; y<Height[n]; y++) 
	{
		for (x=0; x<Width[n]; x++) 
			{
				if(Roi.contains(BX[n]+x, BY[n]+y))
				{
				PixCoordX[m] = BX[n] + x;
				PixCoordY[m] = BY[n] + y;
				m += 1;
				}
			}
	}
}

Array.show(PixCoordX,PixCoordY);