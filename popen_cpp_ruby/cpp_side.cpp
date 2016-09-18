#include <iostream>
#include <stdio.h>
#include <unistd.h>
using namespace std;

int main() 
{
	FILE *fp;
	char logPrgName[] = "./rubylog.rb";

	fp = popen(logPrgName, "w");
	if(fp == NULL) cout<<"ERROR MUTHAFAKA!!!!!!!11\n";

	/* Let's turn fukken buffering OFF */
	setvbuf(fp, NULL, _IONBF, 0);

	char msg[] = "MESG MESG MESG\n";
	char msg1[] = "Message queue number two\n";
	fputs(msg, fp);
	sleep(1);
	fputs(msg1, fp);
	sleep(2);
	fputs(msg, fp);
	sleep(3);
	fputs(msg1, fp);

	int status = pclose(fp);
	if(status == -1) {
		cout<<"ERROR IN  PCLOSE MUUUU\n";
	}

	return 0;


}
