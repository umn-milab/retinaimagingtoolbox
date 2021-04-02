function [u, v] = rit_LucasKanade(im1, im2, windowSize, ind, G, dG)
%Lucas Kanade algorithm without pyramidal extension
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

    %%
    [fx, fy, ft] = rit_ComputeDerivatives(im1, im2, G, dG );

    halfWindow = floor(windowSize/2);   

    % if nargin==4
    % size(ind,1)
    for ii = 1:size(ind,1)

          curFx = fx(ind(ii,1)-halfWindow:ind(ii,1)+halfWindow, ind(ii,2)-halfWindow:ind(ii,2)+halfWindow);
          curFy = fy(ind(ii,1)-halfWindow:ind(ii,1)+halfWindow,ind(ii,2)-halfWindow:ind(ii,2)+halfWindow);
          curFt = ft(ind(ii,1)-halfWindow:ind(ii,1)+halfWindow, ind(ii,2)-halfWindow:ind(ii,2)+halfWindow);

          curFx = curFx(:);
          curFy = curFy(:);
          curFt = curFt(:);

          A = [sum(curFx.^2), sum(curFx.*curFy);...
                  sum(curFx.*curFy),  sum(curFy.^2)]; 

          b = [sum(curFt.*curFx); sum(curFt.*curFy)]; 

          U = A\b;

          u(ii,1) = U(1);
          v(ii,1) = U(2);        
    end
end