FROM alpine:latest


# Install OpenSSH and OpenRC
RUN apk update
RUN apk add --no-cache openssh openrc bash
RUN apk add --no-cache tmux screen

# Generate SSH host keys
RUN ssh-keygen -A

# Optional: Add a user and set up authorized_keys for key-based authentication
RUN adduser -D myuser
RUN mkdir -p /home/myuser/.ssh
RUN chown myuser:myuser /home/myuser/.ssh
RUN chmod 700 /home/myuser/.ssh

COPY authorized_keys /home/myuser/.ssh/authorized_keys
RUN chown myuser:myuser /home/myuser/.ssh/authorized_keys
RUN chmod 600 /home/myuser/.ssh/authorized_keys

COPY shadow /etc/shadow
# Expose SSH port
EXPOSE 22
RUN cat /home/myuser/.ssh/authorized_keys
COPY sshd_config /etc/ssh/sshd_config

# Start sshd in the foreground
CMD ["/usr/sbin/sshd", "-D"]
