FROM ubuntu

# !!! Database and tables must be created before running this image !!!

# creating orchestra user
RUN useradd -ms /bin/bash orchestra

WORKDIR /home/orchestra/

# copying and unpacking archive
ADD orchestra-linux64-install-6.1.RC.tar.gz ./tmp
RUN chown -Rf orchestra:orchestra ./tmp
USER orchestra
RUN mv ./tmp/orchestra-linux64-install-6.1.RC ./tmp/app

WORKDIR /home/orchestra/tmp/app/

# emptying install file
RUN echo '' > ./install.properties

# filling install file
RUN echo 'install.directory=/home/orchestra/app' >> ./install.properties
RUN echo 'instance.name=orchestra' >> ./install.properties
RUN echo 'starting.user=orchestra' >> ./install.properties
RUN echo 'default.language=fr' >> ./install.properties
RUN echo 'DATABASE=postgres' >> ./install.properties
RUN echo 'db.host=database' >> ./install.properties
RUN echo 'db.port=5432' >> ./install.properties
RUN echo 'db.instance=nqidb' >> ./install.properties
RUN echo 'db.user=postgres' >> ./install.properties
RUN echo 'db.password=postgres' >> ./install.properties
RUN echo 'disable.initdb=true' >> ./install.properties
RUN echo 'cpms.hostname=127.0.0.1' >> ./install.properties
RUN echo 'cpms.http.port=8080' >> ./install.properties
RUN echo 'smtp.host=#' >> ./install.properties
RUN echo 'smtp.port=25' >> ./install.properties

WORKDIR /home/orchestra/tmp/app

# installing app
RUN ./install.sh

WORKDIR /home/orchestra/

# removing temp files
RUN rm -Rf ./tmp

# TODO add the license

WORKDIR /home/orchestra/app/orchestra/bin

EXPOSE 8080

# starting orchestra
CMD ./nqi-service run
