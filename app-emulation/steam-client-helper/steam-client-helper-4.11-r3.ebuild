# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MULTILIB_COMPAT=( abi_x86_{64,32} )

inherit meson multilib-minimal

DESCRIPTION="Steam client helper for Proton"
HOMEPAGE="https://github.com/ValveSoftware/Proton"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/ValveSoftware/Proton.git"
	EGIT_BRANCH="proton_4.11"
	EGIT_SUBMODULES=()
	inherit git-r3
	SRC_URI=""
else
	GIT_V="4.11-3"
	GIT_COMMIT=a5fa18152226c864131eb91998c73add2973573f
	SRC_URI="https://github.com/ValveSoftware/Proton/archive/${GIT_COMMIT}.zip -> Proton-${GIT_V}.zip"
	S="${WORKDIR}/Proton-${GIT_COMMIT}"
	KEYWORDS="-* ~amd64"
fi

LICENSE="ValveSteamLicense"
SLOT="${PV}"

RESTRICT="test"

RDEPEND="app-emulation/wine-proton:${SLOT}[${MULTILIB_USEDEP}]
	dev-libs/steam-api-bin:${SLOT}[${MULTILIB_USEDEP}]"

DEPEND="${RDEPEND}
	>=dev-util/meson-0.49"

bits() { [[ ${ABI} = amd64 ]] && echo 64 || echo 32; }

src_prepare() {
	# meson build
	cp "${FILESDIR}/meson.build" ${S}
	cp "${FILESDIR}/build-lsteamclient32.txt" ${S}
	cp "${FILESDIR}/build-lsteamclient64.txt" ${S}
	default

	bootstrap_lsteamclient() {
		# Add *FLAGS to cross-file
		sed -E \
			-e "s#^(c_args.*)#\1 + $(_meson_env_array "${CFLAGS}")#" \
			-e "s#^(cpp_args.*)#\1 + $(_meson_env_array "${CXXFLAGS}")#" \
			-e "s#^(c_link_args.*)#\1 + $(_meson_env_array "${LDFLAGS}")#" \
			-e "s#^(cpp_link_args.*)#\1 + $(_meson_env_array "${LDFLAGS}")#" \
			-i build-lsteamclient$(bits).txt || die
	}

	multilib_foreach_abi bootstrap_lsteamclient || die
}

multilib_src_configure() {
	local emesonargs=(
		--cross-file="${S}/build-lsteamclient$(bits).txt"
		--libdir="$(get_libdir)/wine-proton-${PV}/wine"
		--bindir="$(get_libdir)/wine-proton-${PV}/wine"
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}
