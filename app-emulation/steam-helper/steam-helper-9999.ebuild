# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MULTILIB_COMPAT=( abi_x86_32 )

inherit meson multilib-minimal

DESCRIPTION="Steam helper for Proton"
HOMEPAGE="https://github.com/ValveSoftware/Proton"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/ValveSoftware/Proton.git"
	EGIT_BRANCH="proton_4.11"
	EGIT_SUBMODULES=()
	inherit git-r3
	SRC_URI=""
else
	SRC_URI="https://github.com/ValveSoftware/Proton/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64"
fi

LICENSE="ValveSteamLicense"
SLOT="${PV}"

RESTRICT="test"

RDEPEND="=app-emulation/wine-proton-${PV}:*[${MULTILIB_USEDEP}]
	=dev-libs/steam-api-bin-${PV}:*[${MULTILIB_USEDEP}]"

DEPEND="${RDEPEND}
	>=dev-util/meson-0.49"

src_prepare() {
	# meson build
	cp "${FILESDIR}/meson.build" ${S}
	cp "${FILESDIR}/build-steam.txt" ${S}
	default
}

multilib_src_configure() {
	local emesonargs=(
		--cross-file="${S}/build-steam.txt"
		--libdir="$(get_libdir)/wine-proton-${PV}/wine"
		--bindir="$(get_libdir)/wine-proton-${PV}/wine"
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}
