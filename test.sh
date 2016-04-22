#!/bin/bash
DATE='/bin/date'
customer=10mb-nooptions
input=big_buck_bunny_720p_10mb.mp4
name=$(echo $input | cut -d '.' -f1)
extensions=( mov mp4 mpeg4 avi yuv	m4v	rmvb 3gp2	mp3	rv wav EVRC	QCELP	wma flv	ra wmv iv4 ram m4a	rm mkv asf swf 3gpp 3gp 3g2 divx f4v m2ts  mpg mts ogv ts aac dtb dv h264 h265 mpeg-1 mpeg-2 ogg )
for m in "${extensions[@]}"
do
  echo "Test for ${m}"
  BEFORE=$($DATE +'%s')
  cp /private/docker/big_buck_bunny_720p_10mb.mp4 /private/docker/incomplete/
  sudo docker run -it --rm -e INPUT=${input} -e CUSTOMER=${customer} -e EXTENSION=${m} -v /private/docker:/data transcode
  AFTER=$($DATE +'%s')
  ELAPSED=$(($AFTER - $BEFORE))
  if [ $ELAPSED -lt 2 ]
  then
    rm /private/docker/complete/${customer}/$name.${m}
  else
    echo "For ${customer}, format ${m} done into $ELAPSED seconds" >> /private/docker/complete/10mb-nooptions-timer
  fi
done
exit
