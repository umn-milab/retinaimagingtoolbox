function rit_registration_lucaskanade(fnamepath, mask, index_for_reference_frame, Kvessels,...
    ignore_borderPC, ignore_borderLK, NwinLK, RGB_flag)
%RIT_REGISTRATION_LUCASKANADE runs 2 stage rigid registration algorithm optimized for retinal video-sequences.
%
% INPUTS:
% fnamepath - full path & filename of the video file in the .avi format
%             e.g.: fnamepath='C:\User\Videos\RetinaVideo.avi'
%
% mask - binary mask of the same dimensions as one video frame defining region of interest (ROI).
%        If whole image is the ROI, them mask=[];
%
% index_for_reference_frame - is an integer indexing number of the scan
%                             which is used as the reference image in the registration,
%                             e.g.: index_for_reference_frame=1 
%
% Kvessels - non-negative real parameter for thresholding during blood vessel detection. 
%            It multiplies the threshold during blood vessel detection.
%            e.g.: Kvessels=1
%
% ignore_borderPC - Defines how many border pixels will be ignored in phase correlation registration step.
%                   e.g.: ignore_borderPC=150
%
% ignore_borderLK - Defines how many border pixels will be ignored in Lucas-Kanade registration step.
%                   e.g.: ignore_borderLK=50
%
% NwinLK - Window size for Lucas-Kanade tracking.
%          This should be slightly higher than thickenss of large blood-vessels.
%          e.g.: NwinLK=31
%
% RGB_flag - If the video is RGB, then set to 1; If monochromatic, set to 0.
%
% OUTPUTS:
% Outputs are stored in te same folder as the input .avi video is stored.
%
% After registration process, the following files are created in the input folder:
% 1. AVI file with postfix '_phase' where the result of the first stage registration is saved. 
%   You can use this file to check if the phase correlation method is
%   working. It corrects for large eye movements. Small movements are still present.
%
% 2. AVI file with postfix '_registered' where the result of the final second stage registration is saved.
%
% 3. Excel file with the same name as the original AVI file. This file
%   contains three columns: 1st and 2nd columns contain X, Y shift of each
%   frame with respect to reference frame. 3rd column contains rotation. The
%   number of rows is equal to number of frames in the sequence.
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

    disp([datestr(datetime) ': Rigid two-stage image registration has started for:'])
    disp(fnamepath)
    %% Input video, reading
    aviobj = VideoReader( fnamepath );
%     nFrames = aviobj.NumberOfFrames;
%     nr = aviobj.Height;
%     nc = aviobj.Width;
    %% Open/Create AVI to write result of Phase Correlation
    fnamepath2 = [ fnamepath(1:end-4) '_phase.avi'];

    aviobjPC = VideoWriter(fnamepath2, 'Motion JPEG AVI');
    aviobjPC.Quality = 100;
    aviobjPC.VideoCompressionMethod;
    aviobjPC.FrameRate = aviobj.FrameRate;
    %% Phase Correlation - the 1st stage of registration
    disp([datestr(datetime) ': First stage image registration via phase correlation has started.'])
    open( aviobjPC );
    shift_phase = rit_PhaseCorrelation( aviobj , aviobjPC, index_for_reference_frame, ignore_borderPC, RGB_flag );
    close(aviobjPC);
    % Possible to store the frame shifts estimated by PC method 
    % save( [ fnamepath(1:end-4) '_phase.mat' ], 'shift_phase' );
    disp([datestr(datetime) ': First stage image registration via phase correlation has finished.'])
    %% Lucas-Kanade - the 2nd stage of registration
    disp([datestr(datetime) ': Second stage Lucas-Kanade image registration has started.'])
    % Open/Create AVI to write the final video
    fnamepath3 = [ fnamepath(1:end-4) '_registered.avi'];
    aviobjLK = VideoWriter(fnamepath3, 'Motion JPEG AVI');
    aviobjLK.Quality = 100;
    aviobjLK.VideoCompressionMethod;
    aviobjLK.FrameRate = aviobj.FrameRate;

    % Read AVI with phase correlation corrected video
    aviobjPC = VideoReader( [ fnamepath(1:end-4) '_phase.avi'] );

    open( aviobjLK );
    T_transform = rit_LucasKanadeRigidRegistration( aviobjPC, aviobjLK, index_for_reference_frame, Kvessels, mask, NwinLK, ignore_borderLK, RGB_flag );
    close( aviobjLK );
    % Possible to store the frame shifts/rotation estimated by LK method 
    % save( [ fnamepath(1:end-4) '_registered.mat' ], 'T_transform' ); %save final translation and rotation
    disp([datestr(datetime) ': Second stage Lucas-Kanade image registration has finished.'])
    %% Writing final shift+rotation into Excel file
    % Create shift
    tmpShift = T_transform(1:2,:)' + shift_phase';

    % Add rotation in degree
    tmpShift = [tmpShift (180*T_transform(3,:)/pi)'];

    xlswrite( [fnamepath(1:end-4) '.xlsx'], tmpShift );
    
    disp(['Movement parameters are stored as:'])
    disp([fnamepath(1:end-4) '.xlsx'])
    disp(['Aligned video is stored as:'])
    disp([fnamepath(1:end-4) '_registered.avi'])
    disp([datestr(datetime) ': Rigid two-stage image registration has finished.'])
end