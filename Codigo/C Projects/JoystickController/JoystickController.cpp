#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <string>
using namespace std;
#include "joystick.h"
#include "TCPServer.h"

char srvMsg[256];

int main()
{
	int cant = Joystick::deviceCount();
	cout << "cant joy: "<<cant<<endl;

	if (cant <=0)
	{
		system("pause");
		return 0;
	}

	Joystick* mj = new Joystick(0);
	mj->open();

	DIJOYSTATE2 js;
	//mj->poll(&js);

	float mx,my;

	
	startTCP(10201);


	//sendMessage(12.34,11.152);
	//system("pause");

	while(true)
	{
		int len = receiveMessage(srvMsg);
		if (len<=0) break;
		cout << "mensaje " << srvMsg<<endl;

		if(strcmp(srvMsg,"getAxis\n")==0)
		{
			mj->poll(&js);
			mx = (js.lX)/32767.5 -1;
			my = 1-(js.lY)/32767.5;
			cout<<mx<<" "<< my <<endl;
			sendMessage(mx,my);

		}

	}

	closeTCP();

	mj->close();




	return 0;
}