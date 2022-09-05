#!/bin/sh
dart main.dart
fswatch -o ./ | xargs -n1 -I{} dart main.dart