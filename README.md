# Retina Imaging Toolbox (RIT)

## Content

-   [Introduction](#introduction)
-   [Image registration](#image-registration)
-   [Vessel segmentation](#vessel-segmentation)
-   [Blind source separation](#blind-source-separation)
-   [K-means filter for spike noise suppression](#k-means-filter-for-spike-noise-suppression)
-   [Time-course morphology analysis via control points](#time-course-morphology-analysis-via-control-points)
-   [References](#references)

## Introduction

**ANYONE CAN CONTRIBUTE** to the open-source MATLAB/Octave software library for **automated dynamic or static retina image analysis**. The library includes:
- import of standard video file formats (e.g. .avi, .mp4, .mkv, etc.) into 3D double array variable 
- image registration `(Kolar et al. 2016)`
- blind source separation (i.e. principal component analysis - PCA, independent component analysis - ICA) `(Labounkova et al. 2019; Labounkova et al. 2020)`
- one-dimensional spike noise suppresion K-means filter `(Labounkova et al. 2020)`
- automatic detection of control points in periodic time-courses `(Labounkova et al. 2020)`
- visualization of spatial color-coded statistical parametric map over a retina anatomy background image

In the near future, we plan to rewrite RIT into a paralell and separate full python implementation and build graphical interface for comfortable and easy result visualization.


## Image registration

[In Progress]

## Vessel segmentation

[In Progress]

## Blind source separation

[In Progress]

## K-means filter for spike noise suppression

[In Progress]

## Time-course morphology analysis via control points

[In Progress]

## References
Kolar, R., Tornow, R. P., Odstrcilik, J., & Liberdova, I. (2016). Registration of retinal sequences from new video-ophthalmoscopic camera. *Biomedical Engineering Online*, 15(1), 57. DOI: [10.1186/s12938-016-0191-0](https://biomedical-engineering-online.biomedcentral.com/articles/10.1186/s12938-016-0191-0)

Labounkova, I., Labounek, R., Nestrasil, I., Odstrcilik, J., Tornow, R.P., & Kolar, R. (2021). Blind Source Separation of Retinal Pulsatile Patterns in Optic Nerve Head Video-Recordings. *IEEE Transactions on Medical Imaging*, 40(3), 852-864 DOI: [10.1109/TMI.2020.3039917](https://ieeexplore.ieee.org/document/9269462)

Labounkova, I., Labounek, R., Odstrcilik, J., Hracho, M., Nestrasil, I., Tornow, R. P., & Kolar, R. (2019). Blind Source Separation of Different Retinal Pulsatile Patterns from Simultaneous Long-term Binocular Ophthalmoscopic Video-records. In *41st Annual International Conference of the IEEE Engineering in Medicine and Biology Society*, 4729-4732. DOI: [10.1109/EMBC.2019.8857560](https://ieeexplore.ieee.org/document/8857560)

Hyvarinen, A., Oja, E. (1997). A Fast Fixed-Point Algorithm for Independent Component Analysis. *Neural Computation*, 9, 1483-1492. DOI: [10.1162/neco.1997.9.7.1483](https://direct.mit.edu/neco/article/9/7/1483/6120/A-Fast-Fixed-Point-Algorithm-for-Independent)


