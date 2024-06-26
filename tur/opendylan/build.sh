TERMUX_PKG_HOMEPAGE=https://opendylan.org
TERMUX_PKG_DESCRIPTION="Open Dylan is a compiler and a set of libraries for the Dylan programming language."
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="License.txt"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=2024.1.0
TERMUX_PKG_SRCURL=git+https://github.com/dylan-lang/opendylan
TERMUX_PKG_DEPENDS="libgc"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-gc=${TERMUX_PREFIX}
--with-harp-collector=boehm
"

termux_step_pre_configure() {
	curl -Lo "${TERMUX_PKG_CACHEDIR}/opendylan.tar.bz2" https://github.com/dylan-lang/opendylan/releases/download/v2024.1.0/opendylan-2024.1-x86_64-linux.tar.bz2
	tar -xf "${TERMUX_PKG_CACHEDIR}/opendylan.tar.bz2" -C "${TERMUX_PKG_CACHEDIR}"
	export PATH="$PATH:${TERMUX_PKG_CACHEDIR}/opendylan-2024.1/bin"

	case "${TARGET_ARCH:=${TERMUX_ARCH}}" in
	i686) TARGET_ARCH=x86 ;;
	esac
	export OPEN_DYLAN_TARGET_PLATFORM="${TARGET_ARCH}-linux"

	CFLAGS+=" -Wno-error=int-conversion"
	./autogen.sh
}

termux_step_make() {
	pushd "sources/lib/run-time"

	make -j "${TERMUX_PKG_MAKE_PROCESSES}" \
		OPEN_DYLAN_TARGET_PLATFORM="${OPEN_DYLAN_TARGET_PLATFORM}"

	popd

	dylan-compiler \
		-jobs "${TERMUX_PKG_MAKE_PROCESSES}" \
		-back-end c \
		-build-script "sources/jamfiles/${OPEN_DYLAN_TARGET_PLATFORM}-build.jam" \
		-build dylan-compiler -verbose

	dylan-compiler \
		-jobs "${TERMUX_PKG_MAKE_PROCESSES}" \
		-back-end c \
		-build-script "sources/jamfiles/${OPEN_DYLAN_TARGET_PLATFORM}-build.jam" \
		-build dylan-tool -verbose

	find ./_build
}
