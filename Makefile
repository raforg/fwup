#
# firewall - http://fwup.org/
#
# Copyright (C) 1999-2002 raf <raf@raf.org>
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

# Makefile - fwup
#
# 20020626 raf <raf@raf.org>

help:
	@echo "This Makefile supports the following targets"; \
	echo; \
	echo "    help      - show this help (default)"; \
	echo "    install   - install the firewall scripts (as root)"; \
	echo "    policy    - install firewall.policy (as root)"; \
	echo "    uninstall - uninstall the firewall scripts and policy (as root)"; \
	echo "    lrpkg     - create an LRP package of the firewall and policy"; \
	echo "    ls        - list installed firewall scripts and policy file"; \
	echo "    decent    - change \"EVIL\" to \"EXTREMELY_DANGEROUS\" (before install)"; \
	echo "    dist      - make a distribution"; \
	echo "    backup    - make a backup"; \
	echo; \
	echo "    meta-install   - install the meta-firewall control script"; \
	echo "    meta-uninstall - uninstall the meta-firewall control script"; \
	echo "    meta-ls        - list the meta-firewall installation"; \
	echo

install:
	@./make-install

policy:
	@./make-policy

uninstall:
	@./make-uninstall

lrpkg:
	@./make-lrpkg

ls:
	@./make-ls

meta-install:
	@./make-meta-install

meta-uninstall:
	@./make-meta-uninstall

meta-ls:
	@./make-meta-ls

decent:
	@perl -pi -e 's/EVIL/EXTREMELY_DANGEROUS/g' Makefile fwup firewall.policy examples/*

dist:
	@src=`basename \`pwd\``; \
	dst=firewall-`date +%Y%m%d`; \
	cd ..; \
	test "$$src" != "$$dst" -a ! -e "$$dst" && ln -s $$src $$dst; \
	tar chzf $$dst.tar.gz $$dst/[RMfm]* $$dst/examples/* $$dst/tools/* $$dst/patches/*; \
	test -h "$$dst" && rm -f $$dst; \
	tar tzvf $$dst.tar.gz

backup:
	@name=`basename \`pwd\``; \
	cd ..; \
	tar czf $$name.tar.gz $$name; \
	tar tzvf $$name.tar.gz

# vi:set ts=4 sw=4
