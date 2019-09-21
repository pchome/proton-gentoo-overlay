# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Meson build system cross-files for winelib build"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-util/meson"
RDEPEND="${DEPEND}"
BDEPEND=""

src_unpack() {
	# TODO: create real sources
	mkdir "${WORKDIR}/${P}" || die
}

src_install() {
	insinto "${EPREFIX}/usr/share/meson/cross"

	doins "${FILESDIR}/i686-pc-linux-gnu.x86.winelib"
	doins "${FILESDIR}/i686-pc-linux-gnu.x86.winesrc"
	doins "${FILESDIR}/x86_64-pc-linux-gnu.x86_64.winelib"
	doins "${FILESDIR}/x86_64-pc-linux-gnu.x86_64.winesrc"
}
