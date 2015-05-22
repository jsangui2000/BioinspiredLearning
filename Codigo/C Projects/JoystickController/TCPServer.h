#ifndef __TCPServer_H__
#define __TCPServer_H__

int startTCP(int port);
int receiveMessage(char mstr[]);
void sendMessage(float pos1,float pos2);
void closeTCP();

#endif