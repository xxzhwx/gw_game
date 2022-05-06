#!/bin/sh

cd proto
protoc -o../all.bytes *.proto

cd ..
python genProtoId.py --output=message_define.bytes ./proto/*.proto

cp all.bytes message_define.bytes ../../logic/proto/protobuf/
