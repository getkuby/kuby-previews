FROM ruby:3.0

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y ca-certificates

COPY Gemfile ./
COPY Gemfile.lock ./

RUN bundle install --jobs 3 --retry 3

COPY ./ ./

CMD ["bundle", "exec", "ruby", "sweep.rb"]
