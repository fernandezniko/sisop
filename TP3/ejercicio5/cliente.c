/*
 Nombre Ejercicio: cliente.c
 Trabajo Practico Nro 3
 Nro Ejercicio: 5
 Integrantes: 
		Barja Fernandez, Omar Max 36241378
		Cullia, Sebastian 35306522
		Dal Borgo, Gabriel 35944975
		Fernandez, Nicolas 38168581
		Toloza, Mariano 37113832
 Nro Entrega: Segunda Reentrega (11/07/2017)
*/

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
/*for getting file size using stat()*/
#include<sys/stat.h>
/*for sendfile()*/
#include<sys/sendfile.h>
/*for O_RDONLY*/
#include<fcntl.h>

#define PORT 53210

int main(int argc, char *argv[])
{

	int caller_socket = 0 ;
	unsigned short int listen_port = 0 ;
	unsigned long int listen_ip_address = 0 ; 
	struct sockaddr_in listen_address ;
	struct stat obj;
	char buf[1024] ,filename[100], path[100];
	int status ,size, choice, filehandle, dire, x, puerto;
	int status1;
    	struct stat st_buf;
	int no_of_bytes;
	int remain_data ;
	off_t offset;
	int sent_bytes;

	if(argc != 3) 
	{	
		printf("Error: Debe recibir por parametro la IP o nombre de maquina del servidor y puerto a conectar\n");
		printf("Ejemplo: %s 127.0.0.1 53210\n" , argv[0]);
		printf("Ejemplo: %s user-VirtualBox 53210\n\n" , argv[0]);
		exit(1);
	}

	caller_socket = socket(AF_INET, SOCK_STREAM, 0);
	
	if(caller_socket == -1)
	{
		printf("Error no se pudo crear el socket\n") ;
		return 1 ;
	}

	puerto = strtol(argv[2], NULL, 10) ;
	//printf("%d\n" , puerto);
	if(puerto <= 0)
	{
		printf("Error puerto %s\n" , argv[2]);
		exit(1);
	}

	listen_address.sin_family = AF_INET ;

	listen_port = htons(puerto);
	listen_address.sin_port = listen_port;

	listen_ip_address = inet_addr(argv[1]);
	listen_address.sin_addr.s_addr = listen_ip_address ;

	bzero(&(listen_address.sin_zero), 8);

	if ( (x=connect(caller_socket, (struct sockaddr *)&listen_address, sizeof(struct sockaddr))) < 0) 
	{
		printf("Error IP\n") ;
		
	}
	 
	if (x < 0)
	{	
		printf("ver si existe nombre de maquina...\n");
		struct hostent *he ;
		he = gethostbyname (argv[1]) ;
		if(!he)
		{
			printf("ERROR: No existe nombre maquina: %s\n" , argv[1]);			
			return 1 ;
		}
		memcpy(&listen_address.sin_addr.s_addr, he->h_addr_list[0], he->h_length);
		printf("Dirección IP de %s: %s\n\n", argv[1],
	        inet_ntoa( *((struct in_addr *)he->h_addr)) );

		if ( connect(caller_socket, (struct sockaddr *)&listen_address, sizeof(struct sockaddr)) < 0) 
		{
			printf("Error conectando al servidor.. \n") ;
			return 1 ;
		}
		
	}

	printf("*******Bienvenido*******\n\n");
	printf("Inicio FTP Cliente : \n\n");
	
	while(1)
	{	
		printf("Ingrese opcion: \n 1- subir archivo al servidor\n 2- salir\n");
		printf("\n");
		scanf("%d", &choice);
		
		switch(choice)
		{	
			case 1:
			if( (no_of_bytes = send(caller_socket, &choice, sizeof(int),0)) <= 0)
			{
				printf("Error send opc: se sale de la sesion\n\n");
				goto outsideLoop;
			}

			printf("Ingrese PATH en donde se alojara el archivo: ");
			scanf("%s" ,path) ;
			
			if( (no_of_bytes = send(caller_socket, path, 100, 0)) <= 0) 
			{
				printf("Error send path: se sale de la sesion\n\n");
				goto outsideLoop;
			}

			recv(caller_socket, &dire, sizeof(int),0) ;
	
			
			if(dire)
				printf("Existe directorio. \n\n") ;
			else
			{	printf("ERROR: No existe el directorio %s en el servidor\n" , path) ;
				printf("Debe ingresar la ruta completa\n");
				printf("Ejemplo: /home/user/server/Escritorio\n\n") ;
				break;
			}
			
			printf("Ingrese arhivo a subir al servidor (ruta completa o nombre en caso de que el archivo este en el directorio actual): ");
			scanf("%s", filename);
			//"%*c%[^\n]"
			//printf(":%s:\n" , filename);
			status1 = stat (filename, &st_buf);
    			/*if (status1 != 0) {
       			 printf ("Error, errno = %d\n", errno);
       			 return 1;
   			 }*/
			
			if (S_ISREG (st_buf.st_mode)) {
        		printf ("%s es un archivo.\n", filename);
    			}
    			
			while (S_ISDIR (st_buf.st_mode)) {
        		
				printf ("ERROR: %s es un directorio.\n", filename);

				printf("Ingrese arhivo a subir al servidor: ");
				scanf("%s", filename);
				status1 = stat (filename, &st_buf);
 
    			}

			filehandle = open(filename, O_RDONLY);
			while(filehandle == -1)			
			{
				printf("ERROR: No existe archivo \n\n");
				printf("Debe ingresar la ruta completa del archivo\n");
				printf("O solo el nombre del archivo, en caso de que el archivo este en el directorio actual\n\n");
				
				printf("Ingrese arhivo a subir al servidor: ");
				scanf("%s", filename);
				
				status1 = stat (filename, &st_buf);
				while (S_ISDIR (st_buf.st_mode)) {
        			printf ("ERROR: %s es un directorio.\n", filename);

				printf("Ingrese arhivo a subir al servidor: ");
				scanf("%s", filename);
				status1 = stat (filename, &st_buf);
 
    				}

				filehandle = open(filename, O_RDONLY);
			}
			//close(filehandle);
			strcpy(buf, filename);			
			if( (no_of_bytes = send(caller_socket, buf, 100, 0)) <= 0)
			{
				printf("Error send Nobre arch: se sale de la sesion\n\n");
				goto outsideLoop;
			}
			stat(filename, &obj);
			size = obj.st_size;
			if( (no_of_bytes = send(caller_socket, &size, sizeof(int), 0)) <= 0)
			{
				printf("Error send Tam archivo: se sale de la sesion\n\n");
				goto outsideLoop;
			}
			offset=0;
			remain_data = obj.st_size;
			while ( (remain_data > 0) && ((sent_bytes = sendfile(caller_socket, filehandle, &offset, 1024)) > 0) )
			{
				fprintf(stdout, "1. Cliente envio %d bytes del archivo, offset : %jd , falta mandar = %d\n", sent_bytes, (intmax_t)offset, remain_data);
				remain_data -= sent_bytes;
				fprintf(stdout, "2. Cliente envio %d bytes del archivo, offset : %jd , falta mandar = %d\n", sent_bytes, (intmax_t)offset, remain_data);
			}
			
			recv(caller_socket, &status, sizeof(int), 0);

			if(status)
				printf("Archivo guardado correctamente\n\n");
			else
				printf("ERROR: fallo subiendo el archivo al servidor\n\n");
			break ;
			
			case 2:
			//strcpy(buf, "quit");
			/*send(caller_socket, &choice, 100, 0);
			recv(caller_socket, &status, 100, 0);
			
			if(status)
			{
				printf("Cerrando servidor\nSaliendo..\n");
				exit(0);
			}
			printf("Server failed to close connection\n");
			*/
			goto outsideLoop;
		}
	}
	outsideLoop:
	
	close(caller_socket);
	printf("\n\nFinalizo sesion\n\n");

	fflush(stdout);

	return 0 ;
}
