#!/bin/bash

# utilisateur
# Si besoin à remplacer le nom de l'utilisateur docker final
DOCKER_USER=jeromeklam
DOCKER_PASSWORD=password
DOCKER_REGISTRY=registry

# Chemin courant = real_path
ROOT_DIR=$(dirname dir)

# Nom du container
NAME=u20_apache

# Id, ... de docker
RUNNING=$(docker ps | grep ${NAME} | cut -f 1 -d ' ')
ALL=$(docker ps -a | grep ${NAME} | cut -f 1 -d ' ')

# Préparation
function prepare()
{
  if [ ! -d ${ROOT_DIR}/docker-logs ]; then
    mkdir ${ROOT_DIR}/docker-logs
  fi
}

# Nettoyage complet
function deepclean()
{
  # Arrêt
  if [[ "X${RUNNING}" != "X" ]]; then
    docker stop "${RUNNING}"
  fi
  if [[ "X${ALL}" != "X" ]]; then
    docker rm "${ALL}" --force
  fi
  # Nettoyage répertoires et fichiers
  rm -rf $ROOT_DIR/docker-logs
}

# Génération
function build()
{
  docker build -t="${DOCKER_USER}/${NAME}" .
}

# Exécution
function run()
{
  docker run -d -p 8080:8080 --name="${NAME}" ${DOCKER_USER}/${NAME}
}

# Bash for windows
function wbash()
{
  winpty docker run -t -i --name="${NAME}" ${DOCKER_USER}/${NAME} //bin/bash
}

# Bash
function bash()
{
  docker run -t -i -p 8080:8080 --name="${NAME}" ${DOCKER_USER}/${NAME} /bin/bash
}

# Push to registry
function push()
{ 
  docker login -u $DOCKER_USER -p $DOCKER_PASSWORD ${DOCKER_REGISTRY}
  docker tag $(docker images -q ${DOCKER_USER}/${NAME}) ${DOCKER_REGISTRY}/${NAME}
  docker push ${DOCKER_REGISTRY}/${NAME}
  docker rmi --force $(docker images -q ${DOCKER_USER}/${NAME})
}

# usage
function usage()
{
  echo "$0 : Gestion du conteneur"
  echo ""
  echo "Options"
  echo "   bash : pour se connecter en ligne de commande"
  echo "   build : pour générer le conteneur"
  echo "   clean : pour nettoyer le répertoire"
  echo "   push : pour faire un push sur $DOCKER_REGISTRY"
  echo "   run : pour lancer le conteneur"
  echo "   wbash : pour se connecter en ligne de commande avec winpty"
  echo ""
}

# MAIN
case $# in
  1)
    case $1 in
      "bash")
        deepclean
        bash
        ;;
	  "wbash")
        deepclean
        wbash
        ;;
      "build")
        deepclean
        build
        ;;
      "clean")
        deepclean
        ;;
      "run")
        deepclean
        run
        ;;
	  "push")
        deepclean
        build
        push
        ;;
      *)
        usage
        ;;
    esac
    ;;
  *)
    usage
    ;;
esac
