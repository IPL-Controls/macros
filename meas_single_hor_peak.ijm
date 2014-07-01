height = getHeight();
peak = parseFloat(runMacro("single_gaussian_horizontal"));
abspeak = peak-round(height/2);
print("abspeak =",abspeak);
