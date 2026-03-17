# Build Stage
FROM tgdeploymentcr.azurecr.io/node:24-bullseye-slim AS build

RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    unixodbc \
    unixodbc-dev \
    curl \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list \
    > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build:prods && rm -rf /var/lib/apt/lists/*

COPY .env.local ./build
 
# Production Stage
FROM tgdeploymentcr.azurecr.io/node:24-bullseye-slim AS production

RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    unixodbc \
    unixodbc-dev \
    curl \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list \
    > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install system dependencies (libfontconfig, libxrender, FFmpeg)
RUN apt-get update && \
    apt-get install -y libfontconfig1 libxrender1 ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Install PM2 globally and create a non-root user
RUN npm install -g pm2 && \
    useradd -m nodeuser && \
    chown -R nodeuser:nodeuser /app

# Copy the application files from the build stage
COPY --from=build /app /app

# Expose the port your app will run on
EXPOSE 80

# Use exec form for CMD

CMD ["pm2", "start", "/app/build/src/server.js", "--no-daemon"]
