PREFIX = /usr

.PHONY: all
all:
	shards build --release

.PHONY: install
install:
	install -D -m 0755 bin/queryit $(DESTDIR)$(PREFIX)/bin
