#!/bin/bash

cat -e training_data.csv | tr '^M' '\n' | grep -v '^$' > training_data.cleaned.csv
cat -e test_data.csv | tr '^M' '\n' | grep -v '^$' > test_data.cleaned.csv
