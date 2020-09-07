function inty = rit_kmeans_filt(input,posnon)
%% HELP

%   CITE AS:
%   Labounkova I, Labounek R, Nestrasil I, Odstrcilik J, Tornow R P,
%   Kolar R, "Blind Source Separation of Phase Shifted Retinal Pulsatile
%   Patterns in Optic Disc from Video-ophthalmoscopic Recordings," IEEE
%   Transactions on Medical Imaging, 2020. [Under Review]
%
%   Copyright 2020 Ivana Labounkova(1,2), Rene Labounek(2), Igor Nestrasil(2,3),
%       Jan Odstrcilik(1), Ralf P. Tornow(4), Radim Kolar(1)
%   (1) Department of Biomedical Engineering, Brno University of Technology, Brno, Czech Republic
%   (2) Division of Clinical Behavioral Neuroscience, Department of Pediatrics, University of Minnesota, Minneapolis, USA
%   (3) Center for Magnetic Resonance Research, Department of Radiology, University of Minnesota, Minneapolis, USA
%   (4) Department of Ophthalmology, Friedrich-Alexander University of Erlangen-Nuremberg, Erlangen, Germany
%
%   This file is part of Retina Imaging Toolbox available at: https://github.com/ivanalabounkova/retinaimagingtoolbox
%
%   Retina Imaging Toolbox is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or any later version.
%
%    Retina Imaging Toolbox is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with Retina Imaging Toolbox.  If not, see <https://www.gnu.org/licenses/>.
%%
    operator = [1 -2 1];
    grd = conv(input,operator,'same');
    grd = abs(grd);
    if posnon == 1
        grd(1)=0;
        grd(end)=0;
    else
        grd(1:posnon)=0;
        grd(end-posnon+1:end)=0;
    end

    tmp = kmeans(grd',2);
    tmp_count = 1;
    found=0;
    for iter = 1:300
        grd_km = kmeans(grd',2);
        for sols = 1:size(tmp,2)
            if sum(abs(tmp(:,sols)-grd_km)) == 0
                found = 1;
                tmp_count(1,sols) = tmp_count(1,sols) + 1;
            end                        
        end
        if found == 0
            tmp(:,end+1) = grd_km;
            tmp_count(1,end+1) = 1;
        end
        found = 0;
    end
    grd_km = tmp(:,tmp_count==max(tmp_count));
    grd_km = grd_km(:,1);

    grd_km(grd_km==1)=0;
    grd_km(grd_km==2)=5;

    x = 1:size(grd_km);
    inty = interp1(x(grd_km==0),input(grd_km==0),x,'spline');
end