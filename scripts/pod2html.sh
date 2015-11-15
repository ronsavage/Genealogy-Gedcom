#!/bin/bash

# My web server's doc root is $DR = /dev/shm/html.
# For non-Debian user's, /run/shm is the built-in RAM disk.

PREFIX=Perl-modules/html/Genealogy/Gedcom

mkdir -p $DR/$PREFIX/Reader
mkdir -p ~/savage.net.au/$PREFIX/Reader

pod2html.pl -i lib/Genealogy/Gedcom.pm              -o $DR/$PREFIX.html
pod2html.pl -i lib/Genealogy/Gedcom/Reader.pm       -o $DR/$PREFIX/Reader.html
pod2html.pl -i lib/Genealogy/Gedcom/Reader/Lexer.pm -o $DR/$PREFIX/Reader/Lexer.html

cp -r $DR/$PREFIX ~/savage.net.au/$PREFIX
