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
clear all;
close all;
clc;
%% INPUT VIDEO
dirname = 'C:\Users\Ivanka\Documents\retina\RIT_example'; %Folder path where the input video is stored.
fname = 'Study_02_00040_02_R.avi'; % Input video filename.
% Example of non-aligned input video (RetinaVideo.avi) you can download at: https://github.com/ivanalabounkova/retinaimagingtoolbox-data
fnamepath = fullfile(dirname, fname);
%% RIT INITIALIZATION
% You need to have setup the retinaimagingtoolbox folder in you MATLAB path
% to make basic RIT command such as rit_defaults to work.
% HOME -> Set Path -> Add Folder -> Find the folder at the HDD and add it -> Save (to remember to set path after MATLAB Restart)
rit_defaults % It is enough to execute rit_defaults just once per one MATLAB instance
%% PARAMETERS
index_for_reference_frame = 1; %the first frame is the reference frame
Kvessels = 1; % parameter for thresholding during blood vessel detection; it multiplies the threshold during blood vessel detection
ignore_borderPC = 150; % how many border pixels will be ignored in phase correlation step
ignore_borderLK = 50; % how many border pixels will be ignored in Lucas-Kanade step
NwinLK = 31; % window size for Lucas-Kanade tracking - this should be slightly higher than thickenss of large blood-vessels
RGB_flag = 0; % if the video is RGB, then set to 1; monochromatic - set to 0
%% MASK / REGION OF INTEREST SETUP
mask = [];
% Example how to manually draw mask defining the region of interest (ROI) insted of the full image ROI:
%
% aviobj = VideoReader( fnamepath );
% x2show = read( aviobj, index_for_reference_frame );
% mask = roipoly( x2show );
% mask = imdilate( mask, strel('disk', 7, 0) );
% figure(1);
% imshow( x2show, [] );
%% EXECUTE RIGID LUCAS-KANADE REGISTRATION
rit_registration_lucaskanade(fnamepath,mask, index_for_reference_frame, Kvessels,...
    ignore_borderPC, ignore_borderLK, NwinLK, RGB_flag);
delete([fnamepath(1:end-4) '_phase.avi']);