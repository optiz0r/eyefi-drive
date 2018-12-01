#!/bin/bash
if [ "$7" == "-dPDFFitPage" ]; then
 echo "Faking call to gs to preserve working search"
 cp -- "${@:(-1):1}" "${@:(-2):1}"
elif [ "${5%=*}" == "-sOutputFile" ]; then
 OUT=${5#-sOutputFile=}
 echo "Faking call to gs to preserve working search, copying $6 to $OUT"
 cp $6 $OUT
else
 exec /usr/bin/gs $*
fi
