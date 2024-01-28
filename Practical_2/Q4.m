close all;
clear;
mkdir Q4;

COLOUR_DATA = ["Vivid Blue" 10 65 135; ...
                    "Bold Blue" 100 170 215; ...
                    "Vivid Red" 190 65 65; ...
                    "Vivid Yellow" 240 220 50; ...
                    "Vivid Yellow (Shadow shade)" 120 140 30; ... % Shadow shade
                    "Bold Purple" 100 75 110; ...
                    "Deep Green" 80 110 50; ...
                    "Dull Red" 240 190 190; ...
                    "Bold Orange" 240 100 70];
COLOUR_NAMES = ["Vivid Blue" "Bold Blue" "Vivid Red" "Vivid Yellow" "Vivid Yellow (Shadow shade)" ...
                "Bold Purple" "Deep Green" "Dull Red" "Bold Orange" "Uncertain"];

% Decided colour variance value by reducing increasing in increments of 10
% until there were no remaining Uncertain values.

[original, im, LB, numFills] = countCloseBlocks(1, 4600, 3, 88, 1);
close all;
colours = countColours(original, LB, numFills, COLOUR_DATA, 50, 1);
saveColours(colours, COLOUR_NAMES, 1);
close all;

[original, im, LB, numFills] = countCloseBlocks(2, 4600, 3, 88, 1);
close all;
colours = countColours(original, LB, numFills, COLOUR_DATA, 60, 2);
saveColours(colours, COLOUR_NAMES, 2);
close all;

[original, im, LB, numFills] = countCloseBlocks(3, 4600, 3, 80, 4);
close all;
colours = countColours(original, LB, numFills, COLOUR_DATA, 60, 3);
saveColours(colours, COLOUR_NAMES, 3);
close all;

[original, im, LB, numFills] = countCloseBlocks(4, 4600, 3, 80, 4);
close all;
colours = countColours(original, LB, numFills, COLOUR_DATA, 60, 4);
saveColours(colours, COLOUR_NAMES, 4);
close all;

[original, im, LB, numFills] = countCloseBlocks(5, 4600, 3, 40, 1);
close all;
colours = countColours(original, LB, numFills, COLOUR_DATA, 60, 5); 
saveColours(colours, COLOUR_NAMES, 5);
close all;

function saveColours(colours, COLOUR_NAMES, IM_NUM)
    M = [COLOUR_NAMES; colours]
    fileName = "Q4/" + IM_NUM + ".csv";
    writematrix(M, fileName);
end
function [colours] = countColours(original, LB, numFills, COLOUR_DATA, COLOUR_VARIANCE_VALUE, IM_NUM)
    % Taken values from original image instead of colour quantised image
    % Improved accuracy.
    red = original(:,:,1);
    green = original(:,:,2);
    blue = original(:,:,3);
    colours = [0 0 0 0 0 0 0 0 0 0];
    colourNum = 0; % For saving images

    for i = 2:numFills % Skip the first one (the carpet, close to 0,0,0)
        meanRed = mean(red(LB==i));
        meanGreen = mean(green(LB==i));
        meanBlue = mean(blue(LB==i));
    
        fprintf("R: %.4f, G: %.4f, B: %.4f.\n", meanRed, meanGreen, meanBlue);
        colourName = "Uncertain";
        colourIndex = 0;
        distance = -1;
    
        for k=1:length(COLOUR_DATA)
            checkRGB = [meanRed, meanGreen, meanBlue];
    
            againstRGB = [cast(COLOUR_DATA(k,2),"double"), ...
                cast(COLOUR_DATA(k,3),"double"), ...
                cast(COLOUR_DATA(k,4),"double")];
    
            isColour = checkColour(checkRGB, againstRGB, COLOUR_VARIANCE_VALUE);
            if (isColour)
                curDistance = getDistance(checkRGB, againstRGB, COLOUR_VARIANCE_VALUE);
                fprintf("Colour range detected: %s, index %d, difference %.4f.\n", COLOUR_DATA(k), colourIndex, curDistance);
                if (curDistance < distance || distance == -1)
                    distance = curDistance;
                    colourName = COLOUR_DATA(k);
                    colourIndex = k;
                end
            end
        end
        figure
        x = [0 1 1 0] ; y = [0 0 1 1];
        fill(x, y, [meanRed/255, meanGreen/255, meanBlue/255])
        title(colourName)
        f = gcf;
        exportgraphics(f, "Q4/" + IM_NUM + "_" + colourNum + ".png");
        colourNum = colourNum + 1;

        if (colourIndex > 0)
            colours(colourIndex) = colours(colourIndex) + 1;
        else
            colours(length(colours)) = colours(length(colours)) + 1;
        end
    end
end


function [isColour] = checkColour(checkRGB, againstRGB, COLOUR_VARIANCE_VALUE)
    if (checkRGB(1) > againstRGB(1) - COLOUR_VARIANCE_VALUE && ...
            checkRGB(1) < againstRGB(1) + COLOUR_VARIANCE_VALUE && ...
            checkRGB(2) > againstRGB(2) - COLOUR_VARIANCE_VALUE && ...
            checkRGB(2) < againstRGB(2) + COLOUR_VARIANCE_VALUE && ...
            checkRGB(3) > againstRGB(3) - COLOUR_VARIANCE_VALUE && ...
            checkRGB(3) < againstRGB(3) + COLOUR_VARIANCE_VALUE)

        isColour = true;
    else 
        isColour = false;
    end
