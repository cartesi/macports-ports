# macports-ports
Cartesi MacPorts Ports Repository


The following assumes

* You replace `<MACPORTS_PORTS>` with the full path of your cloned `cartesi/macports-ports` repository;
* You replace `/opt/local` with the appropriate MacPorts prefix;
* You replace `127.0.0.1:6227` with the host name and port of the server used to distribute Portfiles and binary archives.

## Source archives

To generate a `ports.tar` with all portfiles, go to the base of the repo and run
```bash
cd <MACPORTS_PORTS>
tar -cvf ports.tar ports
```

This can be served from anywhere.
To test the setup, I used lighttpd with a configuration file `<MACPORTS_PORTS>/lighttpd.conf`:

```
server.document-root = "<MACPORTS_PORTS>"

server.username  = "_www"
server.groupname = "_www"

server.port = 6227

dir-listing.activate = "enable"

mimetype.assign = (
    ".tbz2"     => "application/x-bzip-compressed-tar",
    ".rmd160"   => "text/binary",

    # make the default mime type application/octet-stream.
    ""          => "application/octet-stream",
)
```

Don't forget to run the server
```bash
sudo port install lighttpd
/opt/local/sbin/lighttpd -D -f <MACPORTS_PORTS>/lighttpd.conf
```

Now append a new source to `/opt/local/etc/macports/sources.conf`.
```bash
# Cartesi test ports
http://127.0.0.1:6227/ports.tar
```
Naturally, for the tests with lighttpd, I used `IP=127.0.0.1` and `PORT=6227`.

To test this setup, you must first sync go anywhere and run

```bash
sudo port sync
```

This should produce something like
```
Synchronizing local ports tree from http://127.0.0.1:6227/ports.tar
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 33792  100 33792    0     0  45.2M      0 --:--:-- --:--:-- --:--:-- 32.2M
x emulators/
x emulators/cartesi-machine-linux-image/
x emulators/cartesi-machine-emulator/
x emulators/cartesi-machine-rootfs-image/
x emulators/cartesi-machine/
x emulators/cartesi-machine/Portfile
x emulators/cartesi-machine-rootfs-image/Portfile
x emulators/cartesi-machine-emulator/Portfile
x emulators/cartesi-machine-linux-image/Portfile
Creating port index in /opt/local/var/macports/sources/IP/PORT/ports
Adding port emulators/cartesi-machine-emulator
Adding port emulators/cartesi-machine-linux-image
Adding port emulators/cartesi-machine
Adding port emulators/cartesi-machine-rootfs-image

Total number of ports parsed:   4
Ports successfully parsed:      4
Ports failed:                   0
Up-to-date ports skipped:       0
```

Now, first make sure there is no garbage left behind from some previous experiment
```bash
for p in cartesi-machine cartesi-machine-emulator cartesi-machine cartesi-machine-linux-image cartesi-machine cartesi-machine-rootfs-image; do
	sudo port uninstall $p
	sudo port clean --all $p
done
```

You should now be able to install the ports from source by running
```
sudo port install -s cartesi-machine
```

