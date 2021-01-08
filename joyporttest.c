/*
compile with vbcc:
vc +kick13 -ljoyport joyporttest.c -o joyporttest
*/

#include <proto/exec.h>
#include <stdio.h>

struct Library *joyportBase = NULL;

int main() {
	LONG status;

	/* open joyport.library */
	if(!(joyportBase=OpenLibrary("joyport.library",0))) {
		printf("Can't open joyport.library\n");
		exit(20);
	}

	/* call getjoyport function from joyport.library */
	status = getjoyport(0);
	printf("status of joyport 0: %lx\n", status);

	status = getjoyport(1);
	printf("status of joyport 1: %lx\n", status);

	CloseLibrary(joyportBase);
	exit(0);
}
