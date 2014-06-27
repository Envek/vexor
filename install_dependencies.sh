#!/bin/sh

rvm use 2.1.1-gost || echo "Installing Ruby with patches for GOST" && rvm install 2.1.1-gost --patch https://bugs.ruby-lang.org/attachments/download/4420/respect_system_openssl_settings.patch --patch https://bugs.ruby-lang.org/attachments/download/4415/gost_keys_support_draft.patch
