#!/bin/ksh

# CREATE TABLE "categoria" ( "id" INTEGER PRIMARY KEY AUTOINCREMENT, "nombre" TEXT );
# CREATE TABLE "paquete" ( "id" INTEGER PRIMARY KEY AUTOINCREMENT, "nombre" TEXT, "descripcion" TEXT, "categoria" INTEGER REFERENCES categoria(id) ON DELETE CASCADE ON UPDATE CASCADE );

#if [ ! -d /usr/ports ]; then
#	echo "Ports base dir cannot found"
#	exit 1
#fi

#if [ ! -f ports.db ]; then
#	sqlite3 ports.db "CREATE TABLE \"categoria\" ( \"id\" INTEGER PRIMARY KEY AUTOINCREMENT, \"nombre\" TEXT );"
#	sqlite3 ports.db "CREATE TABLE \"paquete\" ( \"id\" INTEGER PRIMARY KEY AUTOINCREMENT, \"nombre\" TEXT, \"descripcion\" TEXT, \"categoria\" INTEGER REFERENCES categoria(id) ON DELETE CASCADE ON UPDATE CASCADE );"
#fi

#for categoria in $( find /usr/ports -maxdepth 1 -type d ! -name . ! -name ports ! -name CVS); do
#	nombre=$( basename $categoria )
#	sqlite3 ports.db "INSERT INTO categoria ( nombre ) VALUES ( \"$nombre\" )"

#	echo "Creating category $nombre"
#	psql -U asarch ports -c "INSERT INTO categoria ( nombre ) VALUES ( '$nombre' );"
#done

#exit 1

#for categoria in $( sqlite3 ports.db "SELECT * FROM categoria;" ); do
for categoria in $( psql -U asarch ports -c "SELECT * FROM categoria;" ); do
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

		#psql -U asarch ports -c "INSERT INTO paquete ( nombre, descripcion, categoria ) VALUES ( '$nombre_paquete', '$descripcion', $indice_categoria );"
		echo "INSERT INTO paquete (nombre, descripcion, categoria) VALUES ('$nombre_paquete', :'descripcion', $indice_categoria);" | psql -v descripcion="$descripcion" -f - -U asarch -d ports

#		if [ echo $descripcion | grep "'" ]; then
#			query="INSERT INTO paquete ( nombre, descripcion, categoria ) VALUES ( \"$nombre_paquete\", \"$descripcion\", $indice_categoria );"
#		else
#			query="INSERT INTO paquete ( nombre, descripcion, categoria ) VALUES ( '$nombre_paquete', '$descripcion', $indice_categoria );"
#		fi

#		sqlite3 ports.db $query
	done
done
