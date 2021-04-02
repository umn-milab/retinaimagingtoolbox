function Topt = rit_ThresholdKittler(obr)
% Looking for optimal threshold based on Kittler thresholding
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

    obr = double(obr);

    % obr=obr*1/max(max(obr));
    % obr(obr<0.5*mean(mean(obr))) = mean(mean(obr));
    % obr = 1 - obr;
    h = imhist(obr);

    p = h/sum(h);
    p(1) = 0;

    for i = 1:length(p)
        P = sum(p(1:i));
        mf = sum([1:i].*p(1:i)');
        sigma_f = sqrt(sum((([1:i]-mf).^2) .*p(1:i)'));
    %     sf = std(p(1:i));
        mb = sum([i+1:length(p)].*p(i+1:end)');
        sigma_b = sqrt(sum(([i+1:length(p)]-mf).^2 .* p(i+1:end)'));
    %     sb = std(p(i+1:end));
    %     T(i) = P * log(sf) + (1-P) * log(sb) - P*log(P) - (1-P)* log(1-P);
        T(i) = P * log(sigma_f) + (1-P) * log(sigma_b) - P*log(P) - (1-P)* log(1-P);
    end

    Topt = (find(T == min(T(T>-inf))))/256;
    Topt=Topt(end);
end


