FROM node:17.8.0-alpine3.14

LABEL version="1.0"
LABEL description="This is the base docker image for the react app."
LABEL maintainer = ["lucasbarbosagomes0@gmail.com"]

EXPOSE 3000

RUN mkdir -p /app/node_modules && chown -R node:node /app
WORKDIR /app

USER node
COPY package.json yarn.lock ./
COPY --chown=node:node . .
RUN yarn install --frozen-lockfile

CMD ["yarn", "start"]