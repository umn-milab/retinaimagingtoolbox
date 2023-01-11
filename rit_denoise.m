function video_out = rit_denoise(videoin,ncomponents,visualization)
%RIT_DENOISE
%
% Help

%% Video transfer into spectral domain
Nframes = videoin.NumberOfFrames;
fps = videoin.FrameRate;
% image_sequence = zeros(videoin.Height,videoin.Width, Nframes);
image_sequence_spec = zeros(2*videoin.Height*videoin.Width, Nframes);
frame_mean=zeros(Nframes,1);
for ind = 1:Nframes
    image = double( read(videoin,ind) );
    image = image(:,:,1);
%     image = conv2(image, ones(3)/9, 'same');  % convolution
%     image_sequence(:,:,ind) = fft2(image);
    frame_mean(ind) = mean(image(:));
    spec = fft2(image-frame_mean(ind));
    spec_real = real(spec);
    spec_imag = imag(spec);    
    spec_real = spec_real(:);
    spec_imag = spec_imag(:);
    
    image_sequence_spec(:,ind) = [spec_real; spec_imag]';
end
%% NORDIC PCA
[coeff_reduced,score,~,~,explained,~] = pca(image_sequence_spec);
explained_cumulative = cumsum(explained);
% PCA_com_image = reshape(score,[],1);
coeff_reduced(:,ncomponents+1:end) = 0;
% PCA_com_image = PCA_com_image(:,:,1:ncomponents);
% PCA_coeff = PCA_coeff(:,1:ncomponents);
image_sequence_spec=score*coeff_reduced';
%% VISUALIZATION
if visualization == 1
    figure(1)
    plot(explained_cumulative,'LineWidth',3)
    xlabel('Number of components')
    ylabel('Explained variability')
    title('Variance of retinal video spectra')
    axis([0 size(explained_cumulative,1) min(explained_cumulative) 100])
    grid on
    set(gca,'FontSize',14,'LineWidth',2)
    
    h(2).fig = figure(2);
    set(h(2).fig,'Position',[50 50 2300 1250])
    for cm = 1:25
        subplot(5,5,cm)
        plot(score(:,cm))
        axis([0 size(score,1) min(score(:,cm)) max(score(:,cm))])
        title(['Component ' num2str(cm)])
        grid on
        set(gca,'FontSize',12,'LineWidth',2)
    end
    
    h(3).fig = figure(3);
    set(h(3).fig,'Position',[50 50 2300 1250])
    ps = 1;
    for cm = 30:5:150
        subplot(5,5,ps)
        plot(score(:,cm))
        axis([0 size(score,1) min(score(:,cm)) max(score(:,cm))])
        title(['Component ' num2str(cm)])
        grid on
        set(gca,'FontSize',12,'LineWidth',2)
        ps = ps + 1;
    end
end
%% Denoised image reconstruction
v = VideoWriter([video_file(1:end-4) '_nordic.avi'], 'Uncompressed AVI');
v.FrameRate = fps;
open(v)
for ind = 1:Nframes
    spec_real=image_sequence_spec(1:videoin.Height*videoin.Width,ind);
    spec_imag=image_sequence_spec(videoin.Height*videoin.Width+1:end,ind);
    
    spec_real=reshape(spec_real,videoin.Height,videoin.Width);
    spec_imag=reshape(spec_imag,videoin.Height,videoin.Width);
    spec = spec_real + 1i*spec_imag;
    
    spec = real(ifft2(spec)) + frame_mean(ind);
    spec = spec/255;
%     image_sequence(:,:,ind) = spec;
    writeVideo(v, spec);
end
close(v)