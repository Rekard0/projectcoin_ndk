FROM debian:stretch@sha256:de3eac83cd481c04c5d6c7344cd7327625a1d8b2540e82a8231b5675cef0ae5f
COPY /stretch_deps.sh /
RUN /stretch_deps.sh
