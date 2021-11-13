#!/bin/bash

function modoUso() {
  echo "-------------------------------------------------------------------------"
  echo "|    *Este scrip genera un access point ihalambrico. Cada 5 segundos    |"
  echo "|    *Despliega las personas conocidas que se encuentran conectadas,    |"
  echo "|     si la persona no es Conocida depliega Desconocido: mac address    |"
  echo "|                                                                       |"
  echo "|                 EJECUTA CON PERMISOS DE SUPERUSUARIO                  |"
  echo "|   -s = sin contraseña                                                                   |"
  echo "|   Parametro 1=SSID, que desea para su red                             |"
  echo "|   Parametro 2=Contraseña, que desea para su red                       |"
  echo "|   Parametro 3=Archivo, con direccion macs de conocidos                |"
  echo "|             (formato= MACK,Nombre)                                    |"
  echo "-------------------------------------------------------------------------"
}

while getopts ":s" opt; do
    case $opt in
    s)
        opcionS="1"
        echo "";
        ;;
    "?")
        echo "Opción inválida -$OPTARG";
        modoUso;
        exit 1;
        ;;
    :)
        echo "Se esperaba un parámetro en -$OPTARG";
        modoUso;
        exit 1;
        ;;
    esac
done

shift $((OPTIND-1))


for interface in $(sudo ifconfig | grep -oP "^[a-zA-Z0-9]+(?=:*)");do
  inter="$interface"
done

function validar() {
  [[ "$3" ]] || { echo "Se necesita pasar 3 parameros"; modoUso; exit 1; }
  [[ -f $3 ]] || { echo "El parametro 3 debe ser un archivo valido"; modoUso; exit 1; }
}

function apConContraseña() {
  create_ap "$inter" "$inter" "$1" "$2" >> /dev/null &
  sleep 15
  numAp=$(create_ap --list-running | egrep [0-9]{4} | cut -d " " -f 1)
  #echo "hola"
  #echo "$numAp"
  while true; do
      for mak in $(sudo create_ap --list-clients "$numAp" | egrep -o "([0-9a-f]{2}:){5}[0-9a-f]{2}"); do
        for makarchivo in $(cat "$3" | egrep -o "([0-9a-f]{2}:){5}[0-9a-f]{2}"); do
          resul="false"
          [[ "$mak" == "$makarchivo" ]] && { resul="true"; }
        done
          #echo "$resul"
          [[ "$resul" == "true" ]] && { nombre=$(cat $3 | egrep $mak | cut -d "," -f 2); echo "Conocido: $nombre"; } || { echo "Desconocido: $mak"; }
      done
      sleep 60
  done
}

function apSinContraseña() {
  create_ap "$inter" "$inter" "$1" >> /dev/null &
  sleep 15

  numAp=$(create_ap --list-running | egrep [0-9]{4} | cut -d " " -f 1)
  #echo "hola"
  #echo "$numAp"
  while true; do
      for mak in $(sudo create_ap --list-clients "$numAp" | egrep -o "([0-9a-f]{2}:){5}[0-9a-f]{2}"); do
        for makarchivo in $(cat "$3" | egrep -o "([0-9a-f]{2}:){5}[0-9a-f]{2}"); do
          resul="false"
          [[ "$mak" == "$makarchivo" ]] && { resul="true"; }
        done
          #echo "$resul"
          [[ "$resul" == "true" ]] && { nombre=$(cat $3 | egrep $mak | cut -d "," -f 2); echo "Conocido: $nombre"; } || { echo "Desconocido: $mak"; }
      done
      sleep 60
  done
}

#egrep -o "([0-9a-f]{2}:){5}[0-9a-f]{2}"

validar "$@"
#ap "$@"

echo "$opcionS"
echo "holis"
[[ $opcionS ]] && { apSinContraseña "$@"; } || { apConContraseña "$@"; }
