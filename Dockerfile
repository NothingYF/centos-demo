# Version 1.0.1

FROM nothingdocker/centos-systemd

# Base Development Library
RUN yum install -y gcc gcc-c++ bzip2 bzip2-devel bzip2-libs python-devel.x86_64 make cmake clang pcre-devel openssl openssl-devel;

# Mongodb
ENV MONGODB_VER 3.6
RUN echo -e "\n\
[mongodb-org-3.6]\n\
name=MongoDB Repository\n\
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.6/x86_64/\n\
gpgcheck=1\n\
enabled=1\n\
gpgkey=https://www.mongodb.org/static/pgp/server-3.6.asc\n\
" >> /etc/yum.repos.d/mongodb-org-3.6.repo \
	&& yum install -y mongodb-org \
	&& yum clean all \
	&& systemctl enable mongod.service
RUN mkdir -p /var/lib/mongo \
	&& mkdir -p /var/log/mongod \
	&& chown -R mongod:mongod /var/lib/mongo \
	&& chown -R mongod:mongod /var/log/mongodb
VOLUME /var/lib/mongo /var/log/mongodb
COPY mongod.conf /etc/mongod.conf

# Redis
RUN yum install -y redis \
	&& yum clean all \
	&& systemctl enable redis.service

# Rabbit MQ 
ENV RMQ_VER 3.6.9
COPY ./rabbitmq.config /etc/rabbitmq/rabbitmq.config
RUN wget https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_9/rabbitmq-server-3.6.9-1.el7.noarch.rpm;\
	rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc;\
	yum -y install rabbitmq-server-3.6.9-1.el7.noarch.rpm;\
	yum clean all;\
	rm -f rabbitmq-server-3.6.9-1.el7.noarch.rpm;\
	systemctl enable rabbitmq-server;\
	rabbitmq-plugins enable rabbitmq_management;

# Nginx
RUN mkdir /tmp/nginx;cd /tmp/nginx;\
	git clone https://github.com/arut/nginx-rtmp-module.git;\
	wget http://nginx.org/download/nginx-1.13.9.tar.gz;\
	tar -zxf nginx-1.13.9.tar.gz;\
	cd nginx-1.13.9;\
	./configure --prefix=/usr/local/nginx --sbin-path=/usr/sbin/nginx --pid-path=/run/nginx.pid --conf-path=/etc/nginx/nginx.conf --add-module=../nginx-rtmp-module  --with-http_ssl_module;\
	make && make install;\
	rm -rf /tmp/nginx;\

COPY nginx.service /usr/lib/systemd/system/nginx.service
COPY nginx.conf /etc/nginx/nginx.conf
RUN systemctl enable nginx

# Nodejs
ENV NODE_VER v8.10.0
RUN cd /usr/local;\ 
	wget https://nodejs.org/dist/$NODE_VER/node-$NODE_VER-linux-x64.tar.xz;\
	tar xJf node-$NODE_VER-linux-x64.tar.xz;\
	rm -f node.tar.xz;\
	mv node-$NODE_VER-linux-x64 node;\
	ln -s /usr/local/node/bin/node /usr/local/bin/node;\
	ln -s /usr/local/node/bin/npm /usr/local/bin/npm
RUN echo "PATH=/usr/local/node/bin:$PATH" >> /etc/bashrc; \
	echo "export PATH" >> /etc/bashrc;
RUN echo "alias cnpm=\"npm --registry=https://registry.npm.taobao.org \
	--cache=$HOME/.npm/.cache/cnpm \
	--disturl=https://npm.taobao.org/dist \
	--userconfig=$HOME/.cnpmrc\"" >> /etc/bashrc;
RUN mkdir ~/.npm-global;\
	echo "prefix=~/.npm-global" >> ~/.npmrc;\
	echo "export LANG=en_GB.utf8" >> /etc/bashrc;\
	echo "export TERM=linux" >> /etc/bashrc;\
	echo "export PATH=~/.npm-global/bin:$PATH" >> /etc/bashrc;\
	echo "export NODE_PATH=~/.npm-global/lib/node_modules" >> /etc/bashrc;
RUN npm -g config set user root;npm config set cache=~/.npm-global; npm install -g node-gyp;npm install -g v8-profiler;
#RUN echo "registry = http://npm.scsv.online" >> ~/.npmrc

RUN yum install -y etcd;yum clean all;systemctl enable etcd;
RUN yum install -y golang;yum install -y git;yum clean all;
#WORKDIR /root

#RUN yum install -y sudo;yum clean all;
#RUN useradd --create-home --no-log-init --shell /bin/bash dev
#RUN echo 'dev:dev000#' | chpasswd
#USER dev
#WORKDIR /home/dev
RUN mkdir -p /data/src
VOLUME /data/src
WORKDIR /data/src

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/init"]
