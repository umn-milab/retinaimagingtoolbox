function rit_denoise(videoin,sratio,visualization,nframes,fps,save_dir,video_name,precision,video_file)
%RIT_DENOISE
%
% Help

%% Video transfer into spectral domain
disp([datestr(datetime) ': Spectral PCA denoising has started for:'])
disp(video_file)

height = size(videoin,1);
width = size(videoin,2);
if strcmp(precision,'single')
    image_sequence_spec = single(zeros(2*height*width, nframes));
else
    image_sequence_spec = zeros(2*height*width, nframes);
end
frame_mean=zeros(nframes,1);
for ind = 1:nframes
    image = videoin(:,:,ind);
    if strcmp(precision,'single')
        image = single(image);
    end
    frame_mean(ind) = mean(image(:));
    spec = fft2(image-frame_mean(ind));
    spec_real = real(spec);
    spec_imag = imag(spec);    
    spec_real = spec_real(:);
    spec_imag = spec_imag(:);
    image_sequence_spec(:,ind) = [spec_real; spec_imag]';
end
clear videoin
%% PCA denoising
[coeff_reduced,score,~,~,st.explained,~] = pca(image_sequence_spec);
st.explained_cumulative = cumsum(st.explained);
score_ratio = zeros(1,size(score,2));
for ind=1:size(score,2)
    k1 = mean(abs(score(10:round(0.0195*size(score,1)),ind)));
    k2 = mean(abs( score(round(0.1948*size(score,1)):round(0.3247*size(score,1)),ind) ));
    score_ratio(1,ind) = k1/k2;
end
st.score_ratio = score_ratio';
st.sratio_thr = sratio;
st.ncomponents = find(score_ratio<sratio,1,'first')-1;
coeff_reduced(:,st.ncomponents+1:end) = 0;
image_sequence_spec=score*coeff_reduced';
%% VISUALIZATION
if visualization == 1
    figure(1)
    plot(st.explained_cumulative,'LineWidth',3)
    xlabel('Number of components')
    ylabel('Explained variability')
    title('Variance of retinal video spectra')
    axis([0 size(st.explained_cumulative,1) min(st.explained_cumulative) 100])
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
v = VideoWriter(fullfile(save_dir,[video_name(1:end-4) '_denoised.avi']), 'Uncompressed AVI');
v.FrameRate = fps;
open(v)
for ind = 1:nframes
    spec_real=image_sequence_spec(1:height*width,ind);
    spec_imag=image_sequence_spec(height*width+1:end,ind);
    
    spec_real=reshape(spec_real,height,width);
    spec_imag=reshape(spec_imag,height,width);
    spec = spec_real + 1i*spec_imag;
    
    spec = real(ifft2(spec)) + frame_mean(ind);
    if min(spec(:))<0
        spec = spec + abs(min(spec(:)));
    end
    if max(spec(:)) > 1
        spec = spec ./ max(spec(:));
    end
%     spec = spec/255;
    writeVideo(v, spec);
end
close(v)
save(fullfile(save_dir,[video_name(1:end-4) '_denoised.mat']),'st','-v7.3');

disp(['Denoising stats are stored as:'])
disp(fullfile(save_dir,[video_name(1:end-4) '_denoised.mat']))
disp(['Denoised video is stored as:'])
disp(fullfile(save_dir,[video_name(1:end-4) '_denoised.avi']))
disp([datestr(datetime) ': Spectral PCA denoising has finished.'])