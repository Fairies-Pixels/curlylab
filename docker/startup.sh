#!/bin/bash

if [ $# != 1 ]
then
	cat .res/errors/invalid_arg.txt
	exit
fi

export JAVA_HOME=$1

DOCKERFILES=dockerfiles
BACKEND=curlylab-backend
GATEWAY=curlylab-api-gateway
COMPOSITION=curlylab-composition-ai
POROSITY=curlylab-hair-porosity-ai

if [ ! -f env.sh ]
then
	cat .res/errors/no_env.txt
	exit
fi

if [ ! -f swa_convnext.pt ]
then
	cat .res/errors/no_model.txt
	exit
fi

source env.sh

echo "Fetching repositories..."
echo "---[ Fetching API-Gateway Repo ]"
pushd .
if [ -d $GATEWAY ]
then
	cd $GATEWAY
	git fetch
else
	git clone https://github.com/Fairies-Pixels/curlylab-api-gateway.git $GATEWAY
	cd $GATEWAY
	chmod +x gradlew
fi
popd
echo "---[ Fetched! ]"

echo "---[ Fetching Backend Repo ]"
pushd .
if [ -d $BACKEND ]
then
	cd $BACKEND
	git fetch
else
	git clone https://github.com/Fairies-Pixels/curlylab-backend.git $BACKEND
	cd $BACKEND
	chmod +x gradlew
fi
popd
echo "---[ Fetched! ]"

echo "---[ Fetching Composition AI Service ]"
pushd .
if [ -d $COMPOSITION ]
then
	cd $COMPOSITION
	git fetch
else
	git clone https://github.com/Fairies-Pixels/curlylab-hair_ai.git -b feature/consists-check-service $COMPOSITION
fi
popd
echo "---[ Fetched! ]"

echo "---[ Fetching Hair's Porosity AI Service ]"
pushd .
if [ -d $POROSITY ]
then
	cd $POROSITY
	git fetch
else
	git clone https://github.com/Fairies-Pixels/curlylab-hair_ai.git -b feature/hair-porosity-service $POROSITY
fi
popd
echo "---[ Fetched! ]"
echo "Done!"

echo "Build applications..."
echo "---[ Build API Gateway ]"
pushd .
cd $GATEWAY
./gradlew assemble
popd
echo "---[ Built! ]"
echo "---[ Build Backend ]"
pushd .
cd $BACKEND
./gradlew assemble
popd
echo "---[ Built! ]"
echo "Done!"

echo "Load neural models..."
echo "---[ Load Hair's Porosity AI model ]"
cp swa_convnext.pt $POROSITY/models
echo "---[ Loaded ]"
echo "Done!"

echo "Dispatch Dockerfiles..."
echo "---[ Copy Dockerfile for API Gateway ]"
cp $DOCKERFILES/api-gateway/Dockerfile $GATEWAY 
echo "---[ Copied! ]"
echo "---[ Copy Dockerfile for Backend ]"
cp $DOCKERFILES/backend/Dockerfile $BACKEND
echo "---[ Copied! ]"
echo "---[ Copy Dockerfile for Composition AI ]"
cp $DOCKERFILES/composition-ai/Dockerfile $COMPOSITION
echo "---[ Copied! ]"
echo "---[ Copy Dockerfile for Hair's Porosity AI ]"
cp $DOCKERFILES/porosity-ai/Dockerfile $POROSITY
echo "---[ Copied! ]"
echo "Done!"

echo "Run Docker-Compose..."
docker-compose up -d --build
echo "Done!"
