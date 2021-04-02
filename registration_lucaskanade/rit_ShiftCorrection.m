function out = rit_ShiftCorrection(im, r_x, c_x )
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

    [nr,nc] = size( im );

    out = zeros( nr, nc );

    if -c_x<0
        od_c_mov = c_x+1;
        do_c_mov = nc;
        c_pridat_dozadu = abs(c_x);
        c_pridat_dopredu = 0;    
    %     od_c_ref = 1;
    %     do_c_ref = nc-c_x;
    elseif -c_x>0
    %     od_c_ref = -c_x;
    %     do_c_ref = nc;
        od_c_mov = 1;
        do_c_mov = nc+c_x;
        c_pridat_dopredu = abs( c_x );
        c_pridat_dozadu = 0;
    else
    %     od_c_ref = 1;
    %     do_c_ref = nc;
        od_c_mov = 1;
        do_c_mov = nc;    
        c_pridat_dopredu = 0;
        c_pridat_dozadu = 0;     
    end

    if -r_x<0
        od_r_mov = r_x+1;
        do_r_mov = nr;
        r_pridat_dozadu = abs(r_x);
        r_pridat_dopredu = 0;
    %     od_r_ref = 1;
    %     do_r_ref = nr-r_x;
    elseif -r_x>0
    %     od_r_ref = -r_x;
    %     do_r_ref = nr;
        od_r_mov = 1;
        do_r_mov = nr+r_x;
        r_pridat_dopredu = abs( r_x );    
        r_pridat_dozadu = 0;        
    else
    %     od_r_ref = 1;
    %     do_r_ref = nr;
        od_r_mov = 1;
        do_r_mov = nr;
        r_pridat_dopredu = 0;
        r_pridat_dozadu = 0; 
    end

    out(r_pridat_dopredu+1 : end-r_pridat_dozadu, ...
        c_pridat_dopredu+1 : end-c_pridat_dozadu ) = im(od_r_mov:do_r_mov, od_c_mov:do_c_mov);
end
