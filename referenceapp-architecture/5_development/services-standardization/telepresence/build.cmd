@echo off

if "%1" == "" (
  echo Usage : build AWS_PROFILE
  exit /B -1
)

if not exist %HOMEDRIVE%%HOMEPATH%/.aws/credentials (
  echo file not found [%HOMEDRIVE%%HOMEPATH%\.aws\credentials]
  exit /B -1
)

if not exist %HOMEPATH%/.aws/config (
  echo file not found [%HOMEDRIVE%%HOMEPATH%\.aws\config]
  exit /B -1
)

if not exist %HOMEPATH%/.kube/config (
  echo file not found [%HOMEDRIVE%%HOMEPATH%\.kube\config]
  exit /B -1
)

mkdir ".aws"
mkdir ".kube"
COPY "%HOMEDRIVE%%HOMEPATH%/.aws" ".aws/"
COPY "%HOMEDRIVE%%HOMEPATH%/.kube"  ".kube/"

docker build --build-arg AWS_PROFILE=%1 . -t telepresence

rd /q /s ".aws"
rd /q /s ".kube"
