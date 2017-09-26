#!/bin/bash
gpg --export-secret-subkeys --export-options export-reset-subkey-passwd -a 0DBB3AFE |vagrant ssh -c 'HOME=/root sudo gpg --import'
