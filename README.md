# eyefi-drive

Docker container to scan and upload documents from an eyefi scanner to google drive.

The EyeFi card will do a network scan to find a listening server, so this
container must be running on a machine connected to the same network as the
EyeFi card.

## Prerequisites

You will need your EyeFi card's MAC address and upload key to use this. One way of
finding them is described here:
http://1wayofdoingit.blogspot.com/2017/12/how-to-get-your-eyefi-upload-key-and.html

## Usage

* Pull the image

        docker pull optiz0r/eyefi-drive:latest

* Run the container

        docker run --rm \
            -v /data/eyefi-drive/gdrive:/gdrive \
            -v /data/eyefi-drive/unprocessed:/tmp/eyefiserver \
            -v /data/eyefi-drive/processed:/tmp/processed \
            -e UPLOAD_KEY=myuploadkey \
            -e MAC_ADDRESS=001122334455 \
            -e ENABLE_OCR=1 \
            -e ENABLE_GDRIVE=1 \
            -e GDRIVE_DIR="eyefi/unsorted" \
            -p 59278:59278/tcp \
            --name eyefi-drive \
            optiz0r/eyefi-drive:latest:latest

* Initialise the Google Drive credentials (required on the first run only)
  * Obtain a shell inside the container and run the init command

        docker exec -ti eyefi-drive bash
        cd /gdrive
        drive init

  * Paste the URL you are given into a browser and login where prompted
  * Copy and paste the authorization token back into the prompt
  * Exit the terminal with `ctrl-D`

## Volumes

* `/gdrive` - Cache for the Google Drive mirrored root directory
  This path also contains your OAuth credentials 
* `/tmp/processed` - Directory under which copies of the scanned
  documents, and the OCR-processed copies will be stored to.
* `/tmp/eyefiserver` (optional)- Directory into which scanned documents are stored
  while they are being processed.

## Ports

* `59278` - The EyeFi card is hardcoded to use this port number and
  so this should not be changed

## Environment Variables

* `MAC_ADDRESS` - The MAC address of your EyeFi card without punctuation symbols
  (should be 12 hexadecimal digits)
* `UPLOAD_KEY` - The upload key for your EyeFi card
* `ENABLE_OCR` - Runs OCR to extract the text from the scan and re-embeds it into
  the PDF so that the document is searchable. Set to a non-empty string to enable.
* `ENABLE_GDRIVE` - Enables uploading the processed document to Google Drive.
  Requires that `ENABLE_OCR` is also enabled. Set to a non-empty string to enable.
* `GDRIVE_DIR` - Path relative to the root of the Google Drive root where processed
  documents should be uploaded to.

## References

This project is derieved from multiple sources including:
  - [sbm44/eyefi-docker](https://github.com/sbma44/eyefi-docker)
  - [dgrant/eyefiserver2](https://github.com/dgrant/eyefiserver2)
  - [eyefiserver Ubuntu package](https://launchpad.net/ubuntu/cosmic/+package/eyefiserver)
  - [Going Paperless](https://blog.benroberts.net/2016/01/going-paperless/)

