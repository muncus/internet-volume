FROM alpine:latest

WORKDIR /root
EXPOSE 53 5300

RUN apk --update add ruby ruby-dev ruby-bundler ca-certificates build-base wget
RUN wget -q https://raw.githubusercontent.com/muncus/internet-volume/master/dns/volume.rb ;\
wget -q https://raw.githubusercontent.com/muncus/internet-volume/master/dns/Gemfile ; \
bundler install

ENTRYPOINT ["ruby", "/root/volume.rb"]
