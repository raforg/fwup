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

# Install the firewall scripts
# 20000321 raf <raf2@zip.com.au>

help:
	@echo "This Makefile supports the following targets"
	@echo
	@echo "    help      - show this help (default)"
	@echo "    install   - install the firewall scripts (as root)"
	@echo "    policy    - install firewall.policy (as root)"
	@echo "    uninstall - uninstall the firewall scripts and policy (as root)"
	@echo "    list      - list installed firewall scripts and policy"
	@echo "    dist      - make a distribution"
	@echo "    MANIFEST  - create a manifest file"
	@echo "    decent    - change \"EVIL\" to \"EXTREMELY_DANGEROUS\" (before install)"
	@echo

SRC = firewall firewall.policy fwdown fwhelper fwup
START = rc2.d rc3.d rc4.d rc5.d
KILL = rc0.d rc1.d rc6.d

install:
	install -m 744 fwup /usr/local/sbin
	install -m 744 fwdown /usr/local/sbin
	install -m 755 firewall /etc/rc.d/init.d
	for code in S09 K91; do for rc in $(START); do [ -x /etc/rc.d/$$rc/$${code}firewall ] || ln -s ../init.d/firewall /etc/rc.d/$$rc/$${code}firewall; done; done

policy:
	install -m 600 firewall.policy /etc/sysconfig

uninstall:
	rm -f /etc/rc.d/init.d/firewall /usr/local/sbin/fwup /usr/local/sbin/fwdown /etc/sysconfig/firewall.policy /etc/rc.d/rc?.d/[SK][0-9][0-9]firewall

list:
	@ls -l /etc/rc.d/init.d/firewall /usr/local/sbin/fwup /usr/local/sbin/fwdown /etc/sysconfig/firewall.policy /etc/rc.d/rc?.d/[SK][0-9][0-9]firewall

dist: MANIFEST
	@src=`basename \`pwd\``; \
	dst=firewall-`date +%Y%m%d`; \
	cd ..; \
	test "$$src" != "$$dst" -a ! -e "$$dst" && ln -s $$src $$dst; \
	tar chzf $$dst.tar.gz $$dst/[RMfd]*; \
	test -L "$$dst" && rm -f $$dst; \
	rm -f $$src/MANIFEST; \
	tar tzf $$dst.tar.gz

MANIFEST:
	@find . -name '[RMfd]*' > MANIFEST

decent:
	@perl -pi -e 's/EVIL/EXTREMELY_DANGEROUS/g' fwup firewall.policy

# vi:set ts=4 sw=4:
