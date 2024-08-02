#!/bin/bash

set -e

PROTO_DIR="./proto"
JAVA_OUT_DIR="./android/app/src/main/java"
DART_OUT_DIR="./lib/messages"

if ! command -v protoc &> /dev/null; then
  echo "Error: protoc is not installed."
  exit 1
fi

if ! command -v protoc-gen-dart &> /dev/null; then
  echo "Error: protoc-gen-dart is not installed."
  echo "Run 'dart pub global activate protoc_plugin' and add ~/.pub-cache/bin to your PATH."

  read -p "Do you want to install protoc-gen-dart automatically? (yes/no): " response
  if [[ "$response" == "yes" ]]; then
    echo "Installing protoc-gen-dart..."
    dart pub global activate protoc_plugin

    echo "Adding ~/.pub-cache/bin to your PATH..."
    if ! grep -q 'export PATH="$PATH:$HOME/.pub-cache/bin"' ~/.bashrc; then
       echo "# Added by Scrobblium build tool" >> ~/.bashrc
       echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.bashrc
       echo "Added to ~/.bashrc."
    else
      echo "Path is already set in ~/.bashrc."
    fi
    if ! grep -q 'export PATH="$PATH:$HOME/.pub-cache/bin"' ~/.zshrc; then
       echo "# Added by Scrobblium build tool" >> ~/.zshrc
       echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
       echo "Added to ~/.zshrc."
    else
      echo "Path is already set in ~/.zshrc."
    fi
    export PATH="$PATH:$HOME/.pub-cache/bin"
  else
    echo "Please install protoc-gen-dart manually and add ~/.pub-cache/bin to your PATH."
    exit 1
  fi
fi


mkdir -p $JAVA_OUT_DIR
mkdir -p $DART_OUT_DIR

for proto_file in $PROTO_DIR/*.proto; do
  echo "Processing $proto_file..."

  protoc --java_out=$JAVA_OUT_DIR $proto_file
  echo "Successfully generated Java files for $proto_file"

  protoc --dart_out=$DART_OUT_DIR $proto_file
  echo "Successfully generated Dart files for $proto_file"
done

echo "All .proto files processed successfully."
