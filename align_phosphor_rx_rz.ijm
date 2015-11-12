* 
 * Aligns phosphor detector in Rz and Ry axis.
 *  
 *  __author__			=	'Alejandro Morales'
 *  __status__          =   "stable"
 *  __date__            =   "10/15/15"
 *  __version__         =   "1.0"
 *  __to-do__			=   
 *  __update-log__		= 	10/30/15: Added comments and removed old edits  
 */

macro "align_phosphor_rx_rz" {
{

			requires("1.47v"); // makes sure user has correct IJ version 
			Overlay.remove; // clear any existing overlays in the image
			updateDisplay(); 
            
            num_circles = 5; line_width = 2.0; x_center = getWidth()/2; // define initial parameters
            y_center = getHeight()/2; outer_radius = 0.0; 
            clear_overlays = false;

			Dialog.create("Add Circles"); 
    		Dialog.addNumber("Circles:", num_circles, 1, 8, "");
    		Dialog.addNumber("Line width:", line_width, 1, 8, "");
    		Dialog.addNumber("X center:", x_center, 1, 8, "pixels");
    		Dialog.addNumber("Y center:", y_center, 1, 8, "pixels");
    		Dialog.addNumber("Outer Radius:", outer_radius, 1, 8, "pixels");
			Dialog.addCheckbox("Clear Overlays:", clear_overlays);
			Dialog.show(); // creates a dialog for the circle creation

            num_circles = Dialog.getNumber(); 
            line_width = Dialog.getNumber();
            x_center = Dialog.getNumber();
            y_center = Dialog.getNumber();
            outer_radius = Dialog.getNumber();
            clear_overlays = Dialog.getCheckbox();

            if (clear_overlays == true)
            {
                Overlay.clear();
            }
            else 
            {
                inc = (outer_radius)/(num_circles);
                for (r = inc; r <= outer_radius + inc/100.0; r += inc) 
                {
					makeOval(x_center - r, y_center - r, r * 2, r * 2); // creates oval that's half width and half height of the image
                    Roi.setStrokeColor("red");
                    if (line_width > 1)
                    {
                        Roi.setStrokeWidth(line_width);
                    }
					Overlay.addSelection;
					if (num_circles == 1) 
                    {
					exit();
                    }
                }
                run("Select None");
            }
        } 
}