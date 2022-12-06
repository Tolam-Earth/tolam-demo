#!/bin/bash

# Copyright 2022 Tolam Earth
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#  

# clone all repos if they do not exist
# otherwise update them

set -e
REPOS=(
  "marketplace-build"
  "integration-services"
  "armm-services"
  "armm-data-engineering"
#optional  
#  "integration-smart-contracts"
#  "e2e-testing"
)
GITHUB_ROOT_URL="git@github.com:Tolam-Earth"

for repo in "${REPOS[@]}"
do
   echo "Checking for existence of ${repo}..."
   if [ -d "${repo}" ]
   then
     echo "${repo} exists. Updating..."
     pushd "${repo}"
     git pull
     popd
   else
     echo "${repo} does not exist. Cloning..."
     git clone -b demo "${GITHUB_ROOT_URL}/${repo}.git"
   fi
done

echo "done!"