#!/bin/sh
cd /opt/SuRVoS/SuRVoS
. ccpi/bin/activate
export LD_LIBRARY_PATH="$(pwd)/lib64:${LD_LIBRARY_PATH}"
exec SuRVos
