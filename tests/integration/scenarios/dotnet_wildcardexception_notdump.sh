#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
PROCDUMPPATH=$(readlink -m "$DIR/../../../bin/procdump");
TESTWEBAPIPATH=$(readlink -m "$DIR/../TestWebApi");

pushd .
cd $TESTWEBAPIPATH
dotnet run --urls=http://localhost:5032&
TESTPID=$!
sleep 10s
sudo $PROCDUMPPATH -e -f on*Existing TestWebApi testdump&
sleep 5s
wget http://localhost:5032/throwinvalidoperation
sleep 5s
sudo pkill -9 procdump
if [ -f "testdump_0" ]; then
    rm -rf testdump_0
    sudo pkill -9 TestWebApi
    popd
    exit 1
else
    popd

    #check to make sure profiler so is unloaded
    PROF="$(cat /proc/${TESTPID}/maps | awk '{print $6}' | grep '\procdumpprofiler.so' | uniq)"
    pkill -9 TestWebApi
    if [[ "$PROF" == "procdumpprofiler.so" ]]; then
        exit 1
    else
        exit 0
    fi
fi
