FROM ubuntu:18.04
#FROM rattydave/ubuntu-ssh:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

COPY sources.list /etc/apt/sources.list

RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -yqq apt-utils software-properties-common

RUN cd /root && \
    sed -i 's/^#\s*\(deb.*partner\)$/\1/g' /etc/apt/sources.list && \
    apt-get install -yqq locales  && \
    echo 'LANG="zh_CN.UTF-8"' > /etc/default/locale && \
    echo 'LANGUAGE="zh_CN:zh"' >> /etc/default/locale && \
    echo 'LC_ALL="zh_CN.UTF-8"' >> /etc/default/locale && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    apt-get install -yqq \
        mate-desktop-environment-core \
        mate-themes \
        mate-accessibility-profiles \
        mate-applet-appmenu \
        mate-applet-brisk-menu \
        mate-applets \
        mate-applets-common \
        mate-calc \
        mate-calc-common \
        mate-dock-applet \
        mate-hud \
        mate-indicator-applet \
        mate-indicator-applet-common \
        mate-menu \
        mate-notification-daemon \
        mate-notification-daemon-common \
        mate-utils \
        mate-utils-common \
        mate-window-applets-common \
        mate-window-buttons-applet \
        mate-window-menu-applet \
        mate-window-title-applet \
        ubuntu-mate-icon-themes \
        ubuntu-mate-themes \
        xrdp \
        xorgxrdp \
        tightvncserver && \
    apt-get install --no-install-recommends -yqq \
        supervisor \
        sudo \
        tzdata \
        vim \
        mc \
        ca-certificates \
        xterm \
        curl \
        wget \
        epiphany-browser && \
    ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime && dpkg-reconfigure -f noninteractive tzdata && \
    apt-get -y autoclean && apt-get -y autoremove && \
    apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
    rm -rf /var/lib/apt/lists/*  && \
    echo "mate-session" > /etc/skel/.xsession && \
    sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini  && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini  && \
    xrdp-keygen xrdp auto  && \
    mkdir -p /var/run/xrdp && \
    chmod 2775 /var/run/xrdp  && \
    mkdir -p /var/run/xrdp/sockdir && \
    chmod 3777 /var/run/xrdp/sockdir && \
    echo "[program:sshd]" >/etc/supervisor/conf.d/sshd.conf && \
    echo "command=/usr/sbin/sshd -D" >> /etc/supervisor/conf.d/sshd.conf && \
    echo "stdout_logfile=/var/log/supervisor/%(program_name)s.log" >> /etc/supervisor/conf.d/sshd.conf && \
    echo "stderr_logfile=/var/log/supervisor/%(program_name)s.log" >> /etc/supervisor/conf.d/sshd.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/sshd.conf && \
    echo "[program:xrdp-sesman]" > /etc/supervisor/conf.d/xrdp.conf && \
    echo "command=/usr/sbin/xrdp-sesman --nodaemon" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "process_name = xrdp-sesman" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "[program:xrdp]" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "command=/usr/sbin/xrdp -nodaemon" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "process_name = xrdp" >> /etc/supervisor/conf.d/xrdp.conf
    #echo "[Desktop Entry]" > /etc/xdg/autostart/setxkbmap.desktop && \
    #echo "Type=Application" >> /etc/xdg/autostart/setxkbmap.desktop && \
    #echo "Exec=setxkbmap gb" >> /etc/xdg/autostart/setxkbmap.desktop && \
    #echo "Hidden=false" >> /etc/xdg/autostart/setxkbmap.desktop && \
    #echo "X-MATE-Autostart-enabled=true" >> /etc/xdg/autostart/setxkbmap.desktop && \
    #echo "Name[C]=SetKeyBoard GB" >> /etc/xdg/autostart/setxkbmap.desktop && \
    #echo "Name=SetKeyBoard GB" >> /etc/xdg/autostart/setxkbmap.desktop && \
    #echo "Comment[C]=Sets the keyboard to GB" >> /etc/xdg/autostart/setxkbmap.desktop && \
    #echo "Comment=Sets the keyboard to GB" >> /etc/xdg/autostart/setxkbmap.desktop

ADD xrdp.ini /etc/xrdp/xrdp.ini

ADD startup.sh /root/startup.sh
CMD ["/bin/bash", "/root/startup.sh"]
                                    
EXPOSE 3389

RUN add-apt-repository ppa:qbittorrent-team/qbittorrent-stable && \
    apt-get update && apt-get upgrade -yqq && apt-get install -yqq qbittorrent \
    language-pack-zh-hans language-pack-zh-hans-base \
    xfonts-wqy fonts-wqy-zenhei fonts-wqy-microhei && \
    apt-get remove -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* /var/cache/* /root/sources/*
