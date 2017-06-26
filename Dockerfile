FROM redis:3.2.9-alpine

MAINTAINER friends@niiknow.org

RUN \
  && sed -i 's/^\(maxmemory-policy .*\)$/# \1\\nmaxmemory-policy allkeys-lru/' /usr/local/etc/redis/redis.conf \
  && sed -i 's/^\(maxmemory .*\)$/# \1\\nmaxmemory 3gb/' /usr/local/etc/redis/redis.conf \
  && echo "/sbin/shutdown -h 5 'System will reboot in 5 minutes'" > /etc/cron.daily/reboot-me \
  && chmod +x /etc/cron.daily/reboot-me
