function [out,r_x, c_x] = rit_ShiftEstimatePhaseCorrelation( im1, im2, ignore_border )
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
    % Create and apply 2D Hanning window (with respect to set borders)
    if nargin==2
        [nr,nc] = size( im1 );
        h1 = hanning( nr ).^0.5;
        h2 = (hanning( nc ).^0.5)';
        H = zeros( nr, nc );
        for rr = 1:nr
            H(rr,:) = h1(rr)*h2;
        end
        x1 = H.*im1;
        x2 = H.*im2;
    else
        [nr,nc] = size( im1 );
        h1 = [ zeros(ignore_border,1); hanning( nr-2*ignore_border ).^0.5; zeros(ignore_border,1)];
        h2 = [zeros(ignore_border,1); hanning( nc-2*ignore_border ).^0.5; zeros(ignore_border,1)]';

        H = zeros( nr, nc );
        for rr = 1:nr
            H(rr,:) = h1(rr)*h2;
        end
        x1 = H.*im1;
        x2 = H.*im2;    
    end

    % imshow( x1, []);
    % pause
    % [r_x, c_x, kvalita] = my_phase_reg_f( x1, x2, 0 );

    %% Apply the main algorithm
    % [r_x, c_x] = my_phase_reg_f( x1, x2, 0 );

    % function [r_x, c_x, kvalita] = my_phase_reg_f( x2, x1, visu, quality_eval )
    %
    % Prvni je VELKY obraz, druhy je malinkaty obrazek, ale neni nutne.
    % Funkce vraci vzajemny posun dvou obrazku - r_x (radky), c_x (sloupce)
    % a obraz xx, ze ktereho se hodnoti poloha posunu.
    % Nejsem si 100% jisty, zda dobre prepocitavam polohu v xx obrazku na
    % posun ale snad jo.
    % Dale funkce vraci hodnotu 'kvality' - viz radek 91 %% pocitani kvality

    %% prevedeme pro jistotu na double
    tmp = double( x2 ); % float
    x2 = double( x1 );    % ref
    % x1 = double( x1 );
    x1 = tmp;
    %% zjistime maximalni velikost snimku
    [nr1,nc1] = size( x1 );
    [nr2,nc2] = size( x2 );
    nr = max([nr1 nr2]);
    nc = max([nc1 nc2]);

    %% Possibility to use additional window function
    h1 = hanning( nr ).^0;
    h2 = (hanning( nc ).^0)';
    H = zeros( nr, nc );

    for rr = 1:nr
        H(rr,:) = h1(rr)*h2;
    end
    x1 = H.*x1;
    x2 = H.*x2;

    %% 2D DFT
    X1 = fftshift( fft2( x1, nr, nc ) );
    X2 = fftshift( fft2( x2, nr, nc ) );

    %% Phase correlation 
    XX = X1.*conj(X2);
    XX = XX./( abs(X1.*X2) );

    %% 2D iDFT
    xx = fftshift( abs( ifft2( fftshift(XX) ) ) );

    %% Fitlering in spectral domain to suppress spikes
    h = fspecial('disk', 2 );
    xx = conv2( xx, h, 'same' );
    % xx = medfilt2( xx, [3 3] );

    %%
    maxi = max( max(xx) );
    [r,c] = find( xx == maxi );
    if numel(r)==0, r = 0; end
    if numel(c)==0, c = 0; end

    nr2 = nr/2;
    nc2 = nc/2;

    [nrpom,ncpom] = size(x1);
    r_x = ( (r(1) - nr2) + (nrpom/2) ) -1;
    c_x = ( (c(1) - nc2) + (ncpom/2) ) -1;

    %% Correctiof with respect to the center of the image
    r_x = r_x - nr/2;
    c_x = c_x - nc/2;

    %% Create the output image
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
        c_pridat_dopredu+1 : end-c_pridat_dozadu ) = im2(od_r_mov:do_r_mov, od_c_mov:do_c_mov);
end