#!/bin/bash

# Scarica Flutter
git clone https://github.com/flutter/flutter.git -b stable

# Aggiungi Flutter al PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# Verifica installazione
flutter --version

# Installa le dipendenze del progetto
flutter pub get

# (Facoltativo) Esegui i test
flutter test
