//Draws a crosshair in the center of any size image, as well as concentric circles,
//centered around the center of the image
// Useful for aligning camera focal plane to a flat surface
//AAG 7/10/2014
Overlay.remove;

width=getWidth();
height=getHeight();

centerx=width/2;
centery=height/2;



setColor("red");
setLineWidth(1);
Overlay.show;
Overlay.moveTo(centerx,centery);
Overlay.drawLine(0,centery,width,centery);
Overlay.add;
Overlay.drawLine(centerx,0,centerx,height);
Overlay.add;
Overlay.moveTo(centerx,centery);

diameter=1000;
radius=diameter/2;
numCircles=5;

for (a=1; a<numCircles; a+=1) {
Overlay.drawEllipse(centerx-radius*a, centery-radius*a ,diameter*a,diameter*a);
Overlay.add;
Overlay.show;
}
