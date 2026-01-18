# Original Source: https://github.com/CM2Walki/steamcmd/blob/master/bookworm/Dockerfile
# Thanks to CM2Walki
# Updating for stable (Currently Trixie) and customising

FROM debian:stable-slim

LABEL org.opencontainers.image.authors="teejo75"
LABEL org.opencontainers.image.source="https://github.com/teejo75/steamcmd-base"
LABEL org.opencontainers.image.description="Debian Stable SteamCMD base image"

ARG DEBIAN_FRONTEND=noninteractive
ENV PUID=1000
ENV GUID=1000
ENV USER=steam
ENV HOMEDIR="/home/${USER}"
ENV STEAMCMDDIR="${HOMEDIR}/steamcmd"

RUN set -x \
	# Install, update & upgrade packages
	&& apt-get update \
    && apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		lib32stdc++6 \
		lib32gcc-s1 \
		ca-certificates \
		curl \
		locales \
	    gosu \
	    tzdata \
	    procps \
	&& sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
	&& dpkg-reconfigure -f noninteractive locales \
	# Create group
	&& groupadd -g "${GUID}" "${USER}" \
	# Create unprivileged user
	&& useradd -u "${PUID}" -g "${GUID}" -m "${USER}" \
	# Download SteamCMD, execute as user
	&& su "${USER}" -c \
		"mkdir -p \"${STEAMCMDDIR}\" \
                && curl -fsSL 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar xvzf - -C \"${STEAMCMDDIR}\" \
                && \"./${STEAMCMDDIR}/steamcmd.sh\" +quit \
                && ln -s \"${STEAMCMDDIR}/linux32/steamclient.so\" \"${STEAMCMDDIR}/steamservice.so\" \
                && mkdir -p \"${HOMEDIR}/.steam/sdk32\" \
                && ln -s \"${STEAMCMDDIR}/linux32/steamclient.so\" \"${HOMEDIR}/.steam/sdk32/steamclient.so\" \
                && ln -s \"${STEAMCMDDIR}/linux32/steamcmd\" \"${STEAMCMDDIR}/linux32/steam\" \
                && mkdir -p \"${HOMEDIR}/.steam/sdk64\" \
                && ln -s \"${STEAMCMDDIR}/linux64/steamclient.so\" \"${HOMEDIR}/.steam/sdk64/steamclient.so\" \
                && ln -s \"${STEAMCMDDIR}/linux64/steamcmd\" \"${STEAMCMDDIR}/linux64/steam\" \
                && ln -s \"${STEAMCMDDIR}/steamcmd.sh\" \"${STEAMCMDDIR}/steam.sh\"" \
	# Symlink steamclient.so; So misconfigured dedicated servers can find it
	&& ln -s "${STEAMCMDDIR}/linux64/steamclient.so" "/usr/lib/x86_64-linux-gnu/steamclient.so" \
	&& apt-get clean -y && apt-get autopurge -y && rm -rf /var/lib/apt/lists/*

WORKDIR ${STEAMCMDDIR}

