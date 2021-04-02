function shift_phase = rit_PhaseCorrelation( aviobj , aviobjOut, RefFrame, ignore_border, RGB_flag   )
% Function for image registration using phase correlation
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

    %% Large shift correction via Phase Correlation
    nFrames = aviobj.NumberOfFrames;
    % nr = aviobj.Height;
    % nc = aviobj.Width;

    %% This is to store the shift parameters
    shift_phase = zeros(2,nFrames-1);

    %% Start registration

    % Read reference frame
    x1 = read(aviobj, RefFrame); 

    if RGB_flag  % If RGB, then take only one color channel - green, which has the highest contrast
        x1 = double( x1(:,:,2) );
    else
        % just for sure, take the first
        x1 = double( x1(:,:,1) );
    end

    % Here, it is possible to apply  preprocessing
    x1b = medfilt2( x1, [3 3]);
    x1b = double( adapthisteq(uint8(x1b)) );

    % Create list of indexes for frames to register except the reference frame
    FrameList = 1:nFrames;
    FrameList = setdiff( FrameList, RefFrame );
    flag = 1; % flag to hold if reference frame has been written into output video

    h = waitbar(0,'The 1st stage of registration is running. Please wait...');

    for ii = FrameList
        waitbar(ii/nFrames, h);

        % Read frame
        x2 = read(aviobj, ii);
        if RGB_flag % If RGB, then take only one color channel - green, which has the highest contrast
            x2 = double( x2(:,:,2) );
        else
            % ...will work in double
            x2 = double( x2(:,:,1) );
        end

        % Preprocessing
        x2b = medfilt2( x2, [3 3]);    
        x2b = double( adapthisteq(uint8(x2b)) );

        % Estimate the shift
        [~, r_x, c_x] = rit_ShiftEstimatePhaseCorrelation( x1b, x2b, ignore_border );

        % Apply the estimated shifts on the original frame (without preprocessing)
        x2 = rit_ShiftCorrection( x2, r_x, c_x );
     
        % Store shift coordinates 
        shift_phase(:,ii) = [c_x; r_x ];
    
        if RGB_flag == 0
            % Write frame
            tmp = uint8( floor(x2) );
        else
            tmp2 = read(aviobj, ii);
            tmp(:,:,1) = uint8( floor( rit_ShiftCorrection( tmp2(:,:,1), r_x, c_x ) ) );
            tmp(:,:,2) = uint8( floor(x2) );
            tmp(:,:,3) = uint8( floor( rit_ShiftCorrection( tmp2(:,:,3), r_x, c_x ) ) );
        end
        
        writeVideo( aviobjOut, tmp );
        
        % Write reference frame into output sequence
        if (RefFrame<ii && flag==1)
             writeVideo( aviobjOut, uint8( floor(x1)) );
            flag = 0;
        end
        
        % Write reference frame into output sequence - if the reference
        % frame is the last frame in sequence
         if ( (RefFrame-1) == ii && flag==1)
             writeVideo( aviobjOut, uint8( floor(x1)) );
            flag = 0;
         end
        
    end
    
    shift_phase(:,RefFrame) = [0;0];
    
    % Close and return parameters
    close(h) 
end


