TO_INSTALL = api bin conf dashboard orange install
ORANGE_HOME ?= /usr/local/orange
ORANGE_BIN ?= /usr/local/bin/orange
ORNAGE_HOME_PATH = $(subst /,\\/,$(ORANGE_HOME))

.PHONY: test install show
init-config:
	@ test -f conf/nginx.conf   || (cp conf/nginx.conf.example conf/nginx.conf && echo "copy nginx.conf")
	@ test -f conf/orange.conf  || (cp conf/orange.conf.example conf/orange.conf && echo "copy orange.conf")


deps:init-config
	mkdir -p resty
	wget https://github.com/pintsized/lua-resty-http/archive/master.zip
	unzip master.zip
	yes|cp -fr   lua-resty-http-master/lib/resty/*  resty/
	rm -fr  master.zip  lua-resty-http-master
	wget https://github.com/doujiang24/lua-resty-kafka/archive/master.zip
	unzip master.zip
	yes|cp -fr lua-resty-kafka-master/lib/resty/* resty
	rm -fr  master.zip lua-resty-kafka-master

test:
	@echo "to be continued..."

install:init-config
	@rm -rf $(ORANGE_BIN)
	@rm -rf $(ORANGE_HOME)
	@mkdir -p $(ORANGE_HOME)

	@for item in $(TO_INSTALL) ; do \
		cp -a $$item $(ORANGE_HOME)/; \
	done;

	@cat $(ORANGE_HOME)/conf/nginx.conf | sed "s/..\/\?.lua;\/usr\/local\/lor\/\?.lua;;/"$(ORNAGE_HOME_PATH)"\/\?.lua;\/usr\/local\/lor\/?.lua;;/" > $(ORANGE_HOME)/conf/new_nginx.conf
	@rm $(ORANGE_HOME)/conf/nginx.conf
	@mv $(ORANGE_HOME)/conf/new_nginx.conf $(ORANGE_HOME)/conf/nginx.conf

	@echo "#!/usr/bin/env resty" >> $(ORANGE_BIN)
	@echo "package.path=\"$(ORANGE_HOME)/?.lua;;\" .. package.path" >> $(ORANGE_BIN)
	@echo "require(\"bin.main\")(arg)" >> $(ORANGE_BIN)
	@chmod +x $(ORANGE_BIN)
	@echo "Orange installed."
	$(ORANGE_BIN) help

show:
	$(ORANGE_BIN) help
