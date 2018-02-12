#!/usr/bin/make -f
# Makefile for se3_dhcp

all:

install:
	mkdir -p $(DESTDIR)/var/
	mkdir -p $(DESTDIR)/tftpboot/
	mkdir -p $(DESTDIR)/usr/
	mkdir -p $(DESTDIR)/etc/sudoers.d/
	cp -R var/* $(DESTDIR)/var/
	cp -R tftpboot/* $(DESTDIR)/tftpboot/
	cp -R usr/* $(DESTDIR)/usr/
	cp -R etc/sudoers.d/* $(DESTDIR)/etc/sudoers.d/
	
clean:
