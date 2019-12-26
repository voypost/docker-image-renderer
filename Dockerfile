FROM node:12-alpine

# can be deleted, `timezone` lib should contain it, to test
RUN apk add --no-cache tzdata
# for installing packages from git repos
RUN apk add --update make git
# for image generation
RUN apk add --no-cache \
    build-base \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    giflib-dev

ONBUILD ARG NODE_ENV=development

ONBUILD ARG RUN_ESLINT=false
ONBUILD ARG RUN_JEST=false

RUN mkdir -p /usr/app
WORKDIR /usr/app

ONBUILD COPY --from=installer /usr/app/node_modules ./node_modules
ONBUILD COPY --from=installer /usr/app/package.json ./
ONBUILD COPY --from=installer /usr/app/yarn.lock ./
ONBUILD COPY --from=installer /usr/app/.npmrc ./
ONBUILD COPY --from=installer /usr/app/.yarnrc ./
ONBUILD RUN NODE_ENV=development yarn install

ONBUILD COPY .babelrc ./
ONBUILD COPY jest.config.js ./
ONBUILD COPY .env.test ./
ONBUILD COPY data ./data
ONBUILD COPY src ./src
ONBUILD COPY tests ./tests

# Run ESLint
ONBUILD RUN sh -c "if [ $RUN_ESLINT == true ]; then yarn lint; else true; fi"

# Run Jest
ONBUILD RUN sh -c "if [ $RUN_JEST == true ]; then yarn test; else true; fi"

ONBUILD RUN NODE_ENV=$NODE_ENV yarn build
