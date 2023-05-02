function  T_transform = rit_LucasKanadeRigidRegistration(aviobj, aviobjOut,...
    RefFrame, Kvessels, mask, Nwin, ignore_border, RGB_flag)
%
% Radim Kolar, December 2014
%
%
%
% IMPLEMENTED BY:
% Radim Kolar, Brno University of Technology, Department of Biomedical
% Engineering, Faculty of Electrical Engineering and Communication,
% Created in 2016, corrected and submitted to Github in 03/2021.
%
% CITE AS:
% Kolar R, Tornow R P, Odstrcilik J, Liberdova I (2016) "Registration of retinal sequences
% from new video-ophthalmoscopic camera." Biomedical Engineering Online, 15(1), 1-17.
%
% Copyright 2020-2021 Ivana Labounkova(1,2), Rene Labounek(2), Igor Nestrasil(2,3),
%     Jan Odstrcilik(1), Ralf P. Tornow(4), Radim Kolar(1)
% (1) Department of Biomedical Engineering, Brno University of Technology, Brno, Czech Republic
% (2) Division of Clinical Behavioral Neuroscience, Department of Pediatrics, University of Minnesota, Minneapolis, USA
% (3) Center for Magnetic Resonance Research, Department of Radiology, University of Minnesota, Minneapolis, USA
% (4) Department of Ophthalmology, Friedrich-Alexander University of Erlangen-Nuremberg, Erlangen, Germany
% 
% This file is part of Retina Imaging Toolbox available at: https://github.com/ivanalabounkova/retinaimagingtoolbox
% 
% Retina Imaging Toolbox is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any later version.
% 
% Retina Imaging Toolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with Retina Imaging Toolbox.  If not, see <https://www.gnu.org/licenses/>.
% 
% Papers related to specific RIT functions are listed in the cite_papers.txt file.

    %% Prepare Gauss filters for LK tracking
    sig = 1.5;
    x = floor(-3*sig):ceil(3*sig);
    G = exp(-0.5*x.^2/sig^2);
    G = G/sum(G);
    % Derivation Gauss
    dG = exp(-0.5*x.^2/sig^2);
    dG = dG/sum(dG);
    dG = -x.*dG/sig^2;

    %% Reading from input AVI
    nFrames = aviobj.NumberOfFrames;
%     nr = aviobj.Height;
%     nc = aviobj.Width;

    %% For storing the frame shifts
%     shift_phase = zeros(2,nFrames-1);

    %% Detekce cev
    x1_rgb = read(aviobj, RefFrame);
    x1 = double(rgb2gray(x1_rgb) );
    [nr, nc] = size( x1 );

    %% Segmenting the blood vessels and create skeleton
    %% Different method can be used
    ind = rit_FindFeaturePoints( x1, Kvessels, 0 );
    if length(ind)>=8000 % if there are too much detected centerline point inside the vessels
        while length(ind)>=8000
            Kvessels = Kvessels*1.1;
            ind = rit_FindFeaturePoints( x1, Kvessels, 0 );
        end
    else
        while length(ind)<1500 % if there are too low number of detected centerline point inside the vessels
            Kvessels = Kvessels*0.9;
           ind = rit_FindFeaturePoints( x1, Kvessels, 0 );
        end
    end

    % Possible to select every Nth point
    Nth = 4;
    ind = ind(1:Nth:end);

    % Find coordinates of blood vessels centerlines
    [yp, xp] = ind2sub( size(x1), ind );
    % Discard positions near the image borders
    ind = intersect( find( xp>ignore_border & xp<nc-ignore_border ), find( yp>ignore_border & yp<nr-ignore_border ), 'rows' ) ;
    yp = yp(ind);
    xp = xp(ind);

    % Apply mask
    if ~isempty(mask)
        [yr,xc] = find( mask == 1 );
        body = intersect(  [yp(:), xp(:)], [yr(:), xc(:)], 'rows' );
        yp = body( :, 1 );
        xp = body( :, 2 );
    end

    %% Store transformation parameters 
    T_transform = zeros( 3, nFrames - 1);

    %% For each frame 
    FrameList = 1:nFrames;
    FrameList = setdiff( FrameList, RefFrame );
    flag = 1;

    % Preprocessing of the reference image 
    tmpx1 = double( adapthisteq(uint8(x1)) );
%     h = waitbar(0,'The 2nd stage of registration is running. Please wait...');

    for ii = FrameList
%         waitbar(ii/nFrames, h)

        % Read next frame to register
        x2 = read(aviobj, ii);
        if RGB_flag % If RGB, then take only one color channel - green, which has the highest contrast
            x2 = double( x2(:,:,2) );
        else
            % ...will work in double
            x2 = double( x2(:,:,1) );
        end    
         x2_orig = x2;

        % LK method
        tt = [0;0;0]; % store current transformation param
        T =  [0;0;0]; % store total transformation param

        % Preprocessing
         tmpx2 = double( adapthisteq(uint8(x2)) );

         % LK iteration
        for jj = 1:10   
            % Compute optical flow
            [dx, dy] = rit_LucasKanade( tmpx1, tmpx2, Nwin, [yp(:) xp(:)], G, dG );

            % Estimate of shift and rotation
            t = rit_SolveRotationTranslation( [xp(:), yp(:)], [xp(:)+dx(:), yp(:)+dy(:)] );

            % Total transformation parameters
            T = T + t;

            % Apply current transformation
            tmpx2 = rit_SolveRotationTranslation( tmpx2, t, 'linear' );

            % If the change of transformation parameters between iteration is
            % negligible then END iteration
            if max(abs(tt-t))<0.05 
                    break; % break current FOR
            else 
                    % store current transformation parameters
                    tt = t;
            end
        end

        % Apply and store the final transformation
        x2_rgb_out = rit_SolveRotationTranslation( x2_orig, T, 'linear' );
        x2_rgb_out = uint8( floor(x2_rgb_out ));
        T_transform(:,ii) = T;

        % Write current registered frame
        writeVideo( aviobjOut, x2_rgb_out );
        if RefFrame<ii && flag==1
            writeVideo( aviobjOut, uint8( floor(x1)) );
            flag = 0;
        end        
    end
%     close(h);
end