FROM ruby:2.5.1
MAINTAINER Adrian Perez <adrian@adrianperez.org>

RUN apt-get update && apt-get install -y nodejs nginx supervisor \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

COPY . /usr/src/app
WORKDIR /usr/src/app

RUN chmod 777 /usr/src/app/run.sh

RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /usr/src/app/nginx.conf /etc/nginx/sites-enabled/eratoexpert.conf

RUN bundle install

VOLUME /usr/src/app
EXPOSE 4567

CMD ["/usr/src/app/run.sh"]
