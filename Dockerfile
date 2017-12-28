FROM ubuntu:16.04

RUN apt update && apt install -y build-essential wget git cmake \
   && rm -rf /var/lib/apt/lists/*

RUN wget -q http://releases.llvm.org/5.0.0/clang+llvm-5.0.0-linux-x86_64-ubuntu16.04.tar.xz \
   && mkdir clang_5.0.0 \
   && tar xf clang+llvm-5.0.0-linux-x86_64-ubuntu16.04.tar.xz -C clang_5.0.0 --strip-components=1 \
   && rm clang+llvm-5.0.0-linux-x86_64-ubuntu16.04.tar.xz

ENV PATH="/clang_5.0.0/bin:${PATH}"
ENV LD_LIBRARY_PATH="/clang_5.0.0/lib:/usr/local/lib:${LD_LIBRARY_PATH}"

RUN wget -q https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_66_0.tar.gz \
   && tar xf boost_1_66_0.tar.gz && rm boost_1_66_0.tar.gz \
   && cd boost_1_66_0 \
   && ./bootstrap.sh --prefix=/usr/local --with-libraries=program_options \
   && ./b2 toolset=clang cxxflags="-std=c++17 -stdlib=libc++" linkflags="-std=c++17 -stdlib=libc++" install \
   && cd .. && rm -rf boost_1_66_0

RUN git clone -b release-0.5.3-c++17 https://github.com/ml85/yaml-cpp \
   && cd yaml-cpp && mkdir build && cd build \
   && cmake .. -DCMAKE_C_COMPILER="clang" -DCMAKE_CXX_COMPILER="clang++" -DCMAKE_CXX_FLAGS="-std=c++17 -stdlib=libc++" -DCMAKE_EXE_LINKER_FLAGS="-stdlib=libc++" \
   && make \
   && make install \
   && cd ../../ && rm -rf yaml-cpp


# Start from a Bash prompt
CMD [ "/bin/bash" ]
