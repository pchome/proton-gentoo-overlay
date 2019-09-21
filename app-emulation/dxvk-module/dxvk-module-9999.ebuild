# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit meson multilib-minimal

DESCRIPTION="A Vulkan-based translation layer for Direct3D 10/11"
HOMEPAGE="https://github.com/doitsujin/dxvk"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/doitsujin/dxvk.git"
	EGIT_BRANCH="master"
	inherit git-r3
	SRC_URI=""
else
	SRC_URI="https://github.com/doitsujin/dxvk/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64"
fi

LICENSE="ZLIB"
SLOT="${PV}"
IUSE="+hud +openvr"
RESTRICT="test"

RDEPEND="app-emulation/wine-proton:*[${MULTILIB_USEDEP},vulkan]"

DEPEND="${RDEPEND}
	dev-util/glslang"

BDEPEND="dev-util/meson-common-winelib"

PATCHES=(
	"${FILESDIR}/install-each-lib-in-subdir.patch"
	"${FILESDIR}/ddraw-stub.patch"
	"${FILESDIR}/dxvk-hud-and-vr-options.patch"
)

dxvk_check_requirements() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if ! tc-is-gcc || [[ $(gcc-major-version) -lt 7 || $(gcc-major-version) -eq 7 && $(gcc-minor-version) -lt 3 ]]; then
			die "At least gcc 7.3 is required"
		fi
	fi
}

pkg_pretend() {
	dxvk_check_requirements
}

pkg_setup() {
	dxvk_check_requirements
}

cross_file() { [[ ${ABI} = amd64 ]] && echo "${CHOST_amd64}.x86_64.winelib" || echo "${CHOST_x86}.x86.winelib" ; }

winelib_flags() {
	# winelib specific flags for the project
	local winelib_cargs="${CFLAGS}"
	local winelib_cppargs="${CXXFLAGS}"
	local winelib_largs="${LDFLAGS}"

	# Do not emit STB_GNU_UNIQUE symbols for uuidof declarations, which prevents .so files from being unloaded.
	winelib_cppargs="${winelib_cppargs} --no-gnu-unique"

	# No min()/max()
	winelib_cppargs="${winelib_cppargs} -DNOMINMAX"

	# Hide symbols
	winelib_cargs="${winelib_cargs} -fvisibility=hidden"
	winelib_cppargs="${winelib_cppargs} -fvisibility=hidden -fvisibility-inlines-hidden"

	# Fix compilation for Wine >=4.15
	winelib_cargs="${winelib_cargs} -fpermissive"
	winelib_cppargs="${winelib_cppargs} -fpermissive"

	# For deps and entry points
	winelib_largs="${winelib_largs} -mwindows"

	if [[ $1 ]]; then
		[[ $1 = "cflags" ]] && echo "${winelib_cargs}"
		[[ $1 = "cppflags" ]] && echo "${winelib_cppargs}"
		[[ $1 = "ldflags" ]] && echo "${winelib_largs}"
	fi
}

multilib_src_configure() {
	local emesonargs=(
		--cross-file="$(cross_file)"
		--libdir="$(get_libdir)/wine-modules/dxvk"
		--bindir="$(get_libdir)/wine-modules/dxvk"
		$(meson_use hud enable_hud)
		$(meson_use openvr enable_openvr)
		-Dc_args="$(winelib_flags cflags)"
		-Dcpp_args="$(winelib_flags cppflags)"
		-Dc_link_args="$(winelib_flags ldflags)"
		-Dcpp_link_args="$(winelib_flags ldflags)"
		-Denable_tests=false
		--unity=on
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	dodoc "${S}/dxvk.conf"

	einstalldocs
}
