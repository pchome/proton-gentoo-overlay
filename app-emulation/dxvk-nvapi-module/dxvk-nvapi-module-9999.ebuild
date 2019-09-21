# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit meson multilib-minimal

DESCRIPTION="Wine-staging NvAPI implementation with DXVK interfaces support"
HOMEPAGE="https://github.com/pchome/dxvk-nvapi-module"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/pchome/dxvk-nvapi-module.git"
	EGIT_BRANCH="master"
	inherit git-r3
	SRC_URI=""
else
	SRC_URI="https://github.com/pchome/dxvk-nvapi-module/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64"
fi

SLOT="${PV}"
RESTRICT="test"

RDEPEND="app-emulation/wine-proton:*[${MULTILIB_USEDEP},vulkan]"

DEPEND="${RDEPEND}"

BDEPEND="dev-util/meson-common-winelib"

PATCHES=(
	"${FILESDIR}/install-each-lib-in-subdir.patch"
)

cross_file() { [[ ${ABI} = amd64 ]] && echo "${CHOST_amd64}.x86_64.winesrc" || echo "${CHOST_x86}.x86.winesrc" ; }

winesrc_flags() {
	# winesrc specific flags for the project
	local winesrc_cargs="${CFLAGS}"
	local winesrc_largs="${LDFLAGS}"

	# Hide symbols
	winesrc_cargs="${winesrc_cargs} -fvisibility=hidden"

	if [[ $1 ]]; then
		[[ $1 = "cflags" ]] && echo "${winesrc_cargs}"
		[[ $1 = "ldflags" ]] && echo "${winesrc_largs}"
	fi
}

multilib_src_configure() {
	local emesonargs=(
		--cross-file="$(cross_file)"
		--libdir="$(get_libdir)/wine-modules/dxvk"
		--bindir="$(get_libdir)/wine-modules/dxvk"
		-Dc_args="$(winesrc_flags cflags)"
		-Dc_link_args="$(winesrc_flags ldflags)"
		--unity=on
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}
