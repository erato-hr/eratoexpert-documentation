FROM ruby:2.5.1
MAINTAINER Adrian Perez <adrian@adrianperez.org>

RUN apt-get update && apt-get install -y nodejs \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

COPY . /usr/src/app

WORKDIR /usr/src/app

RUN bundle install

VOLUME /usr/src/app
EXPOSE 4567

CMD ["bundle", "exec", "middleman", "server", "--watcher-force-polling"]
