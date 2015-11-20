/* 
 * Creates an action tool that generates oval shaped ROI 
 * wherever the user clicks in the image. It also saves 
 * said ROI into the ROI manager.
 *  
 *  __author__			=	'Alejandro Morales'
 *  __status__          =   "stable"
 *  __date__            =   "11/9/15"
 *  __version__         =   "1.0"
 *  __to-do__			=   
 *  __update-log__		= 	11/12/15: Added new lines.  
 */


var pwidth = 61;
var pheight = 34;

macro "ROI Picker Tool - C0a0L18f8L818f" {
getCursorLoc(x,y,z,flags);
makeOval(x-pwidth/2, y-pheight/2, pwidth, pheight);
roiManager("Add");
n = roiManager("count");
for (i=1; i<=n; i++) {
roiManager("Select", i-1);
roiManager("Rename", "ROI-" + i);
}
}

macro "ROI Picker Tool Options" {
    pwidth = getNumber("Pixel Width: ", pwidth);
    pheight = getNumber("Pixel Height: ", pheight);
}