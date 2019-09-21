# Copyright 2018-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5,6,7} )
inherit distutils-r1

DESCRIPTION="A module for applying fixes at runtime to unsupported games with Steam Proton without changing game installation files"
HOMEPAGE="https://github.com/simons-public/protonfixes"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/simons-public/protonfixes.git"
	inherit git-r3
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="https://github.com/simons-public/protonfixes/archive/${PV}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
fi

LICENSE="Unlicense"
SLOT="0"

IUSE=""
RESTRICT="test"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

PATCHES=(
	"${FILESDIR}/experimental.2.patch"
)

src_prepare() {
	distutils-r1_src_prepare

	# TODO:
	# Silence errors
	mv "${S}/tests" "${S}/test-proton"
	mv "${S}/static" "${S}/splash-proton"
}
