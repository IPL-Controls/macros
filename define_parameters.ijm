
macro "define_parameters" {
	Dialog.create("Menu");
	Dialog.addString("Camera:", "D800");
	Dialog.addString("Gain:", "ISO100");
  	Dialog.addNumber("Pixel Size (um):", 15); 
  	Dialog.addNumber("Bin:", 6);
  	Dialog.addNumber("Exposure time:", 30);
  	Dialog.show();
  	cam = Dialog.getString();
  	gain = Dialog.getString();
  	pix_size = parseFloat(Dialog.getNumber());
  	bin = Dialog.getNumber();
  	time = Dialog.getNumber();
  	return cam + " " + gain + " " + toString(pix_size) + " " + toString(bin) + " " + toString(time);
}
