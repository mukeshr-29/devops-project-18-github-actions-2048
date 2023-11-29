FROM node:16
WORKDIR /app/public
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm" , "start"]