#
# firewall: http://www.zip.com.au/~raf2/lib/software/firewall
#
# Copyright (C) 1999, 2000 raf <raf2@zip.com.au>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# or visit http://www.gnu.org/copyleft/gpl.html
#

# Makefile - Install the firewall scripts
#
# 20000601 raf <raf2@zip.com.au>

help:
	@echo "This Makefile supports the following targets"; \
	echo; \
	echo "    help      - show this help (default)"; \
	echo "    install   - install the firewall scripts (as root)"; \
	echo "    policy    - install firewall.policy (as root)"; \
	echo "    uninstall - uninstall the firewall scripts and policy (as root)"; \
	echo "    show      - show installed firewall scripts and policy file"; \
	echo "    decent    - change \"EVIL\" to \"EXTREMELY_DANGEROUS\" (before install)"; \
	echo "    MANIFEST  - create a manifest file"; \
	echo "    dist      - make a distribution"; \
	echo "    backup    - make a backup"; \
	echo

START := rc2.d rc3.d rc4.d rc5.d
STOP := rc0.d rc1.d rc6.d
START_TIME := 09
STOP_TIME := 91

install:
	@. ./firewall.policy; \
	[ -d /usr/local/sbin ] || mkdir /usr/local/sbin; \
	install -m 744 fwup /usr/local/sbin || exit 1; \
	install -m 744 fwdown /usr/local/sbin || exit 1; \
	create() { if [ ! -f $$1 ]; then echo '#!/bin/sh' > $$1; echo >> $$1; chmod u+x $$1; fi }; \
	reload() { create $$1; grep -q '/firewall reload' $$1 || echo "[ -x $$loc/firewall ] && $$loc/firewall reload" >> $$1 }; \
	links() { for rc in $$1; do [ -x $$2/$$rc/$${3}firewall ] || ln -s ../init.d/firewall $$2/$$rc/$${3}firewall; done }; \
	initd() { install -m 755 firewall $$loc && links "$(START)" $$1 S$(START_TIME) && links "$(STOP)" $$1 K$(STOP_TIME) }; \
	dynamic() { if [ -z "$$UNTRUSTED_ADDRESSES" ]; then ppp; dhcp; fi }; \
	rclocal() { install -m 755 firewall $$loc && reload $$1/rc.local }; \
	ppp() { [ -d /etc/ppp ] && reload /etc/ppp/ip-up.local && reload /etc/ppp/ip-down.local }; \
	dhcp() { if [ -d /etc/dhcpc ]; then for iface in $$UNTRUSTED_INTERFACES; do reload /etc/dhcpc/dhcpcd-$$iface.exe; done; fi }; \
	if [ -d /etc/rc.d/init.d ]; then loc=/etc/rc.d/init.d; initd /etc/rc.d; dynamic; \
	elif [ -d /etc/init.d ]; then loc=/etc/init.d; initd /etc; dynamic; \
	elif [ -x /etc/rc.d/rc.local ]; then loc=/etc; rclocal /etc/rc.d; dynamic; \
	elif [ -x /etc/rc.local ]; then loc=/etc; rclocal /etc; dynamic; \
	else exit 1; \
	fi

policy:
	@install -m 600 firewall.policy /etc

uninstall:
	@. ./firewall.policy; \
	unmodify() { if [ -x $$1 ]; then grep -v '/firewall reload' $$1 > /tmp/fwun.$$$$; cat /tmp/fwun.$$$$ > $$1; rm -f /tmp/fwun.$$$$; fi }; \
	rm -f /etc/rc.d/init.d/firewall /etc/init.d/firewall /etc/firewall /usr/local/sbin/fwup /usr/local/sbin/fwdown /etc/firewall.policy /etc/rc.d/rc?.d/[SK][0-9][0-9]firewall /etc/rc?.d/[SK][0-9][0-9]firewall; \
	for modified in /etc/rc.d/rc.local /etc/rc.local /etc/ppp/ip-up.local /etc/ppp/ip-down.local /etc/dhcpc/dhcpcd-*.exe; do unmodify $$modified; done

show:
	@echo "Installed files:"; \
	ls -l /etc/rc.d/init.d/firewall /etc/init.d/firewall /etc/firewall /usr/local/sbin/fwup /usr/local/sbin/fwdown /etc/firewall.policy /etc/rc.d/rc?.d/[SK][0-9][0-9]firewall /etc/rc?.d/[SK][0-9][0-9]firewall 2>/dev/null; \
	echo "Modified files:"; \
	modified="`grep -l '/firewall reload' /etc/rc.d/rc.local /etc/rc.local /etc/ppp/ip-up.local /etc/ppp/ip-down.local /etc/dhcpc/dhcpcd-*.exe 2>/dev/null`"; \
	[ -n "$$modified" ] && ls -l $$modified; \
	exit 0

decent:
	@perl -pi -e 's/EVIL/EXTREMELY_DANGEROUS/g' Makefile fwup firewall.policy examples/*

MANIFEST:
	@ls -1 [RMf]* examples/* tools/* patches/* > MANIFEST

dist: MANIFEST
	@src=`basename \`pwd\``; \
	dst=firewall-`date +%Y%m%d`; \
	cd ..; \
	test "$$src" != "$$dst" -a ! -e "$$dst" && ln -s $$src $$dst; \
	tar chzf $$dst.tar.gz $$dst/[RMf]* $$dst/examples/* $$dst/tools/* $$dst/patches/*; \
	test -L "$$dst" && rm -f $$dst; \
	rm -f $$src/MANIFEST; \
	tar tzf $$dst.tar.gz

backup:
	@name=`basename \`pwd\``; \
	cd ..; \
	tar czf $$name.tar.gz $$name; \
	tar tzf $$name.tar.gz

# vi:set ts=4 sw=4
