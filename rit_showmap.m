function [output] = rit_showmap(background, overlay_image, treshold, varargin)
%HELP
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
   defaultAlpha = 0.9;
   defaultMask = ones(size(background));
   defaultScale = 'lin';
   
   expectedScale = {'lin','log'};
   
   p = inputParser;
   
   addRequired(p,'background', @(x) isnumeric(x) && size(x,1)>1 && size(x,2)>1);
   addRequired(p,'overlay_image', @(x) isnumeric(x) && size(x,1)==size(background,1) && size(x,2)==size(background,2));
   addRequired(p,'treshold', @(x) isnumeric(x) && isscalar(x));
   
   addOptional(p,'Alpha', defaultAlpha, @(x) isnumeric(x) && isscalar(x) && (x > 0 && x <= 1));
   addOptional(p,'Mask', defaultMask, @(x) size(x,1)==size(background,1) && size(x,2)==size(background,2) && ismember([0],ismember((double(x(:)))', [0,1]))==0);
   
   addParameter(p,'Scale',defaultScale,@(x) any(validatestring(x,expectedScale)));
    
   parse(p, background, overlay_image, treshold ,varargin{:});
   
   %%
                
    binarymask = zeros(size(p.Results.background));
    binarymask(abs(p.Results.overlay_image)>p.Results.treshold & p.Results.Mask == 1) = 1;

    component = p.Results.overlay_image;
    intmin = min(component(:));
    intmax = max(component(:));

    component(abs(component)<p.Results.treshold) = 0;

%                 figure()
    h_bar = colorbar('south', 'AxisLocation', 'out'); caxis([intmin, intmax])
    orig_axis = get(h_bar, 'Ticks');
    orig_axis = (sort(unique([orig_axis -p.Results.treshold p.Results.treshold])));
    cla

    switch p.Results.Scale
        case 'lin'
            norm_component = uint8(((component-intmin)./(intmax-intmin))*255);

%                         
            vls = orig_axis;
            vals1 = num2cell(vls);
            vals = (arrayfun(@(y) num2str(vals1{y}),1:length(vals1),'UniformOutput',false));                 


        case 'log'
            component(component>0) = log(component(component>0));
            component(component<0) = -log(-component(component<0));
            component(component>log(intmax)) = log(intmax);
            component(component<-log(-intmin)) = -log(-intmin);
            norm_component = uint8(((component-(-log(-intmin)))./(log(intmax)-(-log(-intmin))))*255);

            vls1 = -log(abs(orig_axis(orig_axis<=-1)));
            vls2 = log(orig_axis(orig_axis>=1));

            val1 = num2cell((orig_axis(orig_axis<=-1)));
            val2 = num2cell(orig_axis(orig_axis>=1));


            if abs(p.Results.treshold) < 1 && abs(p.Results.treshold)>=0
                error('Tresh value is not applicable for log colorbar axis')
                return                   
            elseif p.Results.treshold == 1
                vls = [vls1(1:end-1), vls2];
                vals = [ (arrayfun(@(y) num2str(val1{y}),1:length(val1)-1,'UniformOutput',false)), {[num2str(-abs(p.Results.treshold)) '=' num2str(abs(p.Results.treshold))]}, ((arrayfun(@(y) num2str(val2{y}),2:length(val2),'UniformOutput',false)))];                 
            else
                vls = [vls1(1:end-1), vls2];
                vals = [ (arrayfun(@(y) num2str(val1{y}),1:length(val1)-1,'UniformOutput',false)), {'-1=1'}, ((arrayfun(@(y) num2str(val2{y}),2:length(val2),'UniformOutput',false)))];                 
            end                      

    end

    norm_component = ind2rgb(norm_component, jet(256));             

    rchannel = norm_component(:,:,1);
    gchannel = norm_component(:,:,2);
    bchannel = norm_component(:,:,3);

    background_norm = (p.Results.background - min(p.Results.background(:)))./(max(p.Results.background(:))-min(p.Results.background(:)));
    vizual_r = background_norm;
    vizual_g = background_norm;
    vizual_b = background_norm;

    vizual_grey = cat(3, vizual_r, vizual_g, vizual_b);

    vizual_r(logical(binarymask)) = rchannel(logical(binarymask));
    vizual_g(logical(binarymask)) = gchannel(logical(binarymask));
    vizual_b(logical(binarymask)) = bchannel(logical(binarymask));

    vizual = cat(3, vizual_r, vizual_g, vizual_b);

    component_data=component;
    component_data = uint8(((component-intmin)./(intmax-intmin))*255);

    first_viz = imshow(vizual_grey, []);
    hold on
    viz_over = imshow(vizual, []);
    set(viz_over, 'Alphadata', p.Results.Alpha)

    component_transp = imshow(component_data); set(component_transp, 'Alphadata', 0.01); colormap jet;

    h_bar = colorbar('south', 'AxisLocation', 'out','Ticks',vls,'TickLabels',vals); abc = get(h_bar, 'Position'); set(h_bar, 'Position', [abc(1)-0.0 abc(2)-0.08 abc(3) abc(4)*5/6]);
    caxis([vls(1,1) vls(1,end)])                

end