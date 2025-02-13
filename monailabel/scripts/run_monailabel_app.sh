#!/usr/bin/env bash
set -e

app_dir=$1
study_dir=$2
method=$3
request=$4
output=$5

if [[ "${app_dir}" == "" ]]; then
  exit 1
fi

echo "Virtual Env: $VIRTUAL_ENV"

PYEXE=python
version=$(python --version)
if echo "$version" | grep "Python 2"; then
  echo "Trying python3 instead of python ($version)"
  PYEXE=python3
fi

echo "USING PYTHON: $(which ${PYEXE})"

if test -f "${app_dir}/requirements.txt"; then
  user_packages=$(sed '/^\s*#/d;/^\s*$/d' <"${app_dir}/requirements.txt" | wc -l)
  if [[ ${user_packages} == 0 ]]; then
    echo "No need to install anything..."
  else
    if test ! -d "${app_dir}/.venv"; then
      ${PYEXE} -m venv --system-site-packages "${app_dir}/.venv"
      source "${app_dir}/.venv/bin/activate"

      BASE_REQ="${DIR}/../../requirements.txt"
      if test -f "${BASE_REQ}"; then
        echo "+++++++++++++++++ Installing Base requirements"
        ${PYEXE} -m pip install -r "${BASE_REQ}" >/dev/null
      fi
    else
      source "${app_dir}/.venv/bin/activate"
    fi

    # always ensure the user packages are up to date
    ${PYEXE} -m pip install --upgrade pip >/dev/null

    echo "+++++++++++++++++ Installing PIP requirements"
    echo "App:: Virtual Env: $VIRTUAL_ENV"

    ${PYEXE} -m pip install -r "${app_dir}/requirements.txt"
    if [[ $? -ne 0 ]]; then
      echo "Failed to initialize APP venv"
      exit 1
    fi
  fi
fi

echo "Using PYTHONPATH:: ${PYTHONPATH}"
if [[ -z "$output" ]]; then
  ${PYEXE} -m monailabel.utils.others.app_utils -a "$app_dir" -s "$study_dir" -m "$method" -r "$request"
else
  ${PYEXE} -m monailabel.utils.others.app_utils -a "$app_dir" -s "$study_dir" -m "$method" -r "$request" -o "$output"
fi
