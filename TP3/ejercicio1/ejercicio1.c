/*
 Nombre Ejercicio: ejercicio1.c
 Trabajo Practico Nro 3
 Nro Ejercicio: 1
 Integrantes: 
		Barja Fernandez, Omar Max 36241378
		Cullia, Sebastian 35306522
		Dal Borgo, Gabriel 35944975
		Fernandez, Nicolas 38168581
		Toloza, Mariano 37113832

 Nro Entrega: Primera Reentrega (06/07/2017)
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

int main(int argc, char *argv[])
{
    
    if(argc > 1)
    {
	printf("Error: NO debe recibir parametros\n\n") ;
	exit(1) ;
    }

    pid_t pid1,pid2,pid3,pid4,pid5,pid6;

    int status1,status2, status3, status4, status5, status6;

    if((pid1=fork())==0) //pid 101
    {
        int padre=getppid(); //pid 100
        int abuelo=getpid(); //pid 101

        if((pid3=fork())==0) //pid 102
        {
	       //sleep(1);
               printf("Soy el proceso con PID 102 (%d) , Mi padre es el PID 101 (%d) , Mi abuelo es el PID 100 (%d)\n", getpid(), getppid(), padre);
        }
        else
        {
            if((pid4=fork())==0) //pid 103
            {
                //printf("Soy el Pid 103 Mi proceso es %d, Hijo dePid 101 %d, Nieto de Pid 100 %d", getpid(), getppid(), padre);
                if((pid5=fork())==0) //pid 104
                {	waitpid(pid3,NULL,0);
                    printf("Soy el proceso con PID 104 (%d), Mi padre es el PID 103 (%d), Mi abuelo es el PID 101 (%d), Mi bisabuelo es el PID 100 (%d)\n", getpid(), getppid(), abuelo, padre);

                }
                else
                {   //sleep(2);
			waitpid(pid3,NULL,0);
                    printf("Soy el proceso con PID 103 (%d), Mi padre es el PID 101 (%d), Mi abuelo es el PID 100 (%d)\n", getpid(), getppid(), padre);
                    //printf("Pid 101(%d, Hijo de %d)\n", getpid(), getppid());
                    waitpid(pid5,&status5,0);
                }
            }
            else
            {	
		//sleep(4);
		
                printf("Soy el proceso con PID 101 (%d) , Mi padre es el PID 100 (%d)\n", getpid(), getppid());
                waitpid(pid4, &status4, 0);
                waitpid(pid3, &status3, 0);
            }
        }
    }

    else
    {
        int padre=getpid(); //pid 100
	waitpid(pid1,NULL,0);
        if((pid2=fork())==0)
        {
            //printf("Soy el PID 105(%d, hijo de %d)\n", getpid(), getppid());
            if((pid6=fork())==0)
            {	//sleep(3);
                printf("Soy el proceso con PID 106 (%d), Mi padre es el PID 105 (%d) , Mi abuelo es el PID 100 (%d)\n", getpid(), getppid(),padre);
            }
            else
            {	//sleep(5);
                printf("Soy el proceso con PID 105 (%d) , Mi padre es el PID 100 (%d)\n", getpid(), getppid());
                waitpid(pid6, &status6,0);
            }
        }
        else
            {
            waitpid(pid1,&status1,0);
            waitpid(pid2,&status2,0);
	    //sleep(6);
            printf("Soy el proceso con PID 100 (%d), Mi hijo nro1 es el PID 101 (%d) y Mi hijo nro2 es el PID 105 (%d)\n", getpid(), pid1, pid2);
            }
    }


    return 0;
}
