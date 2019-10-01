# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-18.04
# Minimal TERM Is required
ENV TERM xterm
# It has to be made non interactive for the apt-get and add-pkg to say yes to licenses and confirmations.
ENV DEBIAN_FRONTEND noninteractive
# Build requirements
RUN add-pkg xterm wget build-essential gcc git && mkdir /opt/SuRVoS && cd /opt/SuRVoS
WORKDIR /opt/SuRVoS
RUN add-pkg -y software-properties-common gnupg1 dirmngr gpg-agent
# This key is required to add repository - next
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
#RUN dpkg -i cuda-repo-ubuntu1804-10-1-local-10.1.243-418.87.00_1.0-1_amd64.deb
RUN add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /"
#RUN apt-key add /var/cuda-repo-10-1-local-10.1.243-418.87.00/7fa2af80.pub
#install cuda from rerpository
RUN apt-get update -y && add-pkg cuda
# Install anaconda
RUN wget https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh
RUN bash Anaconda3-2019.07-Linux-x86_64.sh -b -p /usr/local/conda
#Cuda installed above with add-pkg
#RUN sh /opt/cuda/cuda.run --silent
ENV PATH="/usr/local/conda/bin/:/usr/local/cuda/bin/:${PATH}"
#RUN echo $PATH && ls -lrt /usr/local/conda/bin
#RUN conda install -c conda-forge -c numba -c ccpi survos
RUN cd /opt/SuRVoS && git clone https://github.com/DiamondLightSource/SuRVoS.git && cd SuRVoS
#RUN conda create -n ccpi python=3.6 && source activate ccpi
WORKDIR /opt/SuRVoS/SuRVoS
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
RUN cd /opt/SuRVoS/SuRVoS && python -m venv ccpi && . ccpi/bin/activate
RUN pip install cmake cython numpy scipy matplotlib h5py pyqt5==5.8.2 tifffile networkx scikit-image scikit-learn seaborn
RUN cmake -G "Unix Makefiles" -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${VIRTUAL_ENV}" -DINSTALL_BIN_DIR="${VIRTUAL_ENV}/bin" -DINSTALL_LIB_DIR="${VIRTUAL_ENV}/lib64" survos/lib/src
RUN make
RUN make install
RUN python setup.py build
RUN python setup.py install 
RUN export LD_LIBRARY_PATH=${VIRTUAL_ENV}/lib64:${LD_LIBRARY_PATH}
#ENV LD_LIBRARY_PATH="${VIRTUAL_ENV}/lib64:${LD_LIBRARY_PATH}"
RUN echo $LD_LIBRARY_PATH
#RUN conda create -n ccpi python=3.6 && source activate ccpi
# Copy the start script.
COPY startapp.sh /startapp.sh
# Set the name of the application.
ENV APP_NAME="SuRVoS"
#RUN del-pkg xterm wget build-essential gcc git
#RUN del-pkg software-properties-common gnupg1 dirmngr gpg-agent
