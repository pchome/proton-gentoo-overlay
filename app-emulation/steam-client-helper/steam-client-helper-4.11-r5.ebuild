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
	GIT_V="4.11-5"
	GIT_COMMIT=8d895938e6cab82df5e50211e441135d08573d9a
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

BDEPEND="dev-util/meson-common-winelib"

cross_file() { [[ ${ABI} = amd64 ]] && echo "${CHOST_amd64}.x86_64.winelib" || echo "${CHOST_x86}.x86.winelib" ; }

winelib_flags() {
        # winelib specific flags for the project
        local winelib_cargs="${CFLAGS}"
        local winelib_cppargs="${CXXFLAGS}"
        local winelib_largs="${LDFLAGS}"

        # Do not emit STB_GNU_UNIQUE symbols for uuidof declarations, which prevents .so files from being unloaded.
        winelib_cppargs="${winelib_cppargs} --no-gnu-unique"

        # Hide symbols
        winelib_cargs="${winelib_cargs} -fvisibility=hidden"
        winelib_cppargs="${winelib_cppargs} -fvisibility=hidden -fvisibility-inlines-hidden"

        # Silence some warnings
        winelib_cppargs="${winelib_cppargs} -Wno-attributes"

        if [[ $1 ]]; then
                [[ $1 = "cflags" ]] && echo "${winelib_cargs}"
                [[ $1 = "cppflags" ]] && echo "${winelib_cppargs}"
                [[ $1 = "ldflags" ]] && echo "${winelib_largs}"
        fi
}

src_prepare() {
	# meson build
	cp "${FILESDIR}/meson.build" ${S}
	default
}

multilib_src_configure() {
	local emesonargs=(
		--cross-file="$(cross_file)"
		--libdir="$(get_libdir)/wine-proton-${PV}/wine"
		--bindir="$(get_libdir)/wine-proton-${PV}/wine"
		-Dc_args="$(winelib_flags cflags)"
		-Dcpp_args="$(winelib_flags cppflags)"
		-Dc_link_args="$(winelib_flags ldflags)"
		-Dcpp_link_args="$(winelib_flags ldflags)"
		#--unity=on
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}
