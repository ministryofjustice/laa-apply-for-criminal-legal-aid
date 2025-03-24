FROM ruby:3.4.2-alpine3.21 AS base
LABEL maintainer="LAA Crime Apply Team"

RUN apk add --no-cache \
  postgresql15-dev tzdata gcompat nodejs npm build-base yaml-dev git && \
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

RUN npm install -g corepack && \
  corepack prepare yarn@4.7.0 --activate && \
  yarn install --immutable

COPY . .
RUN rails assets:precompile --trace

FROM base

ARG APPUID=1000
RUN addgroup -g $APPUID -S appgroup && \
  adduser -u $APPUID -S appuser -G appgroup

WORKDIR /usr/src/app

COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/
COPY --from=dependencies /usr/src/app/public ./public
COPY --from=dependencies /usr/src/app/tmp ./tmp 
COPY --from=dependencies /usr/src/app/log ./log
COPY . .

RUN chmod -R 777 log tmp && \
  chown -R appuser:appgroup log tmp

ENV RDS_COMBINED_CA_BUNDLE=/usr/src/app/config/global-bundle.pem
RUN wget -O $RDS_COMBINED_CA_BUNDLE https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem && \
  chmod +r $RDS_COMBINED_CA_BUNDLE

USER appuser

ENV PORT=3000
EXPOSE $PORT
ENTRYPOINT ["./run.sh"]
