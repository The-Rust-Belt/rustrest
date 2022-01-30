FROM rust:latest as builder

RUN apt-get update && apt-get install libpq-dev musl-tools -y \
    && rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/app
COPY . .

RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl

FROM alpine:latest

RUN apk add postgresql-dev \
    && addgroup -g 1000 app \
    && adduser -D -s /bin/sh -u 1000 -G app app

WORKDIR /home/app/bin/
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/rustrest .

RUN chown app:app rustrest

USER app

EXPOSE 9090

CMD ["./rustrest"]