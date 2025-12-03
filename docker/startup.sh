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

echo "Fetching repositories..."
echo "---[ Fetching API-Gateway Repo ]"
git clone https://github.com/Fairies-Pixels/curlylab-api-gateway.git $GATEWAY
echo "---[ Fetched! ]"
echo "---[ Fetching Backend Repo ]"
git clone https://github.com/Fairies-Pixels/curlylab-backend.git $BACKEND
echo "---[ Fetched! ]"
echo "---[ Fetching Composition AI Service ]"
git clone https://github.com/Fairies-Pixels/curlylab-hair_ai.git -b feature/consists-check-service $COMPOSITION
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
echo "Done!"

echo "Run Docker-Compose..."
docker-compose up -d --build
echo "Done!"
