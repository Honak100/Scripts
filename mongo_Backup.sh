#!/bin/bash

TODATE=$(TZ=Asia/Kolkata date  "+%Y-%m-%d-%H-%M");

SERDIR="/Honak/BookMyFarm"
DESDIR="/home/revolution/Honak"
CONTAINER="mongo_mongo_1"
TAR="$DESDIR/BookMyFarm"
DIR="/home/revolution/Honak/script/Mondo_Backup"

cd $DIR

docker cp -L $CONTAINER:./$SERDIR $DESDIR

tar -cvzf BookMyFarm-$TODATE.tar.gz $TAR