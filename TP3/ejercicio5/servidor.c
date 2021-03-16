/*
 Nombre Ejercicio: servidor.c
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

#include <sys/types.h> // socket() , bind()
#include <sys/socket.h> // socket(), bind(), inet_addr()
#include <netinet/in.h> // inet_addr()
#include <arpa/inet.h> // inet_addr()
#include <string.h> // bzero()
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
/*for getting file size using stat()*/
#include<sys/stat.h>
/*for sendfile()*/
#include<sys/sendfile.h>
/*for O_RDONLY*/
#include<fcntl.h>
#include <dirent.h>

#define MAXQ 10
#define PORT 53210

void *connection_handler(void *);

int main(int argc, char *argv[])
{
	int listen_socket = 0 , comm_socket = 0 ;
	unsigned short int listen_port = 0 ;
	unsigned short int listen_ip_address=0 ;
	struct sockaddr_in listen_address , con_address ;
	socklen_t con_addr_len ;
	int *new_sock ;
	int puerto ;
	
	if(argc != 2) 
	{	
		printf("Error: Debe recibir por parametro el puerto a conectar el servidor \n");
		printf("Ejemplo: %s 53210\n\n " , argv[0]) ;
		exit(1);
	}

	listen_socket = socket(AF_INET, SOCK_STREAM, 0) ;
	if( listen_socket == -1)
	{
		printf("Error no se pudo crear el socket") ;
		exit(1);
	}

	puerto = strtol(argv[1], NULL, 10) ;
	//printf("%d\n" , puerto);
	if(puerto <= 0)
	{
		printf("Error puerto %s\n" , argv[1]);
		exit(1);
	}

	bzero(&listen_address, sizeof(listen_address));	
	listen_address.sin_family = AF_INET ;
	listen_port = htons(puerto);
	listen_address.sin_port = listen_port ;

	listen_ip_address = htonl(INADDR_ANY);
	listen_address.sin_addr.s_addr = listen_ip_address ;
	
		
	if ( bind(listen_socket, (struct sockaddr *)&listen_address, sizeof(struct sockaddr)) < 0)
	{
		printf("Error bind") ;
		return 1 ;
	}

	if( listen(listen_socket, MAXQ) == -1)
	{
		printf("Error listen") ;
		return 1;
	}

	printf("Comenzamos a escuchar conexiones...\n");
	printf("\nServidor iniciado en el puerto: %d\n", puerto);
	
	while(1)
	{
		if( (comm_socket = accept(listen_socket, (struct sockaddr *)(&con_address), &(con_addr_len)) )== -1 )
		{
			printf("Error accept");
			return 1;
		}
		
		printf("Peticion aceptada del cliente: (%s,%d) \n" ,inet_ntoa(con_address.sin_addr) ,ntohs(con_address.sin_port)) ;
		
		new_sock = malloc(1);
        	*new_sock = comm_socket;
		pthread_t sniffer_thread;
		pthread_create(&sniffer_thread, NULL, connection_handler, (void *)new_sock);
	}
	

	close(listen_socket);

	return 0 ;
}

void *connection_handler(void *socket_desc)
{
	char buf[50],buf2[1024], command[5] ,filename[100],path[100] ;
	int size, filehandle, i ;
	int sock = *(int*)socket_desc ;
	int dire ,bytes;
	int opc ;
	int no_of_bytes ;
	char *aux ;
	int remain_data ;
	FILE *received_file;

	while(1)
	{	
		
		bytes = recv(sock, &opc, sizeof(int),0);
		if (bytes == 0)
		{
			printf("se cerro el cliente anterior \n ");			
			break;			
			//goto pepe;			
			
			
			//break;
		}

		printf("Opcion recibida: %d\n" , opc) ;
		switch(opc)
		{case 1:

			memset(&path,'\0', 100);
			
			if( (no_of_bytes = recv(sock, path, 100, 0)) <= 0 )
			{
				printf("error recv path\n ");
				if(no_of_bytes == 0)
				{
					printf("se cerro el cliente anterior\n");
				}
				//printf("1");
				break ;
				//goto pepe ;
				//break ;
			}
				
			printf("PATH recibido: %s\n" , path) ;

			DIR *dir = opendir(path);
			if (dir)
			{
    				/* Directory exists. */
				dire = 1 ;
    				closedir(dir);
			}
			else //if (ENOENT == errno)
			{	
				dire = 0 ;
				//printf("%d\n" , dire) ;
				if( (no_of_bytes = send(sock, &dire, sizeof(int), 0)) <=0 )
				{
								
					printf("error recv archivo a subir:\n\n");
					if(no_of_bytes == 0)
					{
						printf("se cerro el cliente: anterior\n");
					}
					break ;
					//goto pepe;
				}
				break;
    				/* Directory does not exist. */
			}
			//printf("%d\n" , dire) ;
			if( (no_of_bytes = send(sock, &dire, sizeof(int), 0)) <= 0)
			{
							
				printf("error send archivo a subir:\n\n");
				if(no_of_bytes == 0)
				{
					printf("se cerro el cliente: anterior\n");
				}
				break ;
				//goto pepe;
			}

			int c = 0, len;
			char *f;
			if( (no_of_bytes = recv(sock, buf, 100, 0)) <= 0)
			{
				printf("error recv archivo a subir:\n\n");
				if(no_of_bytes == 0)
				{
					printf("se cerro el cliente: anterior\n");
				}
				break;
				//goto pepe;
				//break ;
			}
			printf("Archivo a subir: %s\n" , buf);
			if( (aux = strrchr(buf, '/')) == NULL )
				strcpy(filename, buf);
			else
			{
				aux++ ;
				strcpy(filename, aux);
			}
			
			//printf("final:%s\n" , filename);
			if( (no_of_bytes = recv(sock, &size, sizeof(int), 0)) <= 0)
			{
				printf("error recv tam arch\n\n");	
				break ;
				//goto pepe;
				//break ;
			}

			strcat(path, "/");
			strcat(path,filename);
			i = 1;
			
			/*while(1)
			{
				filehandle = open(filename, O_CREAT | O_EXCL | O_WRONLY, 0666);
				if(filehandle == -1)
				{
					sprintf(filename + strlen(filename), "%d", i);
				}
				else
				break;
			}
			*/
			received_file=fopen(path,"w");
			if(received_file == NULL)
			{
				fprintf(stderr, "Failed to open file foo --> %s\n", filename);

                		exit(1);
			}
		
			remain_data = size ;
			//f = malloc(size);
			while ((remain_data > 0) && ((no_of_bytes = recv(sock, buf2, 1024, 0)) > 0) )
			{	
				fwrite(buf2, sizeof(char),no_of_bytes, received_file);
				remain_data -= no_of_bytes ;
				fprintf(stdout, "Servidor recibio %d bytes, falta :- %d bytes\n", no_of_bytes, remain_data);
			}
			c=1; 
			fclose(received_file);
			send(sock, &c, sizeof(int), 0) ;

			//rename(filename,path);
		break ;
		 //else if(!strcmp(command, "quit"))
		/*case 2:
			printf("FTP servidor cerrando..\n");
			i = 1;
			send(sock, &i, sizeof(int), 0);
			///close(comm_socket);
			exit(0);
		*/
		}


	}

	pepe:

	close(sock);
	
	
	free(socket_desc);
}

