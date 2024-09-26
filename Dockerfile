FROM ruby:3.3.5-alpine3.20 AS base
LABEL maintainer="LAA Crime Apply Team"

# dependencies required both at runtime and build time
# ClamAV binaries required to access separate ClamAV service over TCP
RUN apk add --update \
  postgresql15-dev \
  tzdata \
  yarn \
  gcompat \
  clamav-clamdscan && \
  apk del clamav-daemon freshclam

FROM base AS dependencies

# system dependencies required to build some gems
RUN apk add --update \
  build-base \
  git

COPY Gemfile* .ruby-version package.json yarn.lock ./

RUN bundle config set frozen 'true' && \
    bundle config set without test:development && \
    bundle install --jobs 5 --retry 3

RUN yarn install --frozen-lockfile --ignore-scripts


FROM base

# add non-root user and group with alpine first available uid, 1000
ENV APPUID 1000
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
COPY --from=dependencies /node_modules/ node_modules/

# copy over the remaning files and code
COPY . .

# Some ENV variables need to be present by the time
# the assets pipeline run, but doesn't matter their value.
RUN SECRET_KEY_BASE=needed_for_assets_precompile \
    RAILS_ENV=production \
    ENV_NAME=production \
    rails assets:precompile --trace

# non-root user should own these directories
RUN chown -R appuser:appgroup log tmp

# Download RDS certificates bundle -- needed for SSL verification
# We set the path to the bundle in the ENV, and use it in `/config/database.yml`
#
ENV RDS_COMBINED_CA_BUNDLE /usr/src/app/config/global-bundle.pem
ADD https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem $RDS_COMBINED_CA_BUNDLE
RUN chmod +r $RDS_COMBINED_CA_BUNDLE

ARG APP_BUILD_DATE
ENV APP_BUILD_DATE ${APP_BUILD_DATE}

ARG APP_BUILD_TAG
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}

# switch to non-root user
USER $APPUID

ENV PORT 3000
EXPOSE $PORT

ENTRYPOINT ["./run.sh"]
