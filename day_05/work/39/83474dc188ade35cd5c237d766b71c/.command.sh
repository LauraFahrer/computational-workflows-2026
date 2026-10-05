#!/bin/bash -ue
zip hello_world_compressed.zip hello_world_uppercase.txt
gzip -c hello_world_uppercase.txt > hello_world_compressed.gz
bzip2 -c hello_world_uppercase.txt > hello_world_compressed.bz2
