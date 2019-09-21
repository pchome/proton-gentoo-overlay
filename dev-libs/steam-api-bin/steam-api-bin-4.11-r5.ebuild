# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MULTILIB_COMPAT=( abi_x86_32 )

inherit multilib-minimal

DESCRIPTION="Steam api lib for Proton"
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

multilib_src_install() {
	insinto "${EPREFIX}/usr/$(get_libdir)/wine-proton-${PV}"
	doins "${S}/steam_helper/libsteam_api.so"
}
