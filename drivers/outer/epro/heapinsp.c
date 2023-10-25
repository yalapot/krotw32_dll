// heapinsp.c 
// ���������� ������ � ���� ���������������� ������� 
// ���������� ��������� � ������������ ������ �� ����.

#include <stdio.h>
#include <stdlib.h>

#include "heapinsp.h"

// ������ ������� ���������� ������ ������ 
// T_ADRESS_IN_HEAP * == NULL - ����� �������
T_ADRESS_IN_HEAP *list_blocks = NULL;


// ��������� ������� ������� ���������� ������ ������ 
T_ADRESS_IN_HEAP *last_block = NULL;


// ��������� ����� ������ � ���� � ������������ � ������
// ���������� ����� ����� ��� ������� ��������� � NULL ��� �������

#ifndef HEAP_DEBUG

void *heap_alloc  (long size) {
   return malloc(size);
};

#else

void *heap_alloc  (long size) {
  
  T_ADRESS_IN_HEAP *new_block = NULL;  


  // ������� ������ ��� ����� ������� ������
  new_block = malloc(sizeof(T_ADRESS_IN_HEAP));
  if (new_block == NULL) {
     return NULL; // � �� ����������!
   };
  new_block->next_block=NULL; // ����� ��������� ����� ������ !!!

  // ������� ������ ������� ��������� ����������
  new_block->adress = malloc(size);
  if (new_block->adress == NULL) {
     free(new_block); // �� ���, ������ � �������������� ������
     return NULL;
   };
  new_block->size = size;

  // ������ � ������ ���������� ���� ������:
  if (list_blocks == NULL) { // ���� ������ ��� ������, �� ...
     list_blocks = new_block;
   };

  // ���� ��� ���� ��������� �������, �� ������� � ���� ����� ����
  if (last_block!=NULL) last_block->next_block=new_block;

  // ��������� ������� ������ ������ ��������������
  last_block = new_block;

  return new_block->adress;
 }; // void *heap_alloc  (long size) {

#endif

// ������������ ����� ������ � ���� � ��������� ��� ����������� � �������
// ���������� NULL ��� ������� ������������ � ��� �� ����� ��� ���������� ������ � ������

#ifndef HEAP_DEBUG

void *heap_free ( void * free_adress) {
  free(free_adress);
  return NULL;
};

#else

void *heap_free ( void * free_adress) {

  T_ADRESS_IN_HEAP *check_block; // ��������� �� ������� ����������� ������� ������
  T_ADRESS_IN_HEAP *pred_block;  // ��������� �� ���������� ����� ����������� ��������� ������


  check_block  = list_blocks;
  pred_block = NULL;


  // ������ �������� ������ � ������� ������������ ��� ������������ ������
  while (check_block!=NULL) {
     if (check_block->adress == free_adress) { // ���� ����� - ���������� �����
        break;
      };
     pred_block = check_block;
     check_block  = check_block->next_block;
   };

  // ���� �� �����, �� ������� � �������:
  if (check_block == NULL) return free_adress;

  // � ����� ������������� ���� ���������, ����� ������ ����. �������
  if (check_block == last_block) last_block = pred_block;

  // ���� ������� ������ � ������
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