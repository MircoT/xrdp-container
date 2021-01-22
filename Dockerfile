FROM     ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y apt-utils

RUN apt-get install -y --no-install-recommends xrdp \
    xorgxrdp \
    lightdm \
    unity-greeter \
    xfce4 \
    xfce4-terminal \
    supervisor \
    dbus \
    dbus-x11 \
    fuse \
    whoopsie \
    language-pack-en-base \
    && apt-get autoremove -y \
    && apt-get clean -y

RUN service xrdp stop

# DBus
RUN dbus-uuidgen > /var/lib/dbus/machine-id \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && mkdir -p /var/run/dbus \
    && chown messagebus:messagebus /var/run/dbus

# Supervisord
COPY supervisord.conf /etc/supervisor/conf.d/

# User
RUN groupadd fuse \
    && useradd -m -d /home/resu resu \
    && echo 'resu:resu' | chpasswd \
    && chsh -s /usr/bin/bash resu \
    && adduser resu sudo \
    && adduser resu fuse

RUN rm /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf

COPY 50-xfce-greeter.conf /usr/share/lightdm/lightdm.conf.d/

# Expose RDP port
EXPOSE 3389

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]