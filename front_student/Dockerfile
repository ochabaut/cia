FROM mhart/alpine-node:11
WORKDIR /front_student

# COPY the package.json file, update any deps and install them
COPY package.json .
RUN npm install

# copy the whole source folder(the dir is relative to the Dockerfile
COPY . .

EXPOSE 3000
CMD [ "npm", "run", "start" ]