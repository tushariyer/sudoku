% Homework Nine | Tushar Iyer | Spring 2018 | CSCI 631
function Sudoku_Iyer_Tushar_main( )
    disp('Begin');

    disp('Adding paths');
    % addpath( '../TEST_IMAGES/' );
    % addpath( '../../TEST_IMAGES/' );

    % For the 'sudoku' folder
    disp('For Sudoku Images');
    sudoku_dir = 'YOUR_DIR_HERE';  % Change this to the test directory if thats where the images are
    HW10_Iyer_Tushar_Prep_Images(sudoku_dir)

    disp('End');
    pause(2);
    close all;
end

function HW10_Iyer_Tushar_Prep_Images(im_directory)
    filePattern = fullfile(im_directory, '*.jpg');  % All files are jpegs
    jpegFiles = dir(filePattern);  % Store all files in this directory

    for file = 1:length(jpegFiles)  % For every file in the folder
        im_name = jpegFiles(file).name;  % Get its name

        fullFileName = fullfile(im_directory, im_name);  % Create a full path name
        im_in = imread(fullFileName);  % Read in the image
        disp('Reading in new image');
        im_display = im_in;  % Store original image

        imagesc(im_in);  % Show image in current state
        title("Original Image");
        disp(' - Displaying Original Image');
        pause(2);

        % Add a Gaussian filter to clear some basic noise
        fltr = fspecial( 'gauss', [15 15], 3 );
        im_in = imfilter( im_in, fltr, 'same', 'repl' );
        imagesc(im_in);  % Show image in current state
        title("De-noised Image");
        disp(' - Displaying De-noised Image');
        pause(2);

        % Grayscale
        im_in = rgb2gray(im_in);  % Take grayscale
        imagesc(im_in);  % Show image in current state
        colormap('gray');
        title("Grayscaled Image");
        disp(' - Displaying Grayscaled Image');
        pause(2);

        % Binarize
        im_in = imbinarize(im_in);  % Take binary
        imagesc(im_in);  % Show image in current state
        title("Binarized Image");
        disp(' - Displaying Binarized Image');
        pause(2);

        % Opening and Closing
        im_in = imclose(im_in, strel('rectangle', [5 5]));  % Closing
        imagesc(im_in);  % Show image in current state
        title("Morphalogical Closing & Opening of Image");
        disp(' - Displaying Morphalogical Closing & Opening of Image');
        pause(2);

        % Take advantage of closing to remove further small objects
        im_in = imcomplement(im_in);  % Reverse black on white
        im_in = bwareaopen(im_in, 300);  % Remove all objects containing less than 20 pixels
        im_in = imcomplement(im_in);  % Reverse white on black

        im_in = imopen(im_in, strel('rectangle', [15 15]));  % Opening

        % Remove small objects again, just in case
        im_in = imcomplement(im_in);  % Reverse black on white
        im_in = bwareaopen(im_in, 320);  % Remove all objects containing less than 20 pixels
        im_in = imcomplement(im_in);  % Reverse white on black
        imagesc(im_in);  % Show image in current state
        title("Removing small objects from Image");
        disp(' - Displaying Removal of small objects from Image');
        pause(2);

        image_edges = edge(im_in, 'canny');  % Canny edge detection

        imagesc(image_edges);  % Show image in current state
        title("Image Edges [Canny]");
        disp(' - Displaying Image Edges [Canny]');
        pause(2);

        % Hough Transform
        [image_hough, hough_theta, hough_rho] = hough(image_edges);  % Hough Transform

        imshow(imadjust(rescale(image_hough)),'XData',hough_theta,'YData',hough_rho,...
              'InitialMagnification','fit');  % Show transform
        xlabel('\theta'), ylabel('\rho');  % Graph details
        axis on, axis normal, hold on;  % Keep graph active
        colormap(winter);  % Colormap
        title("Hough Transform (Peaks highlighted in green squares)");
        disp(' - Displaying Hough Transform');

        % Hough Peaks
        hough_peaks = houghpeaks(image_hough,40,'threshold',ceil(0.62 * max(image_hough(:))));  % Find the hough peaks
        x = hough_theta(hough_peaks(:,2));
        y = hough_rho(hough_peaks(:,1));
        plot(x,y,'s','color','green');  % Plot green squares on the peaks
        disp(' - Displaying Hough Peaks on plot');

        % Hough Lines
        lines = houghlines(image_edges,hough_theta,hough_rho,hough_peaks,'FillGap',60,'MinLength',50);  % Hough lines

        hold off;
        pause(2);

        imagesc(im_display);  % Show image in current state
        title("Lines on Image");
        disp(' - Displaying Lines on Image');
        hold on;

        % Plot the magenta lines
        for k = 1:length(lines)
           xy = [lines(k).point1; lines(k).point2];
           plot(xy(:,1),xy(:,2),'LineWidth',4,'Color','magenta');
        end

        pause(3);
        hold off;
    end
end
