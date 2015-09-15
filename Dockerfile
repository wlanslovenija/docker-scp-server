FROM wlanslovenija/runit

MAINTAINER Jernej Kos <jernej@kos.mx>

EXPOSE 28932/tcp

VOLUME /etc/ssh/keys
VOLUME /readonly/files

RUN apt-get -q -q update && \
 apt-get --no-install-recommends --yes --force-yes install openssh-server git ca-certificates build-essential && \
 cd /tmp && \
 git clone https://github.com/scponly/scponly.git && \
 cd scponly && \
 ./configure --prefix=/usr --enable-chrooted-binary --disable-wildcards --without-sftp-server --enable-scp-compat --disable-gftp-compat --disable-winscp-compat && \
 make && \
 make install && \
 mkdir -p /readonly/bin && \
 mkdir -p /readonly/lib/x86_64-linux-gnu && \
 mkdir -p /readonly/lib64 && \
 mkdir -p /readonly/usr/bin && \
 mkdir -p /readonly/dev && \
 mkdir -p /readonly/etc && \
 mknod /readonly/dev/null c 1 3 && \
 chmod 666 /readonly/dev/null && \
 cp /usr/bin/scponly /readonly/bin/scponly && \
 cp /lib/x86_64-linux-gnu/libc.so.6 /readonly/lib/x86_64-linux-gnu && \
 cp /lib/x86_64-linux-gnu/libnss_files.so.2 /readonly/lib/x86_64-linux-gnu && \
 cp /lib64/ld-linux-x86-64.so.2 /readonly/lib64/ld-linux-x86-64.so.2 && \
 cp /usr/bin/scp /readonly/usr/bin/scp && \
 echo "fileserver:x:1000:1000::/:/bin/scponly" > /readonly/etc/passwd && \
 chown -R root:root /readonly && \
 chmod 555 /readonly && \
 echo "/bin/scponly" >> /etc/shells && \
 useradd --home-dir / --shell /bin/scponly --no-create-home fileserver && \
 sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
 sed 's@session\s*optional\s*pam_motd.so@#@g' -i /etc/pam.d/sshd && \
 rm -rf /tmp/scponly && \
 rm /etc/ssh/ssh_host_* && \
 apt-get purge --yes --force-yes git ca-certificates build-essential && \
 apt-get autoremove --yes --force-yes

ADD ./etc /etc

