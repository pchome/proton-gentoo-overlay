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

RDEPEND="=app-emulation/wine-proton-${PV}:*[${MULTILIB_USEDEP},vulkan]"

DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/install-each-lib-in-subdir.patch"
)

bits() { [[ ${ABI} = amd64 ]] && echo 64 || echo 32; }

src_prepare() {
	default

	bootstrap_nvapi() {
		# Add *FLAGS to cross-file
		sed -E \
			-e "s#^(c_args.*)#\1 + $(_meson_env_array "${CFLAGS}")#" \
			-e "s#^(cpp_args.*)#\1 + $(_meson_env_array "${CXXFLAGS}")#" \
			-e "s#^(c_link_args.*)#\1 + $(_meson_env_array "${LDFLAGS}")#" \
			-e "s#^(cpp_link_args.*)#\1 + $(_meson_env_array "${LDFLAGS}")#" \
			-i build-wine$(bits).txt || die
	}

	multilib_foreach_abi bootstrap_nvapi || die
}

multilib_src_configure() {
	local emesonargs=(
		--cross-file="${S}/build-wine$(bits).txt"
		--libdir="$(get_libdir)/wine-modules/dxvk"
		--bindir="$(get_libdir)/wine-modules/dxvk"
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}
