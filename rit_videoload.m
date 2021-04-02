function [video, fps, nframes] = rit_videoload(video_file, colormode)
%% HELP
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

%%
    v = VideoReader(video_file);
    if size(double(readFrame(v)),3) == 1
        colormode = 'r';
    end    
    v = VideoReader(video_file);
    ind = 1;
    switch colormode
        case {'r', 'g', 'b'}        
            switch colormode
                case 'r'
                    channel = 1;
                case 'g'
                    channel = 2;
                case 'b'
                    channel = 3;
            end
            while hasFrame(v)
                frame = im2double(readFrame(v));
                video(:,:,ind) = frame(:,:,channel);
                ind = ind + 1;
            end  
        case 'gray'
            while hasFrame(v)
                frame = im2double(readFrame(v));
                video(:,:,ind) = rgb2gray(frame);
                ind = ind + 1;
            end
    end
    fps = v.FrameRate;
    nframes = size(video,3);
end