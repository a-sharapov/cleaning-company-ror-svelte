FROM ruby:3.1.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN mkdir -p /usr/src/backend
WORKDIR /usr/src/backend
COPY Gemfile* /usr/src/backend/
RUN ls -l
RUN bundle install
COPY . /usr/src/backend
CMD ["bundle", "exec", "rails", "s", "-p 5000", "-b '0.0.0.0'"]