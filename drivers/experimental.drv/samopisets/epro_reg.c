// epro_reg.c - утилита для регистрации (индексации) файлов *.da
// для драйвера просмотра данных електронного блока "epro" 
// программой KrotW32
//

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#include "krtapi.h"
#include "krotepro.h"
#include "libdafil.h"

long KRTAPI krtDrvRegister (
 const char * datFile, 
 const char * trcFile, 
 char **errText, 
 long (KRTAPI *userBreak) (short percentDone)
 );

long KRTAPI UserBreak (short percentDone) {
    return KRT_OK;
};


int main(int argc, char *argv[]){

  char *Text_errors;

  Text_errors = (char *) malloc (256);
  if (krtDrvRegister ("", "epro_reg.trc", &Text_errors, UserBreak)!=KRT_OK){
      free(Text_errors);
      return KRT_ERR;
  };

  free(Text_errors);
  return KRT_OK;
 };

