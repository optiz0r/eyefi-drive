#!/bin/bash

set -xe

SHELLNOCASEMATCH=$(shopt -p nocasematch; true)

if [ -z "${ENABLE_OCR}" ]; then
    exit 0
fi
 
DATE=$(date +"%Y-%m-%d")
EXIFDATE=$(date +"%Y:%m:%d-%H:%M:%S")

GDRIVE_ROOT="/gdrive"
GDRIVE_DIR=${GDRIVE_DIR:-eyefi/unsorted}
 
IMAGE=${1##*/}
UNPROCESSED_PATH=${1%/*}
IMAGE_PATH=/tmp/processed/${DATE}
 
WORK_PATH=/tmp/processing
PDF_PATH="${IMAGE_PATH}/OCR"
PDF=${IMAGE%.*}.pdf
OCR_PDF=${PDF%.pdf}_ocr.pdf
 
# Create the output dirs if not already
mkdir -p "${PDF_PATH}" "${WORK_PATH}" /gdrive

# Ignore case while checking file type
shopt -s nocasematch

if [[ "${IMAGE}" == *.jpg ]] || [[ "${IMAGE}" == *.jpeg ]] ; then
    # Scanner malforms the JPG files
    /usr/bin/mogrify -write "${IMAGE_PATH}/${IMAGE}" -set comment 'Extraneous bytes removed' "${UNPROCESSED_PATH}/${IMAGE}" 2>/dev/null
    
    # Update the exif timestamp to today's date, since the scanner isn't accurate
    jhead -ts"${EXIFDATE}" "${IMAGE_PATH}/${IMAGE}"
    
    # Convert to PDF
    /usr/bin/convert "${IMAGE_PATH}/${IMAGE}" "${WORK_PATH}/${PDF}"

elif [[ "${IMAGE}" == *.pdf ]] ; then
    # Already a PDF so just copy it to the working path
    cp "${UNPROCESSED_PATH}/${IMAGE}" "${WORK_PATH}/${PDF}"
fi
 
# OCR it
/usr/bin/pdfsandwich "${WORK_PATH}/${PDF}" -o "${WORK_PATH}/${OCR_PDF}" -nthreads 1 -rgb -gs /ghostscript-wrapper.sh
 
if [ ! -z "${ENABLE_GDRIVE}" ]; then
    # Push the resulting OCR'd document up to Google Drive
    mkdir -p "${GDRIVE_ROOT}/${GDRIVE_DIR}"
    cp "${WORK_PATH}/${OCR_PDF}" "${GDRIVE_ROOT}/${GDRIVE_DIR}/${PDF}"
    pushd /gdrive
    /usr/bin/drive push -no-prompt ${GDRIVE_DIR}/${PDF}
    popd
    rm "${GDRIVE_ROOT}/${GDRIVE_DIR}/${PDF}"
fi
 
# Move the unsorted PDF to the final local location
mv "${WORK_PATH}/${OCR_PDF}" "${PDF_PATH}/${PDF}"
 
# And tidy up
rm "${UNPROCESSED_PATH}/${IMAGE}" "${WORK_PATH}/${PDF}"
