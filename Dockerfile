FROM ruby:latest

RUN apt-get update && apt-get install -y cmake sqlite3 git

ADD . /oss-dashboard/

WORKDIR /oss-dashboard/docker
RUN bundle install

WORKDIR /oss-dashboard
