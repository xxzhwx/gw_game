#!/bin/sh

cd proto
protoc -o../all.bytes *.proto

cd ..
python genProtoId.py --output=message_define.bytes ./proto/*.proto
