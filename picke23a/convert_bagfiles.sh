#! /bin/sh

# This program assumes you have a directory named bagfiles containing all the bagfiles
# you intend to convert,
# a directory named experimentData to which converted data will be moved
# and a directory named data_recording_basics which has the cvImage files needed
# to convert bagfile data to image file (can be found on imero github)
# You will also need to download the pcl_ros libary to get access to 
# bag_to_pcd which is used to convert bagfile depth data to a pcl point 
#cloud


#Setup
home="$1"
bagFile="$2"
echo "Bagfile name:" "$bagFile"
echo "Path to bagfiles and experimentData home directory:" "$home"

# Set up directories
cd "$home"/experimentData
mkdir "$bagFile"
cd "$bagFile"
mkdir csvFiles
mkdir kinova_color_images
mkdir kinova_depth_images
mkdir kinova_pointClouds
mkdir external_color_images
mkdir external_depth_images

# Convert bagfile data to csv files
cd "$home"/bagfiles
for topic in `rostopic list -b "$bagFile".bag`
  do
    echo "Creating csv for" "$topic"
    rostopic echo -p -b "$bagFile".bag $topic > "$bagFile"-${topic//\//_}.csv
done

# Move csv files to the correct file
mv "$home"/bagfiles/"$bagFile"-*.csv "$home"/experimentData/"$bagFile"/csvFiles

# Convert color image data to images (robot camera and external)
cd "$home"/data_recording_basics
python bag_to_colorImages.py ""$home"/bagfiles/"$bagFile".bag" ""$home"/experimentData/"$bagFile"/kinova_color_images" "/cam_1/color/image_raw"
python bag_to_colorImages.py ""$home"/bagfiles/"$bagFile".bag" ""$home"/experimentData/"$bagFile"/external_color_images" "/cam_2/color/image_raw"

# Convert depth image data to images (robot camera and external)
python bag_to_images.py ""$home"/bagfiles/"$bagFile".bag" ""$home"/experimentData/"$bagFile"/kinova_depth_images" "/cam_1/depth/image_raw"
python bag_to_images.py ""$home"/bagfiles/"$bagFile".bag" ""$home"/experimentData/"$bagFile"/external_depth_images" "/cam_2/depth/image_rect_raw"

#Convert robot depth data to point clouds using pcl library
rosrun pcl_ros bag_to_pcd "$home"/bagfiles/"$bagFile".bag /camera/depth/points "$home"/experimentData/"$bagFile"/kinova_pointClouds
