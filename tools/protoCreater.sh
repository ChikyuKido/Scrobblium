#!/bin/bash


PROTO_DIR="./proto"
JAVA_OUT_DIR="./android/app/src/main/java"
DART_OUT_DIR="./lib/messages"


mkdir -p $JAVA_OUT_DIR
mkdir -p $DART_OUT_DIR


for proto_file in $PROTO_DIR/*.proto; do
  echo "Processing $proto_file..."


  protoc --java_out=$JAVA_OUT_DIR $proto_file
  if [ $? -ne 0 ]; then
    echo "Error generating Java files for $proto_file"
    exit 1
  fi

  protoc --dart_out=$DART_OUT_DIR $proto_file
  if [ $? -ne 0 ]; then
    echo "Error generating Dart files for $proto_file"
    exit 1
  fi

  echo "Successfully processed $proto_file"
done

echo "All .proto files processed successfully."
