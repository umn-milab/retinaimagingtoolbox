% Copyright 2020-2023 Ivana Labounkova(1,2), Rene Labounek(2), Igor Nestrasil(2,3),
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
clc;
clear all;
close all;

video_dir = 'C:\Users\User\Videos'; %Folder path where the input video is stored.
video_name = 'RetinaVideo.avi'; % Input video filename.
save_dir = 'C:\Users\User\Results'; % Folder path where the results are stored.

sratio=1.40; % Ratio between amplitude of the image signal and amplitude of estimated noise. The value defines float index of the first principal component
             % which will be zeroed. For the value 1.25, last preserved component will have amplitude of the signal image about 40% higher than amplitude of
             % the estimated noise,
visualization=1; % set to value 1, if you want to see example of components in spectral domain (first half real values, second half imaginery values)
precision = 'double';
% precision = 'single'; % if limitted RAM memory is available

video_file=fullfile(video_dir, video_name);
[video, fps, nframes] = rit_videoload(video_file, 'gray');
[video_denoised, denoise_stats] = rit_denoise(video,sratio,visualization,nframes,fps,save_dir,video_name,precision);
% Hello world, Ivanka