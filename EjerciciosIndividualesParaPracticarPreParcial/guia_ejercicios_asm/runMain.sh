#!/usr/bin/env bash
reset

make main
if [ $? -ne 0 ]; then
  echo "ERROR: Error de compilacion."
  exit 1
fi

