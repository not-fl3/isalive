CARGO_FLAGS += --release
# CARGO_FLAGS += --verbose

server: client
	cargo build $(CARGO_FLAGS)

run: client
	RUST_BACKTRACE=1 cargo run $(CARGO_FLAGS)

client:
	cd web; \
	elm make src/Main.elm --output=main.js; \
	cp -rf assets ../static/; \
	cp -f main.html ../static/index.html; \
	cp -f main.js ../static;
