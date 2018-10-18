FROM ruby:2.4

WORKDIR /opt/refresher

RUN apt-get update
RUN apt-get install libldap-2.4-2 libidn11-dev dnsutils -y
RUN gem install idn-ruby -v '0.1.0'

ADD app /opt/refresher

RUN \
    cd /opt/refresher ;\
    bundle install

CMD ["bundle", "exec", "foreman", "start"]