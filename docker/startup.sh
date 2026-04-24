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

# This variable is used as an argumet to echo command.
FETCHED="Fetched!"
CLONED="Cloned!"
UP_TO_DATE="Up-to-date!"
LAST_STATUS=""

# This variables are used as flags to conditional building of
# kotlin applications.
BACKEND_NEEDS_BUILD=1
GATEWAY_NEEDS_BUILD=1

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

	if [ $# -eq 0 ]
	then
		LAST_STATUS=$FETCHED
	else
		GATEWAY_NEEDS_BUILD=0
		LAST_STATUS=$UP_TO_DATE
	fi
else
	git clone git@github.com:Fairies-Pixels/curlylab-api-gateway.git $GATEWAY
	cd $GATEWAY
	chmod +x gradlew
	LAST_STATUS=$CLONED
fi
popd
echo "---[ $LAST_STATUS ]"

echo "---[ Fetching Backend Repo ]"
pushd .
if [ -d $BACKEND ]
then
	cd $BACKEND
	git fetch

	if [ $# -eq 0 ]
	then
		LAST_STATUS=$FETCHED
	else
		BACKEND_NEEDS_BUILD=0
		LAST_STATUS=$UP_TO_DATE
	fi
else
	git clone git@github.com:Fairies-Pixels/curlylab-backend.git $BACKEND
	cd $BACKEND
	chmod +x gradlew
	LAST_STATUS=$CLONED
fi
popd
echo "---[ $LAST_STATUS ]"

echo "---[ Fetching Composition AI Service ]"
pushd .
if [ -d $COMPOSITION ]
then
	cd $COMPOSITION
	git fetch

	if [ $# -eq 0 ]
	then
		LAST_STATUS=$FETCHED
	else
		LAST_STATUS=$UP_TO_DATE
	fi
else
	git clone git@github.com:Fairies-Pixels/curlylab-hair_ai.git -b feature/consists-check-service $COMPOSITION
	LAST_STATUS=$CLONED
fi
popd
echo "---[ $LAST_STATUS ]"

echo "---[ Fetching Hair's Porosity AI Service ]"
pushd .
if [ -d $POROSITY ]
then
	cd $POROSITY
	git fetch

	if [ $# -eq 0 ]
	then
		LAST_STATUS=$FETCHED
	else
		LAST_STATUS=$UP_TO_DATE
	fi
else
	git clone git@github.com:Fairies-Pixels/curlylab-hair_ai.git -b feature/hair-porosity-service $POROSITY
	LAST_STATUS=$CLONED
fi
popd
echo "---[ $LAST_STATUS ]"
echo "Done!"

echo "Build applications..."
echo "---[ Build API Gateway ]"
if [ $GATEWAY_NEEDS_BUILD -eq 1 ]
then
	pushd .
	cd $GATEWAY
	./gradlew assemble
	popd
fi
echo "---[ Built! ]"
echo "---[ Build Backend ]"
if [ $BACKEND_NEEDS_BUILD -eq 1 ]
then
	pushd .
	cd $BACKEND
	./gradlew assemble
	popd
fi
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
