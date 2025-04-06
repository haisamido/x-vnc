ARG REGISTRY_HOST=docker.io
ARG IMAGE_USERNAME=library
ARG IMAGE_NAME=ubuntu
ARG IMAGE_TAG=25.04
ARG IMAGE_URI=${REGISTRY_HOST}/${IMAGE_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}

ARG VNC_PASSWORD=0123456789

################################################################################
FROM ${IMAGE_URI}
################################################################################

ARG VNC_PASSWORD
ENV VNC_PASSWORD=${VNC_PASSWORD}

RUN apt-get update && \
    apt-get install -y \
      gnupg \
      wget \
      apt-transport-https \
      software-properties-common \
      novnc \
      websockify \
      libxv1 \
      libglu1-mesa \
      xauth \
      x11-utils \
      xorg \
      tightvncserver && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# turbovnc: https://turbovnc.org/
RUN wget -q -O- https://packagecloud.io/dcommander/turbovnc/gpgkey |  gpg --dearmor >/etc/apt/trusted.gpg.d/TurboVNC.gpg
RUN wget -P /etc/apt/sources.list.d/ https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list

# virtualgl: https://virtualgl.org/
RUN wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey | gpg --dearmor >/etc/apt/trusted.gpg.d/VirtualGL.gpg
RUN wget -P /etc/apt/sources.list.d/ https://raw.githubusercontent.com/VirtualGL/repo/main/VirtualGL.list

# Install virtualgl and turbovnc
RUN apt-get update && \
    apt-get install -y \
      virtualgl \
      turbovnc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# VNC Config
RUN mkdir -p ~/.vnc/
RUN echo ${VNC_PASSWORD} | vncpasswd -f > ~/.vnc/passwd
RUN chmod 0600 ~/.vnc/passwd
RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout ~/novnc.pem -out ~/novnc.pem -days 3650 -subj "/C=US/ST=NY/L=NY/O=NY/OU=NY/CN=NY emailAddress=email@example.com"

# Install and configure Display Manager(s) - https://fluxbox.org/
RUN apt-get update && \
    apt-get install -y \
      fluxbox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# TODO: need to figure out why this is needed
RUN ln -sf /usr/share/xsessions/fluxbox.desktop /usr/share/xsessions/gnome.desktop

# Install tools for git cloning and development, etc.
RUN apt-get update && \
    apt install -y curl git build-essential vim jq xq tree tmux htop && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install https://taskfile.dev/ (Taskfile.yaml)
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d v3.36.0

COPY entrypoint.sh /entrypoint.sh

COPY startapp.sh /startapp.sh

CMD ["/entrypoint.sh"]
