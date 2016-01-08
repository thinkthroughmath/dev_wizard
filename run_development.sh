#!/usr/bin/env bash

if [[ -e "secret_vars.sh" ]] ; then
  source secret_vars.sh
fi

export DW_GH_CALLBACK_URL="http://localhost:4000/oauth_callback"

iex -S mix phoenix.server
