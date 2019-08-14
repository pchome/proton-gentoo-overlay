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
RESTRICT="test"

RDEPEND="=app-emulation/wine-proton-${PV}:*[${MULTILIB_USEDEP},vulkan]"

DEPEND="${RDEPEND}
	dev-util/glslang"

PATCHES=(
	"${FILESDIR}/install-each-lib-in-subdir.patch"
)

bits() { [[ ${ABI} = amd64 ]] && echo 64 || echo 32; }

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

src_prepare() {
	default

	bootstrap_dxvk() {
		# Add *FLAGS to cross-file
		sed -E \
			-e "s#^(c_args.*)#\1 + $(_meson_env_array "${CFLAGS}")#" \
			-e "s#^(cpp_args.*)#\1 + $(_meson_env_array "${CXXFLAGS}")#" \
			-e "s#^(c_link_args.*)#\1 + $(_meson_env_array "${LDFLAGS}")#" \
			-e "s#^(cpp_link_args.*)#\1 + $(_meson_env_array "${LDFLAGS}")#" \
			-i build-wine$(bits).txt || die
	}

	multilib_foreach_abi bootstrap_dxvk || die
}

multilib_src_configure() {
	local emesonargs=(
		--cross-file="${S}/build-wine$(bits).txt"
		--libdir="$(get_libdir)/wine-modules/dxvk"
		--bindir="$(get_libdir)/wine-modules/dxvk"
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
