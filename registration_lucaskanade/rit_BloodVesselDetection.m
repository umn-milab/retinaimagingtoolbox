function out = rit_BloodVesselDetection( im1, vis )
% im1 - 2D obraz
% vis - pokud je 1, tak se bude vykreslovat do figure 1
% out - 2D obraz
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

% if vis==1, figure(1); subplot(131); imshow( im1, []); end
%% FILTRACE - ROZMAZANI - POTLACENI SUMU A MALYCH HRAN
% h = fspecial( 'gaussian', 11, 2.5 ); 
h = fspecial( 'gaussian', 17, 4 ); 
im1 = conv2( im1, h, 'same' );
% im1 = double( adapthisteq(uint8(im1)) );
% im1 = conv2( im1, h, 'same' );

% if vis==1, subplot(132); imshow( im1, []); end
%% Sobel
gy = fspecial('sobel'); 
gx = gy';
%% First differences
Ix = conv2( im1, gx, 'same' );
Iy = conv2( im1, gy, 'same' );

%% Second differences
Ixx = conv2( Ix, gx, 'same' );
Iyy = conv2( Iy, gy, 'same' );
Ixy = conv2( Ix, gy, 'same' );

%% Eigenvalues
[nr, nc] = size( Ixx );
l1 = zeros( nr, nc );
l2 = zeros( nr, nc );

%% Determinant
D = sqrt( (Ixx+Iyy).^2 + 4*Ixy.^2 - 4*Ixx.*Iyy );
l1 = (-(Ixx + Iyy) + D)/2;
l2 = (-(Ixx + Iyy) - D)/2;
out = abs(l2);

% if vis==1, subplot(133); imshow( out(10:end-10,10:end-10), []); end
end