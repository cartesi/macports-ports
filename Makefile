PREFIX          ?= /opt/local
PORT            ?= $(PREFIX)/bin/port
SIGNIFY         ?= $(PREFIX)/libexec/macports/bin/signify
LIGHTTPD        ?= $(PREFIX)/sbin/lighttpd
ENVSUBST        ?= envsubst
OPENSSL         ?= openssl
SUDO            ?= sudo
KEYS_DIR        := keys
RMD160_PRIVKEY  ?= $(KEYS_DIR)/cartesi-macports-rmd160-privkey.pem
SIGNIFY_SECKEY  ?= $(KEYS_DIR)/cartesi-macports-signify.sec
SERVE_ADDRESS   ?= 127.0.0.1
SERVE_PORT      ?= 6227
SOFTWARE_DIR    := $(PREFIX)/var/macports/software
MACPORTS_CONF   := $(PREFIX)/etc/macports/macports.conf

# MacPorts reads Portfiles as the macports user, who usually cannot read home directories
# The ports tree is staged where it can, and rsync --delete only ever touches that copy
override STAGE_DIR := $(PREFIX)/var/macports/sources/cartesi-local
PORTS_DIR       := $(STAGE_DIR)/ports/emulators

# Dependencies come before the ports that need them
PORTS := \
    cartesi-machine-emulator \
    cartesi-machine-linux-image \
    cartesi-machine-rootfs-image \
    cartesi-machine

all: archives ports-tar

stage:
	$(SUDO) install -d -o $$(id -u) -m 0755 $(STAGE_DIR)
	rsync -a --delete --exclude PortIndex --exclude PortIndex.quick --exclude work --exclude .DS_Store \
	    ports/ $(STAGE_DIR)/ports/

# Build each port from source, collect its binary archive, and uninstall the ports again
# Other dependencies may come from binary archives and stay installed, marked unrequested
archives: stage
	@grep -Eq '^[[:space:]]*portimage_mode[[:space:]]+directory_and_archive' $(MACPORTS_CONF) || \
	    { echo 'Add "portimage_mode directory_and_archive" to $(MACPORTS_CONF)' >&2; exit 1; }
	@for p in $(PORTS); do \
	    [ -z "$$($(PORT) -q installed $$p)" ] || \
	        { echo "$$p is installed, run make uninstall first" >&2; exit 1; }; \
	done
	@echo 'Building the Cartesi ports from source with sudo port. This installs their'
	@echo 'build dependencies (marked unrequested) and stages the ports tree in'
	@echo '$(STAGE_DIR). The Cartesi ports are'
	@echo 'uninstalled again once their archives are collected.'
	@set -e; for p in $(PORTS); do \
	    deps=$$(cd $(PORTS_DIR)/$$p && $(PORT) -q info --line --depends | tr '\t,' '\n\n'); \
	    for d in $$deps; do \
	        [ -n "$$($(PORT) -q installed $$d)" ] || $(SUDO) $(PORT) -N install --unrequested $$d; \
	    done; \
	    (cd $(PORTS_DIR)/$$p && $(SUDO) $(PORT) -N -s install); \
	    vr=$$(cd $(PORTS_DIR)/$$p && $(PORT) -q info --line --version --revision | tr '\t' _); \
	    mkdir -p archives/$$p; \
	    rsync -a --delete --delete-excluded --include="$$p-$$vr[+.]*.tbz2" --exclude='*' \
	        $(SOFTWARE_DIR)/$$p/ archives/$$p/; \
	done
	$(MAKE) uninstall

ports-tar:
	mkdir -p archives
	COPYFILE_DISABLE=1 tar --exclude PortIndex --exclude PortIndex.quick --exclude work --exclude .DS_Store \
	    -cf archives/ports.tar ports

sign:
	@set -e; for b in archives/*/*.tbz2; do \
	    echo "Signing $$b"; \
	    $(OPENSSL) dgst -ripemd160 -provider legacy -provider default \
	        -sign $(RMD160_PRIVKEY) -out $$b.rmd160 $$b; \
	done
	$(SIGNIFY) -S -s $(SIGNIFY_SECKEY) -m archives/ports.tar -x archives/ports.tar.sig

# Serve with the same layout as https://dist.cartesi.io/macports/latest
serve:
	DOCUMENT_ROOT=$(CURDIR)/archives SERVE_ADDRESS=$(SERVE_ADDRESS) SERVE_PORT=$(SERVE_PORT) \
	    $(ENVSUBST) '$$DOCUMENT_ROOT $$SERVE_ADDRESS $$SERVE_PORT' < lighttpd.conf.template > lighttpd.conf
	$(LIGHTTPD) -D -f lighttpd.conf

# Remove all installed versions of the ports
uninstall:
	@set -e; for p in $(PORTS); do \
	    $(PORT) -q installed $$p | while read n v rest; do \
	        $(SUDO) $(PORT) -N uninstall --follow-dependents $$n $$v; \
	    done; \
	done

# Remove work and distfiles of the ports, both when built from the staged tree and from the synced one
clean: stage
	@set -e; for p in $(PORTS); do \
	    (cd $(PORTS_DIR)/$$p && $(SUDO) $(PORT) -N clean --all); \
	    $(SUDO) $(PORT) -N clean --all $$p || true; \
	done
	rm -f lighttpd.conf

distclean: clean
	rm -rf archives

.PHONY: all stage archives ports-tar sign serve uninstall clean distclean
