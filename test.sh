#!/bin/bash

#Clear
rm -rf /private/docker/complete/*
rm -rf /private/docker/incomplete/*
rm -rf /private/docker/progress/*
rm -rf /private/docker/csv*

#Set var
DATE='/bin/date'
ramlimit=( nolimit ) #512m 1024m 2048m )
name=$(echo $input | cut -d '.' -f1)
extensions=( MP4 MOV AVI WMV MKV SWF ASF FLV VOB RM 3GP WEBM MPG MP3 WAV FLAC WMA AC3 AAC OGG RA )

echo "X" >> /private/docker/csv
#Shape table
for e in ${extensions[@]}
do
  echo $e >> /private/docker/csv
done
e=$(wc -l /private/docker/csv)
e=$(echo $e | cut -d ' ' -f1)


#Loop for multiple input
for r in "${ramlimit[@]}"
do
  for i in ${extensions[@]}
  do
    customer="$i-$(echo ${n} | cut -d '_' -f5 | cut -d '.' -f1)-$r"
    echo "RETURN" >> /private/docker/csv
    echo $i >> /private/docker/csv
    for j in ${extensions[@]}
    do
      if [ $i != $j ]
      then
        echo "Test for ${j}"
        cp /private/docker/big_buck_bunny_720p_10mb.${i} /private/docker/incomplete/
        BEFORE=$($DATE +'%s')
        if [ $r != "nolimit" ]
        then
          sudo docker run -it --rm -e INPUT=big_buck_bunny_720p_10mb.${i} -m ${r} -e CUSTOMER=${customer} -e EXTENSION=${j} -v /private/docker:/data amsatique/transcode-worker
        else
          sudo docker run -it --rm -e INPUT=big_buck_bunny_720p_10mb.${i} -e CUSTOMER=${customer} -e EXTENSION=${j} -v /private/docker:/data amsatique/transcode-worker
        fi
        AFTER=$($DATE +'%s')
        ELAPSED=$(($AFTER - $BEFORE))
        if [ $ELAPSED -lt 3 ]
        then
          rm /private/docker/complete/${customer}/big_buck_bunny_720p_10mb.${j}
          echo "Format ${i} to ${j} done ERROR" >> /private/docker/complete/$customer/timer
          echo "ERROR" >> /private/docker/csv
        else
          echo "Format ${i} to ${j} done into $ELAPSED seconds" >> /private/docker/complete/$customer/timer
          echo $ELAPSED >> /private/docker/csv
        fi
      else
        echo "NONE" >> /private/docker/csv
      fi
    done
  done
done
sed -e '0,/"RETURN,"/ s/"RETURN,"//' /private/docker/csv && awk -v RS="" '{gsub (/\n/,",")}1' /private/docker/csv > /private/docker/csv2 && awk -v RS="" '{gsub ("RETURN,",/\n/)}1' /private/docker/csv2 > /private/docker/csv3
exit
