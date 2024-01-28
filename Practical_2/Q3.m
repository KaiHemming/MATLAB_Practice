close all;
clear;
mkdir Q3;

countDistantBlocks(1, 4600); % 88 1
countDistantBlocks(2, 4600);
close all;

countCloseBlocks(3, 4600, 3, 80, 4);
close all;
countCloseBlocks(4, 4600, 3, 80, 4);
close all;
countCloseBlocks(5, 4600, 3, 40, 1);
close all;

% BLOCK_SIZE
% Last known pixel threshold to remove a block: 4700
% Discovered pixel threshold by increasing/decreasing by 100 increments

function countDistantBlocks(IM_NUM, BLOCK_SIZE)     
    [im, numColours, L] = getBinarizedLAB(IM_NUM, BLOCK_SIZE);
    [LB, numFills] = bwlabel(L);
    fprintf("Image %d, NumBlocks: %d.\n", IM_NUM, numFills);
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
    f = gcf;
    exportgraphics(f, "Q3/image_" + IM_NUM + "_step_1.png");

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
    f = gcf;
    exportgraphics(f, "Q3/image_" + IM_NUM + "_step_2.png");
    
    % Grayscale
    L = rgb2gray(J);
    % Blur to improve fill performance later
    L = imgaussfilt(L);
    figure
    imagesc(L)
    colorbar
    title("Blurred Grayscale Labeled a*b*")
    f = gcf;
    exportgraphics(f, "Q3/image_" + IM_NUM + "_step_3.png");
    
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
    f = gcf;
    exportgraphics(f, "Q3/image_" + IM_NUM + "_step_4.png");
end
function [im,L] = countCloseBlocks(IM_NUM, ...
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
    title("Original Without Background")
    f = gcf;
    exportgraphics(f, "Q3/image_" + IM_NUM + "_step_5.png");
    
    % Colour Quantisation and Blurring
    [L,C] = imsegkmeans(im,numColours+1);
    im = label2rgb(L,im2double(C));
    im = imgaussfilt(im, COLOUR_QUANTISATION_BLUR);
    im(im(:)<50) = 0;
    figure
    imagesc(im)
    colorbar
    title("Colour Quantised and Blurred Image")
    f = gcf;
    exportgraphics(f, "Q3/image_" + IM_NUM + "_step_6.png");
    
    % Gradient Magnitude
    [gmag,gdir] = imgradient(rgb2gray(im));
    figure
    imagesc(gmag);
    colorbar;
    title("Gradient Magnitude")
    f = gcf;
    exportgraphics(f, "Q3/image_" + IM_NUM + "_step_7.png");
    
    % Binarized 
    gmag(gmag < GRADIENT_BOUNDARY) = 0;
    figure
    imagesc(gmag);
    colorbar;
    title("Gradient Magnitude (RM < GRADIENT_BOUNDARY)")
    f = gcf;
    exportgraphics(f, "Q3/image_" + IM_NUM + "_step_8.png");
    
    gmag = imgaussfilt(gmag,GRADIENT_BLUR);
    gmag(gmag > 1) = 255;
    figure
    imagesc(gmag);
    colorbar
    f = gcf;
    exportgraphics(f, "Q3/image_" + IM_NUM + "_step_9.png");
    
    L = watershed(gmag);
    % Remove small blocks
    L = bwareaopen(L, BLOCK_SIZE);
    
    [LB, numFills] = bwlabel(L);
    numBlocks = numFills-1; % Don't count background
    figure
    imagesc(LB)
    colorbar
    title("Cleaned and Labeled Watershed (RM < BLOCK_SIZE)")
    fprintf("Image %d, NumBlocks: %d.\n", IM_NUM, numBlocks)
    f = gcf;
    exportgraphics(f, "Q3/image_" + IM_NUM + "_step_10.png");
end
