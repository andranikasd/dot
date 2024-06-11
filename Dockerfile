FROM ubuntu:20.04

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    gnupg \
    lsb-release \
    software-properties-common

# Copy the setup script
COPY setup.sh /setup.sh

# Make the setup script executable
RUN chmod +x /setup.sh

# Run the setup script
RUN /setup.sh

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]
