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
	GIT_V="4.11-4"
	GIT_COMMIT=c149aae8881f92b35e9d5627c74dac3ac3ed1586
	SRC_URI="https://github.com/ValveSoftware/Proton/archive/${GIT_COMMIT}.zip -> Proton-${GIT_V}.zip"
	S="${WORKDIR}/Proton-${GIT_COMMIT}"
	KEYWORDS="-* ~amd64"
fi

PROTON_INITIAL_VER="4.11-2"

LICENSE="ValveSteamLicense"
SLOT="${PV}"

RESTRICT="test"

RDEPEND="app-emulation/wine-proton:${SLOT}[${MULTILIB_USEDEP}]

	app-emulation/d9vk-module:*[${MULTILIB_USEDEP}]
	app-emulation/dxvk-module:*[${MULTILIB_USEDEP}]

	app-emulation/steam-client-helper:${SLOT}[${MULTILIB_USEDEP}]
	app-emulation/steam-helper:${SLOT}

	>=app-emulation/faudio-19.08:*[${MULTILIB_USEDEP}]

	dev-python/filelock
	media-fonts/liberation-fonts"

DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/proton-custom-tmp-no-vr.patch" # temporary disabled
	"${FILESDIR}/proton-custom-use-wine-modules.patch"
	"${FILESDIR}/proton-custom-use-config.patch"
	"${FILESDIR}/proton-custom-user_settings.patch"
	"${FILESDIR}/proton-custom-fix-paths.patch"
	"${FILESDIR}/proton-custom-fix-more-paths.patch"
	"${FILESDIR}/proton-custom-fix-more-paths-2.patch"
	"${FILESDIR}/proton-custom-wine-dxgi.patch"
)

src_prepare() {
	echo "$(date +"%s") proton-${PROTON_INITIAL_VER}" >> "${S}/version"

	cp "${FILESDIR}/proton.conf.in" "${S}/proton.conf"

	# create compatibilitytool.vdf
	sed -E \
		-e "s/\"display_name\" \"##BUILD_NAME##\"/\"display_name\" \"Proton (custom) ${PROTON_VER}\"/" \
		-e "s/\"##BUILD_NAME##\"/\"${PN}-${PROTON_VER}\"/" \
		-i compatibilitytool.vdf.template || die
	mv compatibilitytool.vdf.template compatibilitytool.vdf
	
	# set current version
	sed -E \
		-e "s#^PFX=\"Proton: \"#PFX=\"Proton (custom): \"#" \
		-i proton || die

	# set config
	sed -E \
		-e "s#@PV@#${PV}#g" \
		-e "s#@PROTON_VER@#${PROTON_VER}#g" \
		-e "s#@LIB32@#$(get_abi_LIBDIR x86)#g" \
		-e "s#@LIB64@#$(get_abi_LIBDIR amd64)#g" \
		-i proton.conf || die

	default
}

multilib_src_install_all() {
	ins_path="${EPREFIX}/usr/share/steam/compatibilitytools.d/${P}"

	exeinto "${ins_path}"
	doexe "${S}/proton"

	insinto "${ins_path}"

	doins "${S}/proton.conf"
	doins "${S}/user_settings.sample.py"
	
	doins "${S}/compatibilitytool.vdf"
	doins "${S}/toolmanifest.vdf"
	
	doins "${S}/proton_3.7_tracked_files"
	doins "${S}/version"

	doins "${S}/README.md"
}
