// heapinsp.c 
// Объявление данных и тела инструментальных функций 
// контролера выделения и освобождения памяти из кучи.

#include <stdio.h>
#include <stdlib.h>

#include "heapinsp.h"

// начало очереди выделенных блоков памяти 
// T_ADRESS_IN_HEAP * == NULL - конец очереди
T_ADRESS_IN_HEAP *list_blocks = NULL;


// последний элемент очереди выделенных блоков памяти 
T_ADRESS_IN_HEAP *last_block = NULL;


// выделение блока памяти в куче с регистрацией в списке
// возвращает адрес блока при удачном выделении и NULL при неудаче

#ifndef HEAP_DEBUG

void *heap_alloc  (long size) {
   return malloc(size);
};

#else

void *heap_alloc  (long size) {
  
  T_ADRESS_IN_HEAP *new_block = NULL;  


  // выделим память под новый элемент списка
  new_block = malloc(sizeof(T_ADRESS_IN_HEAP));
  if (new_block == NULL) {
     return NULL; // а не выделяется!
   };
  new_block->next_block=NULL; // будет признаком конца списка !!!

  // выделим память которую запросили параметром
  new_block->adress = malloc(size);
  if (new_block->adress == NULL) {
     free(new_block); // ну вот, теперь и регистрировать нечего
     return NULL;
   };
  new_block->size = size;

  // внесем в список выделенный блок памяти:
  if (list_blocks == NULL) { // если список еще пустой, то ...
     list_blocks = new_block;
   };

  // если уже есть последний элемент, то добавим к нему новый блок
  if (last_block!=NULL) last_block->next_block=new_block;

  // последний элемент теперь другой соответственно
  last_block = new_block;

  return new_block->adress;
 }; // void *heap_alloc  (long size) {

#endif

// освобождение блока памяти в куче с проверкой его регистрации в очереди
// возвращает NULL при удачном освобождении и тот же адрес при отсутствии адреса в списке

#ifndef HEAP_DEBUG

void *heap_free ( void * free_adress) {
  free(free_adress);
  return NULL;
};

#else

void *heap_free ( void * free_adress) {

  T_ADRESS_IN_HEAP *check_block; // указатель на текущий проверяемый элемент списка
  T_ADRESS_IN_HEAP *pred_block;  // указатель на предыдущий перед проверяемым элементом списка


  check_block  = list_blocks;
  pred_block = NULL;


  // начнем просмотр списка в поисках запрошенного для освобождения адреса
  while (check_block!=NULL) {
     if (check_block->adress == free_adress) { // если нашли - прекрашаем поиск
        break;
      };
     pred_block = check_block;
     check_block  = check_block->next_block;
   };

  // если не нашли, то выходим с ошибкой:
  if (check_block == NULL) return free_adress;

  // а вдруг освобождаемый блок последний, тогда меняем посл. элемент
  if (check_block == last_block) last_block = pred_block;

  // если элемент первый в списке
  if (pred_block == NULL) {
     list_blocks = check_block->next_block;
   } else {
     pred_block->next_block = check_block->next_block;
   };

  free(check_block->adress);
  free(check_block);

  return NULL;
 }; //  void *heap_free ( void * free_adress) {

#endif