This should output something like:
```
--->  Computing dependencies for cartesi-machine
The following dependencies will be installed:
 cartesi-machine-emulator
 cartesi-machine-linux-image
 cartesi-machine-rootfs-image
Continue? [Y/n]: Y
--->  Fetching distfiles for cartesi-machine-emulator
--->  Attempting to fetch add-generated-files.diff from https://distfiles.macports.org/cartesi-machine-emulator
--->  Attempting to fetch add-generated-files.diff from https://lis.pt.distfiles.macports.org/cartesi-machine-emulator
--->  Attempting to fetch add-generated-files.diff from https://fra.de.distfiles.macports.org/cartesi-machine-emulator
--->  Attempting to fetch add-generated-files.diff from https://github.com/cartesi/machine-emulator/releases/download/v0.19.0-test2/
--->  Attempting to fetch machine-emulator-0.19.0-test2.tar.gz from https://distfiles.macports.org/cartesi-machine-emulator
--->  Attempting to fetch machine-emulator-0.19.0-test2.tar.gz from https://lis.pt.distfiles.macports.org/cartesi-machine-emulator
--->  Attempting to fetch machine-emulator-0.19.0-test2.tar.gz from https://fra.de.distfiles.macports.org/cartesi-machine-emulator
--->  Attempting to fetch machine-emulator-0.19.0-test2.tar.gz from https://github.com/cartesi/machine-emulator/archive/v0.19.0-test2
--->  Verifying checksums for cartesi-machine-emulator
--->  Extracting cartesi-machine-emulator
--->  Applying patches to cartesi-machine-emulator
--->  Configuring cartesi-machine-emulator
--->  Building cartesi-machine-emulator
--->  Staging cartesi-machine-emulator into destroot
--->  Installing cartesi-machine-emulator @0.19.0-test2_0
--->  Activating cartesi-machine-emulator @0.19.0-test2_0
--->  Cleaning cartesi-machine-emulator
--->  Fetching distfiles for cartesi-machine-rootfs-image
--->  Attempting to fetch rootfs-ubuntu.ext2 from https://distfiles.macports.org/cartesi-machine-rootfs-image
--->  Attempting to fetch rootfs-ubuntu.ext2 from https://lis.pt.distfiles.macports.org/cartesi-machine-rootfs-image
--->  Attempting to fetch rootfs-ubuntu.ext2 from https://fra.de.distfiles.macports.org/cartesi-machine-rootfs-image
--->  Attempting to fetch rootfs-ubuntu.ext2 from https://github.com/cartesi/machine-rootfs-image/releases/download/v0.20.0-test1/
--->  Verifying checksums for cartesi-machine-rootfs-image
--->  Extracting cartesi-machine-rootfs-image
--->  Configuring cartesi-machine-rootfs-image
--->  Building cartesi-machine-rootfs-image
--->  Staging cartesi-machine-rootfs-image into destroot
--->  Installing cartesi-machine-rootfs-image @0.20.0-test1_0
--->  Activating cartesi-machine-rootfs-image @0.20.0-test1_0
--->  Cleaning cartesi-machine-rootfs-image
--->  Fetching distfiles for cartesi-machine-linux-image
--->  Attempting to fetch linux-6.5.13-ctsi-1-v0.20.0.bin from https://distfiles.macports.org/cartesi-machine-linux-image
--->  Attempting to fetch linux-6.5.13-ctsi-1-v0.20.0.bin from https://lis.pt.distfiles.macports.org/cartesi-machine-linux-image
--->  Attempting to fetch linux-6.5.13-ctsi-1-v0.20.0.bin from https://fra.de.distfiles.macports.org/cartesi-machine-linux-image
--->  Attempting to fetch linux-6.5.13-ctsi-1-v0.20.0.bin from https://github.com/cartesi/machine-linux-image/releases/download/v0.20.0/
--->  Verifying checksums for cartesi-machine-linux-image
--->  Extracting cartesi-machine-linux-image
--->  Configuring cartesi-machine-linux-image
--->  Building cartesi-machine-linux-image
--->  Staging cartesi-machine-linux-image into destroot
--->  Installing cartesi-machine-linux-image @0.20.0_0
--->  Activating cartesi-machine-linux-image @0.20.0_0
--->  Cleaning cartesi-machine-linux-image
--->  Fetching distfiles for cartesi-machine
--->  Verifying checksums for cartesi-machine
--->  Extracting cartesi-machine
--->  Configuring cartesi-machine
--->  Building cartesi-machine
--->  Staging cartesi-machine into destroot
--->  Installing cartesi-machine @0.20.0_0
--->  Activating cartesi-machine @0.20.0_0
--->  Cleaning cartesi-machine
--->  Scanning binaries for linking errors
--->  No broken files found.
--->  No broken ports found.
```

You should be able to run a simple test
```
which cartesi-machine && cartesi-machine
```
Producing
```
/opt/local/bin/cartesi-machine

         .
        / \
      /    \
\---/---\  /----\
 \       X       \
  \----/  \---/---\
       \    / CARTESI
        \ /   MACHINE
         '

Nothing to do.

Halted
Cycles: 48600713
```

## Binary archives

Binary archives must be signed.
First, create a signature pair.
```bash
openssl genrsa -des3 -out <MACPORTS_PORTS>/cartesi-macports-privkey.pem 2048
openssl rsa -in <MACPORTS_PORTS>/cartesi-macports-privkey.pem -pubout -out <MACPORTS_PORTS>/cartesi-macports-pubkey.pem
```

By default, the command `port archive` now generates a directory with all the binaries inside it.
(This is later `clonefile()`ed to its final destination on install.)
I was unable to force it to generate binary archives unless I append a new option `/opt/local/etc/macports/macports.conf`:
```bash
# Generate binary archives as well
portimage_mode          directory_and_archive
```

