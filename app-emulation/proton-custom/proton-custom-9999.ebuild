# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit multilib-minimal

DESCRIPTION="Compatibility tool for Steam Play based on Wine and additional components"
HOMEPAGE="https://github.com/ValveSoftware/Proton"

if [[ ${PV} == "9999" ]] ; then
	PROTON_VER="4.11"
	EGIT_REPO_URI="https://github.com/ValveSoftware/Proton.git"
	EGIT_BRANCH="proton_4.11"
	EGIT_SUBMODULES=()
	inherit git-r3
	SRC_URI=""
else
	PROTON_VER="${PV}"
	SRC_URI="https://github.com/ValveSoftware/Proton/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64"
fi

LICENSE="ValveSteamLicense"
SLOT="${PV}"

RESTRICT="test"

RDEPEND="=app-emulation/wine-proton-${PV}:*[${MULTILIB_USEDEP}]

	=app-emulation/d9vk-module-${PV}:*[${MULTILIB_USEDEP}]
	=app-emulation/dxvk-module-${PV}:*[${MULTILIB_USEDEP}]

	=app-emulation/steam-client-helper-${PV}:*[${MULTILIB_USEDEP}]
	=app-emulation/steam-helper-${PV}

	>=app-emulation/faudio-19.08:*[${MULTILIB_USEDEP}]

	dev-python/filelock
	media-fonts/liberation-fonts"

DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/proton-custom-tmp-no-vr.patch" # temporary disabled
	"${FILESDIR}/proton-custom-use-wine-modules.patch"
)

src_prepare() {
	echo "$(date +"%s") proton-${PROTON_VER}-1" >> "${S}/version"
	touch dist.lock

	# create compatibilitytool.vdf
	sed -E \
		-e "s/\"display_name\" \"##BUILD_NAME##\"/\"display_name\" \"Proton (custom) ${PROTON_VER}\"/" \
		-e "s/\"##BUILD_NAME##\"/\"${PN}-${PROTON_VER}\"/" \
		-i compatibilitytool.vdf.template || die
	mv compatibilitytool.vdf.template compatibilitytool.vdf
	
	# set current version
	sed -E \
		-e "s#^CURRENT_PREFIX_VERSION=\".*-1\"#CURRENT_PREFIX_VERSION=\"${PROTON_VER}-1\"#" \
		-e "s#^PFX=\"Proton: \"#PFX=\"Proton (custom): \"#" \
		-e "s#self\.path\(\"dist/share/default_pfx/\"\)#os.path.expanduser('~/.local/share/${PN}-${PROTON_VER}-default_pfx/')#" \
		-i proton || die
	# TODO
#		-e "s#self\.path\(\"user_settings.py\"\)#os.path.expanduser('~/.config/${PN}-${PROTON_VER}-user_settings.py')#" \

	default
}

multilib_src_install_all() {
	ins_path="${EPREFIX}/usr/share/steam/compatibilitytools.d/${P}"

	exeinto "${ins_path}"
	doexe "${S}/proton"

	insinto "${ins_path}"

	doins "${S}/user_settings.sample.py"
	
	doins "${S}/compatibilitytool.vdf"
	doins "${S}/toolmanifest.vdf"
	
	doins "${S}/proton_3.7_tracked_files"
	doins "${S}/version"
	doins "${S}/dist.lock"

	doins "${S}/README.md"

	# dist dir
	dodir "${ins_path}/dist"
	dodir "${ins_path}/dist/share"

	# create lib and lib64 dir
	abilinks() { dosym "${EPREFIX}/usr/$(get_abi_LIBDIR ${ABI})/wine-proton-${PV}" "${ins_path}/dist/$(get_abi_LIBDIR ${ABI})"; }
	multilib_foreach_abi abilinks || die

	# bin dir
	dosym "${EPREFIX}/usr/$(get_abi_LIBDIR x86)/wine-proton-${PV}/bin" "${ins_path}/dist/bin"

	dosym "../version" "${ins_path}/dist/version"

	# share dir
	dosym "${EPREFIX}/usr/share/wine-proton-${PV}/applications" "${ins_path}/dist/share/applications"
	dosym "${EPREFIX}/usr/share/wine-proton-${PV}/wine" "${ins_path}/dist/share/wine"

	# fonts dir
	dosym "${EPREFIX}/usr/share/fonts/liberation-fonts" "${ins_path}/dist/share/fonts"
}
