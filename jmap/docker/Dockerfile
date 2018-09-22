FROM ubuntu

RUN apt-get update

RUN useradd -ms /bin/bash k2

WORKDIR /home/k2/

USER k2

VOLUME ["/jmap"]

CMD ["/jmap/bin/startjmapserver"]