all:
	shards build --release

install:
	install bin/queryit /usr/bin