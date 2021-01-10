/*
compile with vbcc:
vc +kick13 -ljoyport joyporttest.c -o joyporttest
*/

#include <proto/exec.h>
#include <stdio.h>

struct Library *joyportBase = NULL;

void portOutput(int port);

char *device[4] = {"GAMEPAD","MOUSE","JOYSTICK","UNKNOWN"};
char *UDLR[4] = {"RIGHT","LEFT","DOWN","UP"};
char *button_p[7] = {"PLAY","RWD","FFW","GREEN","YELLOW","RED","BLUE"};
char *button_m[3] = {"MIDDLE","LEFT","RIGHT"};
char *button_j[3] = {"3rd BUTTON","FIRE","2nd BUTTON"};
	
int main() {
	/* open joyport.library */
	if(!(joyportBase=OpenLibrary("joyport.library",0))) {
		printf("Can't open joyport.library\n");
		exit(20);
	}

	/* call getjoyport function from joyport.library */
	portOutput(0);
	portOutput(1);
	
	CloseLibrary(joyportBase);
	exit(0);
}

void portOutput(port) {
	int i,j;
	int b;
	long status, temp;
	
	status = getjoyport(port);
	printf("\nstatus of joyport %d: %lx\n", port, status);
	printf("controller type: %s\n", device[(status>>28)-1]);
	if (status>>28 & 1) {
		printf("direction: ");
		temp = status;
		b = 0;
		for(i = 0; i <= 3; i++) {
			if (temp & 1) {
				if (b) { printf("+"); }
				printf("%s",UDLR[i]);
				b = 1;
			}
			temp = temp >> 1;
		}
		if (!b) { printf("NONE"); }
		printf("\n");
	}
	
	printf("buttons pressed: ");
	b = 0;

	for(i = 0; i <= 6; i++) {
		if (status>>(17+i) & 1) {
			if (b) { printf("+"); }
			if (status>>28 == 1) {
				printf("%s", button_p[i]);
				b = 1;
			}
			if (status>>28 == 2) {
				j = i;
				if (i) { j = i-4; }
				printf("%s", button_m[j]);
				b = 1;
			}
			if (status>>28 == 3) {
				j = i;
				if (i) { j = i-4; }
				printf("%s", button_j[j]);
				b = 1;
			}
		}
	}
	if (!b) { printf("NONE"); }
	printf("\n\n");

}