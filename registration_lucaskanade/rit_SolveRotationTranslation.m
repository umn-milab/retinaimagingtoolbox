function out = rit_SolveRotationTranslation( XY, xy, method )
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

    if nargin==2
        [nr, ~] = size( XY );

        M = zeros( 3, 3 );
        b = zeros( 3, 1 );

        for ii = 1:nr
            M = M +  [-1, 0, xy(ii,2); 0, -1, -xy(ii,1); -xy(ii,2), xy(ii,1), xy(ii,1)^2 + xy(ii,2)^2 ];
            b = b + [XY(ii,1)-xy(ii,1); XY(ii,2)-xy(ii,2); (XY(ii,1)-xy(ii,1))*xy(ii,2) - (XY(ii,2)-xy(ii,2))*xy(ii,1)];
        end

        out = M\b;

    else

        im = XY;

        xt = xy(1);
        yt = xy(2);
        fi = xy(3);

        [yi,xi] = ndgrid(1:1:size(im,1),1:1:size(im,2) );
        xxi = xi*cos(fi) - yi*sin(fi) + xt;
        yyi = xi*sin(fi) + yi*cos(fi) + yt;

        if size(im,3)==1
            out = interp2( xi, yi, double(im), xxi, yyi, method);
        else
            out(:,:,1) = interp2( xi, yi, double(im(:,:,1)), xxi, yyi, method);
            out(:,:,2) = interp2( xi, yi, double(im(:,:,2)), xxi, yyi, method);
            out(:,:,3) = interp2( xi, yi, double(im(:,:,3)), xxi, yyi, method);
    %         out(:,:,1) = interp2( xi, yi, (im(:,:,1)), xxi, yyi, method);
    %         out(:,:,2) = interp2( xi, yi, (im(:,:,2)), xxi, yyi, method);
    %         out(:,:,3) = interp2( xi, yi, (im(:,:,3)), xxi, yyi, method);
        end

        ind = find( isnan( out) );
        out( ind ) = 0;
    end
end