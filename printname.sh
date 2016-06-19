Folder_A="/home/seedclass/superpiggy/Images"

for file_a in ${Folder_A}/*; do  
    temp_file="/home/seedclass/superpiggy/Image/"`basename $file_a`  
    echo $temp_file >> path.txt; 
#find . -name "*.JPEG" | xargs -I {} convert {} -resize "256^>" {}  
 # th load-images.lua -d $temp_file
done 
