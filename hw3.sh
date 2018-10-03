#!/bin/sh
flex dillonm.l
bison dillonm.y
g++ dillonm.tab.c -o mipl_parser
