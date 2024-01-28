close all;
clear;
mkdir Q5;

            % Name Fill_Multiplier Side_Multiplier (small to big)
SHAPE_DATA = ["Square" 1.0 1.0; ...
    "Rectangle" 1.0 2; ...
    "Triangle" 0.5 2; ...
    "Circle" 0.7 1.0; ...
    "Semi-Circle" 0.7 1.5; ...
    "Bridge" 0.7 2];
SHAPE_NAMES = ["Square" "Rectangle" "Triangle" "Circle" "Semi-Circle" "Bridge"];

[original, im, LB, numFills] = countCloseBlocks(1, 4600, 3, 88, 1);
close all;
shapes = detectShapes(LB, numFills, SHAPE_DATA, 1);
saveShapes(shapes, SHAPE_NAMES, 1);
close all;

[original, im, LB, numFills] = countCloseBlocks(2, 4600, 3, 88, 1);
close all;
shapes = detectShapes (LB, numFills, SHAPE_DATA, 2);
saveShapes(shapes, SHAPE_NAMES, 2);
close all;

[original, im, LB, numFills] = countCloseBlocks(3, 4600, 3, 80, 4);
close all;
shapes = detectShapes (LB, numFills, SHAPE_DATA, 3);
saveShapes(shapes, SHAPE_NAMES, 3);
close all;

[original, im, LB, numFills] = countCloseBlocks(4, 4600, 3, 80, 4);
close all;
shapes = detectShapes (LB, numFills, SHAPE_DATA, 4);
saveShapes(shapes, SHAPE_NAMES, 4);
close all;

[original, im, LB, numFills] = countCloseBlocks(5, 4600, 3, 40, 1);
close all;
shapes = detectShapes (LB, numFills, SHAPE_DATA, 5);
saveShapes(shapes, SHAPE_NAMES, 5);
close all;

function [rotatedIM, width, height] = getSmallestRotation(im)
    [width, height, tot] = getDimensions(im);
    smallestTot = tot;
    rotatedIM = im;
    for i = 1:8
        im = imrotate(im, 45);
        tot = getDimensions(im);
        fprintf("%.4f.\n", tot); % Bug: Always increasing?
        if (tot < smallestTot)
            rotatedIM = im;
            smallestTot = tot;
        end
    end
end
function [row1, row2, col1, col2, rowDif, colDif, tot] = getDimensions(im)
    [rows, columns] = find(im);
    row1 = min(rows);
    row2 = max(rows);
    rowDif = row2-row1;
    col1 = min(columns);
    col2 = max(columns);
    colDif = col2 - col1;
    tot = rowDif + colDif;
end
function [shapes] = detectShapes(LB, numFills, SHAPE_DATA, IM_NUM)
    shapes = [0 0 0 0 0 0];
    shapeNum = 1;

    for i = 2:numFills
       difference = -1;
       im = LB == i;

       filledArea = bwarea(im);
       [row1, row2, col1, col2, width, height] = getDimensions(im);

       %croppedImage = im(row1:row2, col1:col2);
       %[rotatedIM, width, height] = getSmallestRotation(croppedImage);
       fprintf("Area: %.4f, Width: %.4f, Height: %.4f.\n", filledArea, width, height);
    
       shapeIndex = -1;

       for k = 1:length(SHAPE_DATA)
           expectedFill = cast(SHAPE_DATA(k,2),"double") * height * width;
           curDifference = abs(filledArea - expectedFill)/100;
           if (width < height)
               expectedHeight = cast(SHAPE_DATA(k,3),"double") * width;
               curDifference = curDifference + abs(expectedHeight - height);
           else
               expectedWidth = cast(SHAPE_DATA(k,3),"double") * height;
               curDifference = curDifference + abs(expectedWidth - width)/2;
           end

           if (curDifference < difference || difference == -1)
               difference = curDifference;
               shapeIndex = k;
               fprintf("%s shape similarity detected, difference: %.4f.\n", SHAPE_DATA(k,1), curDifference);
           end
       end
       croppedImage = LB(row1:row2, col1:col2);
       figure
       imshow(croppedImage)
       title (SHAPE_DATA(shapeIndex,1))
       f = gcf;
       exportgraphics(f, "Q5/" + IM_NUM + "_" + shapeNum + ".png");
       
       shapeNum = shapeNum +1;
       shapes(shapeIndex) = shapes(shapeIndex) + 1;
    end
end
function saveShapes(shapes, SHAPE_NAMES, IM_NUM)
    M = [SHAPE_NAMES; shapes]
    fileName = "Q5/" + IM_NUM + ".csv";
    writematrix(M, fileName);
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
