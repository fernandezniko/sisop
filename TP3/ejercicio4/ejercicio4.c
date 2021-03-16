
/*
 Nombre Ejercicio: ejercicio4.c
 Trabajo Practico Nro 3
 Nro Ejercicio: 4
 Integrantes: 
		Barja Fernandez, Omar Max 36241378
		Cullia, Sebastian 35306522
		Dal Borgo, Gabriel 35944975
		Fernandez, Nicolas 38168581
		Toloza, Mariano 37113832

 Nro Entrega: Primera Reentrega (06/07/2017)
*/

#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <semaphore.h>

// for sleep
#include <unistd.h>

#define BUFF_SIZE   1           /* total number of slots */
#define ANCHO       256

int randomInt(int min, int max);

typedef struct
{
    char buf[ANCHO];    /* shared var */
    int fin;              /* si esta en 1 indica que finalizo */
    sem_t full;           /* keep track of the number of full spots */
    sem_t empty;          /* keep track of the number of empty spots */

    // use correct type here
    pthread_mutex_t mutex;          /* enforce mutual exclusion to shared data */
} sbuf_t;

sbuf_t shared;


void *Producer(void *arg)
{
    FILE * archEntrada;
    char nomArch[50];
    char linea[ANCHO];

    printf("Ingrese nombre del archivo: ");
   scanf("%s",nomArch);

    archEntrada = fopen(nomArch, "rt");

   if ( archEntrada == NULL )
   {
      printf("NO SE PUDO ABRIR EL ARCHIVO [ %s ]\n", nomArch);
      exit(-1);
   }
	/* Produce item */
	fgets(linea, ANCHO, archEntrada);
	while( ! feof(archEntrada) )
	{
		/* Prepare to write item to buf */

		/* If there are no empty slots, wait */
		sem_wait(&shared.empty);
		/* If another thread uses the buffer, wait */
		pthread_mutex_lock(&shared.mutex);

		//shared.buf[shared.in] = item;
		printf("PADRE - Buffer: %s\n",shared.buf);
		memmove(shared.buf, linea, ANCHO);        
		printf("PADRE - Buffer: %s\n",shared.buf);

		/* Release the buffer */
		pthread_mutex_unlock(&shared.mutex);
		/* Increment the number of full slots */
		sem_post(&shared.full);

		/* Interleave  producer and consumer execution */
		sleep(1);
	
		/* Produce item */
		fgets(linea, ANCHO, archEntrada);
	}

		/* If there are no empty slots, wait */
		sem_wait(&shared.empty);
		/* If another thread uses the buffer, wait */
		pthread_mutex_lock(&shared.mutex);
		puts("PADRE - indica fin de archivo");
		shared.fin = 1;

		/* Release the buffer */
		pthread_mutex_unlock(&shared.mutex);
		/* Increment the number of full slots */
		sem_post(&shared.full);

  fclose(archEntrada);
    return NULL;
}

void *Consumer(void *arg)
{
	FILE * archSalida;
	char item[ANCHO];
	int condicionFin;
	int cantidadItems = 0;
	archSalida = fopen("Salida" ,"w");

    while(1) {
        sem_wait(&shared.full);
        pthread_mutex_lock(&shared.mutex);

	condicionFin = shared.fin;

	printf("HIJO - Valor linea antes de memcpy: %s\n",item);
         memcpy(item, shared.buf, ANCHO);
	 printf("HIJO - Valor linea despues de memcpy: %s\n",item); 

		


        /* Release the buffer */
        pthread_mutex_unlock(&shared.mutex);
        /* Increment the number of full slots */
        sem_post(&shared.empty);

	if (condicionFin == 1)
	{
	puts("HIJO - conficion fin alcanzada");
		break;
	}
	else
	{
		//if (cantidadItems > 0)
		//{
//
//			printf("HIJO - Cant Items: %d\n",cantidadItems);
//			rewind(archSalida);
//			int row = randomInt(0, cantidadItems);
//			printf("HIJO - Rand: %d\n",row);
//			int fila = 0;
//			int ct_str_length;
//			long new_byte_position;
//			long cur_pos;
//			while (fila != row)
//			{
//				cur_pos = ftell(archSalida);
//			printf("HIJO - Cur pos: %ld\n",cur_pos);
//				fgets(item, ANCHO, archSalida);
//				ct_str_length=strlen(item);
//			printf("HIJO - length row: %d\n",ct_str_length);
//				new_byte_position=ct_str_length
//			printf("HIJO - length row: %ld\n",new_byte_position);
//				fseek(archSalida,new_byte_position,SEEK_CUR);
//				fila++;			
//			}
//			puts("-----------------");
//		}
		fprintf(archSalida, "%s", item);
		cantidadItems++;
	}

        /* Interleave  producer and consumer execution */
        sleep(1);
    }
	fclose(archSalida);
//system("sort -o Salida");
}

int randomInt(int min, int max)
{
	srand(time(NULL));
	double scaled = (double)rand() / RAND_MAX;
	return (int)((max - min + 1)*scaled + min);
}

int main()
{
    pthread_t idP, idC;
    int index;

    shared.fin = 0;
    sem_init(&shared.full, 0, 0);
    sem_init(&shared.empty, 0, BUFF_SIZE);
    pthread_mutex_init(&shared.mutex, NULL);
    pthread_create(&idP, NULL, Producer, (void*)0);
    pthread_create(&idC, NULL, Consumer, (void*)index);
    pthread_exit(NULL);
}