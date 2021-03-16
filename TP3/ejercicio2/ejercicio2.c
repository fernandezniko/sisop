
/*
 Nombre Ejercicio: ejercicio2.c
 Trabajo Practico Nro 3
 Nro Ejercicio: 2
 Integrantes: 
		Barja Fernandez, Omar Max 36241378
		Cullia, Sebastian 35306522
		Dal Borgo, Gabriel 35944975
		Fernandez, Nicolas 38168581
		Toloza, Mariano 37113832

 Nro Entrega: Segunda Reentrega (11/07/2017)
*/

#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <semaphore.h>
#include <syscall.h>

// for sleep
#include <unistd.h>

struct dataThread {
	int filaInicial;
	int cantidadFilas;
	int cantidadUnos;
	int cantidadCeros;
	long tid;
};

int lines, columns, cantidadThreads;
int *intMatrix, *vector;
pthread_t *tid;
struct dataThread *dataThreads; 

int ingresarParametros()
{
  lines = 0;
  columns = 0;
  cantidadThreads = 0;

  printf("Cantidad de lineas de la matriz: (valor entero mayor a cero)\n");
  scanf("%d", &lines);
  if (lines <= 0)
  {
     printf("El valor ingresado no es valido.\n");
     return -1;
  }

  printf("Cantidad de columnas de la matriz: (valor entero mayor a cero)\n");
  scanf("%d", &columns);
  if (columns <= 0)
  {
     printf("El valor ingresado no es valido.\n");
     return -1;
  }

  printf("Cantidad de threads: (valor entero mayor a cero y menor o igual a %d)\n", lines);
  scanf("%d", &cantidadThreads);
  if (cantidadThreads <= 0 || cantidadThreads > lines)
  {
     printf("El valor ingresado no es valido.\n");
     return -1;
  }
  puts("");
  return 0;
};

void imprimirParametros(FILE *fp)
{
  fprintf(fp, "Parametros ingresados:\n");
  fprintf(fp, " - Cantidad de filas: %d\n", lines);
  fprintf(fp, " - Cantidad de columnas: %d\n", columns);
  fprintf(fp, " - Cantidad de threads: %d\n\n", cantidadThreads);
}

void reservarMemoria()
{
  intMatrix = (int *)malloc(lines * columns * sizeof(int)); 
  vector = (int *)malloc(lines * sizeof(int)); 
  dataThreads = (struct dataThread*)malloc(cantidadThreads * sizeof(struct dataThread)); 
  tid = (pthread_t *)malloc(sizeof(pthread_t)*cantidadThreads);
}

void liberarMemoria()
{
  free(intMatrix);
  free(vector);
  free(dataThreads);
  free(tid);
}

void iniciarVector()
{
  int i;
  for(i = 0; i < lines; i++)
  {
	vector[i] = -1;
  }
}

void imprimirVector()
{
  int i;
  puts("-----------VECTOR----------");
  for(i = 0; i < lines; i++)
  {
	printf("%d\n", vector[i]);
  }
}

void imprimirLineas()
{
  int i;
  // Muestra resultados por linea
  puts("---------Lineas--------");
  for (i=0;i<lines;i++)
  {
	printf("Fila: %d - Cantidad unos: %d - Cantidad ceros: %d\n", i, vector[i], columns - vector[i]);
  }
}

void iniciarMatriz()
{
  int i;
  // Carga matriz con valores 1 o 0 random
  for(i=0; i<(lines*columns); i++)
  {
      	intMatrix[i] = rand() % 2;
  }
}

void imprimirMatriz(FILE *fp)
{
  int i;
  // Muestra la matriz por pantalla
  // TODO guardar a log
  fprintf(fp, "Matriz:\n");
  for(i=0; i<(lines*columns); i++)
  {        
	if ((i % columns) == 0)
	 	fprintf(fp, "FILA %d ->\t", i / columns);
	fprintf(fp, "%d ", intMatrix[i]);
	if (((i + 1) % columns) == 0 )
		fprintf (fp,"\n");
  }
  fprintf (fp,"\n");
}

