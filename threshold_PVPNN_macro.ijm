// threshold_PVPNN_macro.ijm
// macro for thresholding PV and PNN channels using same methods with different particle size ranges
// runs analyze particles on PV, PNN, and AND gate images

//Open file dialog to choose an image
inputPath = File.openDialog("Choose an image file to process");
if (inputPath == "") {
    exit("No input file specified.");
}
print("Input Path: " + inputPath);

//Import image using Bio-Formats
run("Bio-Formats Importer", "open=[" + inputPath + "] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");

// Split channels
run("Split Channels");

// Extract base filename (no extension)
parts = split(inputPath, File.separator);
filename = parts[lengthOf(parts) - 1];
// Remove .tif/.TIF/.tiff/.TIFF
basename = filename;
basename = replace(basename, ".tif", "");
basename = replace(basename, ".TIF", "");
basename = replace(basename, ".tiff", "");
basename = replace(basename, ".TIFF", "");

// Define output path
outputDir = File.getParent(inputPath);

// Process Channel 2 (PNN)
winC2 = "C2-" + filename;
if (!isOpen(winC2)) {
    winC2 = "C2-" + basename; // fallback if extension removed
}
if (isOpen(winC2)) {
    selectWindow(winC2);
    run("Z Project...", "projection=[Max Intensity]");
    run("Auto Threshold", "method=MaxEntropy");
    setOption("BlackBackground", false);
    run("Convert to Mask");
    saveAs("Tiff", outputDir + File.separator + basename + "_PNN_thresholded.tif");
    
    // Particle analysis for Channel 2
    run("Analyze Particles...", "size=100-Infinity show=Masks clear summarize");
    
    // Save new resulting mask image
    run("Convert to Mask");
    saveAs("Tiff", outputDir + File.separator + basename + "_PNN_mask.tif");
    
    // Save results of particle analysis
    saveAs("Results", outputDir + File.separator + basename + "_PNN_particles_results.csv");
    //close();
} else {
    print("Warning: Channel 2 window not found.");
}

// Process Channel 3 (PV)
winC3 = "C3-" + filename;
if (!isOpen(winC3)) {
    winC3 = "C3-" + basename; // fallback
}
if (isOpen(winC3)) {
    selectWindow(winC3);
    run("Z Project...", "projection=[Max Intensity]");
    run("Auto Threshold", "method=MaxEntropy");
    setOption("BlackBackground", false);
    run("Convert to Mask");
    saveAs("Tiff", outputDir + File.separator + basename + "_PV_thresholded.tif");
    
    // Particle analysis for Channel 3
    run("Analyze Particles...", "size=40-Infinity show=Masks clear summarize");
    
    // Save new resulting mask image
    run("Convert to Mask");
    saveAs("Tiff", outputDir + File.separator + basename + "_PV_mask.tif");
    
    // Save results of particle analysis
    saveAs("Results", outputDir + File.separator + basename + "_PV_particles_results.csv");
    //close();
} else {
    print("Warning: Channel 3 window not found.");
}

// Open the mask images for C2 and C3 (Thresholded PV and PNN)
maskPNN = basename + "_PNN_mask.tif";  // Mask of PNN
maskPV = basename + "_PV_mask.tif";   // Mask of PV

// Check if the mask images are open and then proceed
if (isOpen(maskPNN) && isOpen(maskPV)) {
    selectWindow(maskPNN);
    selectWindow(maskPV);

    // Compute AND Gate (using Image Calculator on the mask images)
    run("Image Calculator...", "image1=" + maskPNN + " image2=" + maskPV + " operation=AND create");


// Save AND Gate as a separate image
andGateWindow = "Result of " + maskPNN; // name of AND gate result
if (isOpen(andGateWindow)) {
    selectWindow(andGateWindow);
    saveAs("Tiff", outputDir + File.separator + basename + "_AND_gate.tif");  // Save the AND gate as a TIFF image
} else {
    print("Warning: AND gate image not found.");
}


//  Particle Analysis for AND Gate (Channel 2 AND Channel 3)
run("Analyze Particles...", "size=0-Infinity show=Masks clear summarize");
saveAs("Results", outputDir + File.separator + basename + "_AND_particles_results.csv");


// Cleanup
run("Close All");

