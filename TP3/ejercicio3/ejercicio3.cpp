// TP3.cpp : Defines the entry point for the console application.
//
/*
 Nombre Ejercicio: ejercicio3.cpp
 Trabajo Practico Nro 3
 Nro Ejercicio: 3
 Integrantes: 
		Barja Fernandez, Omar Max 36241378
		Cullia, Sebastian 35306522
		Dal Borgo, Gabriel 35944975
		Fernandez, Nicolas 38168581
		Toloza, Mariano 37113832

 Nro Entrega: Primera Reentrega (06/07/2017)
*/
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

void mainProcess();
void sensorProcess(int nroSensor);

#define MAX_SENSORES 100

typedef struct {
	int nroSensor;
	bool lastIsMax;
	bool lastIsMin;
	int minTemperatura;
	int maxTemperatura;
	int marcas[10];
	int cantMarcas;
	int total;
	int promedio;
	int antigua;
} Sensor;

typedef struct {
	Sensor items[MAX_SENSORES];
	int cantidad;
} Sensores;

bool existeSensor(Sensores *sensores, int nroSensor, int &index);
Sensor procesarData(Sensores *sensores, int nroSensor, int temperatura);

// FIFO HELPER
#define  FIFO_FILE         "MIFIFO"

typedef struct {
	int nroSensor;
	int temperatura;
} Mensaje;

void enviar(Mensaje mensaje);
Mensaje recibir();

Mensaje fromString(char * mensajeString);
char* toString(Mensaje mensaje);
// FIFO HELPER

// TOOLS
int str2int(int &i, char const *s, int base = 0);
int randomInt(int min, int max);

int toint(char str[]);
void tostring(char str[], int num);
// TOOLS

int main(int argc, char **argv)
{
	switch (argc)
	{
		case 1:
			mainProcess();
		break;
		case 2:
		{	
			int nroSensor = 0;
			int resultado = str2int(nroSensor, argv[1], 10);
			if (resultado == 0)
				sensorProcess(nroSensor);
			else
				printf("Ejecución inválida - El nombre del sensor debe ser numérico.\n");
		}
		break;
		default:
			printf("Ejecución inválida.\n");
		break;
	}
	return 0;
}

// MAIN
void mainProcess()
{
	Sensores sensores;
	sensores.cantidad = 0;

	printf("Proceso central iniciado\n");
	while (true)
	{
		Mensaje mensaje = recibir();
		Sensor sensor = procesarData(&sensores, mensaje.nroSensor, mensaje.temperatura);
		printf("Sensor:%d - Temperatura:%d - Promedio:%d - Maximo:%s - Minimo:%s\n", sensor.nroSensor, mensaje.temperatura, sensor.promedio, sensor.lastIsMax ? "Si" : "No", sensor.lastIsMin ? "Si" : "No");
	}
}

void sensorProcess(int nroSensor)
{
	// Se obtiene un valor random de temperatura en el intervalo dado
	Mensaje mensaje = { nroSensor, randomInt(10, 30) };
	printf("Sensor %d - Temperatura %d\n", mensaje.nroSensor, mensaje.temperatura);
	enviar(mensaje);
}

bool existeSensor(Sensores *sensores, int nroSensor, int &index)
{
	for (int i = 0; i < sensores->cantidad; i++)
	{
		if (sensores->items[i].nroSensor == nroSensor)
		{
			index = i;
			return true;
		}
	}
	return false;
}

Sensor procesarData(Sensores *sensores, int nroSensor, int temperatura)
{
	int i = 0;
	if (existeSensor(sensores, nroSensor, i))
	{
		// Marca minimo
		if (sensores->items[i].minTemperatura > temperatura)
		{
			sensores->items[i].minTemperatura = temperatura;
			sensores->items[i].lastIsMin = true;
		}
		else
		{
			sensores->items[i].lastIsMin = false;
		}

		// Marca maximo
		if (sensores->items[i].maxTemperatura < temperatura)
		{
			sensores->items[i].maxTemperatura = temperatura;
			sensores->items[i].lastIsMax = true;
		}
		else
		{
			sensores->items[i].lastIsMax = false;
		}

		if (sensores->items[i].cantMarcas == 10)
		{
			int indexTemperaturaAntigua = sensores->items[i].antigua;
			int temperaturaAntigua = sensores->items[i].marcas[indexTemperaturaAntigua];
			sensores->items[i].total -= temperaturaAntigua;
			sensores->items[i].marcas[indexTemperaturaAntigua] = temperatura;
			sensores->items[i].antigua++;
			if (sensores->items[i].antigua == 10)
				sensores->items[i].antigua = 0;
		}
		else
		{
			sensores->items[i].marcas[sensores->items[i].cantMarcas] = temperatura;
			sensores->items[i].cantMarcas++;
		}
		sensores->items[i].total += temperatura;
		sensores->items[i].promedio = (sensores->items[i].total / sensores->items[i].cantMarcas);
		return sensores->items[i];
	}
	else
	{
		Sensor sensor;
		sensor.nroSensor = nroSensor;
		sensor.minTemperatura = temperatura;
		sensor.maxTemperatura = temperatura;
		sensor.lastIsMax = true;
		sensor.lastIsMin = true;
		sensor.marcas[0] = temperatura;
		sensor.marcas[1] = 0;
		sensor.marcas[2] = 0;
		sensor.marcas[3] = 0;
		sensor.marcas[4] = 0;
		sensor.marcas[5] = 0;
		sensor.marcas[6] = 0;
		sensor.marcas[7] = 0;
		sensor.marcas[8] = 0;
		sensor.marcas[9] = 0;
		sensor.cantMarcas = 1;
		sensor.promedio = temperatura;
		sensor.total = temperatura;
		sensor.antigua = 0;
		sensores->items[sensores->cantidad] = sensor;
		sensores->cantidad++;

		return sensor;
	}
}
// MAIN

