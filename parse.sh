#!/bin/ksh

if [ ! -d /usr/ports ]; then
	echo "Ports base dir cannot found"
	exit 1
fi

for categoria in $( find /usr/ports -maxdepth 1 -type d ! -name . ! -name ports ! -name CVS); do
	nombre_categoria=$( basename $categoria )

	echo "Creating category $nombre_categoria"
	psql -U asarch ports -c "INSERT INTO categoria (nombre) VALUES ('$nombre_categoria');"
done

for categoria in $( psql --no-align --tuples-only -U asarch ports -c "SELECT * FROM categoria;" ); do
	indice_categoria=$( echo $categoria | awk -F\| '{ print $1 }' )
	nombre_categoria=$( echo $categoria | awk -F\| '{ print $2 }' )

	for paquete in $( find /usr/ports/$nombre_categoria -maxdepth 1 ! -name . ! -name CVS ! -name $nombre_categoria ! -name Makefile ); do
		nombre_paquete=$( basename $paquete )

		if [ -f /usr/ports/$nombre_categoria/$nombre_paquete/pkg/DESCR ]; then
			descripcion=$( cat /usr/ports/$nombre_categoria/$nombre_paquete/pkg/DESCR )
		else
			descripcion=""
		fi

		echo "Processing package $nombre_categoria/$nombre_paquete"

		echo "INSERT INTO paquete (nombre, descripcion, categoria) VALUES ('$nombre_paquete', :'descripcion', $indice_categoria);" | psql -v descripcion="$descripcion" -f - -U asarch -d ports

	done
done
