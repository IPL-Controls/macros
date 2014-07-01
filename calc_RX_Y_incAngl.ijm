//  Calculate the RX (radians) and the Y (mm) positions of the mirror based on
//	mirror edge projection and reflection positions in pixels.
//	hw 2-26-2014
//  Input is a List with variables from param.txt as well as edgeabsx and reflabsx.
//	Modified code to use imageJ list functionality, as well as made it so it can work for any mirror(set by grtnum variable)
//  aag 4-8-2014

macro "calc_RX_Y_incAngl"{
	
	//import variables
	argList=getArgument();
	List.setList(argList); 
	
	//set local variables to global variables
	ss_g_dist=List.getValue("ss_g_dist");
	edgeabsx=List.getValue("edgeabsx");
	reflabsx=List.getValue("reflabsx");
	ss_phos_dist=List.getValue("ss_phos_dist");
	cam_pixsize=List.getValue("cam_pixsize");
	mirror_rad=List.getValue("mirror_rad");
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
	Lp=ss_phos_dist/ss_g_dist;
	rp=mirror_rad/ss_g_dist;
	dep=edgeabsx*cam_pixsize/ss_g_dist;
	drp=reflabsx*cam_pixsize/ss_g_dist;
	a=2-drp*cos_phos-Lp;
	b1=-2*(Lp+drp*cos_phos-1);
	c=-drp*sin_phos;
	d=1;
	e=-rp;
	f=-dep*sin_phos*(1+rp)/(Lp+dep*cos_phos);
	h1=(c*e-f*b1)/(a*e-d*b1);
	b=b1*(1-h1*h1/2);
/*	//Debug
	print(toString(a,10));
	print(toString(b,10));
	print(toString(c,10));
	print(toString(d,10));
	print(toString(e,10));
	print(toString(f,10));
	//Debug end */
	hp=(c*e-f*b)/(a*e-d*b);
	sin_RX=(c*d-f*a)/(b*d-a*e);
	RXval=asin(sin_RX);
	Yval=ss_g_dist*hp;
	inciAngl=-Yval/ss_g_dist-RXval;

	List.set("RXval",d2s(RXval, 9));
	List.set("Yval",d2s(Yval, 9));
	List.set("inciAngl",d2s(inciAngl,9));
	

	return List.getList;
}
