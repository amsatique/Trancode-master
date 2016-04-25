#!/bin/bash

#Clear
rm -rf /private/docker/complete/*
rm -rf /private/docker/incomplete/*
rm -rf /private/docker/progress/*

#Set var
DATE='/bin/date'
ramlimit=( 512m 1024m 2048m nolimit )
input=( big_buck_bunny_720p_10mb.mp4 big_buck_bunny_720p_50mb.mp4 )
input_format=$(echo $input | cut -d '.' -f2)
name=$(echo $input | cut -d '.' -f1)
extensions=( MP4 MOV AVI WMV MKV SWF ASF FLV VOB RM 3GP WEBM MPG DV M4A M4R MP3 WAV FLAC WMA AC3 AAC OGG RA )


#Loop for docker options
for l in "${ramlimit[@]}"
do
  #Loop for multiple input
  for n in "${input[@]}"
  do
    customer="$(echo ${n} | cut -d '_' -f5)-$ramlimit"

    #Loop for extensions
    for m in "${extensions[@]}"
      do
        echo "Test for ${m}"
        cp /private/docker/${n} /private/docker/incomplete/
        BEFORE=$($DATE +'%s')
        if [ $l != "nolimit" ]
          sudo docker run -it --rm -e INPUT=${n} -m ${l} -e CUSTOMER=${customer} -e EXTENSION=${m} -v /private/docker:/data transcode
        else
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
done
exit
