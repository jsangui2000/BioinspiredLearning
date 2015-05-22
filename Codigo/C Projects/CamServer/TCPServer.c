#include <stdio.h>
#include <stdlib.h>
#include<WinSock2.h>
#include <io.h>


#pragma comment(lib,"ws2_32.lib")

WSADATA wsa;
SOCKET s, new_socket;
struct sockaddr_in server, client;
int c;
char *message , server_reply[2000];

int startTCP(int port)
{
	SOCKET TempSock=SOCKET_ERROR;
	u_long iMode =1;

	printf("\nInitialising Winsock...");
	if (WSAStartup(MAKEWORD(2,2),&wsa)!=0)
	{
		printf("Failed. Error Code : %d",WSAGetLastError());
		return -1;
	}
	printf("Initialized.\n");

	if((s = socket(AF_INET , SOCK_STREAM , IPPROTO_TCP )) == INVALID_SOCKET)
	{
		printf("Could not create socket : %d" , WSAGetLastError());
		return -1;
	}

	printf("Socket created.\n");

	//Prepare the sockaddr_in structure
	server.sin_family = AF_INET;
	server.sin_addr.s_addr = INADDR_ANY;
	server.sin_port = htons( port );

	if( bind(s ,(struct sockaddr *)&server , sizeof(server)) == SOCKET_ERROR)
	{
		printf("Bind failed with error code : %d" , WSAGetLastError());
		system("pause");
		exit(-1);
	}

	puts("Bind done");

	//Listen to incoming connections
	listen(s , 1);

	//Accept and incoming connection
	puts("Waiting for incoming connections...");


	
	c = sizeof(struct sockaddr_in);

	while(TempSock == SOCKET_ERROR)
	{
		printf("Waiting for connection...\n");
		TempSock=accept(s,(struct sockaddr *)&client,NULL);
	}

	new_socket=TempSock;
	ioctlsocket(new_socket,FIONBIO,&iMode);

	puts("Connection accepted");
}

int receiveMessage(char mstr[])
{
	int recv_size;
	recv_size = recv(new_socket ,mstr  , 2000 , 0);
	if(recv_size>0)
	{
		mstr[recv_size] = '\0';
	}
	return recv_size;
}

void sendMessage(float pos1,float pos2)
{
	char mfloat[50];
	char mfloat2[50];
	//char *msg = "hola mundo\r\n";
	sprintf(mfloat,"%f",pos1);

	
	sprintf(mfloat2,"%f",pos2);

	send(new_socket, mfloat	, strlen(mfloat) , 0);
	send(new_socket, "#"					, sizeof(char),0);
	send(new_socket, mfloat2	, strlen(mfloat2) , 0);
	send(new_socket, "\n"					, sizeof(char),0);
	//send(new_socket,msg,strlen(msg),0);
	puts("enviado");


}

void closeTCP()
{
	closesocket(s);
	WSACleanup();
}