Now, first make sure there is no garbage left behind from some previous experiment
```bash
for p in cartesi-machine cartesi-machine-emulator cartesi-machine cartesi-machine-linux-image cartesi-machine cartesi-machine-rootfs-image; do
	sudo port uninstall $p
	sudo port clean --all $p
done
```

Once that is done, we can build the archive for each of our ports, copy it to the `archives` directory, and sign it.
Something like this:
```bash
cd <MACPORTS_PORTS>
# create archives
mkdir archives
for t in emulator linux-image rootfs-image; do
    p="cartesi-machine-$t"
    cd ports/emulators/$p
    sudo port archive -s
    cd ../../..
    mkdir -p archives/$p
    cp /opt/local/var/macports/software/$p/$p*.tbz2 archives/$p
	# sign archive
	for b in archives/$p/*; do
		 openssl dgst -ripemd160 -sign cartesi-macports-privkey.pem -out $b.rmd160 $b
	done
done
```

To test the binary packages, we need to first append our public key to `/opt/local/etc/macports/pubkeys.conf`:
```bash
# Cartesi test binary packages
<MACPORTS_PORTS>/cartesi-macports-pubkey.pem
```

And then append the new archive  site to `/opt/local/etc/macports/archive_sites.conf`:
```bash
# Cartesi test binary packages
name                	Cartesi test
urls                	http://127.0.0.1:6227/archives
```

You should now be able to install the ports from binary archives by running
```
sudo port install cartesi-machine
```

This should produce something like

```
--->  Computing dependencies for cartesi-machine
The following dependencies will be installed:
 cartesi-machine-emulator
 cartesi-machine-linux-image
 cartesi-machine-rootfs-image
Continue? [Y/n]: Y
--->  Fetching archive for cartesi-machine-emulator
--->  Attempting to fetch cartesi-machine-emulator-0.19.0-test2_0.darwin_23.arm64.tbz2 from http://127.0.0.1:6227/archives/cartesi-machine-emulator
--->  Attempting to fetch cartesi-machine-emulator-0.19.0-test2_0.darwin_23.arm64.tbz2.rmd160 from http://127.0.0.1:6227/archives/cartesi-machine-emulator
--->  Installing cartesi-machine-emulator @0.19.0-test2_0
--->  Activating cartesi-machine-emulator @0.19.0-test2_0
--->  Cleaning cartesi-machine-emulator
--->  Fetching archive for cartesi-machine-rootfs-image
--->  Attempting to fetch cartesi-machine-rootfs-image-0.20.0-test1_0.any_any.noarch.tbz2 from http://127.0.0.1:6227/archives/cartesi-machine-rootfs-image
--->  Attempting to fetch cartesi-machine-rootfs-image-0.20.0-test1_0.any_any.noarch.tbz2.rmd160 from http://127.0.0.1:6227/archives/cartesi-machine-rootfs-image
--->  Installing cartesi-machine-rootfs-image @0.20.0-test1_0
--->  Activating cartesi-machine-rootfs-image @0.20.0-test1_0
--->  Cleaning cartesi-machine-rootfs-image
--->  Fetching archive for cartesi-machine-linux-image
--->  Attempting to fetch cartesi-machine-linux-image-0.20.0_0.any_any.noarch.tbz2 from http://127.0.0.1:6227/archives/cartesi-machine-linux-image
--->  Attempting to fetch cartesi-machine-linux-image-0.20.0_0.any_any.noarch.tbz2.rmd160 from http://127.0.0.1:6227/archives/cartesi-machine-linux-image
--->  Installing cartesi-machine-linux-image @0.20.0_0
--->  Activating cartesi-machine-linux-image @0.20.0_0
--->  Cleaning cartesi-machine-linux-image
--->  Fetching archive for cartesi-machine
--->  Attempting to fetch cartesi-machine-0.20.0_0.any_any.noarch.tbz2 from http://127.0.0.1:6227/archives/cartesi-machine
--->  Fetching distfiles for cartesi-machine
--->  Verifying checksums for cartesi-machine
--->  Extracting cartesi-machine
--->  Configuring cartesi-machine
--->  Building cartesi-machine
--->  Staging cartesi-machine into destroot
--->  Installing cartesi-machine @0.20.0_0
--->  Activating cartesi-machine @0.20.0_0
--->  Cleaning cartesi-machine
--->  Scanning binaries for linking errors
--->  No broken files found.
--->  No broken ports found.
```
