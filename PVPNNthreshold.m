% Define paths
fijiExe = 'C:\Users\kirkpagr\Downloads\Fiji\fiji-windows-x64.exe';

% Path to the macro script
macroFile = 'C:\Users\kirkpagr\Desktop\threshold_PVPNN_macro.ijm';

% Path to image file
inputImage = 'C:/Users/kirkpagr/Desktop/PNN/Confocal/4.7.2V (Vehicle) Hippocampus/4.8.2V_P14_CA1_Contra_DAPI_WFA_PV_C3R2_A.oib';

% Run Fiji headlessly
command = sprintf('"%s" --headless -macro "%s" "%s"', fijiExe, macroFile, inputImage);
disp(command);
[status, output] = system(command);

% Check result
if status == 0
    disp('Fiji macro completed successfully.');

    % Define output paths
    base = strrep(inputImage, '.oib', '');
    ch1 = imread([base '_ch1_thresholded.tif']);
    ch2 = imread([base '_ch2_thresholded.tif']);

    % Display thresholded outputs
    figure; imshow(ch1); title('Thresholded Channel 1');
    figure; imshow(ch2); title('Thresholded Channel 2');
else
    error('Fiji macro failed:\n%s', output);
end