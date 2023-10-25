#ifndef _INT_UNIT_H_
#define _INT_UNIT_H_

// ���������� ������������� �������� �� ����� ������ �� ���������� ���
// ������������ � ������� �����������

#ifndef u64
#define u64 unsigned long long
#endif

#ifndef u32
#define u32 unsigned long
#endif

#ifndef u16
#define u16 unsigned short
#endif

#ifndef u8
#define u8 unsigned char
#endif

#ifndef s64
#define s64  long long
#endif

#ifndef s32
#define s32 long
#endif

#ifndef s16
#define s16 short
#endif

#ifndef s8
#define s8 char
#endif


union u64items {
  u64 i64;    // ������ 64 ������ ��������
  u32 i32[2]; // 64 ������ �������� ��� ��� 32 ������ 
                   // (������� ����� � ������� �����)
  u16 i16[4]; // 64 ������ �������� ���  ������ 16 ������
  u8  i8[8];  // 64 ������ �������� ���  ������ 8 ������
}; // union u64_to_u32LowHi {

union u32items {
  u32 i32;
  u16 i16[2];
  u8  i8[4];
}; // union u32_to_u16LowHi {

union u16items {
  u16 i16;
  u8  i8[2];
}; // union u16_to_u8LowHi {

union s64items {
  s64 i64;    // ������ 64 ������ ��������
  u32 i32[2]; // 64 ������ �������� ��� ��� 32 ������ 
                   // (������� ����� � ������� �����)
  u16 i16[4]; // 64 ������ �������� ���  ������ 16 ������
  u8  i8[8];  // 64 ������ �������� ���  ������ 8 ������
}; // union s64_to_u32LowHi {

union s32items {
  s32 i32;
  u16 i16[2];
  u8  i8[4];
}; // union s32_to_u16LowHi {

union s16items {
  s16 i16;
  u8  i8[2];
}; // union s16_to_u8LowHi {

#endif  // #ifndef _INT_UNIT_H
