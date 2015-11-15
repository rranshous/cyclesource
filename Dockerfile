FROM ruby:2.2.0

RUN mkdir /data

ADD . /app
WORKDIR /app
RUN bundle install

VOLUME /var/run/docker.sock

EXPOSE 80
ENV DATA_DIR=/data
ENV PORT=80
ENTRYPOINT ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0"]
