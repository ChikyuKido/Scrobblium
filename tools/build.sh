#!/bin/bash

set -e

flutter clean
flutter build apk --split-per-abi
flutter build apk

cd build/app/outputs/flutter-apk
for file in *app*; do
    mv "$file" "${file//app/Scrobblium}"
done