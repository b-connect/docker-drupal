FROM centos:latest
MAINTAINER Erik Seifert <erik.seifert@b-connect.de>

# - Install basic packages needed by supervisord
# - Install inotify, needed to automate daemon restarts after config file changes
# - Install supervisord (via python's easy_install - as it has the newest 3.x version)

#Install tools
RUN yum install -y yum-utils python-setuptools inotify-tools unzip sendmail tar mysql sudo wget telnet rsync git

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

RUN yum install -y nginx

#Install nginx, php70w-fpm and php extensions
RUN yum install -y php70w-fpm php70w-common memcached
RUN yum install -y php70w-pecl-apc php70w-cli php70w-pear php70w-pdo php70w-mysql php70w-pecl-memcache php70w-pecl-memcached php70w-gd php70w-mbstring php70w-mcrypt php70w-xml php70w-adodb php70w-imap php70w-intl php70w-soap
RUN yum install -y php70w-mysqli php70w-zip php70w-iconv php70w-curl php70w-simplexml php70w-dom php70w-bcmath php70w-opcache php70w-pecl-redis

#Clean up yum repos to save spaces
RUN yum update -y && yum clean all

#Install supervisor
RUN easy_install supervisor
#Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Update nginx user group and name
RUN groupmod --gid 80 --new-name www nginx && \
    usermod --uid 80 --home /data/www --gid 80 --login www --shell /bin/bash --comment www nginx && \
    rm -rf /etc/nginx/*.d /etc/nginx/*_params && \
    chown -R www:www /var/www
    #lib/nginx

#Add pre-configured files
ADD container-files /
RUN find /config |grep .sh |xargs chmod +x

VOLUME ["/data"]

EXPOSE 80 443

ENTRYPOINT ["/config/bootstrap.sh"]
