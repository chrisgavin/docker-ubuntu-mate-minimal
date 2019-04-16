FROM ubuntu:bionic as seeds
RUN apt-get update && \
	apt-get install -y bzr && \
	bzr branch lp:~ubuntu-mate-dev/ubuntu-seeds/ubuntu-mate.bionic

FROM ubuntu:bionic as final
COPY --from=seeds /ubuntu-mate.bionic/desktop.minimal-remove /tmp/
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-mate-desktop dbus && \
	apt-get remove -y blueman network-manager && \
	sed "/^#.*$/d" /tmp/desktop.minimal-remove | sed "/^$/d" | sort > /tmp/cleaned-minimal-remove.txt && \
	dpkg -l | tr -s " " | cut -d " " -f 2 | sort > /tmp/installed-packages.txt && \
	packages_to_remove="$(comm -12 /tmp/cleaned-minimal-remove.txt /tmp/installed-packages.txt)" && \
	echo "$packages_to_remove" | xargs apt-get remove -y && \
	apt-get autoremove -y && \
	rm -rf /tmp/* /var/lib/apt/lists/*
COPY ./root/final/ /
ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["mate-session"]
