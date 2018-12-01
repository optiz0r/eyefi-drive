FROM ubuntu:18.04

EXPOSE 59278

RUN mkdir -p /tmp/eyefiserver && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends software-properties-common dirmngr && \
    apt-get update -y && \
    add-apt-repository ppa:twodopeshaggy/drive && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 822B68845525C0F9BD1D6F826B880C4CE122E8FC && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends python2.7 python-setuptools python-pip drive imagemagick jhead exactimage pdfsandwich && \
    rm -rf /var/lib/apt/lists/* && \
    pip install flickr_api

# Update ImageMagick policy to allow modifying PDF documents
RUN sed -i -e '/pattern="PDF"/ s/rights="none"/rights="read|write"/' /etc/ImageMagick-6/policy.xml

ADD start-eyefiserver.sh .
ADD eyefiserver.py .
ADD flickr.verifier .
ADD eyefiserver.conf.example .
ADD ocr.sh .
ADD ghostscript-wrapper.sh .

ENTRYPOINT [ "bash", "start-eyefiserver.sh" ]
