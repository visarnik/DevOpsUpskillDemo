ARG ARCH=
ARG IMAGE_BASE=16-alpine

FROM ${ARCH}node:$IMAGE_BASE
LABEL Name="Node.js Demo App" Version=4.8.5
LABEL org.opencontainers.image.source = "https://github.com/benc-uk/nodejs-demoapp"
ENV NODE_ENV production
#ENV WEATHER_API_KEY=88e9b797e2a09f1d3036fde3a2b89f5f
#ENV TODO_MONGO_CONNSTR=mongodb://localhost:27017
#ENV TODO_MONGO_DB=todoDb
WORKDIR /app 

# For Docker layer caching do this BEFORE copying in rest of app
COPY src/package*.json ./
RUN npm install --production --silent

# NPM is done, now copy in the rest of the project to the workdir
COPY src/* /app/
COPY manifests/* /test/
COPY src/* /test1/

# Port 3000 for our Express server 
EXPOSE 3000
ENTRYPOINT ["npm", "start"]