void iniciarDataThreads()
{
  int i;
  // Calcula datos a procesar por threads
  int auxTh = cantidadThreads;
  int auxCantidadFilasSinAsignar = lines;
  int auxFila = 0;
  int auxCantidadFilas = 0;
  for (i=0;i<cantidadThreads;i++)
  {
	auxCantidadFilas = auxCantidadFilasSinAsignar / auxTh;

  	dataThreads[i].tid = i;
	dataThreads[i].filaInicial = auxFila;
	dataThreads[i].cantidadFilas = auxCantidadFilas;
	dataThreads[i].cantidadUnos = 0;
  	dataThreads[i].cantidadCeros = 0;

        auxCantidadFilasSinAsignar -= auxCantidadFilas;
	auxFila += auxCantidadFilas;
        auxTh--;
  }
}

void imprimirDataThreads()
{
  int i;
  // Muestra resultados de cada thread
  puts("---------DATA THREADS--------");
  for (i=0;i<cantidadThreads;i++)
  {
	printf("TID: %ld - Inicio: %d - Cant: %d - Unos: %d - Ceros: %d\n", dataThreads[i].tid,dataThreads[i].filaInicial,dataThreads[i].cantidadFilas,dataThreads[i].cantidadUnos,dataThreads[i].cantidadCeros);
  }
}

void imprimirResultados(FILE *fp) 
{
  int i;
  // Muestra resultado del proceso
  fprintf(fp, "Resultado:\n");
  int finalUnos = 0;
  int finalCeros = 0;
  for (i=0;i<cantidadThreads;i++)
  {
	finalUnos += dataThreads[i].cantidadUnos;
	finalCeros += dataThreads[i].cantidadCeros;
  }
  fprintf(fp, " - Cantidad unos: %d\n", finalUnos);
  fprintf(fp, " - Cantidad ceros: %d\n", finalCeros);

  int r = 0;
  int rMax = 0;	
  int rMin = 0;
  for (i=0;i<lines;i++)
  {
	int vectorValue = vector[i];
   	if(r == 0)
        {
		rMax = vectorValue;
		rMin = vectorValue;
		r = 1;
	}
	else if (vectorValue > rMax)
	{
		rMax = vectorValue;
	}
	else if (vectorValue < rMin)
	{
		rMin = vectorValue;
 	}
  }
  
  fprintf(fp, " - Filas con mayor numero de 1: (%d)\n", rMax);
  for (i=0;i<lines;i++)
  {
	if(vector[i] == rMax)
		fprintf(fp, "\tFila %d\n", i);
  }

  fprintf(fp," - Filas con mayor numero de 0: (%d)\n", columns - rMin);
  for (i=0;i<lines;i++)
  {
	if(vector[i] == rMin)
		fprintf(fp, "\tFila %d\n", i);
  }

  int t = 0;
  int tMaxUnos = 0;	
  int tMaxCeros = 0;	
  int tMinUnos = 0;	
  int tMinCeros = 0;	
  for (i=0;i<cantidadThreads;i++)
  {
	int tCantUnos = dataThreads[i].cantidadUnos;
	int tCantCeros = dataThreads[i].cantidadCeros;
   	if(t == 0)
        {
		tMaxUnos = tCantUnos;
		tMinUnos = tCantUnos;
		tMaxCeros = tCantCeros;
		tMinCeros = tCantCeros;
		t = 1;
	}
        else
 	{
		if (tCantUnos > tMaxUnos)
		{
			tMaxUnos = tCantUnos;
		}
		else if (tCantUnos < tMinUnos)
		{
			tMinUnos = tCantUnos;
	 	}

		if (tCantCeros > tMaxCeros)
		{
			tMaxCeros = tCantCeros;
		}
		else if (tCantCeros < tMinCeros)
		{
			tMinCeros = tCantCeros;
	 	}
	}
  }
  fprintf(fp, " - TID que conto la mayor cantidad de 0: (%d)\n", tMaxCeros);
  for (i=0;i<cantidadThreads;i++)
  {
	if(dataThreads[i].cantidadCeros == tMaxCeros)
		fprintf(fp,"\tTID %ld\n", dataThreads[i].tid);
  }
  fprintf(fp," - TID que conto la menor cantidad de 0: (%d)\n", tMinCeros);
  for (i=0;i<cantidadThreads;i++)
  {
	if(dataThreads[i].cantidadCeros == tMinCeros)
		fprintf(fp,"\tTID %ld\n", dataThreads[i].tid);
  }
  fprintf(fp," - TID que conto la mayor cantidad de 1: (%d)\n", tMaxUnos);
  for (i=0;i<cantidadThreads;i++)
  {
	if(dataThreads[i].cantidadUnos == tMaxUnos)
		fprintf(fp,"\tTID %ld\n", dataThreads[i].tid);
  }
  fprintf(fp," - TID que conto la menor cantidad de 1: (%d)\n", tMinUnos);
  for (i=0;i<cantidadThreads;i++)
  {
	if(dataThreads[i].cantidadUnos == tMinUnos)
		fprintf(fp,"\tTID %ld\n", dataThreads[i].tid);
  }
}

