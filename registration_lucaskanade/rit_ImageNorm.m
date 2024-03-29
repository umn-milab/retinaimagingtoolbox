function out = rit_ImageNorm( x, meze )
%
% out = ImageNorm( x [,meze] )
%
% 	Pro jeden vstupni parametr, funkce provede normalizaci 
% matice (vektoru) x.
% 	Druhy vstupni parametr je vektor [a b], ktery rika do 
% jakeho intervalu se maji hodnoty matice x transformovat.
% 	Musi platit, ze a<b !!!
%
% 	Radim Kolar 31.8.1999   9:20 
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

    if nargin==1 % normalizace od 0 do 1   

       maxi = max( max( x ) );
        mini = min( min( x ) );
        out = (x-mini)/(maxi-mini);

    elseif nargin==2 % normalizace od meze(1) do meze(2)

       maxi = max( max( x ) );
       mini = min( min( x ) );
       if maxi==mini 
          out = zeros( size(x) );
       else   
          out = (x-mini)/(maxi-mini);
       end   

       if meze(1)<0 && meze(2)>0 % pro kladnou a zapornou mez
           out = ( meze(2) - meze(1) )*out;      
          out = out - abs(meze(1));

       elseif meze(1)>=0 && meze(2)>0 % pro kladne meze
           out = ( meze(2) - meze(1) )*out;      
          out = out + abs(meze(1));

       elseif meze(1)<0 && meze(2)<0 % pro zaporne meze
           out = ( abs(meze(1)) - abs(meze(2)) )*out;      
          out = out - abs(meze(1));      

       end % if

    end % if 

    clear maxi mini
end
