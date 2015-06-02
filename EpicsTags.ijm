macro "EPICS Tags Action Tool - C059T3e16A" {

path = getInfo("image.directory")+File.separator+getInfo("image.filename"); 
run("TIFF Tags", "open="+path+" show_ascii_tags_as_string result_limit=80");
}