
for((;;)); do \
    ./ffmpeg/bin/ffmpeg -re -i
/home/xienan/srs.oschina/trunk/objs/nginx/html/video/ori/ironman.mkv \
    -ar 22050 -strict -2  -c:v libx264 -c:a aac -f flv -y
rtmp://114.55.52.254/live/livestream; \
    sleep 1; \
done