end

function [distance] = getDistance(checkRGB, againstRGB, COLOUR_VARIANCE_VALUE)
    red = abs(checkRGB(1) - againstRGB(1));
    if (red > COLOUR_VARIANCE_VALUE) 
        red = red + (red - (COLOUR_VARIANCE_VALUE/2));
    end
    green = abs(checkRGB(2) - againstRGB(2));
    if (green > COLOUR_VARIANCE_VALUE) 
        green = green + (green - (COLOUR_VARIANCE_VALUE/2));
    end
    blue = abs(checkRGB(3) - againstRGB(3));
    if (blue > COLOUR_VARIANCE_VALUE) 
        blue = blue + (blue - (COLOUR_VARIANCE_VALUE/2));
    end
    distance = red + green + blue;
end

function [im, numColours, L] = getBinarizedLAB(IM_NUM, BLOCK_SIZE)
    IM_DATA = ["Original_Images/easy.jpg" 6; ...
                "Original_Images/medium.jpg" 7; ...
                "Original_Images/hard.jpg" 8; ...
                "Original_Images/very_hard.jpg" 8; ...
                "Original_Images/extreme.jpg" 8];

    % Read Original Image
    numColours = str2num(IM_DATA(IM_NUM,2));
    im = imread(IM_DATA(IM_NUM,1));
    figure
    imagesc(im)
    colorbar
    title("Original")

    % Copied code from https://uk.mathworks.com/help/images/color-based-segmentation-using-k-means-clustering.html
    % 200022530: Added comments and changed numColours above
    % K means clustering with La*b* colourspace
    lab_im = rgb2lab(im);
    % a* b* values: red-green, blue-yellow
    ab = lab_im(:,:,2:3);
    ab = im2single(ab);
    % numColours = numColouredBlocks + carpetColour
    [L] = imsegkmeans(ab,numColours+1);
    J = label2rgb(L);
    % End of copied code.
    
    figure
    imagesc(J)
    colorbar
    title("Labeled a*b*")
    
    % Grayscale
    L = rgb2gray(J);
    % Blur to improve fill performance later
    L = imgaussfilt(L);
    figure
    imagesc(L)
    colorbar
    title("Blurred Grayscale Labeled a*b*")
    
    % Binarize
    if (IM_NUM == 5)
        % Hard-coded extreme case
        % Harder to detect background in this context
        L(L < 40 & L > 10) = 150;
        L(L < 100) = 0;
        %L = imbinarize(L);
    else 
        L(L>40) = 255;
        L = imbinarize(L);
    end
    
    % Cleanup
    L = bwareaopen(L, BLOCK_SIZE);
    L = wiener2(L, [10,10]);
    % Removed noise
    L = imfill(L,"holes");
    % Fill holes
    figure
    imagesc(L)
    colorbar
    title("Binarized Image")
end
function [original, im, LB, numFills] = countCloseBlocks(IM_NUM, ...
    BLOCK_SIZE, ...
    COLOUR_QUANTISATION_BLUR, ...
    GRADIENT_BOUNDARY, ...
    GRADIENT_BLUR)

    [im,numColours,L] = getBinarizedLAB(IM_NUM, BLOCK_SIZE);
    
    % Background Removal using mask from L
    mask = cat(3, L, L, L);
    im = immultiply(im, mask);
    figure
    imagesc(im);
    colorbar;
    title("Original Without Background");
    original = im;

    % Colour Quantisation and Blurring
    [L,C] = imsegkmeans(im,numColours+1);
    im = label2rgb(L,im2double(C));
    im = imgaussfilt(im, COLOUR_QUANTISATION_BLUR);
    im(im(:)<50) = 0;
    figure
    imagesc(im)
    colorbar
    title("Colour Quantised and Blurred Image");
    
    % Gradient Magnitude
    [gmag,gdir] = imgradient(rgb2gray(im));
    figure
    imagesc(gmag);
    colorbar;
    title("Gradient Magnitude");
    
    % Binarized 
    gmag(gmag < GRADIENT_BOUNDARY) = 0;
    figure
    imagesc(gmag);
    colorbar;
    title("Gradient Magnitude (RM < GRADIENT_BOUNDARY)");
    
    gmag = imgaussfilt(gmag,GRADIENT_BLUR);
    gmag(gmag > 1) = 255;
    figure
    imagesc(gmag);
    colorbar;
    
    L = watershed(gmag);
    % Remove small blocks
    L = bwareaopen(L, BLOCK_SIZE);
    
    [LB, numFills] = bwlabel(L);
    numBlocks = numFills-1; % Don't count background
    figure
    imagesc(LB)
    colorbar
    title("Cleaned and Labeled Watershed (RM < BLOCK_SIZE)")
    fprintf("Image %d, NumBlocks: %d.\n", IM_NUM, numBlocks);
end