// FIFO HELPER
void enviar(Mensaje mensaje)
{
	char* msj = toString(mensaje);
	char mensajeString[20];
	strncpy(mensajeString, msj, sizeof mensajeString);

	//Envio real a FIFO
	int fd;
	mkfifo(FIFO_FILE, 0666);
	fd = open(FIFO_FILE, O_WRONLY);
	write(fd, mensajeString, sizeof mensajeString);
	close(fd);
	//unlink(FIFO_FILE);
}

Mensaje recibir()
{
	Mensaje mensaje;
	int fd;
	char buffer[20];
	
	do
	{
		fd = open(FIFO_FILE, O_RDONLY);
		read(fd, buffer, 20);
		close(fd);	

		char mensajeString[20];
		strncpy(mensajeString, buffer, sizeof mensajeString);
		mensaje = fromString(mensajeString);
	} while (mensaje.temperatura < 0);
	//Leer mensaje string desde fifo
	return mensaje;
}

Mensaje fromString(char * mensajeString)
{
	char msjSensor[10];
	char msjTemp[10];
	for (int i = 0; i < 10; i++)
	{
		msjSensor[i] = mensajeString[i];
	}
	for (int i = 0; i < 10; i++)
	{
		msjTemp[i] = mensajeString[i + 10];
	}

	int nroSensor = toint(msjSensor);
	int temperatura = toint(msjTemp);
	
	Mensaje mensaje;
	mensaje.nroSensor = nroSensor;
	mensaje.temperatura = temperatura;
	return mensaje;
}

char* toString(Mensaje mensaje)
{
	char * str;
	str = (char*)malloc(sizeof(char) * 20);

	for (int i = 0; i < 20; i++)
		str[i] = '0';

	int length, digito, num;

	length = 0;
	digito = 0;
	num = mensaje.nroSensor;
	while (num != 0)
	{
		length++;
		num /= 10;
	}
	num = mensaje.nroSensor;
	for (int i = 0; i < length; i++)
	{
		int posicion = 9 - i;
		if (posicion < 0)
			break;
		digito = num % 10;
		num = num / 10;
		str[posicion] = digito + 48;
	}

	length = 0;
	digito = 0;
	num = mensaje.temperatura;
	while (num != 0)
	{
		length++;
		num /= 10;
	}
	num = mensaje.temperatura;
	for (int i = 0; i < length; i++)
	{
		int posicion = 19 - i;
		if (posicion < 10)
			break;
		digito = num % 10;
		num = num / 10;
		str[posicion] = digito + 48;
	}

	return str;
}
//FIFO HELPER

//TOOLS
int str2int(int &i, char const *s, int base)
{
	char *end;
	long  l;
	errno = 0;
	l = strtol(s, &end, base);
	if ((errno == ERANGE && l == LONG_MAX) || l > INT_MAX) {
		return -1;
	}
	if ((errno == ERANGE && l == LONG_MIN) || l < INT_MIN) {
		return -1;
	}
	if (*s == '\0' || *end != '\0') {
		return -1;
	}
	i = l;
	return 0;
}

int randomInt(int min, int max)
{
	srand(time(NULL));
	double scaled = (double)rand() / RAND_MAX;
	return (int)((max - min + 1)*scaled + min);
}

void tostring(char str[], int num)
{
	int i, rem, len = 0, n;

	n = num;
	while (n != 0)
	{
		len++;
		n /= 10;
	}
	for (i = 0; i < len; i++)
	{
		rem = num % 10;
		num = num / 10;
		str[len - (i + 1)] = rem + '0';
	}
	str[len] = '\0';
}

int toint(char str[])
{
	int num = 0;
	for (int i = 0; i < 10; i++)
	{
		num = num + ((str[10 - (i + 1)] - '0') * pow(10, i));
	}
	return num;
}
//TOOLS