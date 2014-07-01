
//Moves a single motor which is set in the list by the movmot variable(can be either Xmot Ymot Zmot RXmot RYmot RZmot)
macro "move_motor"{

////////////////////////////////////////////////////////////////////////////////
//Set up variables
	argList=getArgument();
	List.setList(argList);
	ggrtnum=List.get("ggrtnum");
	movemot=List.get("movemot");

	movemotname=List.get(movemot+"name");
	movemotdest=List.get(movemot+"dest");
	movemotval=List.get(movemot+"val");

////////////////////////////////////////////////////////////////////////////////
//Ask Permission
	Dialog.create("Move " + ggrtnum +" motors?");
	Dialog.addMessage("Moving "+ ggrtnum + " "+movemot+"(" + movemotname + ") from " + movemotval+ " to " + movemotdest);
	Dialog.addCheckbox("Move?",true);
	Dialog.show();

////////////////////////////////////////////////////////////////////////////////
//Move Motors
	movemotors=Dialog.getCheckbox();

	if(movemotors==true){
		run("EPICSIJ ");
		Ext.write(movemotname,movemotdest);
	}
}