FROM ubuntu:latest

# リポジトリを日本のミラーに変更
RUN sed -i".bak" -e 's/\/\/us.archive.ubuntu.com/\/\/ftp.jaist.ac.jp/g' /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y curl unzip \
        iputils-ping net-tools x11-apps \
        openjdk-11-jdk \
        libeclipse-e4-ui-swt-gtk-java \
        language-pack-ja-base language-pack-ja
RUN apt-get install -y fonts-ipafont
ENV DISPLAY host.docker.internal:0.0
ENV LANG=ja_JP.UTF-8

# eclipseのダウンロード
ENV ECLIPSE_VERSION 2021-06
WORKDIR /tmp
RUN curl -O https://ftp.yz.yamagata-u.ac.jp/pub/eclipse/technology/epp/downloads/release/${ECLIPSE_VERSION}/R/eclipse-java-${ECLIPSE_VERSION}-R-linux-gtk-x86_64.tar.gz && \
    tar -zxvf eclipse-java-*-R-linux-gtk-x86_64.tar.gz && \
    rm eclipse-java-*-R-linux-gtk-x86_64.tar.gz && \
    mv eclipse /eclipse

# eclipseの日本語化
RUN curl -O https://ftp.jaist.ac.jp/pub/mergedoc/pleiades/build/stable/pleiades.zip && \
    unzip pleiades.zip -d pleiades && \
    cp -r pleiades/* /eclipse/

# ermasterの適用
RUN /eclipse/eclipse -application org.eclipse.equinox.p2.director -nosplash -repository https://download.eclipse.org/eclipse/updates/4.20 -installIU org.eclipse.equinox.p2.ui/2.7.100.v20210426-1115 && \
    /eclipse/eclipse -application org.eclipse.equinox.p2.director -nosplash -repository https://download.eclipse.org/releases/2021-06 -installIU org.eclipse.gef/3.11.0.201606061308 && \
    /eclipse/eclipse -application org.eclipse.equinox.p2.director -nosplash -repository http://ermaster.sourceforge.net/update-site/ -installIU org.insightech.er.feature.feature.group/1.0.0.v20150619-0219

WORKDIR /eclipse

# eclipseのバージョンに依存しているかも。。。
ENTRYPOINT [ "java", "-jar", "/eclipse/plugins/org.eclipse.equinox.launcher_1.6.200.v20210416-2027.jar", "-application", "org.eclipse.ant.core.antRunner" ]
