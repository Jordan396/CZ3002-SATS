# SATS server

```
docker build -t jordan396/faceapp-web .
docker push jordan396/faceapp-web
```

```
docker run \
-v "$(pwd)"/config:/usr/src/app/config \
-p 5000:5000 \
-d \
jordan396/faceapp-web 
```