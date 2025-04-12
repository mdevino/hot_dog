# using :slim for :1 currently has 4 high vulnerabilities
# Phase 1: download/cache dependencies
FROM rust:1 AS chef
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

# Phase 2: Load dependencies and pre-build
FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .

# Install `dx`
RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
RUN cargo binstall dioxus-cli --root /.cargo -y --force
ENV PATH="/.cargo/bin:$PATH"

# Create the final bundle folder. Bundle always executes in release mode with optimizations enabled
RUN dx bundle --platform web

# Phase 3: copy and build
FROM chef AS runtime
COPY --from=builder /app/target/dx/hot_dog/release/web/ /usr/local/app

ENV PORT=8080
ENV IP=0.0.0.0

EXPOSE 8080

WORKDIR /usr/local/app
ENTRYPOINT [ "/usr/local/app/server" ]