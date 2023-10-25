#include <stdio.h>
#include <stdlib.h>

#include <krot128.h>

short main (int argc, char *argv[]) {
  if (argc < 2)
   {
    fprintf(stdout, "\nUsage : report in_file");
    return 1;
   }
   VoiceReport(argv[1]);
  return 0;
}

#pragma argsused
void Lamp(unsigned char val) {
	return;
}
void Say (const char *msg) {
FILE *f;

	f = fopen("_say.bat", "wt");
	fprintf(f, "@echo off\n");
	fprintf(f, "- ");
	fprintf(f, msg);
	fprintf(f, "\n");
	fclose(f);
	system("_say.bat");
	unlink("_say.bat");
	return;
}