# Use openjdk:21-jdk-slim as base image
FROM openjdk:21-jdk-slim

# Set working directory
WORKDIR /opt/minecraft

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install tools
RUN apt-get update && apt-get install -y wget curl unzip && rm -rf /var/lib/apt/lists/*

# Create minecraft user and set permissions
RUN useradd -m -s /bin/bash minecraft && chown minecraft:minecraft /opt/minecraft

# Switch to minecraft user
USER minecraft

# Download Minecraft server JAR
RUN wget -O server.jar https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar

# Create startup script
RUN echo '#!/bin/bash' > start.sh && \
    echo 'echo "eula=true" > eula.txt' >> start.sh && \
    echo 'java -Xms1G -Xmx2G -jar server.jar nogui' >> start.sh && \
    chmod +x start.sh

# Expose the minecraft server port
EXPOSE 25565

CMD ["./start.sh"]