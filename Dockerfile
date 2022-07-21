FROM ruby:3.1.2-alpine
MAINTAINER LAA Crime Apply Team

RUN apk --no-cache add --virtual build-deps \
  build-base \
  postgresql-dev \
  git \
  bash \
  curl \
&& apk --no-cache add \
  postgresql-client \
  shared-mime-info \
  linux-headers \
  xz-libs \
  tzdata \
  yarn

# Alpine does not have a glibc, and this is needed for dart-sass
# Refer to: https://github.com/sgerrand/alpine-pkg-glibc
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk
RUN apk add glibc-2.34-r0.apk

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

# create some required directories
RUN mkdir -p /usr/src/app && \
    mkdir -p /usr/src/app/log && \
    mkdir -p /usr/src/app/tmp && \
    mkdir -p /usr/src/app/tmp/pids

WORKDIR /usr/src/app

COPY Gemfile* .ruby-version ./

RUN gem install bundler && \
    bundle config set frozen 'true' && \
    bundle config without test:development && \
    bundle install --jobs 2 --retry 3

COPY . .

RUN yarn install --pure-lockfile
RUN RAILS_ENV=production ENV_NAME= rails assets:precompile --trace

# tidy up installation
RUN apk del build-deps && rm -rf /tmp/*

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup log tmp db

# Download RDS certificates bundle -- needed for SSL verification
# We set the path to the bundle in the ENV, and use it in `/config/database.yml`
#
ENV RDS_COMBINED_CA_BUNDLE /usr/src/app/config/rds-combined-ca-bundle.pem
ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem $RDS_COMBINED_CA_BUNDLE
RUN chmod +r $RDS_COMBINED_CA_BUNDLE

ARG APP_BUILD_DATE
ENV APP_BUILD_DATE ${APP_BUILD_DATE}

ARG APP_BUILD_TAG
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}

ENV APPUID 1000
USER $APPUID

ENV PORT 3000
EXPOSE $PORT

ENTRYPOINT ["./run.sh"]
