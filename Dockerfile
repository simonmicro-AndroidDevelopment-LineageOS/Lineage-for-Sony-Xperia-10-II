FROM ubuntu:20.04

WORKDIR /root

# Personal
RUN apt-get update
RUN apt-get install -y default-jdk python

# Android
RUN apt-get install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
RUN apt-get install -y git gcc curl make libxml2-utils flex m4
RUN apt-get install -y openjdk-8-jdk lib32stdc++6 libelf-dev
RUN apt-get install -y libssl-dev python-enum34 python-mako syslinux-utils
RUN apt-get install -y git-core gnupg flex bison build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig

# Repo
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo
RUN chmod a+rx /bin/repo
RUN git config --global color.ui true
RUN git config --global user.name "Your Name"
RUN git config --global user.email you@example.com

# Stuff for signing builds
RUN apt-get install -y xxd cgpt

# To show the output of the repo command...
ENV PYTHONUNBUFFERED 1

# Cleanup
RUN apt-get autoremove -y
RUN apt-get autoclean
RUN apt-get clean

CMD bash
