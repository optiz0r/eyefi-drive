#!/bin/bash

# Runtime interpolation of environment variables into config file
eval "cat <<<\"$(<eyefiserver.conf.example)\"" > eyefiserver.conf

# Start the daemon process
exec python eyefiserver.py

