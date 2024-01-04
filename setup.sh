#!/bin/bash

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump | gzip`
set -o pipefail

CONDA_VERSION=py311_23.10.0-1
PYTHON_VERSION=3.12.0
POETRY_VERSION=1.7.1
PYTHON_VIRTUALENV=myenv

if [ "$(uname)" == "Darwin" ]; then
    SYSTEM="MacOSX"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    SYSTEM="Linux"
else
    echo "Unsupported OS. Only Linux and MacOS are supported."
    exit 1
fi
ARCH=$(uname -m)
ENVIRONMENT="environment-${SYSTEM}-${ARCH}-${CONDA_VERSION}-${POETRY_VERSION}.yml"

function install_dependencies() {
    if [ "$EUID" -ne 0 ]; then
        SUDO=sudo
    else
        SUDO=""
    fi

    if [ "${SYSTEM}" == "Linux" ]; then
        ${SUDO} apt update && ${SUDO} apt install -y curl build-essential
    fi
}

function install_conda() {
    if ! [ $(command -v conda) ]; then
        echo "Installing Conda ${CONDA_VERSION}"

        CONDA_SCRIPT="Miniconda3-${CONDA_VERSION}-${SYSTEM}-${ARCH}.sh"
        curl https://repo.anaconda.com/miniconda/${CONDA_SCRIPT} -o /tmp/${CONDA_SCRIPT}
        chmod +x /tmp/${CONDA_SCRIPT}
        /tmp/${CONDA_SCRIPT}

        export PATH=${PATH}:${HOME}/miniconda3/bin

        conda config --set auto_activate_base false

        SHELL_TYPE=$(echo "${SHELL}" | sed 's/^.*\///g')
        conda init ${SHELL_TYPE}
    fi
}

function create_virtualenv_from_environment() {
    echo "Creating virtual environment from existing environment file"
    conda env create -n ${PYTHON_VIRTUALENV} -f ${ENVIRONMENT}
}

function create_virtualenv() {
    echo "Creating new virtual environment for python ${PYTHON_VERSION}"

    conda create -y -n ${PYTHON_VIRTUALENV} python=${PYTHON_VERSION}
    conda install -y -n ${PYTHON_VIRTUALENV} -c conda-forge poetry=${POETRY_VERSION}
    conda env export -n ${PYTHON_VIRTUALENV} | grep -v "^prefix: " > ${ENVIRONMENT}
}

### Script start
install_dependencies
install_conda

# Check if the virtual environment already exist
EXISTING_ENVS="$(conda env list)"
MATCHED_ENV=$(grep "${PYTHON_VIRTUALENV}" <<<"${EXISTING_ENVS}" || true)
if [ -z "${MATCHED_ENV}" ]; then
    echo "Creating virtual environemnt"
    if test -f ${ENVIRONMENT}; then
        create_virtualenv_from_environment
    else
        create_virtualenv
    fi
else
    echo "Virtual environment already exists"
fi

echo "
===============================================================================
CONGRUTULATIONS!!
You completed the setup of Conda.

Before continuoing please REFRESH your shell to load the updated environment!
===============================================================================
"
