#! /bin/bash
set -e

repo=$1
commit=$2
toolchain=$3
target_host=$4
bits=$5

if [ -d "projectcoin" ]; then
    # Control will enter here if $DIRECTORY exists.
    echo "clean up projectcoin folder ... .. ."
    rm -r projectcoin
    sleep 2s
fi

echo "cloning fresh repo ... ... .. . . ."
git clone $repo projectcoin
cd projectcoin
#git checkout $commit
sleep 2s

echo "copy new default.mk"
rm depends/hosts/default.mk
cp /repo/default.mk depends/hosts/
sleep 2s

patch -p1 < /repo/0001-android-patches.patch
sleep 5s

export PATH=/opt/$toolchain/bin:${PATH}
export AR=$target_host-ar
export AS=$target_host-clang
export CC=$target_host-clang
export CXX=$target_host-clang++
export LD=$target_host-ld
export STRIP=$target_host-strip
export LDFLAGS="-pie -static-libstdc++"

num_jobs=4
if [ -f /proc/cpuinfo ]; then
    num_jobs=$(grep ^processor /proc/cpuinfo | wc -l)
fi
cd depends
make HOST=$target_host NO_QT=1 -j $num_jobs

cd ..

./autogen.sh
./configure --prefix=$PWD/depends/$target_host ac_cv_c_bigendian=no ac_cv_sys_file_offset_bits=$bits --disable-bench --enable-experimental-asm --disable-tests --disable-man --without-utils --without-libs --with-daemon

make -j $num_jobs
make install

$STRIP depends/$target_host/bin/projectcoind

repo_name=$(basename $(dirname ${repo}))

tar -zcf /repo/${target_host}_${repo_name}.tar.gz -C depends/$target_host/bin projectcoind

echo "we start cleaning in 10 seconds..."
sleep 10s
make clean
