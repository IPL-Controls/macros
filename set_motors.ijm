//Generalized this code so that it can work for any mirror- aag

macro "set_motors"{
	//get the argument and import variables
	argList=getArgument();
	List.setList(argList); //import variables

	//see which grating we are doing the calcuation for, this should be passed in the argstr
	grtnum=List.getValue("grtnum");
	ggrtnum=List.get("ggrtnum");

	RXval=List.getValue("RXval");//In radians
	Yval=List.getValue("Yval");//In mm
	inciAngl=List.getValue("inciAngl");//In radians
	Ytarg=List.getValue("Y_targ");//In mm
	RXtarg=List.getValue("RX_targ");//In radians
	
	RXmotname=List.get("RXmotname"); 
	Ymotname=List.get("Ymotname");
	RXmotstep=List.getValue("RXmotstep"); //In degrees
	Ymotstep=List.getValue("Ymotstep"); //In mm
	RXmotval=List.getValue("RXmotval");
	print("set_motors RXmotval check ", RXmotval);
	Ymotval=List.getValue("Ymotval");

	RXmotdest = RXmotval+(RXtarg-RXval)*180/PI; // In degrees
	RXmotdest = round(RXmotdest/RXmotstep)*RXmotstep;
	Ymotdest = Ymotval+(Ytarg-Yval); //In mm
	Ymotdest = round(Ymotdest/Ymotstep)*Ymotstep; 

	//Debug
	/*
	print("RXval is "+ RXval);
	print("Yval is " + Yval);
	print("RXmotval is " + RXmotval);
	print("Ymotval is " + Ymotval);
	//print(RXmotstep);
	//print(Ymotstep);
	//print(RXtarg);
	//print(Ytarg);
	print("RXmotdest is " + RXmotdest);
	print("Ymotdest is " + Ymotdest);
	//Debugend
	*/

	//Set macro results to List
	List.set("RXmotval",d2s(RXmotval, 9));
	List.set("Ymotval",d2s(Ymotval, 9));
	List.set("RXmotdest",d2s(RXmotdest, 9));
	List.set("Ymotdest",d2s(Ymotdest, 9));


	//Ask if its okay to move motors
	Dialog.create("Move " + ggrtnum+" motors?");
	Dialog.addMessage("Moving "+ ggrtnum + " RXmot  (" + RXmotname + ") from " +RXmotval+ " to " + RXmotdest);
	Dialog.addCheckbox("Move " + RXmotname + "?",true)
	Dialog.addMessage("Moving "+ ggrtnum + " Ymot (" +Ymotname + ") from " + Ymotval+ " to " + Ymotdest);
	Dialog.addCheckbox("Move " + Ymotname + "?",true)
	Dialog.show();
	moverxmot=Dialog.getCheckbox();
	moveymot=Dialog.getCheckbox();

	//If it is okay, move the motors using EPICSIJ plugin
	
	if(moverxmot || moveymot==true){
		run("EPICSIJ ");
		if(moverxmot==true){Ext.write(RXmotname,RXmotdest);}
		if(moveymot==true){Ext.write(Ymotname,Ymotdest);}
	}

	return List.getList;
}
