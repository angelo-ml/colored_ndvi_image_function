function [greyscale_ndvi, rgb_ndvi] = ndvi(red_img, nir_img, min_ndvi, ndvi_figure, parallel)

	% set function options
	if nargin < 3
		min_ndvi = 0;
	end

    if nargin < 4
        ndvi_figure = true;      
    end
    
    if nargin < 5
        parallel = false;      
    end

	% load image data as matrices
	NIR=imread(nir_img);
	R=imread(red_img);

	% Convert matrices from integers to doubles
	NIR=double(NIR); 
	R=double(R);

	% NDVI index computation per pixel
	NDVI=(NIR-R)./(NIR+R);
    
    % initialize ndvi image matrices (red, green, blue)
	[ndviR,ndviC] = size(NDVI); % NDVI image rows and columns 
	ndvi_green=zeros(ndviR,ndviC);
	ndvi_red=zeros(ndviR,ndviC);
	ndvi_blue=zeros(ndviR,ndviC);
    
    % check if parallel toolbox exists
    if parallel
       matlab_version = ver;
       parallel_exists = any(strcmp(cellstr(char(matlab_version.Name)), 'Parallel Computing Toolbox'));
       if ~parallel_exists
            disp('Parallel Computing Toolbox is not available')
            parallel = false;
       end
    end
    
    if parallel    
        parfor i=1:ndviR
            for j=1:ndviC
                % replace NaN values with -1
                if isnan(NDVI(i,j))
                    NDVI(i,j)=-1;
                end

                % replace with zero ndvi index values bellow 'min_ndvi'
                if NDVI(i,j) <= min_ndvi
                    NDVI(i,j) = 0;
                end

                % create RGB NDVI image
                if NDVI(i,j) < 0.2
                    ndvi_green(i,j)=NDVI(i,j);
                    ndvi_red(i,j)=NDVI(i,j);
                    ndvi_blue(i,j)=NDVI(i,j);
                end
                if NDVI(i,j) >= 0.25 && NDVI(i,j) < 0.4
                    ndvi_green(i,j)=NDVI(i,j);
                end
                if NDVI(i,j) >= 0.4
                    ndvi_red(i,j)=NDVI(i,j);
                end
            end
        end
    else    
        for i=1:ndviR
            for j=1:ndviC
                % replace NaN values with -1
                if isnan(NDVI(i,j))
                    NDVI(i,j)=-1;
                end

                % replace with zero ndvi index values bellow 'min_ndvi'
                if NDVI(i,j) <= min_ndvi
                    NDVI(i,j) = 0;
                end

                % create RGB NDVI image
                if NDVI(i,j) < 0.2
                    ndvi_green(i,j)=NDVI(i,j);
                    ndvi_red(i,j)=NDVI(i,j);
                    ndvi_blue(i,j)=NDVI(i,j);
                end
                if NDVI(i,j) >= 0.25 && NDVI(i,j) < 0.4
                    ndvi_green(i,j)=NDVI(i,j);
                end
                if NDVI(i,j) >= 0.4
                    ndvi_red(i,j)=NDVI(i,j);
                end
            end
        end
    end
    
	% create colored NDVI index image matrix
	rgb_ndvi=cat(3,ndvi_red,ndvi_green,ndvi_blue);
	greyscale_ndvi=NDVI;

	% create figure
    if ndvi_figure
        figure;
        figure_title='NDVI Index';
        imshow(rgb_ndvi,'DisplayRange',[0 1]), title(figure_title);
    end

	% NDVI Image histogram
	figure; 
	hist(NDVI(:)), xlabel('NDVI value'), ylabel('number of pixels'), title('NDVI Index Histogram'), grid on;
end