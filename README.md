Dense Structure-from-Motion with Keypoint Relocalization

Dense feature extraction is done using CNN. It's dense but the drawback is that the feature point locations are located in grid patter. It means that the accuracy of keypoints are not in ideal position. To improve the keypoints accuracy, we implement keypoint relocalization based on coarse to fine method.

Requirement:
1. Please download this network for this code: https://www.di.ens.fr/willow/research/netvlad/data/models/vd16_pitts30k_conv5_3_vlad_preL2_intra_white.mat
Place it in the same directory as main.m
You can change the network with minor modification of the script.

2. You need colmap on your machine. Read about it here https://colmap.github.io/

3. You can download a test dataset here https://www.dropbox.com/sh/0tgz6j374rnvmul/AABv5lfQJfN_qKUMhL2FKR6Ga?dl=0

How to use:
0. Precaution: The features extracted by CNN are saved in the drive and they are big (sometimes huge) in total. Make sure you have enough space in your drive.
In this code, GPU plays important role. We use 1600x1200 image resolution for CNN feature extraction. If your GPU can't handle that resolution, change it in at_serialAllFeats_convfeat_sfm.m line 72

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

3. Set the 'pth' and 'image_format' variable in main.m
The image_format is case sensitive. Please make sure wether, for example, you have .JPG or .jpg format.

4. Run the script

5. You can visualize the inlier matches after everything has finished by changing the visualizeonly variable in main.m to true
