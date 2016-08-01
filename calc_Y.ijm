//  Calculate the Y (mm) positions of the mirror based on
//	mirror edge projection. 2/24/2016
//	
//  Input is a List with variables from param.txt as well as edgeabsx and reflabsx.
//	Modified code to use imageJ list functionality, as well as made it so it can work for any mirror(set by grtnum variable)
//  aag 4-8-2014

macro "calc_Y"{
	
	//import variables
	argList=getArgument();
	List.setList(argList); 
	
	//set local variables to global variables
	ss_g_dist=List.getValue("ss_g_dist");
	edgeabsx=List.getValue("edgeabsx");
//	reflabsx=List.getValue("reflabsx");
	ss_phos_dist=List.getValue("ss_phos_dist");
	cam_pixsize=List.getValue("cam_pixsize");
//	mirror_rad=List.getValue("mirror_rad");
	sin_phos=List.getValue("sin_phos");
	cos_phos=List.getValue("cos_phos");
	
/*	//Debug
	
//	print("gratnum is " + grtnum);
	print("edgeabsx is " + toString(edgeabsx, 2));
	print("reflabsx is " + toString(reflabsx, 2));
	print("ss_g_dist is " + ss_g_dist);
	print("ss_phos_dist is " + ss_phos_dist);
	print("cam_pixsize is " + toString(cam_pixsize, 8));
	print("mirror_rad is " + mirror_rad);
	print("sin_phos is " + toString(sin_phos,8));
	print("cos_phos is " + toString(cos_phos,8));
	
	//Debugend
*/
	//Calculate RXval Yval inci

	Yval=edgeabsx*cam_pixsize*sin_phos*ss_g_dist/ss_phos_dist;
	RXval = 0;
	inciAngl = 0;
	
	List.set("Yval",d2s(Yval, 9));
	List.set("RXval",d2s(RXval, 9));
	List.set("inciAngl",d2s(inciAngl,9));
	
	print("Yval is " + toString(Yval, 2));

	return List.getList;
}
