# Use a specific Ubuntu base image
#FROM ubuntu:24.04
FROM python:3.9.21-slim-bookworm


# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SSH_PORT=888

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server sudo nano python3 python3-venv python3-pip libcurl4 libcurl4-openssl-dev && \
    apt-get install -y onedrive screen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir -p /var/run/sshd && \
    sed -i "s/#Port 22/Port ${SSH_PORT}/" /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Create a non-root user with sudo access
RUN id -u ubuntu || useradd -rm -d /home/ubuntu -s /bin/bash -u 1000 -G sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/ubuntu/.ssh && \
    chown -R ubuntu:ubuntu /home/ubuntu

# Set up SSH keys
COPY id_ed25519.pub /home/ubuntu/.ssh/authorized_keys
RUN chmod 600 /home/ubuntu/.ssh/authorized_keys && \
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# Set up Python dependencies
USER ubuntu
#COPY requirements.txt /tmp/requirements.txt
#RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Add a volume directory and set correct permissions
USER root
RUN mkdir -p /home/work && chown -R ubuntu:ubuntu /home/work


EXPOSE ${SSH_PORT}

# Start SSH
CMD ["/usr/sbin/sshd", "-D"]

# Start SSH, OneDrive sync, and Python script
#CMD ["/bin/bash", "-c", "/usr/sbin/sshd -D & \
#    onedrive --confdir='/home/ubuntu/work/onedrive_config' --syncdir='/home/ubuntu/work/Onedrive' --single-directory 'demodata' --synchronize && \
#    python3 /home/ubuntu/work/Onedrive/demodata/ols.py && \
#    onedrive --confdir='/home/ubuntu/work/onedrive_config' --syncdir='/home/ubuntu/work/Onedrive' --single-directory 'demodata' --synchronize"]