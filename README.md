Dense Structure-from-Motion with Keypoint Relocalization

[Project page: http://www.ok.sc.e.titech.ac.jp/res/DenseSfM/index.html]

Dense feature extraction is done using CNN. It's dense but the drawback is that the feature point locations are located in grid patter. It means that the accuracy of keypoints are not in ideal position. To improve the keypoints accuracy, we implement keypoint relocalization based on coarse to fine method.

Requirement:
1. Please download the MatConvNet from here:
http://www.vlfeat.org/matconvnet/
2. Please download this network for this code: https://www.di.ens.fr/willow/research/netvlad/data/models/vd16_pitts30k_conv5_3_vlad_preL2_intra_white.mat
Place it in the same directory as main.m
You can change the network with minor modification of the script.

3. You need colmap on your machine. Read about it here https://colmap.github.io/
For our paper, we use colmap 3.3.

4. For the dataset, you can use test dataset provided by colmap. I recommend using South Building https://demuc.de/colmap/datasets/
You can also try this dataset https://www.dropbox.com/sh/r1tuac039n1s1ej/AAA0AGFddW-UiX5fHSEaiQj6a?dl=0.

How to use:
0. Precaution: The features extracted by CNN are saved in the drive and they are big (sometimes huge) in total. Make sure you have enough space in your drive.
In this code, GPU plays important role. We use 1600x1200 image resolution for CNN feature extraction. If your GPU can't handle that resolution, change the maximsize variable in main.m

1. Prepare a folder with images of structure you want to reconstruct. The structure should look like this:

+Folder  
|-img1.jpg  
|-img2.jpg  
|-img3.jpg  
|-...  
|-...  
|-imgN.jpg  

The format is arbitrary as long as all images share the same format. The name of the images are also arbitrary

2. Open matlab and run setup.m

3. Set the 'pth', 'colmap_path', and 'image_format' variable in main.m
The image_format is case sensitive. Please make sure wether, for example, you have .JPG or .jpg format.
If your colmap is already global path/variable, just leave it empty, e.g., ''

4. For 'colmap_path' please consider which is the best for your system. It depens on the COLMAP version you have, e.g., older than 3.4 or 3.4

5. You can chose whether to reconstruct using COLMAP (Root)SIFT or not by setting the variable 'reconstruct_sparse_colmap'

7. You can see the summary of the reconstruction model in 'model_properties.txt' in the output folder

8. You can visualize the inlier matches after everything has finished by changing the visualizeonly variable in main.m to true

Additional script:
There is a python script added in this repo that can edit the matches of COLMAP database. Let's say you have a COLMAP database with exhaustive matching and you want to edit the match based on a criteria, you can use this script. 
Just head to Python Script and run
'python database_edit_match.py -h'
