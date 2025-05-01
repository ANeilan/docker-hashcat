FROM ubuntu:24.04

RUN apt-get update && apt-get install -y clinfo wget

# Taken from https://github.com/intel/compute-runtime/releases
# last packages shown to work w/ hashcat on Intel UHD Graphics 620
RUN wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.13822.6/intel-igc-core_1.0.13822.6_amd64.deb
RUN wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.13822.6/intel-igc-opencl_1.0.13822.6_amd64.deb
RUN wget https://github.com/intel/compute-runtime/releases/download/23.17.26241.22/intel-level-zero-gpu_1.3.26241.22_amd64.deb
RUN wget https://github.com/intel/compute-runtime/releases/download/23.17.26241.22/intel-opencl-icd_23.17.26241.22_amd64.deb
RUN wget https://github.com/intel/compute-runtime/releases/download/23.17.26241.22/libigdgmm12_22.3.0_amd64.deb

# uncomment the lines below to get the latest version of Intel OpenCL as of 2025-05-01
#RUN wget https://github.com/intel/intel-graphics-compiler/releases/download/v2.10.8/intel-igc-core-2_2.10.8+18926_amd64.deb
#RUN wget https://github.com/intel/intel-graphics-compiler/releases/download/v2.10.8/intel-igc-opencl-2_2.10.8+18926_amd64.deb
#RUN wget https://github.com/intel/compute-runtime/releases/download/25.13.33276.16/intel-level-zero-gpu_1.6.33276.16_amd64.deb
#RUN wget https://github.com/intel/compute-runtime/releases/download/25.13.33276.16/intel-opencl-icd_25.13.33276.16_amd64.deb
#RUN wget https://github.com/intel/compute-runtime/releases/download/25.13.33276.16/libigdgmm12_22.7.0_amd64.deb

# uncomment the lines below to get the latest version of legacy branch Intel OpenCL
#RUN wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17537.20/intel-igc-core_1.0.17537.20_amd64.deb
#RUN wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17537.20/intel-igc-opencl_1.0.17537.20_amd64.deb
#RUN wget https://github.com/intel/compute-runtime/releases/download/24.35.30872.22/intel-level-zero-gpu-legacy1_1.3.30872.22_amd64.deb
#RUN wget https://github.com/intel/compute-runtime/releases/download/24.35.30872.22/intel-opencl-icd-legacy1_24.35.30872.22_amd64.deb
#RUN wget https://github.com/intel/compute-runtime/releases/download/24.35.30872.22/libigdgmm12_22.5.0_amd64.deb

RUN dpkg -i *.deb && rm *.deb

LABEL maintainer="Danylo Ulianych"


ENV HASHCAT_VERSION="master"
ENV HASHCAT_UTILS_VERSION="master"
ENV HCXTOOLS_VERSION="6.3.5"
ENV HCXDUMPTOOL_VERSION="6.3.5"
ENV HCXKEYS_VERSION="master"

# Update & install packages for installing hashcat
RUN apt-get update && \
    apt-get install -y wget make clinfo build-essential git libcurl4-openssl-dev libssl-dev zlib1g-dev libcurl4-openssl-dev libssl-dev pkg-config pciutils libpcap0.8-dev
RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Fetch PCI IDs list to display proper GPU names
RUN update-pciids

WORKDIR /root

RUN git clone https://github.com/hashcat/hashcat.git && cd hashcat && git checkout ${HASHCAT_VERSION} && make install -j4

RUN git clone https://github.com/hashcat/hashcat-utils.git && cd hashcat-utils/src && git checkout ${HASHCAT_UTILS_VERSION} && make
RUN ln -s /root/hashcat-utils/src/cap2hccapx.bin /usr/bin/cap2hccapx

RUN git clone https://github.com/ZerBea/hcxtools.git && cd hcxtools && git checkout ${HCXTOOLS_VERSION} && make install

RUN git clone https://github.com/ZerBea/hcxdumptool.git && cd hcxdumptool && git checkout ${HCXDUMPTOOL_VERSION} && make install

RUN git clone https://github.com/hashcat/kwprocessor.git && cd kwprocessor && git checkout ${HCXKEYS_VERSION} && make
RUN ln -s /root/kwprocessor/kwp /usr/bin/kwp
