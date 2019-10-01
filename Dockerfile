# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-18.04
# Minimal TERM Is required
ENV TERM xterm
# It has to be made non interactive for the apt-get and add-pkg to say yes to licenses and confirmations.
ENV DEBIAN_FRONTEND noninteractive
# Build requirements
RUN add-pkg xterm wget build-essential gcc git && mkdir /opt/SuRVoS && cd /opt/SuRVoS
WORKDIR /opt/SuRVoS
RUN add-pkg -y software-properties-common gnupg1 dirmngr gpg-agent && \
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub && \
add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /" && apt-get update -y && add-pkg cuda
# Install anaconda
RUN wget https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh && bash Anaconda3-2019.07-Linux-x86_64.sh -b -p /usr/local/conda
#Cuda installed above with add-pkg
ENV PATH="/usr/local/conda/bin/:/usr/local/cuda/bin/:${PATH}"

RUN cd /opt/SuRVoS && git clone https://github.com/DiamondLightSource/SuRVoS.git && cd SuRVoS

WORKDIR /opt/SuRVoS/SuRVoS

ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
RUN cd /opt/SuRVoS/SuRVoS && python -m venv ccpi && . ccpi/bin/activate && \
pip install cmake cython numpy scipy matplotlib h5py pyqt5==5.8.2 tifffile networkx scikit-image scikit-learn seaborn && \
cmake -G "Unix Makefiles" -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${VIRTUAL_ENV}" -DINSTALL_BIN_DIR="${VIRTUAL_ENV}/bin" -DINSTALL_LIB_DIR="${VIRTUAL_ENV}/lib64" survos/lib/src && \
make && \
make install && python setup.py build && python setup.py install &&  export LD_LIBRARY_PATH=${VIRTUAL_ENV}/lib64:${LD_LIBRARY_PATH}
# Copy the start script.
COPY startapp.sh /startapp.sh
# Set the name of the application.
ENV APP_NAME="SuRVoS"
#RUN del-pkg xterm wget build-essential gcc git
#RUN del-pkg software-properties-common gnupg1 dirmngr gpg-agent
