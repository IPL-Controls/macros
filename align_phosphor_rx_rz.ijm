macro "align_phosphor_rx_rz" {
{

			requires("1.47v")
//            if (IJ.versionLessThan("1.47v")) 
           
//            {
//                return false;
//            }
//            img = IJ.getImage();
			//img = File.openDialog("Select image");
			//open(img);
//            Overlay overlay = new Overlay();
			Overlay.remove;
			updateDisplay();
            
            num_circles = 5; line_width = 2.0; x_center = getWidth()/2; 
            y_center = getHeight()/2; outer_radius = 0.0;
            clear_overlays = false;
//            GenericDialog gd_1 = new GenericDialog("Add Circles");

			Dialog.create("Add Circles");
    		Dialog.addNumber("Circles:", num_circles, 1, 8, "");
    		Dialog.addNumber("Line width:", line_width, 1, 8, "");
    		Dialog.addNumber("X center:", x_center, 1, 8, "pixels");
    		Dialog.addNumber("Y center:", y_center, 1, 8, "pixels");
    		Dialog.addNumber("Outer Radius:", outer_radius, 1, 8, "pixels");
			Dialog.addCheckbox("Clear Overlays:", clear_overlays);
//            gd_1.addNumericField("Circles:", num_circles, 1);
//            gd_1.addNumericField("Line width:", line_width, 1);
//            gd_1.addNumericField("X center (pixels):", x_center, 1);
//            gd_1.addNumericField("Y center (pixels):", y_center, 1);
//            gd_1.addNumericField("Outer Radius (pixels):", outer_radius, 1);
//            gd_1.addCheckbox("Clear Overlays:", clear_overlays);
        
        /*    gd_1.addDialogListener(new DialogListener() 
            { 
                public boolean dialogItemChanged(GenericDialog gd_1, AWTEvent arg1) 
                { 
                    double num_circles, line_width, x_center, y_center, outer_radius;
                    boolean clear_overlays;
                    if (gd_1.wasCanceled())
                    {
                        return false;
                    }
                    num_circles = (float)gd_1.getNextNumber();
                    line_width = (float)gd_1.getNextNumber();
                    x_center = (float)gd_1.getNextNumber();
                    y_center = (float)gd_1.getNextNumber();
                    outer_radius = (float)gd_1.getNextNumber();
                    clear_overlays = gd_1.getNextBoolean();
                    return true;
                } 
            }); 
        */

//            gd_1.showDialog(); 
			Dialog.show();
//            if (gd_1.wasCanceled()) 
//            { 
//                return false; 
//            } 

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
//           if (num_circles <= 0) 
//            {
//                img.setOverlay(null);
//            }
//            if (outer_radius <= 0.0)
//            {
//                return false;
//            }
            else 
            {
                inc = (outer_radius)/(num_circles);
                for (r = inc; r <= outer_radius + inc/100.0; r += inc) 
                {
//                    Roi circle = new OvalRoi(x_center - r, y_center - r, r * 2, r * 2);
					makeOval(x_center - r, y_center - r, r * 2, r * 2);
//                    circle.setStrokeColor(Color.red);
                    Roi.setStrokeColor("red");
                    if (line_width > 1)
                    {
                        Roi.setStrokeWidth(line_width);
                    }
//                    overlay.add(circle);
					Overlay.addSelection;
					if (num_circles == 1) 
                    {
//                        break;
					exit();
                    }
                }
                run("Select None");
//                img.setOverlay(overlay);
//                return true;
            }
        } // end align_phosphor_rx_rz()
}