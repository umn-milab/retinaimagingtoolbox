function [extremes, s_out] = rit_extremes(s,fps)
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
    sm_kernel = ones(1,5)/5;
    der1_kernel = [1 -1];
    s_mean = mean(s);
    s_std = std(s);
    s0 = (s - s_mean) / s_std;
    s00 = s0;
    s0 = fft(s0);
    cutoff=round(4/fps*size(s0,2)); 
    cutoff2=round(0.5/fps*size(s0,2));
    s0(1,1) = 0;
    s0(cutoff+2:end-cutoff)=0;
    s0(2:cutoff2) = 0;
    s0(end-cutoff2+2:end) = 0;
    s0 = real(ifft(s0));
    s0(1:3) = s00(1:3);
    s0(end-2:end) = s00(end-2:end);
    s_sm = conv(s0,sm_kernel,'same');
    s_sm(1,1) = s0(1,1);
    s_sm(1,end) = s0(1,end);
    s_der1 = conv(s_sm,der1_kernel,'same');
    s_der1 = [1 1 s_der1(2:end-1)];
    extr_loc = zeros(size(s));
    extr_loc(abs(s_der1)<0.08) = 1;
    extr_loc(end-1:end) = 0;
    for ind = 1:size(extr_loc,2)-1
            if extr_loc(ind) == 0 && extr_loc(ind+1) == 1
                    extr_loc(ind) = 1;
            end
    end
    extr_loc = extr_loc .* s0;
    pks = findpeaks(abs(extr_loc));
    extremes = zeros(size(pks,2),2);
    for ind = 1:size(pks,2)
            pos = find(abs(extr_loc)==pks(1,ind),1,'first');
            extremes(ind,1) = pos;
            extremes(ind,2) = extr_loc(pos);
    end
    pm=abs(extremes(:,2))<0.5; 
    extremes(pm,:)=[]; 
    zer_loc = log(abs(1./s0));
    zer_loc(zer_loc<0) = 0;
    zer_loc = conv(zer_loc,ones(1,3)/3,'same');
    zer_loc = [zer_loc(1:end-1) 0];
    pks = findpeaks(zer_loc);
    pks(pks<1.5) = [];

    dtc = size(extremes,1);
    for ind = 1:size(pks,2)
            pos = find(zer_loc==pks(1,ind),1,'first');
            extremes(dtc+ind,1) = pos;
            extremes(dtc+ind,2) = 0;
    end
    dsts = abs(diff(extremes(:,1)));

    dstsx = find(dsts<=125/fps) + 1;
    extremes(dstsx,:)=[];
    extremes = sortrows(extremes,1);
    ind = 1;
    while ind <= size(extremes,1)-1
            if abs(extremes(ind,2)) > 0 && abs(extremes(ind+1,2)) > 0
                    if abs(extremes(ind,2)) > abs(extremes(ind+1,2))
                            extremes(ind+1,:) = [];
                    else
                            extremes(ind,:) = [];
                    end
            elseif extremes(ind,2) == 0 && extremes(ind+1,2) == 0
                    extremes(ind+1,:) = [];
            end
            ind = ind + 1;
    end
    extremes(:,3) = extremes(:,1)*(1/fps)-1/fps;
    extremes(extremes(:,3)>10,:) = [];

    if extremes(1,2) ~=0
            extremes(1,:) = [];
    end
    if extremes(end,2) ~=0
            extremes(end,:) = [];
    end
    if extremes(2,2) < 0 && extremes(1,2) == 0
            extremes([1 2],:) = [];
    end
    if extremes(end-1,2) > 0 && extremes(end,2) == 0
            extremes([end-1 end],:) = [];
    end
    if extremes(end-1,2) == 0 && extremes(end,2) == 0
            extremes(end,:) = [];
    end
    if extremes(2,2) < extremes(1,2) && extremes(1,2) == 0 
            extremes([1 2],:) = [];
    end 
    if extremes(1,2) == 0 && extremes(2,2) == 0 
            extremes(1,:) = []; 
    end 
    extremes(:,4) = extremes(:,2)*s_std + s_mean;
    s_out = s0*s_std + s_mean;
end