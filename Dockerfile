FROM ruby:3.4.2-alpine3.21 AS base
LABEL maintainer="LAA Crime Apply Team"

# dependencies required both at runtime and build time
# ClamAV binaries required to access separate ClamAV service over TCP
RUN apk add --update \
  postgresql15-dev \
  tzdata \
  gcompat \
  nodejs \
  npm \
  clamav-clamdscan && \
  apk del clamav-daemon freshclam

RUN npm install -g corepack && \
  corepack enable && corepack prepare yarn@4.7.0 --activate

FROM base AS dependencies

# system dependencies required to build some gems and node_modules
RUN apk add --update \
  build-base \
  yaml-dev \
  git

WORKDIR /usr/src/app

COPY Gemfile* .ruby-version package.json yarn.lock .yarnrc.yml ./

RUN gem install bundler && \
  bundle config set frozen 'true' && \
  bundle config set without test:development && \
  bundle install --jobs 5 --retry 3

RUN yarn install --immutable

FROM base

# add non-root user and group with alpine first available uid, 1000
ENV APPUID=1000
RUN addgroup -g $APPUID -S appgroup && \
  adduser -u $APPUID -S appuser -G appgroup

# create some required directories
RUN mkdir -p /usr/src/app && \
  mkdir -p /usr/src/app/log && \
  mkdir -p /usr/src/app/tmp && \
  mkdir -p /usr/src/app/tmp/pids

WORKDIR /usr/src/app

# copy over gems from the dependencies stage
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/

# copy over npm packages from the dependencies stage
COPY --from=dependencies /usr/src/app/node_modules/ node_modules/

# copy over the remaning files and code
COPY . .

RUN rails assets:precompile --trace

# non-root user should own these directories
RUN chown -R appuser:appgroup log tmp

# Download RDS certificates bundle -- needed for SSL verification
# We set the path to the bundle in the ENV, and use it in `/config/database.yml`
#
ENV RDS_COMBINED_CA_BUNDLE=/usr/src/app/config/global-bundle.pem
ADD https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem $RDS_COMBINED_CA_BUNDLE
RUN chmod +r $RDS_COMBINED_CA_BUNDLE

ARG APP_BUILD_DATE
ENV APP_BUILD_DATE=${APP_BUILD_DATE}

ARG APP_BUILD_TAG
ENV APP_BUILD_TAG=${APP_BUILD_TAG}

ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT=${APP_GIT_COMMIT}

# switch to non-root user
USER $APPUID

ENV PORT=3000
EXPOSE $PORT

ENTRYPOINT ["./run.sh"]
