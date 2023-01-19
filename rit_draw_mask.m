function [mask, xy_positions] = rit_draw_mask(im,fnamepath,ttle)
%RIT_DRAW_MASK Summary of this function goes here
%   Detailed explanation goes here

    h.fig = figure(1);
    set(h.fig,'Position',[150 150 1200 840]);
    imshow(im, [] )
    title(ttle,'Fontsize',12)
%     positions = getPosition(imfreehand(gca));
    positions = drawfreehand(gca);

    % To get image from positions
    mask = roipoly(size(im,1), size(im,2), positions.Position(:,1), positions.Position(:,2));
    xy_positions = [positions.Position(:,1) positions.Position(:,2)];
    
    % Save results
    save([fnamepath '.mat'], 'xy_positions','mask');
    imwrite(mask,[fnamepath '.png'])
    close(h.fig)
end

