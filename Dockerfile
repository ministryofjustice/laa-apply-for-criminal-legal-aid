FROM ruby:3.4.8-alpine3.23 AS base
LABEL maintainer="LAA Crime Apply Team"

RUN apk add --no-cache \
  postgresql17-dev tzdata gcompat nodejs build-base yaml-dev git && \
  apk add --update clamav-clamdscan && \
  apk del clamav-daemon freshclam && \
  rm -rf /var/cache/apk/*

FROM base AS dependencies

WORKDIR /usr/src/app

COPY .ruby-version Gemfile* package.json yarn.lock .yarnrc.yml ./

RUN bundle config set frozen 'true' && \
  bundle config set without 'test development' && \
  bundle install --jobs 5 --retry 3 && \
  apk del build-base yaml-dev

# Install npm temporarily only to set up corepack, then remove it
# Also remove npm's system-level node_modules to eliminate vulnerabilities  
RUN apk add --no-cache --virtual .npm-deps npm && \
  npm install -g corepack && \
  apk del .npm-deps && \
  rm -rf /usr/lib/node_modules && \
  corepack prepare yarn@4.11.0 --activate && \
  yarn install --immutable

COPY . .
RUN rails assets:precompile --trace

FROM base

RUN mkdir -p /usr/src/app && \
  mkdir -p /usr/src/app/log && \
  mkdir -p /usr/src/app/tmp && \
  mkdir -p /usr/src/app/tmp/pids

ENV APPUID=1000
RUN addgroup -g $APPUID -S appgroup && \
  adduser -u $APPUID -S appuser -G appgroup

WORKDIR /usr/src/app

COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/
COPY --from=dependencies /usr/src/app/public ./public
COPY . .

RUN chown -R appuser:appgroup log tmp

ENV RDS_COMBINED_CA_BUNDLE /usr/src/app/config/global-bundle.pem
ADD https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem $RDS_COMBINED_CA_BUNDLE
RUN chmod +r $RDS_COMBINED_CA_BUNDLE

ARG APP_BUILD_DATE
ENV APP_BUILD_DATE=${APP_BUILD_DATE}

ARG APP_BUILD_TAG
ENV APP_BUILD_TAG=${APP_BUILD_TAG}

ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT=${APP_GIT_COMMIT}

USER $APPUID

ENV PORT=3000
EXPOSE $PORT
ENTRYPOINT ["./run.sh"]
