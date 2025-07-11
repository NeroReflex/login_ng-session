# Build variables
BUILD_TYPE ?= release
TARGET ?= $(shell rustc -vV | grep "host" | sed 's/host: //')
ETC_DIR ?= etc

.PHONY_: install_login_ng-session
install_login_ng-session: login_ng-session/target/$(TARGET)/$(BUILD_TYPE)/login_ng-session login_ng-session/target/$(TARGET)/$(BUILD_TYPE)/login_ng-sessionctl
	install -D -m 755 login_ng-session/target/$(TARGET)/$(BUILD_TYPE)/login_ng-session $(PREFIX)/usr/bin/login_ng-session
	install -D -m 755 login_ng-session/target/$(TARGET)/$(BUILD_TYPE)/login_ng-sessionctl $(PREFIX)/usr/bin/login_ng-sessionctl
	install -D -m 755 rootfs/usr/share/wayland-sessions/login_ng-session.desktop $(PREFIX)/usr/share/wayland-sessions/login_ng-session.desktop
	install -D -m 755 rootfs/usr/bin/start-login_ng-session $(PREFIX)/usr/bin/start-login_ng-session

.PHONY_: install_sessionexec
install_sessionexec: sessionexec/target/$(TARGET)/$(BUILD_TYPE)/sessionexec
	install -D -m 755 sessionexec/target/$(TARGET)/$(BUILD_TYPE)/sessionexec $(PREFIX)/usr/bin/sessionexec
	install -D -m 755 rootfs/usr/lib/sessionexec/session-return.sh $(PREFIX)/usr/lib/sessionexec/session-return.sh
	install -D -m 755 rootfs/usr/lib/os-session-select $(PREFIX)/usr/lib/os-session-select
	install -D -m 644 rootfs/usr/lib/login_ng-session/steamdeck.service $(PREFIX)/usr/lib/login_ng-session/steamdeck.service
	install -D -m 644 rootfs/usr/lib/login_ng-session/default.service $(PREFIX)/usr/lib/login_ng-session/default.service
	install -D -m 755 rootfs/usr/share/wayland-sessions/game-mode.desktop $(PREFIX)/usr/share/wayland-sessions/game-mode.desktop
	install -D -m 755 rootfs/usr/share/applications/org.sessionexec.session-return.desktop $(PREFIX)/usr/share/applications/org.sessionexec.session-return.desktop
	rm -f $(PREFIX)/usr/share/wayland-sessions/default.desktop
	ln -s game-mode.desktop $(PREFIX)/usr/share/wayland-sessions/default.desktop

.PHONY: install
install: install_login_ng-session install_sessionexec

.PHONY: build
build: sessionexec/target/$(TARGET)/$(BUILD_TYPE)/sessionexec login_ng-session/target/$(TARGET)/$(BUILD_TYPE)/login_ng-session login_ng-session/target/$(TARGET)/$(BUILD_TYPE)/login_ng-sessionctl

.PHONY: fetch
fetch: Cargo.lock
	cargo fetch --locked

sessionexec/target/$(TARGET)/$(BUILD_TYPE)/sessionexec: fetch
	cd sessionexec && cargo build --frozen --offline --all-features --$(BUILD_TYPE) --target=$(TARGET) --target-dir target

login_ng-session/target/$(TARGET)/$(BUILD_TYPE)/login_ng-session: fetch
	cd login_ng-session && cargo build --frozen --offline --all-features --$(BUILD_TYPE) --target=$(TARGET) --target-dir target

login_ng-session/target/$(TARGET)/$(BUILD_TYPE)/login_ng-sessionctl: fetch
	cd login_ng-session && cargo build --frozen --offline --all-features --$(BUILD_TYPE) --target=$(TARGET) --target-dir target --bin login_ng-sessionctl

.PHONY: clean
clean:
	cargo clean
	rm -rf login_ng-session/target
	rm -rf sessionexec/target

.PHONY: all
all: build

.PHONY: deb
deb: fetch
	cd sessionexec && cargo-deb --all-features
	cd login_ng-session && cargo-deb --all-features
