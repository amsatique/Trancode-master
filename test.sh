#!/bin/bash

#Clear
rm -rf /private/docker/complete/*
rm -rf /private/docker/incomplete/*
rm -rf /private/docker/progress/*

#Set var
DATE='/bin/date'
input=( big_buck_bunny_720p_10mb.mp4 big_buck_bunny_720p_50mb.mp4 )
input_format=$(echo $input | cut -d '.' -f2)
name=$(echo $input | cut -d '.' -f1)
extensions=( mov mp4 mpeg4 avi yuv	m4v	rmvb 3gp2	mp3	rv wav EVRC	QCELP	wma flv	ra wmv iv4 ram m4a	rm mkv asf swf 3gpp 3gp 3g2 divx f4v m2ts  mpg mts ogv ts aac dtb dv h264 h265 mpeg-1 mpeg-2 ogg )

#Loop for input
for n in "${input[@]}"
do
  customer=$(echo ${n} | cut -d '_' -f5)

  #Loop for extensions
  for m in "${extensions[@]}"
    do
      echo "Test for ${m}"
      cp /private/docker/${n} /private/docker/incomplete/
      BEFORE=$($DATE +'%s')
      sudo docker run -it --rm -e INPUT=${n} -e CUSTOMER=${customer} -e EXTENSION=${m} -v /private/docker:/data transcode
      AFTER=$($DATE +'%s')
      ELAPSED=$(($AFTER - $BEFORE))
      if [ $ELAPSED -lt 2 ]
      then
        rm /private/docker/complete/${customer}/$name.${m}
        echo "Format ${m} done ERROR" >> /private/docker/complete/$customer/timer
      else
        echo "Format ${m} done into $ELAPSED seconds" >> /private/docker/complete/$customer/timer
      fi
    done
done
exit
