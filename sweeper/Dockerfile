FROM ruby:3.0-alpine

WORKDIR /usr/src/app

RUN apk update && apk add ca-certificates build-base

COPY Gemfile ./
COPY Gemfile.lock ./

RUN bundle install --jobs 3 --retry 3

COPY ./ ./

CMD ["bundle", "exec", "ruby", "sweep.rb"]
