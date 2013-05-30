# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/libgdiplus/libgdiplus-2.10.9.ebuild $

EAPI=5

inherit base eutils mono flag-o-matic

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.mono-project.com"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ppc ppc64 x86 ~amd64-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
SRC_URI="http://download.mono-project.com/sources/${PN}/${P}.tar.bz2"

IUSE="cairo"

RDEPEND="	>=dev-libs/glib-2.16:2
	>=media-libs/freetype-2.3.7
	>=media-libs/fontconfig-2.6
	>=media-libs/libpng-1.4:0
	x11-libs/libXrender
	x11-libs/libX11
	x11-libs/libXt
	>=x11-libs/cairo-1.8.4[X]
	media-libs/libexif
	>=media-libs/giflib-4.1.3
	virtual/jpeg
	media-libs/tiff:0
	!cairo? ( >=x11-libs/pango-1.20 )"
DEPEND="${RDEPEND}"

RESTRICT="test"

PATCHES=( "${FILESDIR}/${P}-gold.patch"
	"${FILESDIR}/${PN}-2.10.1-libpng15.patch" )

src_prepare() {
	base_src_prepare
	sed -i -e 's:ungif:gif:g' configure || die
}

src_configure() {
	append-flags -fno-strict-aliasing
	econf 	--disable-dependency-tracking		\
		--disable-static			\
		--with-cairo=system			\
		$(use !cairo && printf %s --with-pango)	\
		|| die "configure failed"
}

src_compile() {
	emake "$@" || die "emake failed"
}

src_install () {
	emake -j1 DESTDIR="${D}" "$@" install || die "install failed" #nowarn
	mono_multilib_comply
	local commondoc=( AUTHORS ChangeLog README TODO )
	for docfile in "${commondoc[@]}"
	do
		[[ -e "${docfile}" ]] && dodoc "${docfile}"
	done
	if [[ "${DOCS[@]}" ]]
	then
		dodoc "${DOCS[@]}" || die "dodoc DOCS failed"
	fi
	find "${D}" -name '*.la' -exec rm -rf '{}' '+' || die "la removal failed"
}