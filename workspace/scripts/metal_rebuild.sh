#!/usr/bin/env bash

TT_METAL_HOME="/workspace/pytorch2.0_ttnn/torch_ttnn/cpp_extension/third-party/tt-metal"

set -euo pipefail

cd "${TT_METAL_HOME}"

./build_metal.sh

./create_venv.sh

cd "${TT_METAL_HOME}/venv"

source bin/activate


# cd /workspace/pytorch2.0_ttnn
# python setup.py develop
