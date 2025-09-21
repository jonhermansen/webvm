FROM alpine:20250108
RUN apk add --no-cache bash
ENTRYPOINT ["bash"]

