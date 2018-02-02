FROM ruby:2.4

RUN gem i bundler --no-doc
RUN mkdir /app
COPY Gemfile Gemfile.lock /app/
WORKDIR /app
RUN bundle install
COPY . /app
