FROM hyperknot/baseimage16:1.0.2

MAINTAINER friends@niiknow.org

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 \
    TERM=xterm container=docker DEBIAN_FRONTEND=noninteractive 

RUN \
  cd /tmp \

# add our user and group first to make sure their IDs get assigned consistently
  && groupadd -r redis && useradd -r -g redis redis \

# update
  && apt-get update && apt-get upgrade -y --no-install-recommends --no-install-suggests \
  && apt-get install -y --no-install-recommends --no-install-suggests nano redis-server \
  && update-rc.d -f redis-server disable \

  && echo "\n\n* soft nofile 200000\n* hard nofile 200000\n" >> /etc/security/limits.conf \

  && sed -i -e 's:^save:# save:g' \
      -e 's:^bind:# bind:g' \
      -e 's:^logfile:# logfile:' \
      -e 's:daemonize yes:daemonize no:' \
      -e 's:# maxmemory \(.*\)$:maxmemory 1gb:' \
      -e 's:# maxmemory-policy \(.*\)$:maxmemory-policy allkeys-lru:' \
      /etc/redis/redis.conf \

  && mkdir -p /var/lib/redis && mkdir -p /var/log/redis && mkdir -p /etc/service/redis \
  && echo "#!/bin/sh" > /etc/service/redis/run \
  && echo "set -e" >> /etc/service/redis/run \
  && echo "exec /sbin/setuser redis /usr/bin/redis-server /etc/redis/redis.conf" >> /etc/service/redis/run \
  && chmod +x /etc/service/redis/run \

  && apt-get autoremove -y gcc make libc6-dev && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && echo "\nvm.overcommit_memory = 1\nnet.core.somaxconn = 65535\nkernel/mm/transparent_hugepage/enabled = never\kernel/mm/transparent_hugepage/defrag = never\n" >> /etc/sysctl.conf \

  && echo "/sbin/shutdown -h 5 'System will reboot in 5 minutes'" > /etc/cron.monthly/reboot-me \
  && chmod +x /etc/cron.monthly/reboot-me

EXPOSE 6379