void *Proceso(void *arg)
{
	FILE * log;
	int i, j;

	int index = *((int *) arg);
	long tid = syscall(SYS_gettid);
	dataThreads[index].tid = tid;

 	char name[12];
    	sprintf(name, "%ld", tid);
	log = fopen(name ,"w");
	fprintf(log, "TID => %ld\n", tid);
	fprintf(log, "Fila inicial a leer: %d\n", dataThreads[index].filaInicial);
	fprintf(log, "Cantidad de filas a leer: %d\n", dataThreads[index].cantidadFilas);

	int fila = dataThreads[index].filaInicial;
	int posicionInicial = fila * columns;
	int posicionFinal = (dataThreads[index].cantidadFilas * columns) + posicionInicial;
        int unosPorFila = 0;
	int cerosPorFila = 0;
  	for(i = posicionInicial; i < posicionFinal; i++)
  	{
		if (intMatrix[i] == 1)
		{
			unosPorFila++;
		}

		if (((i + 1) % columns) == 0 )
		{
			cerosPorFila = columns - unosPorFila;
			vector[fila] = unosPorFila;
			dataThreads[index].cantidadUnos += unosPorFila;
			dataThreads[index].cantidadCeros += cerosPorFila;
			fprintf(log, "- Fila %d:\n", fila);
			fprintf(log, "\tCantidad de 1: %d\n", unosPorFila);
			fprintf(log, "\tCantidad de 0: %d\n", cerosPorFila);
 			fila++;
			unosPorFila = 0;
			cerosPorFila = 0;
		}
	}

	fclose(log);
	return NULL;
}

void procesar()
{
  int i;
  // Se ejecutan los threads de procesamiento  
  for (i = 0; i < cantidadThreads; i++) {
        int *arg = malloc(sizeof(*arg));
	*arg = i;
        pthread_create(&tid[i], NULL, Proceso, arg);
  }

  // Se espera que todos los threads terminen de procesar
  for (i = 0; i < cantidadThreads; i++)
  	pthread_join(tid[i], NULL);
}

int main()
{ 
  FILE * log;
  
  if (ingresarParametros() != 0)
	return;

  log = fopen("Resultado" ,"w");
  imprimirParametros(log);
  imprimirParametros(stdout);

  reservarMemoria();

  // Se inicializa vector que contabiliza los unos por fila
  iniciarVector();
  // Imprime vector por pantalla
  //imprimirVector(); 

  // Inicializa matriz con valores 1 o 0 random
  iniciarMatriz();
  // Imprimir matriz por pantalla
  imprimirMatriz(log);
  imprimirMatriz(stdout);

  // Inicializa los datos que necesitan los threads para procesar
  iniciarDataThreads();
  // Imprimir los datos de los threads
  //imprimirDataThreads();
  
  // Procesar matriz
  procesar();

  //imprimirMatriz();
  //imprimirDataThreads();
  //imprimirVector();
  //imprimirLineas();
  imprimirResultados(log);
  imprimirResultados(stdout);

  liberarMemoria();

  fclose(log);
}