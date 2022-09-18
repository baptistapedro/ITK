FROM fuzzers/afl:2.52

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev libjpeg-dev libpng-dev libssl-dev
RUN wget https://github.com/Kitware/CMake/releases/download/v3.20.1/cmake-3.20.1.tar.gz
RUN tar xvfz cmake-3.20.1.tar.gz
WORKDIR /cmake-3.20.1
RUN ./bootstrap
RUN make
RUN make install
WORKDIR /
RUN git clone https://github.com/InsightSoftwareConsortium/ITK.git
WORKDIR /ITK
RUN mkdir ./build
WORKDIR /ITK/build
RUN cmake -DBUILD_EXAMPLES=ON -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++ ..
RUN make
RUN mkdir /itkCorpus
RUN wget https://download.samplelib.com/jpeg/sample-clouds-400x300.jpg
RUN wget https://download.samplelib.com/jpeg/sample-red-400x300.jpg
RUN wget https://download.samplelib.com/jpeg/sample-green-200x200.jpg
RUN wget https://download.samplelib.com/jpeg/sample-green-100x75.jpg
RUN mv *.jpg /itkCorpus

ENTRYPOINT ["afl-fuzz", "-i", "/itkCorpus", "-o", "/itkOut"]
CMD  ["/ITK/build/bin/RGBImage", "@@"]
