#!/bin/bash -l

BASEDIR=$(dirname $0)
PROJDIR=$(dirname $BASEDIR)
RUBYVER=`cat "${PROJDIR}/.ruby-version"`

cd $PROJDIR # Make RVM not to move .ruby-version

if type rvm >/dev/null 2>&1; then
  if ! rvm use $RUBYVER; then
   echo "Installing $RUBYVER with patches for GOST (RVM)"
   rvm install $RUBYVER --patch https://bugs.ruby-lang.org/attachments/download/4420/respect_system_openssl_settings.patch --patch https://bugs.ruby-lang.org/attachments/download/4415/gost_keys_support_draft.patch
  fi
elif type rbenv >/dev/null 2>&1; then
  if ! rbenv shell $RUBYVER; then
    echo "Installing $RUBYVER with patches for GOST (Rbenv)"
    cat "${BASEDIR}/enable_gost.patch" | rbenv install "${BASEDIR}/${RUBYVER}" --patch
  fi
else
  echo "Please install GOST-enabled Ruby manually"
fi
