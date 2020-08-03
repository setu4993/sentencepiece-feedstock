mkdir build
cd build

export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export INCLUDE=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [[ "$target_platform" == linux* ]]; then
    cmake \
        -DCMAKE_INSTALL_PREFIX=$PREFIX \
        -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
        -DCMAKE_AR="${AR}" \
        -DSPM_ENABLE_TCMALLOC=OFF \
        -S ..
fi

if [ "$(uname)" == "Darwin" ]; then
    LDFLAGS="${LDFLAGS//-pie/}"
    export CXX="clang++"
    export CC="clang"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    export LIBS="-lc++"
    export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
    export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
    export CLANG_RESOURCE_DIR="${CLANG_INSTALL_RESOURCE_DIR}/include"
    cmake \
        -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
        -DCMAKE_CXX_LINK_FLAGS="${LDFLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
        "${CMAKE_PLATFORM_FLAGS[@]}" \
        ..
fi

make -j"${CPU_COUNT}"
make install

if [[ "$target_platform" == linux* ]]; then
  ldconfig -v -N
if [ "$(uname)" == "Darwin" ]; then
  update_dyld_shared_cache
fi

cd $SRC_DIR/python
${PYTHON} setup.py build
${PYTHON} setup.py install
