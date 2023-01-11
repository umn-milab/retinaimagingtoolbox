clc;clear all;close all;

% video_dir = '/home/range1-raid1/labounek/data-on-porto/retina_imaging/crop/sub-0001/ses-01';
% video_name = 'sub-0001_ses-01_pos90_run1_06_01_2023_15_52_46_crop_1-661.mkv';

% video_dir = '/home/range1-raid1/labounek/data-on-porto/retina_imaging/raw/sub-0001/ses-01';
% video_name = 'sub-0001_ses-01_pos90_run1_06_01_2023_15_52_46.avi';

video_dir = '/mnt/ganglium-raid1/data/ivanka/retina_imaging/crop/sub-0001/ses-01';
video_name = 'sub-0001_ses-01_pos90_run1_06_01_2023_15_52_46_crop_1-661.mkv';

ncomponents=25;
visualization=1;
nframes = 661;

video_file=fullfile(video_dir, video_name);
v = VideoReader(video_file);

for ind = 1:nframes
    im = double(read(v,ind));
    im = im(:,:,1);
    
    video(:,:,ind) = im;
end

[video, fps, nframes] = rit_videoload(video_file, 'gray');
videoin = VideoReader(fullfile(video_dir, video_name));