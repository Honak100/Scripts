#!/bin/bash

DIRECTORY="/home/revolution/Honak/minio"

aws s3 sync $DIRECTORY s3://minio --endpoint-url=http://s3.eu-cental-1.wasabisys.com --region=eu-cental-1