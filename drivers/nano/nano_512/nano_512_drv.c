
#include <int_unit.h>
#include <krotnano_512.h>
#include <tracetool.h>

#include <quicklz.h>
#include <navigate.h>

#include <krotnano_512.c>

#include <krot_trc.c>

#include "acselerometr1.c"
#include "acselerometr2.c"

#include "directmove.c"
#include "drivewheel.c"
#include "height_arrow.h"
#include "hispead.c"
#include "baypass.h"
#include "thick_II.c"
#include "bending_plane.h"

#define CUT_TAILE  (300)

//////////////////////////////////////////////////////////////////////////
//Callback - �������
//////////////////////////////////////////////////////////////////////////


long WINAPI krtDrvFillData( KRTHANDLE handle, long group, long start,
                           long length, KRTDATA *screen, long *rowData)
{
  long i;
  long my_start  = start;
  long my_length = length;

  long cur_trace;
  long cur_idx;
  long cur_dim;
  long num_dim_in_cur_seam;

  long next_idx;
  long next_dim;
  long num_dim_in_next_seam;
  long serch_data_flag;

  long length_counter;
  long sens_counter;

  long beg_sens;
  long end_sens;
  long orient_for_cur_dim;
  long y_for_screen;
  long pos_in_screen;
  long shift_dim;

  T_RECORD_EXTEND_SENS * ext_sens;

  T_OPENED_TRACE *P_trace;

  long start_for_get_data, length_for_get_data;

  long odometer_for_cur_dim = 0;


  if (open_trace_counter==0) {
     sprintf (drvError, "��� �������� �����(krtDrvFillData)");
     return KRT_ERR;
  }

  // ������ �������� ������ � ������:
  for (cur_trace=0; cur_trace<open_trace_counter; cur_trace++) {
     if (handle==trace_list[cur_trace].handle) break;
  }
  if (cur_trace >= open_trace_counter) {
     sprintf(drvError, "�� ������ handle (krtDrvFillData)");
     return KRT_ERR; 
  }

  P_trace = trace_list[cur_trace].trace;

  my_start = my_start * trace_list[cur_trace].trace->virtual_trace_step /
                        trace_list[cur_trace].trace->trace_step;

  if ( trace_list[cur_trace].trace->ReversView > 0 )  {  // ��� ��������� � �������� �������
      my_start  = P_trace->trace_len - my_start - length * trace_list[cur_trace].trace->virtual_trace_step /
                                                           trace_list[cur_trace].trace->trace_step;
  }

  // �������� ��������� �� �������� group
  if (group >= P_trace->group_num) {
     sprintf(drvError, "group ������������ (krtDrvFillData)");
     return KRT_ERR;
  }

  for (i=0; i<P_trace->real_number_sensor_in_group[group] * my_length; i++) {
      screen[i]=0;    // �������� ����� �� ������ ������
  }

   // �������� ��������� �� ����������� ��������� ��������� start 
  if ( my_start > P_trace->trace_len || my_start < P_trace->idx_trc[0].beg_trace) {
     return KRT_OK;
  }

  if ( my_start > P_trace->max_sens_shift) {
     start_for_get_data = my_start - 200;
  } else {
      start_for_get_data = 0;
  }

  length_for_get_data = my_length + 200 + P_trace->max_sens_shift;

  if (start_for_get_data + length_for_get_data > P_trace->trace_len) {
     length_for_get_data = P_trace->trace_len - start_for_get_data;
  }

  if( my_start < P_trace->idx_head.trace_len ) {
     if (get_data(P_trace, start_for_get_data, length_for_get_data) == KRT_ERR) {
            return KRT_OK;
     }
  } else {
      return KRT_OK;
  };

  
  for (cur_idx = 0; cur_idx < P_trace->idx_head.num_idx_in_table; cur_idx++)
  {  // ���� ��� ������ 
       if ( my_start <= P_trace->idx_trc[cur_idx].beg_trace + P_trace->idx_trc[cur_idx].real_len) {
           break;
       }
  }

  if (cur_idx == P_trace->idx_head.num_idx_in_table) {
      return KRT_OK;
  }

  cur_dim = my_start - P_trace->idx_trc[cur_idx].beg_trace;
  num_dim_in_cur_seam = P_trace->idx_trc[cur_idx].real_len;

  switch(group) {
      case 0: {
          beg_sens = 0;
          end_sens = P_trace->linesense_size[group];
          break;
      }
      default: {
          beg_sens = 0;
          end_sens = 0;
          for (i=0; i<group; i++) {
              beg_sens += P_trace->linesense_size[i];
              end_sens += P_trace->linesense_size[i];
          }
          end_sens   += P_trace->linesense_size[group];
      }
  } // switch(group) {


  ext_sens = malloc ( sizeof(ext_sens[0]) * (my_length + 1) );

  fseek( P_trace->ext_idx_file_data, my_start  * sizeof(ext_sens[0]), SEEK_SET );
  fread(ext_sens, 1, sizeof(ext_sens[0]) * (my_length + 1), P_trace->ext_idx_file_data);


  // ��������� ������������� ������ 
  for (length_counter=0; length_counter < my_length; length_counter++) {
      if (P_trace->Orientation_OFF==0) {

         orient_for_cur_dim = ext_sens[length_counter].orient
                              * P_trace->real_number_sensor_in_group[group]
                               /P_trace->real_number_sensor_in_group[0];

         orient_for_cur_dim+=P_trace->Orientation_shift;

         if (group>0) { //�������� ��� ������� �����
             orient_for_cur_dim+=P_trace->Orientation_shift_2;
         }

      } else {
         orient_for_cur_dim = 0;
      }

      while (orient_for_cur_dim<0) {
         orient_for_cur_dim += (P_trace->real_number_sensor_in_group[group]);
      }
      orient_for_cur_dim %= (P_trace->real_number_sensor_in_group[group]);

      for (sens_counter=0; sens_counter < P_trace->corosion_sens_num; sens_counter++ ) {
         if (P_trace->Delete_sens_data[sens_counter] != SENSE_DELETE_FLAG) {
            y_for_screen = sens_counter - P_trace->Delete_sens_data[sens_counter];

            if (sens_counter>=beg_sens && sens_counter<end_sens ) {
               if (P_trace->Orinteation_Direct_count!=0) {
                  y_for_screen -= orient_for_cur_dim;
               } else {
                  y_for_screen += orient_for_cur_dim;
               }

               while (y_for_screen<0) {
                  y_for_screen += P_trace->real_number_sensor_in_group[group];
               }

               y_for_screen %= (P_trace->real_number_sensor_in_group[group]);

               pos_in_screen = (length * y_for_screen) + length_counter;

               if ( P_trace->Zerro_sens_data[sens_counter - P_trace->Delete_sens_data[sens_counter]] == 1) {
                  screen[pos_in_screen] = KRT_PALLETE_SIZE/2;
               } else { // if ( P_trace->Zerro_sens_data[sens_counter - P_trace->Delete_sens_data[sens_counter]] == 1) {

                  shift_dim = cur_dim + P_trace->sens_shift[sens_counter];
                                        // ^^^^^ ���� ���������� �������� �������

                  if ( shift_dim >= 0) {
                      // �� �������� �� ��� �������� �� ������� �������� ���
                      if (shift_dim < num_dim_in_cur_seam) {
                         KRTDATA direct_math;
                         KRTDATA revers_math;

                         direct_math = (KRTDATA)
                            ((P_trace->idx_trc[cur_idx].math_records[shift_dim].magn_sensors_data[sens_counter]
                              * KRT_PALLETE_SIZE
                             ) / P_trace->max_data_code);

                         revers_math = (KRTDATA)
                            ((P_trace->idx_trc[cur_idx].revers_math_records[shift_dim].magn_sensors_data[sens_counter]
                              * KRT_PALLETE_SIZE
                             ) / P_trace->max_data_code);


                         screen[pos_in_screen] = max(direct_math, revers_math);

                         rowData[pos_in_screen] =
                             P_trace->idx_trc[cur_idx].records[shift_dim].magn_sensors_data[sens_counter];

                      } else { //if (shift_dim < num_dim_in_cur_seam)
                         // �, ��� ��� ���� �� ���������� ��������� ��� �����
                         next_idx = cur_idx;
                         next_dim = shift_dim;
                         num_dim_in_next_seam=num_dim_in_cur_seam;
                         serch_data_flag=0;

                         do {
                            if ( (next_idx+1) < P_trace->idx_head.num_idx_in_table) {
                               next_idx++;
                            } else { // if (next_idx < P_trace->idx_head.num_idx_in_table)
                               break;
                            }

                            next_dim-=num_dim_in_next_seam;
                            if (P_trace->idx_trc[next_idx].records == NULL) {
                               continue;
                            }

                            num_dim_in_next_seam = P_trace->idx_trc[next_idx].real_len;
                            if (next_dim < num_dim_in_next_seam) serch_data_flag=1;
                            if (serch_data_flag==1) {
                               KRTDATA direct_math;
                               KRTDATA revers_math;

                               direct_math = (KRTDATA)
                                  ((P_trace->idx_trc[next_idx].math_records[next_dim].magn_sensors_data[sens_counter]
                                    *
                                    KRT_PALLETE_SIZE
                                   )
                                   / P_trace->max_data_code);

                               revers_math = (KRTDATA)
                                  ((P_trace->idx_trc[next_idx].revers_math_records[next_dim].magn_sensors_data[sens_counter]
                                    *
                                    KRT_PALLETE_SIZE
                                   )
                                   / P_trace->max_data_code);


                               screen[pos_in_screen] = max(direct_math, revers_math);

                               rowData[pos_in_screen] =
                                   P_trace->idx_trc[next_idx].records[next_dim].magn_sensors_data[sens_counter];
                             } 
                          } while (serch_data_flag==0);
                      } // else { if (shift_dim < num_dim_in_cur_seam)

                  } else {
                      screen[pos_in_screen] = 0;
                  }

                  if (drive_wheel_data != NULL) {
                     long dim_with_shift =  my_start + length_counter;

#ifdef USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS
                     dim_with_shift += P_trace->max_sens_shift;
#endif
                     if ( dim_with_shift > P_trace->trace_len ) dim_with_shift = P_trace->trace_len - 1;

                     odometer_for_cur_dim = (long) drive_wheel_data[dim_with_shift];
                  }

/*
  {
      char tmp_info[10240];

      sprintf (tmp_info, " P_trace->Odometer_0_sens = %ld\n P_trace->Odometer_1_sens = %ld\n",
               P_trace->Odometer_0_sens, P_trace->Odometer_1_sens);

      MessageBox(NULL, (LPCSTR)tmp_info, (LPCSTR)"2", MB_OK | MB_ICONERROR);
  }
*/

                  if (P_trace->Odometers_tools_use > 0) {
                      if ((sens_counter == P_trace->Odometer_0_sens) && (odometer_for_cur_dim == 0)) {
                          screen[pos_in_screen] = 125;
                      }

                      if ((sens_counter == P_trace->Odometer_1_sens) && (odometer_for_cur_dim == 1)) {
                          screen[pos_in_screen] = 199;
                      }
                  }
               } // else { // if ( P_trace->Zerro_sens_data[sens_counter - P_trace->Delete_sens_data[sens_counter]] == 1) {

               // �������� �� ��������� �� �������� ������������ ����������
               if (screen[pos_in_screen] >= KRT_PALLETE_SIZE) {
                  screen[pos_in_screen] = KRT_PALLETE_SIZE-1;
               }
            } //if (sens_counter>=beg_sens && sens_counter<end_sens ) {
         } // if (P_trace->Delete_sens_data[sens_counter] != SENSE_DELETE_FLAG)
      } // for (sens_counter==beg_sens;


      if (length_counter < (my_length-1)) { // �������� ����� �� ����.���.���
          cur_dim++; 
          if (cur_dim >= num_dim_in_cur_seam) {

               cur_idx ++;

               if (cur_idx == P_trace->idx_head.num_idx_in_table)
               {
                  sprintf(drvError, "���-�� �� ���������� ������� � ����. ���. ���(krtDrvFillData)");
                  free(ext_sens);
                  return KRT_OK;
               } // if (cur_idx == 

               cur_dim = 0;
               num_dim_in_cur_seam = P_trace->idx_trc[cur_idx].real_len;

               if (P_trace->idx_trc[cur_idx].records==NULL) break;
          }
      } // if (lengt_counter < (my_length-1)) { // �������� ����� �� ����.���.���
  } // for (length_counter=0; length_counter < my_length; length_counter++) { 

  free(ext_sens);

  if (trace_list[cur_trace].trace->virtual_trace_step != trace_list[cur_trace].trace->trace_step) {
      // ���� ����������� ������� ���������� �� �������
      KRTDATA *tmp_screen;
      long *tmp_rowData;
      long virtual_length;

      tmp_screen = malloc ( sizeof(tmp_screen[0]) * (length + 1) * P_trace->real_number_sensor_in_group[group]);
      tmp_rowData = malloc ( sizeof(tmp_rowData[0]) * (length + 1) * P_trace->real_number_sensor_in_group[group]);

      memcpy(tmp_screen, screen, ( sizeof(tmp_screen[0]) * length * P_trace->real_number_sensor_in_group[group]));
      memcpy(tmp_rowData, rowData, ( sizeof(tmp_rowData[0]) * length * P_trace->real_number_sensor_in_group[group]));

      // ����������� �������� ��� ���� ��� ��������
      for (length_counter=0; length_counter < length; length_counter++) { 
         virtual_length = length_counter * trace_list[cur_trace].trace->virtual_trace_step / trace_list[cur_trace].trace->trace_step;
         for(sens_counter=0; sens_counter < P_trace->real_number_sensor_in_group[group]; sens_counter++)
         {
             screen[length * sens_counter + length_counter] = 
                         tmp_screen[length * sens_counter + virtual_length];

             rowData[length * sens_counter + length_counter] = 
                         tmp_rowData[length * sens_counter + virtual_length];
         }
      }

      free(tmp_screen);
      free(tmp_rowData);

  } // ��������� ��������� ������ ���� ����������� ������� ���������� �� �������

  if ( trace_list[cur_trace].trace->ReversView > 0 ) {
      long tmp_value_sens;

      // ������������� �������� ��� ������ � �������� �������
      for (length_counter=0; length_counter < length/ 2; length_counter++) { 
         for(sens_counter=0; sens_counter < P_trace->real_number_sensor_in_group[group]; sens_counter++) {
              tmp_value_sens = screen[length * sens_counter + length_counter];
              screen[length * sens_counter + length_counter] = 
                        screen[length * sens_counter + length - length_counter - 1];
              screen[length * sens_counter + length - length_counter - 1] = (KRTDATA) tmp_value_sens;


              tmp_value_sens = rowData[length * sens_counter + length_counter];
              rowData[length * sens_counter + length_counter] = 
                        rowData[length * sens_counter + length - length_counter - 1];
              rowData[length * sens_counter + length - length_counter - 1] = tmp_value_sens;
         }
      }

      // ������������� �������� �� ����������
      for (length_counter=0; length_counter < length; length_counter++) { 
         for(sens_counter=0; sens_counter < P_trace->real_number_sensor_in_group[group]/2; sens_counter++) {
              tmp_value_sens = screen[length * sens_counter + length_counter];
              screen[length * sens_counter + length_counter] = 
                  screen[length * (P_trace->real_number_sensor_in_group[group] - sens_counter-1) + length_counter];
              screen[length * (P_trace->real_number_sensor_in_group[group] - sens_counter-1) + length_counter]
                  = (KRTDATA) tmp_value_sens;

              tmp_value_sens = rowData[length * sens_counter + length_counter];
              rowData[length * sens_counter + length_counter] = 
                  rowData[length * (P_trace->real_number_sensor_in_group[group] - sens_counter-1) + length_counter];
              rowData[length * (P_trace->real_number_sensor_in_group[group] - sens_counter-1) + length_counter]
                  = tmp_value_sens;
         }
      }
  } //   if ( trace_list[cur_trace].trace->ReversView > 0 )

  if ( trace_list[cur_trace].trace->BendingPlane > 0 ) {
      T_bending_plane bending_plane;
      long my_start_vog;
      long dimension_counter;
      long bending_plane_color=0;
      long bending_plane_beg_sens;
      long line_thick = 0;

      for (dimension_counter = 0; dimension_counter < my_length; dimension_counter++) {

          if ( trace_list[cur_trace].trace->ReversView > 0 ) {
              my_start = start * trace_list[cur_trace].trace->virtual_trace_step /
                                 trace_list[cur_trace].trace->trace_step;
          }

          my_start_vog = (my_start + dimension_counter) * 
                         trace_list[cur_trace].trace->trace_step / 10
                         + (trace_list[cur_trace].trace->PigL3 / 10);

          if ( strncmp(trace_list[cur_trace].trace->target_name, "42000102", 8)==0 )
          {
              my_start_vog -= 2 * (trace_list[cur_trace].trace->PigL3 / 10);
          }

          if ( ( strncmp(trace_list[cur_trace].trace->target_name, "20000101", 8)==0 ) )  {
              my_start_vog -= (trace_list[cur_trace].trace->PigL3 / 10);
          }

          my_start_vog += trace_list[cur_trace].trace->ShiftNavigation_data;

          if (my_start_vog < 1 ) my_start_vog = 1;

          if  (bending_plane_data != NULL)
          {
              if (bending_plane_data->file_data != NULL) {
                  Get_bending_plane_Data(my_start_vog, &bending_plane);

                  bending_plane_beg_sens = (long) (bending_plane.Angle * 100
                       * P_trace->real_number_sensor_in_group[group]
                       / 1200);

                  bending_plane_beg_sens += P_trace->real_number_sensor_in_group[group]/4;
                  bending_plane_beg_sens -= P_trace->real_number_sensor_in_group[group] / 20;

                  for (line_thick = 0; line_thick < 8; line_thick ++ ) {
                      if (line_thick == 4) {
                          bending_plane_beg_sens += P_trace->real_number_sensor_in_group[group] / 10 - 4;
                      }
                      bending_plane_beg_sens += 1;

                      if (bending_plane_beg_sens < 0) 
                          bending_plane_beg_sens = P_trace->real_number_sensor_in_group[group] + bending_plane_beg_sens;
                      if ( bending_plane_beg_sens >= P_trace->real_number_sensor_in_group[group] )
                          bending_plane_beg_sens -= P_trace->real_number_sensor_in_group[group];

                      bending_plane_color = 0;
                      if ( bending_plane.Radius < 500) bending_plane_color = 120;
                      if ( bending_plane.Radius < trace_list[cur_trace].trace->BendingPlane) bending_plane_color = KRT_PALLETE_SIZE-1;

                      if (bending_plane_color > 0) {
                          screen[length * bending_plane_beg_sens + dimension_counter]
                              = (KRTDATA) bending_plane_color;

                          if ( bending_plane_beg_sens >= P_trace->real_number_sensor_in_group[group]/2) {
                              screen[length * (bending_plane_beg_sens
                                      - P_trace->real_number_sensor_in_group[group]/2)
                                      + dimension_counter]
                                 = (KRTDATA) bending_plane_color;
                          } else {
                              screen[length * (bending_plane_beg_sens
                                      + P_trace->real_number_sensor_in_group[group]/2)
                                      + dimension_counter]
                                 = (KRTDATA) bending_plane_color;
                          }
                      } // if (bending_plane_color > 0) {
                  } // for (line_thick = 0; line_thick < 8; line_thick ++ ) {
              } // if (bending_plane_data->file_data != NULL) {
          }  // if  (bending_plane_data != NULL)
      } // for (dimension_counter = 0; dimension_counter < my_length; dimension_counter++) {
  } // if ( trace_list[cur_trace].trace->BendingPlane > 0 ) {

  return KRT_OK;
}; // krtDrvFillData


long WINAPI krtDrvGetFirstNode ( KRTHANDLE handle, T_NODE *node,        
                                long start, long sensType, long sensIndex,
                                long length, long controlSize )
 {

   long my_start;
   long my_start_vog;

   long cur_trace;

   T_RECORD_EXTEND_SENS ext_sens;

   if (open_trace_counter==0) {
      sprintf (drvError, "��� �������� �����(krtDrvGetFirstNode)");
      return KRT_ERR;
   };

   // ������ �������� ������ � ������:
   for (cur_trace=0; cur_trace<open_trace_counter; cur_trace++) {
      if (handle==trace_list[cur_trace].handle) break;
   };

   if (cur_trace >= open_trace_counter) {
      sprintf(drvError, "�� ������ handle (krtDrvGetFirstNode)");
      return KRT_ERR; 
   };

   // �������� controlSize
   if (controlSize>0 && controlSize<length) {
      trace_list[cur_trace].trace->controlSize = (double)(length)/(double)(controlSize);
   } else {
      trace_list[cur_trace].trace->controlSize = trace_list[cur_trace].trace->virtual_trace_step;
   };

   my_start = (start/trace_list[cur_trace].trace->virtual_trace_step);

   my_start = my_start * trace_list[cur_trace].trace->virtual_trace_step /
              trace_list[cur_trace].trace->trace_step;


   if (trace_list[cur_trace].trace->controlSize < trace_list[cur_trace].trace->virtual_trace_step)
   {
      trace_list[cur_trace].trace->controlSize=trace_list[cur_trace].trace->virtual_trace_step;
   };
   // ��������� controlSize � ������ �������� ��������� ���� ��� krtDrvGetNextNode
   trace_list[cur_trace].trace->nodeType = sensType;
   trace_list[cur_trace].trace->nodeIndex = sensIndex;
   trace_list[cur_trace].trace->nodePos = start;
   // �������� ��������� ���� ��� krtDrvGetNextNode

   my_start_vog = my_start * trace_list[cur_trace].trace->trace_step / 10 
                   + (trace_list[cur_trace].trace->PigL3 / 10);

   my_start_vog += trace_list[cur_trace].trace->ShiftNavigation_data;

   if (my_start_vog < 1 ) my_start_vog = 1;

#ifdef USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS
   my_start += trace_list[cur_trace].trace->max_sens_shift;
#endif


   if ( trace_list[cur_trace].trace->ReversView > 0 )
   {
       // ��� ��������� ���������
       my_start  = trace_list[cur_trace].trace->trace_len - my_start;
   };

   if ( my_start <= 0) my_start = 1;

    // �������� ��������� �� ����������� ��������� ��������� start 
   if ( my_start >= trace_list[cur_trace].trace->trace_len) 
   {
      sprintf(drvError, "�� �������� start=%i � ������ (krtDrvGetFirstNode)",start);
      my_start = trace_list[cur_trace].trace->trace_len-1;
      // return KRT_ERR;
   };

   if (trace_list[cur_trace].VogData.file_data!=NULL) {
       // ��������� � ������ ������ ������ � rec.vog
       if (GetVogData(my_start_vog, &trace_list[cur_trace].VogData, drvError)!=KRT_OK) {
           strcat(drvError, "(krtDrvGetFirstNode)");
           return KRT_ERR;
       };
   };

   fseek( trace_list[cur_trace].trace->ext_idx_file_data, my_start * sizeof(ext_sens), SEEK_SET );
   fread(&ext_sens, 1, sizeof(ext_sens), trace_list[cur_trace].trace->ext_idx_file_data);

   switch (sensType) {

      case (KRT_SENS_ODO): {     // �������
         node->Val=start;
         node->Pos=start;
         break;
      };

      case (KRT_SENS_TIMER): {   // ������
         node->Val = ext_sens.time;

         if ( trace_list[cur_trace].trace->ReversView > 0 )
         {
             // ��� ��������� ���������
             node->Val  = trace_list[cur_trace].trace->trace_time - ext_sens.time;
         }

         node->Pos = start;
         break;
      };

      case (KRT_SENS_ORIENT): {  // ����������
         node->Val = ext_sens.orient + trace_list[cur_trace].trace->Orientation_shift;

         while (node->Val < 0) {
            node->Val += trace_list[cur_trace].trace->real_number_sensor_in_group[0];
         };

         while (node->Val >= trace_list[cur_trace].trace->real_number_sensor_in_group[0]) {
            node->Val %= trace_list[cur_trace].trace->real_number_sensor_in_group[0];
         };

         node->Pos = start;
         break;
       };

     case (KRT_SENS_TEMP): {    // �����������
        node->Val = ext_sens.termo;
        node->Pos = start;
        break;
       };

     case (KRT_SENS_THICK): {   // �������
        node->Val = ext_sens.Thick;
        node->Pos = start;
        break;
      };

     case (KRT_SENS_PRESS) : // ��������
     {
         byte pressure;

         if (trace_list[cur_trace].trace->pressure_data == 0)
         { 
            node->Val = 0;
            node->Pos = start;
            break;
         }

         fseek( trace_list[cur_trace].trace->pressure_data, my_start, SEEK_SET );
         fread( &pressure, 1, sizeof(pressure), trace_list[cur_trace].trace->pressure_data);

         // ��� ������� � ����������� ���������
         node->Val = (long) (((double)pressure * 3300.0 / 255 - 330) * 0.26116);

         if ( (strncmp(trace_list[cur_trace].trace->target_name, "10050101", 8)==0)
//              || (strncmp(trace_list[cur_trace].trace->target_name, "10050101", 8)==0)
             )
         {
             node->Val = (long) (((5000.0 * (double)pressure / 255.0  - 195.0) /6.4 - 101.0) * 10.0);
         }

         node->Pos = start;
         break;
     };

     case (KRT_SENS_SHAKE) : // ��������
     {
         node->Val= 0;
         node->Pos = start;
         break;
     }

     case (KRT_SENS_AZIMUTH) : // Psi;  ������, (������ * 100)
     {
         node->Val=(long) (trace_list[cur_trace].VogData.cur_data.Psi
                           * 180 * 100 / PI
                          );
         node->Pos = start;
         break;
     };

     case (KRT_SENS_TANGAZH) : // Teta  ������, (������ * 100)
     {
        node->Val=(long) (trace_list[cur_trace].VogData.cur_data.Teta
                          * 180 * 100 / PI
                         );
        node->Pos = start;
        break;
     };

     case (KRT_SENS_UGOL3D) : // ���� 3D, (������ * 100)
     {
        double h=cos(trace_list[cur_trace].VogData.cur_data.Psi);
        double v=cos(trace_list[cur_trace].VogData.cur_data.Teta);
        double Ugol3D=acos(h*v);

        node->Val=(long) (Ugol3D * 180 * 100 / PI);
        node->Pos = start;
        break;
     };

     case (KRT_SENS_EXT): {    // ���������������

        T_arrow_hd arrow_hd;

        T_bending_plane bending_plane;

        long accel_start;

        accel_start = my_start + trace_list[cur_trace].trace->max_sens_shift;
        if ( accel_start <= 0) accel_start = 1;
        if ( accel_start >= trace_list[cur_trace].trace->trace_len) 
        {
           accel_start = trace_list[cur_trace].trace->trace_len-1;
        };

        if (trace_list[cur_trace].NavData.file_data != NULL) {
            // ��������� � ������ ������ ������ � rec.mat
            if (GetNavData(my_start_vog, &trace_list[cur_trace].NavData, drvError) != KRT_OK) {
                strcat(drvError, "(krtDrvGetFirstNode)");
                return KRT_ERR;
            };
        } else {
            if (sensIndex > (6
                             +
                             trace_list[cur_trace].trace->add_ext_sens_bps_pressure
                             +
                             trace_list[cur_trace].trace->add_ext_sens_thick_II
                            )
               )
            {
               break;
            }
        };

        // ����������  �������������� II �����, ���� ��� �� ��������
        if ((trace_list[cur_trace].trace->add_ext_sens_thick_II == 0) &&
            (sensIndex > 5)
           )
        {
           sensIndex += 1;
        }

        // ����������  �������� ������, ���� ��� �� ��������
        if ((trace_list[cur_trace].trace->add_ext_sens_bps_pressure == 0) &&
            (sensIndex > 6)
           )
        {
           sensIndex += 1;
        }

        switch (sensIndex) {

           case (0): { // �����������
              node->Val=0;
              node->Pos = start;
              if (direct_move_data != NULL)
              {
                 node->Val=(long) direct_move_data[my_start];
              }
              break;
           };

           case (1): { // ������� ������
              node->Val=0;
              node->Pos = start;
              if (drive_wheel_data != NULL)
              {
                 node->Val=(long) drive_wheel_data[my_start];
              }
              break;
           };

           case (2): { // ������ ��������
              node->Val=0;
              node->Pos = start;

              node->Val = read_one_hispead_data( trace_list[cur_trace].trace->hispead_file_data,
                                                 my_start);

              break;
           };

           case (3): { // ������� ����
              int idx_count;

              // ���� �� �������� ��� ������ ������ ������
              for (idx_count=0; idx_count < trace_list[cur_trace].trace->idx_head.num_idx_in_table; idx_count++)
              {
                 if ( trace_list[cur_trace].trace->idx_trc[idx_count].beg_trace >= my_start) break;
              };

              node->Val=trace_list[cur_trace].trace->idx_trc[idx_count-1].file_num;
              node->Pos = start;

              break;
            };

           case (4): { // acselerometr1

              node->Val=0;
              node->Pos = start;
              if (acselerometr1_data != NULL)
              {
                 node->Val=(acselerometr1_TYPE_VALUE) acselerometr1_data[accel_start];
              }
              break;
           }; /* case  4 */

           case (5): { // acselerometr2
              node->Val=0;
              node->Pos = start;
              if (acselerometr2_data != NULL)
              {
                 node->Val=(acselerometr1_TYPE_VALUE) acselerometr2_data[accel_start];
              }
              break;
           };

           case (6): { // thick_II
              node->Val=0;
              node->Pos = start;
              if (thick_II_data != NULL)
              {
                 double tolshinav_mm = thick_II_data[accel_start];
                 tolshinav_mm *= 0.02111;
                 tolshinav_mm = tolshinav_mm * 1.1 - 52;
                 tolshinav_mm *= 1000;

                 tolshinav_mm += 2000;

                 node->Val=(long) tolshinav_mm;
              }
              break;
           };

           case (7): { // �������� ������
              node->Val=0;
              node->Pos = start;


              if (trace_list[cur_trace].BPdata.file_data != NULL)
              {
                  if (Get_BPdata(my_start, &trace_list[cur_trace].BPdata, drvError) != KRT_OK) {
                      strcat(drvError, "(krtDrvGetFirstNode)");
                      return KRT_ERR;
                  };

                  if ( (strncmp(trace_list[cur_trace].trace->target_name, "1405", 4)==0) ||
                       (strncmp(trace_list[cur_trace].trace->target_name, "1410", 4)==0)
                     )
                  {
                      // ��� �������� 1405, 1410
                      // P = (A-186)*3300 / 0,24 / 1023  ���
                      node->Val=(long) (trace_list[cur_trace].BPdata.cur_data.abs_pressure - 186) * 
                                       3300 *100/24 / 1023 ;

                  } else {
                      // ��� �������� 1406, 1411, 1007, 1012
                      // P = (A-186)*3300/(16*150/13790*1023)  ���
                      node->Val=(long) (trace_list[cur_trace].BPdata.cur_data.abs_pressure - 186) * 
                                       3300 / 178;
                  }

              }; // if (trace_list[cur_trace].BPdata.file_data != NULL)

              break;
           };

           case (8):  // bending_plane.Radius
           case (9):  // bending_plane.Angle
           {
              bending_plane.Radius = 0;
              bending_plane.Angle = 0;
              if  (bending_plane_data != NULL)
                  if (bending_plane_data->file_data != NULL)
                      Get_bending_plane_Data(my_start_vog, &bending_plane);
              node->Pos = start;

              node->Val=(long) (bending_plane.Radius);

              if (sensIndex == 9)
                  node->Val=(long) (bending_plane.Angle);

              break;
           };

           case (10): { // Vog X
              if (trace_list[cur_trace].NavData.file_data!=NULL) {
                  node->Val=(long) (trace_list[cur_trace].NavData.cur_data.VogX * VOG_KOEFF_UMN);
              }
              node->Pos = start;
              break;
           };
           case (11): { // Vog Y
              if (trace_list[cur_trace].NavData.file_data!=NULL) {
                  node->Val=(long) (trace_list[cur_trace].NavData.cur_data.VogY * VOG_KOEFF_UMN);
              };
              node->Pos = start;
              break;
           };
           case (12): { // Vog Z
              node->Val=(long) (trace_list[cur_trace].NavData.cur_data.VogZ * VOG_KOEFF_UMN);
              node->Pos = start;
              break;
           };
           case (13): { // Accel X
              node->Val=(long) (trace_list[cur_trace].NavData.cur_data.AccelX * ACCEL_KOEFF_UMN);
              node->Pos = start;
              break;
           };
           case (14): { // Accel Y
              node->Val=(long) (trace_list[cur_trace].NavData.cur_data.AccelY * ACCEL_KOEFF_UMN);
              node->Pos = start;
              break;
           };
           case (15): { // Accel Z
              node->Val=(long) (trace_list[cur_trace].NavData.cur_data.AccelZ * ACCEL_KOEFF_UMN);
              node->Pos = start;
              break;
           };

           case (16): { // arrow hd
              arrow_hd.height = 0;
              if  (arrowData != NULL)
                  if (arrowData->file_data != NULL)
                      Get_arrow_hd_Data(my_start_vog, &arrow_hd);
              node->Val=(long) (arrow_hd.height * 100000);
              node->Pos = start;
              break;
            };

           default:{
              sprintf(drvError, "bad sensIndex parameter(krtDrvGetFirstNode)");
              return KRT_ERR;
           };
        }; // switch (sensIndex) {

        break;
     };  // case (KRT_SENS_EXT): {    // ���������������

     default : {
        node->Val=0;
        node->Pos=start;
        sprintf(drvError, "bad sensType parameter(krtDrvGetFirstNode)");
        return KRT_ERR;
     };
   };

   return KRT_OK;
 }; /* krtDrvGetFirstNode */


long WINAPI krtDrvGetNextNode ( KRTHANDLE handle, T_NODE *node) {

   long cur_trace;

   if (open_trace_counter==0) {
      sprintf (drvError, "��� �������� �����(krtDrvGetNextNode)");
      return KRT_ERR;
   };

   // ������ �������� ������ � ������:
   for (cur_trace=0; cur_trace<open_trace_counter; cur_trace++) {
      if (handle==trace_list[cur_trace].handle) break;
   };

   if (cur_trace >= open_trace_counter) {
      sprintf(drvError, "�� ������ handle (krtDrvGetNextNode)");
      return KRT_ERR; 
   };

   trace_list[cur_trace].trace->nodePos += (long)
               trace_list[cur_trace].trace->controlSize;

   if (krtDrvGetFirstNode (handle, node, trace_list[cur_trace].trace->nodePos,
                           trace_list[cur_trace].trace->nodeType,
                           trace_list[cur_trace].trace->nodeIndex, (long) trace_list[cur_trace].trace->controlSize, 1
                          )
       == KRT_ERR)
   {
      strcat(drvError, "(krtDrvGetNextNode)");
      return KRT_ERR; 
   };

   return KRT_OK;
 }; /* krtDrvGetNextNode */


long WINAPI krtDrvGetFirstNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node,        
                                long start, long sensGroup,
                                long length, long controlSize )
 {
  int i; // ���������� ��� �������� � ������

  long my_start  = start/10;

  long my_start_vog;

  int curent_trace;  /* ������ ������� ������ � ������ ����. ����� */

   /* �������� �� ������������ handle : */
  if (handle<=0) return KRT_ERR;   // ������������ �������� handle
  if (open_trace_counter==0) return KRT_ERR; // ��� �������� �����
  for (i=0; i<open_trace_counter; i++) {
     if (handle==trace_list[i].handle) break;
   };
  if (i==open_trace_counter) {
     sprintf(drvError, "Unknown handle trace (krtDrvGetFirstNode)");
     return KRT_ERR; // ���  ������ handle
   } else curent_trace=i;

   /* ���������� ��������� ������������ ��������� node */
  if (node==NULL) {
     sprintf(drvError, "node==NULL (krtDrvGetFirstNode)");
     return KRT_ERR;
   };

   /* �������� ��������� �� ����������� ��������� ��������� start */
  if (my_start<0) my_start=0;
  if ( my_start >= trace_list[curent_trace].trace->trace_len ) {
    my_start = trace_list[curent_trace].trace->trace_len;
   };
  trace_list[curent_trace].cur_par_nodeGroup.startPos=my_start;
  trace_list[curent_trace].cur_par_nodeGroup.sensPos=my_start;

  if (controlSize>0 && controlSize<length/10) {
     trace_list[curent_trace].cur_par_nodeGroup.controlSize=(float)(length/controlSize/9.9);
   } else {
     trace_list[curent_trace].cur_par_nodeGroup.controlSize=1.0;
   };

  my_start= (long) (
          ((float)(trace_list[curent_trace].cur_par_nodeGroup.sensPos-
                 trace_list[curent_trace].cur_par_nodeGroup.startPos)*
           trace_list[curent_trace].cur_par_nodeGroup.controlSize) +
           trace_list[curent_trace].cur_par_nodeGroup.startPos
          );

  trace_list[curent_trace].cur_par_nodeGroup.sensPos++;


  start=my_start*10;

  my_start_vog = my_start + (trace_list[curent_trace].trace->PigL3 / 10);

  my_start_vog += trace_list[curent_trace].trace->ShiftNavigation_data;

  if (my_start_vog < 1 ) my_start_vog = 1;

#pragma warning(disable : 4127)  // ����� ������� ��� ��������� � ������� �����

   /* �������� �������� � ����������� �� ���� ������� */
  if (sensGroup && KRT_SENS_VOG) {

#pragma warning(default:4127)

     // ��������� � ������ ������ ������ � Vog.mat
     if (GetVogData(my_start_vog, &trace_list[curent_trace].VogData, drvError)!=KRT_OK)
     {
        strcat(drvError, "(krtDrvGetFirstNodeGroup)");
        return KRT_ERR;
     };

      node->vogx   = trace_list[curent_trace].VogData.cur_data.VogX*10;
      node->vogy   = trace_list[curent_trace].VogData.cur_data.VogY*10;
      node->vogz   = trace_list[curent_trace].VogData.cur_data.VogZ*10;
                                                                     
      node->vogext1= trace_list[curent_trace].VogData.cur_data.Psi;
      node->vogext2= trace_list[curent_trace].VogData.cur_data.Teta;
      node->vogext3= trace_list[curent_trace].VogData.cur_data.Gamma;
                                                               
      node->vogPos = start; //trace_list[curent_trace].VogData.cur_data.Dist*10;
      node->odoPos = start;

   } else {
       sprintf(drvError, "bad sensGroup parameter(krtDrvGetFirstNodeGroup)");
       return KRT_ERR;
   };

   trace_list[curent_trace].cur_par_nodeGroup.sensTypeGroup = sensGroup;

   return KRT_OK;
 }; /* krtDrvGetFirstNodeGroup  */


long WINAPI krtDrvGetNextNodeGroup ( KRTHANDLE handle, T_NODEGROUP *node) {
  int i; /* ���������� ��� �������� � ������ */

  int curent_trace;  /* ������ ������� ������ � ������ ����. ����� */
  long start;
  long my_start;

  long my_start_vog;

   /* �������� �� ������������ handle : */
  if (handle<=0) return KRT_ERR;   // ������������ �������� handle
  if (open_trace_counter==0) return KRT_ERR; // ��� �������� �����
  for (i=0; i<open_trace_counter; i++) {
     if (handle==trace_list[i].handle) break;
   };
  if (i==open_trace_counter) {
     sprintf(drvError, "Unknown handle trace (krtDrvGetNextNodeGroup)");
     return KRT_ERR; // ���  ������ handle
   } else curent_trace=i;

   /* ���������� ��������� ������������ ��������� node */
  if (node==NULL) {
     sprintf(drvError, "node==NULL (krtDrvGetNextNodeGroup)");
     return KRT_ERR;
   };

  my_start= (long) (
          ((float)(trace_list[curent_trace].cur_par_nodeGroup.sensPos-
                 trace_list[curent_trace].cur_par_nodeGroup.startPos)*
           trace_list[curent_trace].cur_par_nodeGroup.controlSize) +
           trace_list[curent_trace].cur_par_nodeGroup.startPos
          );

  trace_list[curent_trace].cur_par_nodeGroup.sensPos++;

   /* �������� ��������� �� ����������� ��������� ��������� start */
  if (my_start<0) my_start=0;
  if ( my_start >= trace_list[curent_trace].trace->trace_len ) {
    my_start = trace_list[curent_trace].trace->trace_len;
   };

  start=my_start*10;

#ifdef USE_MAX_SENS_SHIFT_FOR_SHIFT_SENS
  my_start += (trace_list[curent_trace].trace->max_sens_shift * trace_list[curent_trace].trace->trace_step) /10;
#endif

#pragma warning(disable : 4127)  // ����� ������� ��� ��������� � ������� �����

   /* �������� �������� � ����������� �� ���� ������� */
  if (trace_list[curent_trace].cur_par_nodeGroup.sensTypeGroup && KRT_SENS_VOG) {

#pragma warning(default:4127)

     my_start_vog = my_start +     (trace_list[curent_trace].trace->PigL3 / 10);

     my_start_vog += trace_list[curent_trace].trace->ShiftNavigation_data;

     if (my_start_vog < 1 ) my_start_vog = 1;

     // ��������� � ������ ������ ������ � Vog.mat
     if (GetVogData(my_start_vog, &trace_list[curent_trace].VogData, drvError) != KRT_OK)
     {
        strcat(drvError, "(krtDrvGetNextNodeGroup)");
        return KRT_ERR;
      };

      node->vogx   = trace_list[curent_trace].VogData.cur_data.VogX*10;
      node->vogy   = trace_list[curent_trace].VogData.cur_data.VogY*10;
      node->vogz   = trace_list[curent_trace].VogData.cur_data.VogZ*10;
                                                                     
      node->vogext1= trace_list[curent_trace].VogData.cur_data.Psi;
      node->vogext2= trace_list[curent_trace].VogData.cur_data.Teta;
      node->vogext3= trace_list[curent_trace].VogData.cur_data.Gamma;
                                                               
      node->vogPos = start;
      node->odoPos = start;

   } else {
       sprintf(drvError, "bad sensGroup parameter(krtDrvGetNextNodeGroup)");
       return KRT_ERR;
   };

   return KRT_OK;
 }; /* krtDrvGetNextNodeGroup */



typedef struct
{
   long  trace;
   long  shift;
} T_length_shift;


T_length_shift length_shift[1000000];

/* ������� ����������� ������ */
long KRTAPI krtDrvRegister (
 const char * datFile,
 const char * trcFile,
 char **errText,
 long (KRTAPI *userBreak) (short percentDone)
 ) 
{

   FILE *add_length;
   long cur_shift=0;
   long cur_pos=0;


   long data_path_len;
   char data_path[_MAX_PATH]; // ���� �� ������ � �������

   FILE * data_file;
   char file_name[1024];

   FILE *idx_file_data;
   char idx_file_name[1024];

   FILE *ext_idx_file_data;
   char ext_idx_file_name[1024];
   FILE *pressure_data;

   T_RECORD_EXTEND_SENS rec_ext_sens;

   long file_counter;
   long test_counter;
   long sens_counter;

   �_file_header  file_head;

   _arc_block  arc_block;

   _data_block unpacked_data_block;

   _record_data * data_block;

   _record_data * data_block_skip;

   long size_data_block_skip;
   long data_block_skip_counter;
   long skip_tests;

   char qlz_scratch[QLZ_SCRATCH_COMPRESS];

   long pred_time;
   long pred_prioritet_od = 0;

   T_IDX_TRC idx_rec;
   T_IDX_TRC idx_rec_for_write;
   T_IDX_HEADER idx_head;

   long first_length = -1;

   double cA, sA;
   double dAy, KAy, dAz, KAz;

   long my_orient;

   long decompressed_size;

   long i;
   char key_name[1024];
   char key_value[1024];

   long sens_sort [MAGN_SENSORS];
   long sens_shift [MAGN_SENSORS];

   double Full_Exponent_average;
   static double Exponent_average[MAGN_SENSORS];
   static long first_Exponent_average = 1;
   static double Exponent_average_koefficient = 0.1;

   static long II_first_Exponent_average = 1;

   unsigned short tmp_sort_data[MAGN_SENSORS];

   static unsigned short pred_accel_x = 0;

   long arc_block_counter;

   long max_data_code;

   long num_file_in_trace;
   long search_file_counter;

   long first_file_index;
   long persent_value;

   char direct_move = 0;
   char drive_wheel = 0;
//   long file_len;

   T_VOG_DATA VogData;

   hyper Time_us = 0;
   hyper pred_Time_us = 0;
   hyper Spead_hi = 0;
   hyper pred_Spead_hi = 0;
   long  pred_Odometr=0;

   long reset_flag = 0;

   long accel_0_flag = 0;
   long accel_1_flag = 0;

   unsigned short thick_2;

   long excess_pressure_flag = 0;

//   FILE *odometer_counter_file;


   (void) errText;


   strcpy(file_name, &datFile[strlen(datFile)-9]);
   file_name[5]=0;
   first_file_index = idx_head.first_file_index = atoi(file_name);

   // ������� ���� �� ������ � ������� �� ������� ���� �� ������� �����
   strcpy(data_path, datFile);

   data_path_len=strlen(data_path);

   while ((data_path_len>0) && (data_path[data_path_len-1]!='\\')) {
     data_path[data_path_len - 1] = 0;
     data_path_len--;
   };
   // ��������� ������ ������ ���� �� ������� ����� (��� �����)

   sprintf(idx_file_name, "%strace.idx", data_path);

   idx_file_data = fopen(idx_file_name, "wb");
   if (idx_file_data==NULL) {
       sprintf(drvError, "������ �������� ����� %s. \n", idx_file_name);
       return KRT_ERR;
   };

   sprintf(ext_idx_file_name, "%sext_data.idx", data_path);

   ext_idx_file_data = fopen(ext_idx_file_name, "wb");
   if (ext_idx_file_data==NULL) {
       sprintf(drvError, "������ �������� ����� %s. \n", ext_idx_file_name);
       return KRT_ERR;
   };

   sprintf(ext_idx_file_name, "%spressure.idx", data_path);

   pressure_data = fopen(ext_idx_file_name, "wb");
   if (pressure_data==NULL) {
       sprintf(drvError, "������ �������� ����� %s. \n", ext_idx_file_name);
       return KRT_ERR;
   };


   idx_head.num_idx_in_table = 0;
   idx_head.trace_len        = 0;
   idx_head.trace_time       = 0;
   idx_rec.pred_odom_result_counter = 0;

   num_file_in_trace = 0;

   for (search_file_counter = first_file_index; search_file_counter < 4096; search_file_counter++)
   {
       sprintf(file_name, STR_FILE_MASK, data_path, search_file_counter);
       data_file = fopen(file_name, "rb");
       if (data_file != NULL)
       {
          fclose(data_file);
          num_file_in_trace ++;
       } else {
          break;
       }
   } // (file_counter*100)/ num_file_in_trace


  // ������� ID �����
  sprintf(file_name, STR_FILE_MASK, data_path, first_file_index);
  data_file = fopen(file_name, "rb");
  if (data_file == NULL) return KRT_ERR;

  read_file_header_nano512(data_file, &file_head);

  if (check_file_ID(file_head.target_name) == KRT_ERR)
  {
      fclose(data_file);
      remove( trcFile );
      return KRT_ERR;
  }
  fclose(data_file);
  // �������� ID �����

  // ������� ������ � trc-���� 

  // ������� � trc-���� ���� �� ������� �������
  WritePrivateProfileString(DRIVER_DATA, PATH_DATA_KEY, "",trcFile);

  // ������� � trc-���� ������ ������� �����
  sprintf(key_value, "%ld", idx_head.first_file_index);
  WritePrivateProfileString(DRIVER_DATA, FIRST_FILE_INDEX_KEY, key_value,trcFile);

  // ������� � trc-���� ����� ���������� ��������
  sprintf(key_value, "%ld", MAGN_SENSORS);
  WritePrivateProfileString(DRIVER_DATA, CORROSION_SENS_NUM_KEY, key_value,trcFile);

#pragma warning(disable : 4090)  // ����� ������� ��� ���������-������ ��� �������� � �������

  // ������� � trc-���� ��� ��������
  Create_long_key_not_rewrite(TRACE_STEP_KEY, DRIVER_DATA, ODOMETER_STEP, trcFile);

  // ������� � trc-���� ��� ������������ ��������
  Create_long_key_not_rewrite(VIRTUAL_TRACE_STEP_KEY, DRIVER_DATA, ODOMETER_STEP, trcFile);

  // ������� � trc-���� ���������� ������
  Create_long_key_not_rewrite(GROUP_NUM_KEY, DRIVER_DATA, GROUP_NUM_IN_DEVICE, trcFile);

  // ������� � trc-���� ���-�� �������� �������� � ������ �����
  sprintf(key_name, "%s%i", LINESENSE_SIZE_KEY, 0);
  Create_long_key_not_rewrite(key_name, DRIVER_DATA, FIRST_SENSLINE_SIZE, trcFile);

#pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
  if (GROUP_NUM_IN_DEVICE > 1) {
     sprintf(key_name, "%s%i", LINESENSE_SIZE_KEY, 1);
     Create_long_key_not_rewrite(key_name, DRIVER_DATA, THECOND_SENSLINE_SIZE, trcFile);
  }
#pragma warning(default:4127)
  // �������� � trc-���� ���-�� �������� �������� � ������ �����

  // ������� � trc-���� �������� ������������� ������ ������������
  // ������������
  Create_long_key_not_rewrite(ShiftNavigation_data_KEY, DRIVER_DATA, 0, trcFile);

  // ������� � trc-���� ���� ����� ReversView
  Create_long_key_not_rewrite(ReversView_KEY, DRIVER_DATA, 0, trcFile);

  // ������� � trc-���� ���� ����� Bending Plane
  Create_long_key_not_rewrite(BendingPlane_KEY, DRIVER_DATA, 0, trcFile);

  // ������� � trc-���� ���� ����� ����������
  Create_long_key_not_rewrite(Orientation_OFF_KEY, DRIVER_DATA, 0, trcFile);

  // ������� � trc-���� ������������ �������������� ��� ����������
  dAy = Create_double_key_not_rewrite("orient_dAy", DRIVER_DATA, Orientation_dAy_value, trcFile);
  KAy = Create_double_key_not_rewrite("orient_KAy", DRIVER_DATA, Orientation_KAy_value, trcFile);
  dAz = Create_double_key_not_rewrite("orient_dAz", DRIVER_DATA, Orientation_dAz_value, trcFile);
  KAz = Create_double_key_not_rewrite("orient_KAz", DRIVER_DATA, Orientation_KAz_value, trcFile);

  // ������� � trc-���� �������� ����������
  Create_long_key_not_rewrite(Orientation_shift_KEY, DRIVER_DATA, Orientation_shift_group_1, trcFile);

  // ������� � trc-���� �������� ���������� ��� ������� �����
#pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
  if (GROUP_NUM_IN_DEVICE > 1) 
       Create_long_key_not_rewrite(Orientation_shift_2_KEY, DRIVER_DATA, Orientation_shift_group_2, trcFile);
#pragma warning(default:4127)

  // ������� � trc-���� ���� ����� ����������
  Create_long_key_not_rewrite(Smooth_data_OFF_KEY, DRIVER_DATA, 0, trcFile);

  // ������� � trc-���� ���� ����� Revers_MATH
  Create_long_key_not_rewrite(Standart_MATH_KEY, DRIVER_DATA, 1, trcFile);

  // ������� � trc-���� ���� ����� Revers_MATH
  Create_long_key_not_rewrite(Revers_MATH_KEY, DRIVER_DATA, 0, trcFile);

  // ������� � trc-���� �������� �� ������� �����
  Create_long_key_not_rewrite(Amplification_Group0_KEY, DRIVER_DATA, Amplification_Group0, trcFile);

#pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
  // ������� � trc-���� �������� �� ������� �����
  if (GROUP_NUM_IN_DEVICE > 1) 
       Create_long_key_not_rewrite(Amplification_Group1_KEY, DRIVER_DATA, Amplification_Group1, trcFile);
#pragma warning(default:4127)

  // ������� � trc-���� ������ ���� ����������� �� ������� �����
  Create_long_key_not_rewrite("smooth_win_length0", DRIVER_DATA, smooth_win_length0, trcFile);

  // ������� � trc-���� ������ ���� ����������� �� ������� �����
#pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
  if (GROUP_NUM_IN_DEVICE > 1) 
       Create_long_key_not_rewrite("smooth_win_length1", DRIVER_DATA, smooth_win_length1, trcFile);
#pragma warning(default:4127)

  // ������� � trc-���� ������������ �������� �������
  max_data_code = Create_long_key_not_rewrite(MAX_DATA_CODE_KEY, DRIVER_DATA, MAX_DATA_CODE, trcFile);

  // ������� � trc-���� ������� �������������� ������� ��������
  Create_str_key_not_rewrite("invert_sens_data", DRIVER_DATA, Invert_sens_string, trcFile);

  // �������� �������� ��� ������ ��������
  Create_str_key_not_rewrite(Delete_sens_data_KEY, DRIVER_DATA, Delete_sens_string, trcFile);

  // �������� ��������� ��� ������ ��������
  Create_str_key_not_rewrite(Zerro_sens_data_KEY, DRIVER_DATA, Zerro_sens_string, trcFile);

  // �������� ����� ����� ��� ������ ���������
  Create_str_key_not_rewrite(RecVog_KEY, DRIVER_DATA, "", trcFile);
  Create_str_key_not_rewrite(RecMat_KEY, DRIVER_DATA, "", trcFile);

  // ������� ������ ���������� �������
  Create_long_key_not_rewrite(Median_Filter_length_KEY, DRIVER_DATA, 0, trcFile);

   // ������� � trc-���� ������������� ������
   for (i=0; i < MAGN_SENSORS; i++) sens_sort[i] =  i;

   create_sens_sort (sens_sort);

   for (i=0; i < MAGN_SENSORS; i++) {
      sprintf(key_name, "%s%d", SENS_SORT_KEY, i);
      Create_long_key_not_rewrite(key_name, DRIVER_DATA, sens_sort[i], trcFile);
    };
   // �������� � trc-���� ������������� ������

   // ������� � trc-���� ������ �������� ��������
   for (i=0; i < MAGN_SENSORS; i++) sens_shift[i] = 0;

   create_sens_shift (sens_shift);

   for (i=0; i < MAGN_SENSORS; i++) {
      sprintf(key_name, "%s%d", SENS_SHIFT_KEY, i);
      Create_long_key_not_rewrite(key_name, DRIVER_DATA, sens_shift[i], trcFile);
   };
   // �������� � trc-���� ������ �������� ��������

   // ������� � trc-���� ���� ������������� ������������ ��������
   Create_long_key_not_rewrite(Odometers_tools_use_KEY, DRIVER_DATA, Odometers_tools_use_value, trcFile);

   // ������� � trc-���� ����� ������� �� �������� ���� 0 �������
   Create_long_key_not_rewrite(Odometer_0_sens_KEY, DRIVER_DATA, Odometer_0_sens_value, trcFile);

   // ������� � trc-���� ����� ������� �� �������� ���� 1 �������
   Create_long_key_not_rewrite(Odometer_1_sens_KEY, DRIVER_DATA, Odometer_1_sens_value, trcFile);

#pragma warning(default:4090)
   // �������� ������ � trc-����


   memset( &VogData, sizeof(VogData), 0);

   VogData.file_data = NULL;

   Init_VogData(&VogData, data_path, (char *) trcFile, drvError);


   open_for_write_file_acselerometr1_data(data_path);
   open_for_write_file_acselerometr2_data(data_path);

   open_for_write_file_direct_move_data(data_path);

   open_for_write_file_drive_wheel_data(data_path);

   open_for_write_file_hispead_data(data_path);

//   sprintf(file_name, "%sodometers_counter.txt", data_path);
//   odometer_counter_file = fopen(file_name, "wt");

   #pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
   if ( MAGN_SENSORS != FIRST_SENSLINE_SIZE)
   #pragma warning(default:4127)
   {
       open_for_write_file_thick_II_data(data_path);
   }

  sprintf(file_name, STR_FILE_MASK, data_path, first_file_index);
  file_counter=first_file_index;

  while ( (data_file = fopen(file_name, "rb")) != NULL) {

      sprintf(register_log_file_name, "%sReg_Log.txt", data_path);
      sprintf(register_log_info, "%s\n", file_name);
      Reg_Log(register_log_info);

      persent_value = (file_counter-first_file_index)*100 / num_file_in_trace;
      if (persent_value<0)persent_value=0;
      if (persent_value>99)persent_value=99;

      // �������� �� �������� �� ������������ �������� ��� ������������� � 
      // ������ ��������� ������� ����������� ������
      if (userBreak((short) persent_value ) ) {
         sprintf (drvError, "�������� ������������� (krtDrvRegister)");

         fclose(data_file);
         data_file=NULL;

         fclose(idx_file_data);
         idx_file_data=NULL;

         fclose(ext_idx_file_data);
         idx_file_data=NULL;

         fclose(pressure_data);
         pressure_data=NULL;

         return KRT_ERR;
      };

      read_file_header_nano512(data_file, &file_head);

      idx_head.num_sens = file_head.magn_sensors_num;

      arc_block_counter = 0;

      while (fread( &arc_block.header, 1, sizeof(arc_block.header), data_file) == sizeof(arc_block.header)) {


           if ( first_length == -1 ) {
               pred_time = 0;

               idx_rec.property = (byte) pred_prioritet_od;

//               if (arc_block.header.begin_odom_cnt > 0)
//               {
//                   idx_rec.pred_odom_result_counter = arc_block.header.begin_odom_cnt-1;
//               } else {
//                   idx_rec.pred_odom_result_counter = arc_block.header.begin_odom_cnt;
//               };

              first_length = 0;
           };


           arc_block_counter ++;

           idx_rec.beg_trace         = idx_head.trace_len;
           idx_rec.shift_in_file     = ftell(data_file) - sizeof(arc_block.header);
           idx_rec.file_num          = (short) file_counter;
           idx_rec.num_test_in_block = arc_block.header.real_dim;
//           idx_rec.property          = (byte) arc_block.header.status;

           memcpy(&idx_rec_for_write, &idx_rec, sizeof(idx_rec) );

           // ������ � ������������� ������
           fread( arc_block.arc_data, 1, arc_block.header.compressed_block_size, data_file);

           decompressed_size = qlz_decompress( arc_block.arc_data, (char*) unpacked_data_block.records, qlz_scratch);

           if (decompressed_size == 0) {
               sprintf(register_log_file_name, "%sReg_Log.txt", data_path);
               sprintf(register_log_info, "   block in file %lds, begin_odom_cnt %ld \n", 
                         arc_block_counter, arc_block.header.begin_odom_cnt);
               Reg_Log(register_log_info);

               continue;
           };
/*	 ZSTD

           decompressed_size=ZSTD_decompress(
                                           (char*) unpacked_data_block.records,
                                           sizeof(unpacked_data_block.records),
                                           arc_block.arc_data,                    
                                           arc_block.header.compressed_block_size
                                          );

*/

           delta_decode( (char*) unpacked_data_block.records, sizeof(unpacked_data_block.records) );
           data_block = malloc(sizeof(data_block[0]) * RECORDS_IN_BLOCK);
           DeOptimize( (unsigned char*) unpacked_data_block.records,
                       (unsigned char*) data_block,
                       sizeof(_record_data)/2, RECORDS_IN_BLOCK);
           // ��������� � ��������������� ������

           idx_head.trace_time = data_block[arc_block.header.real_dim-1].time;

           // ����������� �� ������� ���� �� ��������
           idx_rec_for_write.real_len = 0;
           data_block_skip_counter = 0;

           size_data_block_skip = arc_block.header.real_dim * 2048;

           data_block_skip = malloc(sizeof(data_block_skip[0]) * size_data_block_skip);
           if (data_block_skip == NULL) {
              return KRT_ERR;  
              break;
           };

           for (test_counter = 0; test_counter < arc_block.header.real_dim; test_counter++)
           {
               skip_tests = data_block[test_counter].odom_result_counter - 
                            idx_rec.pred_odom_result_counter;

//
//   { // &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//      char tmp_str[1024];
//
//      if ( skip_tests > 1000)
//      {
//          skip_tests += 900;
//
//          sprintf(tmp_str,"d_trace = %ld, skip_tests = %ld\n", d_trace, skip_tests);
//
//          MessageBox(NULL, tmp_str, "��������������", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
//      }
//   } // &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

               if ((skip_tests <= 0) /* || (skip_tests >= 1000)*/ )
               {
                   skip_tests = 0;
                   if (test_counter == 0)
                   {
                       reset_flag = 1;
                   };
               }

               if ( (data_block[test_counter].service_bits & 1) != pred_prioritet_od)
               {
                   pred_prioritet_od = data_block[test_counter].service_bits & 1;
                   idx_rec.property = (byte) pred_prioritet_od;
                   skip_tests += ADD_THEN_CAHANGE_ODOM;

                   length_shift[cur_pos].trace = (idx_head.trace_len + data_block_skip_counter - cur_shift) * 5;
                   cur_shift += ADD_THEN_CAHANGE_ODOM;
                   length_shift[cur_pos].shift = cur_shift * 5;
                   cur_pos++;
               }

               while (skip_tests > 0)
               {
                    memcpy( &data_block_skip[data_block_skip_counter],
                            &data_block[test_counter],
                            sizeof(data_block[test_counter])
                          );

                    data_block_skip_counter++;

                    if (data_block_skip_counter >= size_data_block_skip)
                    {
                       data_block_skip_counter = size_data_block_skip - 1;
                       break;
                    }

                    skip_tests--;
               }; // while (skip_tests > 0)

               idx_rec.pred_odom_result_counter = data_block[test_counter].odom_result_counter;

           }; // for (test_counter = 0; test_counter < arc_block.header.real_dim; test_counter++)

           idx_rec_for_write.real_len = data_block_skip_counter;
           idx_head.trace_len += idx_rec_for_write.real_len;
           idx_rec.real_len  = idx_rec_for_write.real_len;

           free(data_block);
           data_block = data_block_skip;
           // ������������ �� ������� ���� �� ��������

           // ����������� ������
           for (test_counter = 0; test_counter < idx_rec_for_write.real_len; test_counter++)
           {
               
               for (sens_counter = 0; sens_counter < MAGN_SENSORS; sens_counter++)
               {
                  tmp_sort_data[sens_counter] =
                     data_block[test_counter].magn_sensors_data[sens_sort[sens_counter]];
               };

               for (sens_counter = 0; sens_counter < MAGN_SENSORS; sens_counter++)
               {
                  data_block[test_counter].magn_sensors_data[sens_counter] =
                    tmp_sort_data[sens_counter];
               };
           };
           // ������������� ������

           // ������� ������� �������������� ��������
           for (test_counter = 0; test_counter < idx_rec_for_write.real_len; test_counter++) {

              if ( (data_block[test_counter].accel_x & 0xff) == 0 )
              {
                  data_block[test_counter].accel_x = pred_accel_x;
              } else {
                  pred_accel_x = data_block[test_counter].accel_x;
              };

// ----------------------------------------------------------------------------------------
              // ����� ������������� ��������
              drive_wheel = data_block[test_counter].service_bits & 0x1;

              #ifdef CALL_LOG
//                 // ������� ������ service_bits
//                 sprintf(tmp_log_str, "%d\n", data_block[test_counter].service_bits);
//                 Log(tmp_log_str);
              #endif

              // ����� ����������� ��������
              direct_move = 1;

              if ( ( drive_wheel == 0 
                     && data_block[test_counter].service_bits & 0x2
                   )
                    ||
                   ( drive_wheel == 1
                     && data_block[test_counter].service_bits & 0x4
                   )
                 )
              {
                  direct_move = -1;
              }

// -----------------------------------------------------------------------------------------

              // ������� ����������
              cA=0; sA=0;

              #ifdef CALL_LOG
                 // ������� ������ ��������������
//                 if (debug_counter == 2)
//                 {
//                     sprintf(tmp_log_str, "%d, %d\n", data_block[test_counter].accel_x, data_block[test_counter].accel_y);
//                     Log(tmp_log_str);
//                     debug_counter=0;
//                 };
//
//                debug_counter++;
              #endif

              #ifdef CALL_LOG
                 // ������� ������ ��������� �������� � ������ �����
//                     sprintf(tmp_log_str, "%ld, %ld, %ld, %ld, %d, %d\n", data_block[test_counter].odom_result_counter,
//                                                                      data_block[test_counter].odom1_counter,
//                                                                      data_block[test_counter].odom2_counter,
//                                                                      data_block[test_counter].time,
//                                                                      data_block[test_counter].time_us,
//                                                                      data_block[test_counter].service_bits & 1
//                     );
//                     Log(tmp_log_str);
              #endif

              write_file_acselerometr1_data(data_block[test_counter].accel_x);
              write_file_acselerometr2_data(data_block[test_counter].accel_y);

//              // ��� ��� #�������� ������ ��������������
//              write_file_acselerometr1_data(data_block[test_counter].odom1_counter);
//              write_file_acselerometr2_data(data_block[test_counter].odom2_counter);
//              fprintf(odometer_counter_file, "%ld, %ld\n", data_block[test_counter].odom1_counter,data_block[test_counter].odom2_counter);


              if (data_block[test_counter].accel_x < 20) accel_0_flag = 1;
              if (data_block[test_counter].accel_y < 20) accel_1_flag = 1;

              data_block[test_counter].accel_x = (u16) Orientation_x_smooth(data_block[test_counter].accel_x);
              data_block[test_counter].accel_y = (u16) Orientation_y_smooth(data_block[test_counter].accel_y);

              if (Orientation_shift_direct)
              {
                  cA=((double)(data_block[test_counter].accel_y - dAz)) / (KAz);
                  sA=((double)(data_block[test_counter].accel_x - dAy)) / (KAy);
              } else {
                  sA=((double)(data_block[test_counter].accel_y - dAz)) / (KAz);
                  cA=((double)(data_block[test_counter].accel_x - dAy)) / (KAy);
              };

              my_orient = calkulate_orientation(cA, sA, (double) (FIRST_SENSLINE_SIZE - Deleted_sens_num));

#ifdef ORIENTATION_FROM_VOG
              my_orient = get_orient_from_VOG( idx_head.trace_len * ODOMETER_STEP / 10,
                                              &VogData,
                                              FIRST_SENSLINE_SIZE - Deleted_sens_num);
#endif

              rec_ext_sens.orient = my_orient;

              rec_ext_sens.time   = data_block[test_counter].time;

              rec_ext_sens.termo = calc_termo(data_block[test_counter].temperature);

//              rec_ext_sens.termo = data_block[test_counter].odom2_counter;

              // �������� ���������� ��������
              Time_us = data_block[test_counter].time;
              Time_us *= 1000;
              Time_us += data_block[test_counter].time_us;

              Spead_hi = (data_block[test_counter].odom_result_counter - pred_Odometr);
              Spead_hi *= ODOMETER_STEP;
              Spead_hi *= 1000000;
              if ( (Time_us - pred_Time_us) > 0)
              {
                  Spead_hi /= (Time_us - pred_Time_us);
              } else {
                  Spead_hi = pred_Spead_hi;
              }
              // ��������� ���������� ��������

              pred_Time_us = Time_us;
              pred_Spead_hi = Spead_hi;
              pred_Odometr = data_block[test_counter].odom_result_counter;

              // �������� ������� ��� ������� �����
              if (first_Exponent_average)
              {
                  for (sens_counter = 0; sens_counter < THICK_NUM_DATA; sens_counter++)
                  {
                     Exponent_average[sens_counter] =
                          data_block[test_counter].magn_sensors_data[sens_counter];

                  };
                  first_Exponent_average = 0;
              } else {
                  for (sens_counter = 0; sens_counter < THICK_NUM_DATA; sens_counter++)
                  {
                     Exponent_average[sens_counter] =
                          (Exponent_average[sens_counter] * (1-Exponent_average_koefficient));

                     Exponent_average[sens_counter] +=
                          (data_block[test_counter].magn_sensors_data[sens_counter] * Exponent_average_koefficient);
                  };
              };

              Full_Exponent_average = 0;
              for (sens_counter = 0; sens_counter < THICK_NUM_DATA; sens_counter++)
              {
                 Full_Exponent_average += Exponent_average[sens_counter];
              };

              Full_Exponent_average /= THICK_NUM_DATA;
              rec_ext_sens.Thick = (long) Full_Exponent_average;

              // �������������� �������, ���� ������������� ������� �������
              if (Invert_sens_string[0] == '0')
                  rec_ext_sens.Thick = max_data_code - rec_ext_sens.Thick;
              // ��������� ������� ��� ������� �����

//              rec_ext_sens.Thick = data_block[test_counter].odom1_counter;

              // �������� ������� ��� ������� �����, ���� �� ���� 
              #pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
              if ( MAGN_SENSORS != FIRST_SENSLINE_SIZE)
              #pragma warning(default:4127)
              {
                  if (II_first_Exponent_average)
                  {
                      for (sens_counter = FIRST_SENSLINE_SIZE; sens_counter < MAGN_SENSORS; sens_counter++)
                      {
                         Exponent_average[sens_counter] =
                              data_block[test_counter].magn_sensors_data[sens_counter];

                      };
                      II_first_Exponent_average = 0;
                  } else {
                      for (sens_counter = FIRST_SENSLINE_SIZE; sens_counter < MAGN_SENSORS; sens_counter++)
                      {
                         Exponent_average[sens_counter] =
                              (Exponent_average[sens_counter] * (1-Exponent_average_koefficient));

                         Exponent_average[sens_counter] +=
                              (data_block[test_counter].magn_sensors_data[sens_counter] * Exponent_average_koefficient);
                      };
                  };

                  Full_Exponent_average = 0;
                  for (sens_counter = FIRST_SENSLINE_SIZE; sens_counter < MAGN_SENSORS; sens_counter++)
                  {
                     Full_Exponent_average += Exponent_average[sens_counter];
                  };

                  Full_Exponent_average /= THECOND_SENSLINE_SIZE;

                  thick_2 = (unsigned short) Full_Exponent_average;
                  thick_2 = (unsigned short) max_data_code - thick_2;
              }
              // ��������� ������� ��� ������� �����


              if ( fwrite( &rec_ext_sens, 1, sizeof(rec_ext_sens), ext_idx_file_data) != sizeof(rec_ext_sens))
              {
                  sprintf(drvError, "������ ������ ����� %s. \n", ext_idx_file_name);

                  fclose(data_file);
                  data_file=NULL;

                  fclose(idx_file_data);
                  idx_file_data=NULL;

                  fclose(ext_idx_file_data);
                  idx_file_data=NULL;

                 return KRT_ERR;
              };

              if (data_block[test_counter].pressure > 128)
              {
                  excess_pressure_flag = 1;
              };
 

              if ( fwrite( &data_block[test_counter].pressure, 1, 1, pressure_data) != 1)
              {
                  sprintf(drvError, "������ ������ ����� pressure. \n", ext_idx_file_name);

                  fclose(data_file);
                  data_file=NULL;

                  fclose(idx_file_data);
                  idx_file_data=NULL;

                  fclose(ext_idx_file_data);
                  idx_file_data=NULL;

                  fclose(pressure_data);
                  pressure_data=NULL;

                 return KRT_ERR;
              };

              write_file_direct_move_data(direct_move);

              write_file_drive_wheel_data(drive_wheel);

              write_file_hispead_data((long)Spead_hi);

              #pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
              if ( MAGN_SENSORS != FIRST_SENSLINE_SIZE)
              #pragma warning(default:4127)
              {
                  write_file_thick_II_data(thick_2);
              }

              pred_time = data_block[test_counter].time;

           }; // for (test_counter = 0; test_counter < idx_rec_for_write.real_len; test_counter++)

           free(data_block);

           // ������� ������� �������� ������
           if ( fwrite( &idx_rec_for_write, 1, sizeof(idx_rec_for_write), idx_file_data) != sizeof(idx_rec_for_write))
           {
               sprintf(drvError, "������ ������ ����� %s. \n", idx_file_name);

               fclose(data_file);
               data_file=NULL;

               fclose(idx_file_data);
               idx_file_data=NULL;

               fclose(ext_idx_file_data);
               idx_file_data=NULL;

               fclose(pressure_data);
               pressure_data=NULL;

               return KRT_ERR;
           };

           idx_head.num_idx_in_table++;
           // �������� ������� �������� ������

      } // while (fread( &arc_block.header, 1, sizeof(arc_block.header), data_file) == sizeof(arc_block.header)) {

      fclose(data_file);
      data_file=NULL;

      file_counter++;

      sprintf(file_name, STR_FILE_MASK,  data_path, file_counter);

  };//  while (data_file = fopen(file_name, "rb"))

  if ( fwrite( &idx_head, 1, sizeof(idx_head), idx_file_data) != sizeof(idx_head))
  {
      sprintf(drvError, "������ ������ ����� %s. \n", idx_file_name);
      return KRT_ERR;
  };

#pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
  if (ADD_THEN_CAHANGE_ODOM > 0)
#pragma warning(default:4127)
  {
      sprintf(idx_file_name, "%strace_shift.log", data_path);
      add_length = fopen(idx_file_name, "wb");

      length_shift[cur_pos].trace = idx_head.trace_len * 5;
      length_shift[cur_pos].shift = cur_shift * 5;

      for (i=cur_pos;i >= 0; i--) 
      {
         fwrite( &length_shift[i], 1, sizeof(length_shift[0]), add_length);
//         fprintf(add_length, "%ld, %ld\n", length_shift[i].trace, length_shift[i].shift);
      }
      fclose(add_length);
  };

  fclose(idx_file_data);
  idx_file_data=NULL;

  fclose(ext_idx_file_data);
  idx_file_data=NULL;

  fclose(pressure_data);
  pressure_data=NULL;

  if (VogData.file_data != NULL) {
      fclose(VogData.file_data);
      VogData.file_data = NULL;
  };

    close_for_write_file_acselerometr1_data();

    close_for_write_file_acselerometr2_data();

    close_for_write_file_direct_move_data();

    close_for_write_file_drive_wheel_data();

    close_for_write_file_hispead_data();

//    fclose(odometer_counter_file);

    #pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
    if ( MAGN_SENSORS != FIRST_SENSLINE_SIZE)
    #pragma warning(default:4127)
    {
        close_for_write_file_thick_II_data();
    }

  // ������� � trc-���� ������ ������ � ����������
  sprintf(key_name, "%s", TRACE_LEN_KEY);
  sprintf(key_value, "%ld", idx_head.trace_len);
  WritePrivateProfileString(DRIVER_DATA, key_name, key_value,trcFile);

  if (reset_flag == 1)
  {
      MessageBox(NULL,
     "��� ������ ������ �������� ����������� �����������!\n ����� ���� ��������� � ���������� ���������!\n ��������� ���� ���� ������������ � ��������!",
     "��������������", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
  };

  if (accel_0_flag == 1)
  {
      MessageBox(NULL,
     "�������� �� �������� ������������ 1 ����������!\n",
     "��������������", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
  };

  if (accel_1_flag == 1)
  {
      MessageBox(NULL,
     "�������� �� �������� ������������ 2 ����������!\n",
     "��������������", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
  };


  if ( (strncmp(file_head.target_name, "12060101", 8)==0) || // ��� 1200 ������
       (strncmp(file_head.target_name, "12120101", 8)==0)    // ������ 1200 ������
     )
  {

      if (excess_pressure_flag == 1)
      {
          MessageBox(NULL,
         "� �������� ������ �������� ��������� ���������� �������� ������ ���������������!\n",
         "��������������", MB_OK | MB_ICONWARNING | MB_SYSTEMMODAL);
      };
  };

  return KRT_OK;
}; /* krtDrvRegister */

//////////////////////////////////////////////////////////////////////////
// ����������� Callback - �������
//////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////
// ������� �������������� ���������
//////////////////////////////////////////////////////////////////////////

long EXPORT KRTAPI krtDriverInfo (T_DRVINFO *drv ) {
  if (drv==NULL) return KRT_ERR;

  drv->apiVer = KRT_APIVER;
  drv->krtDrvRegister = krtDrvRegister;
  return KRT_OK;

}; /* krtDriverInfo (T_DRVINFO *drv ) */


long EXPORT KRTAPI krtOpenTrace(const char * traceFile, KRTHANDLE handle, T_TRACEINFO *inf, long draft){

   long curent_trace, cur_idx;

   long i;

   char key_name[1024];
   char key_value[1024];


   FILE *idx_file_data;
   char idx_file_name[1024];
   long idx_table_size;

   char ext_idx_file_name[1024];

   long ext_sens_index;


   inf->krtDrvError = krtDrvError; // � ����� ��. ����, ���� ��������� �������

   // �������� �� ������������ handle
  if (handle<=0) {
     sprintf (drvError, "handle �� ������ ����(krtOpenTrace)");
     return KRT_ERR;
   };


  if (draft) {
     if (open_trace_counter>=MAX_TRACE) {
        sprintf (drvError, "��� ������� ������� ����� �����.(krtOpenTrace)");
        return KRT_ERR;
      };

     for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
        if (handle==trace_list[curent_trace].handle) {
           sprintf (drvError, "��������� ������������� handle.(krtOpenTrace)");
           return KRT_ERR;
         };
      };

     curent_trace = open_trace_counter;

     trace_list[curent_trace].handle=handle;

     trace_list[curent_trace].trace = init_opened_trace();

     if (trace_list[curent_trace].trace == NULL) {
        strcat (drvError, "(krtOpenTrace)");
        return KRT_ERR;
     };


     strcpy(trace_list[curent_trace].trace->trc_file_name, traceFile);
     
     // ������ �� trc-����� ���� �� ������� �������
     sprintf(key_name, "%s", PATH_DATA_KEY);
     if (GetPrivateProfileString(DRIVER_DATA, key_name, "", key_value, sizeof(key_value), traceFile) == 0)
     {
         // �������� ������ ���� �� trc-����� (��� ����� ������ �����)
         strcpy(key_value, traceFile);

         while((strlen(key_value)>0) && (key_value[strlen(key_value)-1]!='\\')) {
           key_value[strlen(key_value)-1]=0;
         };
     };
     strcpy(trace_list[curent_trace].trace->path_data, key_value);
     // �������� �� trc-����� ���� �� ������� �������

#pragma warning(disable : 4090)  // ����� ������� ��� ���������-������ ��� �������� � �������

     // ��������� �� trc-���� ������ ������� �����
     trace_list[curent_trace].trace->first_file_index = 
                   Get_long_key( FIRST_FILE_INDEX_KEY, DRIVER_DATA, 0, traceFile);

     // ������ �� trc-����� ������ ������ � �������� ��������
     trace_list[curent_trace].trace->trace_len =
                   Get_long_key( TRACE_LEN_KEY, DRIVER_DATA, -1, traceFile);
     if (trace_list[curent_trace].trace->trace_len == -1)
     {
        sprintf (drvError, "������ ������ ������ ������ �� ����� %s.", traceFile);
        return KRT_ERR;
     };
	 
     // ������ �� trc-����� ��� ��������
     trace_list[curent_trace].trace->trace_step =
                   Get_long_key( TRACE_STEP_KEY, DRIVER_DATA, 5, traceFile);

     // ������ �� trc-����� ��� ������������ ��������
     trace_list[curent_trace].trace->virtual_trace_step =
                   Get_long_key( VIRTUAL_TRACE_STEP_KEY,
                                 DRIVER_DATA,
                                 trace_list[curent_trace].trace->trace_step,
                                 traceFile
                               );

     // ������ �� trc-����� ���-�� ������ �������� � �������
     trace_list[curent_trace].trace->group_num =
                   Get_long_key( GROUP_NUM_KEY, DRIVER_DATA, GROUP_NUM_IN_DEVICE, traceFile);

     // ������ �� trc-����� ����� ���-�� �������� �������� � �������
     trace_list[curent_trace].trace->corosion_sens_num =
                   Get_long_key( CORROSION_SENS_NUM_KEY, DRIVER_DATA, -1, traceFile);
     if (trace_list[curent_trace].trace->corosion_sens_num == -1)
     {
        sprintf (drvError, "������ ������ ���-�� �������� �� ����� %s.", traceFile);
        return KRT_ERR;
     };

     // ������ �� trc-����� ���-�� �������� �������� � ������ �����
     for (i=0; i<trace_list[curent_trace].trace->group_num; i++) {
        sprintf(key_name, "%s%i", LINESENSE_SIZE_KEY, i);
        trace_list[curent_trace].trace->linesense_size[i] =
                   Get_long_key( key_name, DRIVER_DATA, -1, traceFile);
	trace_list[curent_trace].trace->real_number_sensor_in_group[i] = trace_list[curent_trace].trace->linesense_size[i];
        if (trace_list[curent_trace].trace->real_number_sensor_in_group[i] == 0)
        {
           sprintf (drvError, "������ ������ ���-�� �������� � ������ �� ����� %s.", traceFile);
           break;
        };
      }; // for (i=0; i<opened_trace->group_num; i++)

     // ������ �� trc-���� �������� ������������� ������ ������������
     // ������������
     trace_list[curent_trace].trace->ShiftNavigation_data =
                   Get_long_key( ShiftNavigation_data_KEY, DRIVER_DATA, 0, traceFile);

     // ������ �� trc-����� ���� ReversView
     trace_list[curent_trace].trace->ReversView =
                   Get_long_key( ReversView_KEY, DRIVER_DATA, 0, traceFile);

     // ������ �� trc-����� ���� BendingPlane
     trace_list[curent_trace].trace->BendingPlane =
                   Get_long_key( BendingPlane_KEY, DRIVER_DATA, 0, traceFile);

     // ������ �� trc-����� ���� ����� ����������
     trace_list[curent_trace].trace->Orientation_OFF =
                   Get_long_key( Orientation_OFF_KEY, DRIVER_DATA, 0, traceFile);

     // ������ �� trc-����� �������� ����������
     trace_list[curent_trace].trace->Orientation_shift =
                   Get_long_key( Orientation_shift_KEY, DRIVER_DATA, 0, traceFile);

     // ������ �� trc-����� �������� ����������	2 �����
     trace_list[curent_trace].trace->Orientation_shift_2 =
                   Get_long_key( Orientation_shift_2_KEY, DRIVER_DATA, 0, traceFile);

     // ������ �� trc-����� ���� ����� ����������
     trace_list[curent_trace].trace->Smooth_data_OFF =
                   Get_long_key( Smooth_data_OFF_KEY, DRIVER_DATA, 0, traceFile);

     // ������ �� trc-����� ���� Standart_MATH
     trace_list[curent_trace].trace->Standart_MATH =
                   Get_long_key( Standart_MATH_KEY, DRIVER_DATA, 1, traceFile);

     // ������ �� trc-����� ���� Revers_MATH
     trace_list[curent_trace].trace->Revers_MATH =
                   Get_long_key( Revers_MATH_KEY, DRIVER_DATA, 0, traceFile);

     // ������ �� trc-����� �������� �� ������� �����
     trace_list[curent_trace].trace->Amplification_Group[0] =
                   Get_long_key( Amplification_Group0_KEY, DRIVER_DATA, 10, traceFile);

     // ������ �� trc-����� �������� �� ������� �����
     trace_list[curent_trace].trace->Amplification_Group[1] =
                   Get_long_key( Amplification_Group1_KEY, DRIVER_DATA, 10, traceFile);

     // ������ �� trc-����� ������ ���� ����������� �� ������� �����
     trace_list[curent_trace].trace->smooth_win_length[0] =
                   Get_long_key( Smooth_win_length0_KEY, DRIVER_DATA, 4, traceFile);

     // ������ �� trc-����� ������ ���� ����������� �� ������� �����
     trace_list[curent_trace].trace->smooth_win_length[1] =
                   Get_long_key( Smooth_win_length1_KEY, DRIVER_DATA, 4, traceFile);

     // ��������� �� trc-����� ������ ���������� �������
     trace_list[curent_trace].trace->Median_Filter_length =
                   Get_long_key( Median_Filter_length_KEY, DRIVER_DATA, 0, traceFile);

     // ��������� �� trc-����� ������������ ��������� �������
     trace_list[curent_trace].trace->max_data_code =
                   Get_long_key( MAX_DATA_CODE_KEY, DRIVER_DATA, MAX_DATA_CODE, traceFile);

     // ������ �� trc-����� ������� �������� �������� �� ������
     read_delete_sens_table( trace_list[curent_trace].trace->corosion_sens_num,
                             trace_list[curent_trace].trace->Delete_sens_data,
                             trace_list[curent_trace].trace->real_number_sensor_in_group,
                             trace_list[curent_trace].trace->linesense_size,
                             trace_list[curent_trace].trace->group_num,
                             traceFile );
     // ��������� �������  �������� �������� �� ������

     // ������ �� trc-����� ������� ��������� �������� � ������
     read_zerro_sens_table( trace_list[curent_trace].trace->corosion_sens_num,
                             trace_list[curent_trace].trace->Zerro_sens_data,
                             traceFile );
     // ��������� �������  �������� �������� �� ������

     // ������ �� trc-����� ������� �������������� ������� ��������
     read_invert_sens_table ( trace_list[curent_trace].trace->corosion_sens_num,
                              trace_list[curent_trace].trace->invert_sens_data,
                              traceFile );
     // ��������� ������� �������������� ������� ��������

     // ������ �� trc-����� ���� ���� ������������� ������������ �������� 
     trace_list[curent_trace].trace->Odometers_tools_use =
                   Get_long_key( Odometers_tools_use_KEY, DRIVER_DATA, 0, traceFile);

     // ������ �� trc-����� ����� ������� �� �������� ���� 0 ������� 
     trace_list[curent_trace].trace->Odometer_0_sens =
                   Get_long_key( Odometer_0_sens_KEY, DRIVER_DATA, 0, traceFile);

     // ������ �� trc-����� ����� ������� �� �������� ���� 1 ������� 
     trace_list[curent_trace].trace->Odometer_1_sens =
                   Get_long_key( Odometer_1_sens_KEY, DRIVER_DATA, FIRST_SENSLINE_SIZE/2, traceFile);

#pragma warning(default:4090)


     // ������ �� trc-����� ������������� ������
     for (i = 0; i < trace_list[curent_trace].trace->corosion_sens_num; i++) {
        sprintf(key_name, "%s%i", SENS_SORT_KEY, i);
        if (GetPrivateProfileString(DRIVER_DATA, key_name, "", key_value, sizeof(key_value), traceFile) == 0)
        {
            trace_list[curent_trace].trace->sens_sort[i] = i;
        } else {
            trace_list[curent_trace].trace->sens_sort[i] = atoi(key_value);
        }
     } // for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
     // ��������� �� trc-����� ������������� ������


     // ������ �� trc-����� ������ �������� ��������
     for (i = 0; i < trace_list[curent_trace].trace->corosion_sens_num; i++) {
        sprintf(key_name, "%s%i", SENS_SHIFT_KEY, i);
        if (GetPrivateProfileString(DRIVER_DATA, key_name, "", key_value, sizeof(key_value), traceFile) == 0)
        {
            trace_list[curent_trace].trace->sens_shift[i] = 0;
        } else {
            trace_list[curent_trace].trace->sens_shift[i] = atoi(key_value);
        }
     } // for (i=0; i<opened_trace->sens_num_in_sektor; i++) {


     trace_list[curent_trace].trace->max_sens_shift = 0;
     for (i = 0; i < trace_list[curent_trace].trace->corosion_sens_num; i++) {

        if ( trace_list[curent_trace].trace->max_sens_shift < 
             trace_list[curent_trace].trace->sens_shift[i] )
        {
           trace_list[curent_trace].trace->max_sens_shift =
                 trace_list[curent_trace].trace->sens_shift[i];
        }
     } // for (i=0; i<opened_trace->sens_num_in_sektor; i++) {
     // ��������� �� trc-����� ������  �������� ��������

     // ��������� �� trc-���� ���� �� ������������� ������
     GetPrivateProfileString(DRIVER_DATA, RecVog_KEY, "", key_value, sizeof(key_value), traceFile);
     strcpy(trace_list[curent_trace].VogData.file_name, key_value);

     GetPrivateProfileString(DRIVER_DATA, RecMat_KEY, "", key_value, sizeof(key_value), traceFile);
     strcpy(trace_list[curent_trace].NavData.file_name, key_value);
     // ��������� �� trc-���� ���� �� ������������� ������

     // ��������� �� trc-����� ���� PigL3
     trace_list[curent_trace].trace->PigL3 = 0;
     if (GetPrivateProfileString("Trace", "PigL3", "", key_value,
                                 sizeof(key_value), trace_list[curent_trace].trace->trc_file_name) == 0)
      {
        trace_list[curent_trace].trace->PigL3 = 0;
      } else {
        trace_list[curent_trace].trace->PigL3 = atoi(key_value);
      };
     // ��������� �� trc-����� ���� PigL3

     // ��������� �� trc-����� ������ ���������� �������
     if (GetPrivateProfileString(DRIVER_DATA, Median_Filter_length_KEY, "", key_value,
                          sizeof(key_value), trace_list[curent_trace].trace->trc_file_name) == 0)
      {
        trace_list[curent_trace].trace->Median_Filter_length = 0;
      } else {
        trace_list[curent_trace].trace->Median_Filter_length = atoi(key_value);
      };
     // ��������� �� trc-����� ������ ���������� �������


     // ��������� �� trc-����� ������������ ��������� �������
     if (GetPrivateProfileString(DRIVER_DATA, MAX_DATA_CODE_KEY, "", key_value,
                          sizeof(key_value), trace_list[curent_trace].trace->trc_file_name) == 0)
      {
        trace_list[curent_trace].trace->max_data_code = MAX_DATA_CODE;
      } else {
        trace_list[curent_trace].trace->max_data_code = atoi(key_value);
      };
     // ��������� �� trc-����� ������������ ��������� �������


     // ������� � ���������� ������� �� ����������� ������ 
     sprintf(idx_file_name, "%strace.idx", trace_list[curent_trace].trace->path_data);

     idx_file_data = fopen(idx_file_name, "rb");
     if (idx_file_data==NULL) {
         sprintf(drvError, "������ �������� ����� %s. \n", idx_file_name);
         return KRT_ERR;
     };

     fseek(idx_file_data, 0-sizeof(trace_list[curent_trace].trace->idx_head), SEEK_END);
     fread( &trace_list[curent_trace].trace->idx_head,1,sizeof(trace_list[curent_trace].trace->idx_head), idx_file_data);

     idx_table_size = sizeof(T_IDX_TRC) * trace_list[curent_trace].trace->idx_head.num_idx_in_table;

     trace_list[curent_trace].trace->idx_trc = malloc(idx_table_size);

     fseek(idx_file_data, 0, SEEK_SET);
     fread( trace_list[curent_trace].trace->idx_trc,1 ,idx_table_size, idx_file_data);

     fclose(idx_file_data);
     idx_file_data=NULL;

     for (cur_idx=0; cur_idx < trace_list[curent_trace].trace->idx_head.num_idx_in_table; cur_idx++)
     {
         trace_list[curent_trace].trace->idx_trc[cur_idx].math_records = NULL;
         trace_list[curent_trace].trace->idx_trc[cur_idx].revers_math_records = NULL;
         trace_list[curent_trace].trace->idx_trc[cur_idx].records = NULL;
     };

     // ������� � ���������� ������� �� �������������� �������� 
     sprintf(ext_idx_file_name, "%sext_data.idx", trace_list[curent_trace].trace->path_data);

     trace_list[curent_trace].trace->ext_idx_file_data = fopen(ext_idx_file_name, "rb");
     if (trace_list[curent_trace].trace->ext_idx_file_data==NULL) {
         sprintf(drvError, "������ �������� ����� %s. \n", ext_idx_file_name);
         return KRT_ERR;
     };

     sprintf(ext_idx_file_name, "%spressure.idx", trace_list[curent_trace].trace->path_data);

     trace_list[curent_trace].trace->pressure_data = fopen(ext_idx_file_name, "rb");
     if (trace_list[curent_trace].trace->pressure_data==NULL) {
         sprintf(drvError, "������ �������� ����� %s. \n", ext_idx_file_name);
         trace_list[curent_trace].trace->pressure_data = 0;
     };

     // ����� ������ ���������:
     inf->sensGroups = trace_list[curent_trace].trace->group_num; 

     if ( Init_BPdata( &trace_list[curent_trace].BPdata,
                       trace_list[curent_trace].trace->path_data,
                       trace_list[curent_trace].trace->trc_file_name,
                       drvError
                     ) == KRT_OK )
     {
         trace_list[curent_trace].trace->add_ext_sens_bps_pressure = 1;
     };

     sprintf(ext_idx_file_name, "%sthick_II.idx", trace_list[curent_trace].trace->path_data);

    thick_II_file_data = fopen(ext_idx_file_name, "rb");
    if ( thick_II_file_data != NULL) {
        trace_list[curent_trace].trace->add_ext_sens_thick_II = 1;
        fclose(thick_II_file_data);
    };

     // �������� ���� �� ������������� ������
     if (Serch_navigete( &trace_list[curent_trace].NavData,
                         trace_list[curent_trace].trace->path_data,
                         trace_list[curent_trace].trace->trc_file_name,
                         drvError
                 )==KRT_OK)
      {
         // ��� ���� ���� ������� �������������� �������
         inf->extSensors = 15;
      } else {
         inf->extSensors = 8;
      };

      inf->extSensors += trace_list[curent_trace].trace->add_ext_sens_thick_II;

      inf->extSensors += trace_list[curent_trace].trace->add_ext_sens_bps_pressure;

      open_trace_counter++;
      // ������� ������

      return KRT_OK;
   }; //   if (draft) {

  // �! � ��� ��� ��������� ����� krtOpenTrace � draft == 0
  if (open_trace_counter==0) {
     sprintf (drvError, "��� �������� �����(krtOpenTrace)");
     return KRT_ERR;
   };

  // ������ �������� ������ � ������:
  for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
     if (handle==trace_list[curent_trace].handle) break;
   };
  if (curent_trace >= open_trace_counter) {
     sprintf(drvError, "�� ������ handle (krtOpenTrace)");
     return KRT_ERR; 
   };


  // ���������� ��������� ������ � �������������� �������
  if (Init_navigete( &trace_list[curent_trace].VogData,
                     trace_list[curent_trace].trace->path_data,
                     trace_list[curent_trace].trace->trc_file_name,
                     inf, drvError)
       !=KRT_OK)
  {
     // ���-�� �� ��� � ����������
  };

  read_file_direct_move_data(trace_list[curent_trace].trace->path_data);

  read_file_drive_wheel_data(trace_list[curent_trace].trace->path_data);

  read_file_acselerometr1_data(trace_list[curent_trace].trace->path_data);

  read_file_acselerometr2_data(trace_list[curent_trace].trace->path_data);

  trace_list[curent_trace].trace->hispead_file_data =
         open_for_read_file_hispead_data(trace_list[curent_trace].trace->path_data);

  read_file_thick_II_data(trace_list[curent_trace].trace->path_data);

  Init_arrow_hd_Data(trace_list[curent_trace].trace->trc_file_name);

  Init_bending_plane_Data(trace_list[curent_trace].trace->trc_file_name);

  // �������� ������ �� ����������� ������
  inf->sensGroups = trace_list[curent_trace].trace->group_num;
  inf->askMetod   = SENS_ASK_DIST;
  inf->stepSize   = trace_list[curent_trace].trace->virtual_trace_step;


  // �������� ��������� ������� �������
  inf->group[0].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[0];

  inf->group[0].type    = SENS_TYPE_MFL;

  #pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
  if (THIS_STRESS) inf->group[0].type    = SENS_TYPE_TFI;
  #pragma warning(default:4127)

  #pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
  if (THIS_INTROSCOPE && inf->sensGroups==1) inf->group[0].type    = SENS_TYPE_INTROSCOPE;
  #pragma warning(default:4127)

  inf->group[0].minValue= 0;
  inf->group[0].maxValue= KRT_PALLETE_SIZE;

  inf->group[0].isRow    = 1; // 1/0 ���� 0 ����� ������ �� ��������������
  inf->group[0].minRowVal= 0; // ����������� �������� ����� ������ 
  inf->group[0].maxRowVal= 4096; // ������������ �������� ����� ������ 

  // �������� ��������� ������� �������
  if (inf->sensGroups > 1)
  {
     inf->group[1].num     = trace_list[curent_trace].trace->real_number_sensor_in_group[1];

     inf->group[1].type    = SENS_TYPE_MFL;

     #pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
     if (THIS_STRESS) inf->group[1].type    = SENS_TYPE_TFI;
     #pragma warning(default:4127)

     #pragma warning(disable : 4127)  // ����� ������� ��� ��������� � �������
     if (THIS_INTROSCOPE) inf->group[1].type    = SENS_TYPE_INTROSCOPE;
     #pragma warning(default:4127)

     inf->group[1].minValue= 0;
     inf->group[1].maxValue= KRT_PALLETE_SIZE;

     inf->group[1].isRow    = 1; // 1/0 ���� 0 ����� ������ �� ��������������
     inf->group[1].minRowVal= 0; // ����������� �������� ����� ������ 
     inf->group[1].maxRowVal= 4096; // ������������ �������� ����� ������ 
  };
   
  // ��-�� � �������� ����� �� 1 ��������� ������, �.�. ������� � 0 �� ������
  if (trace_list[curent_trace].trace->trace_len > CUT_TAILE)
      trace_list[curent_trace].trace->trace_len -=CUT_TAILE;
  {
      inf->length   = (trace_list[curent_trace].trace->trace_len) *
                      trace_list[curent_trace].trace->trace_step;
  }

  inf->time     = trace_list[curent_trace].trace->trace_time ;


  inf->orientNum  = 1;
  inf->orientStep = trace_list[curent_trace].trace->virtual_trace_step;

  inf->timerNum  = 1;
  inf->timerStep = trace_list[curent_trace].trace->virtual_trace_step;

  inf->odoNum  = 1;
  inf->odoStep = trace_list[curent_trace].trace->virtual_trace_step;

  inf->tempNum  = 1;
  inf->tempStep = trace_list[curent_trace].trace->virtual_trace_step;
  inf->tempMin  = -100;
  inf->tempMax  =  100;

    // ���� ������ ������� 
  inf->wallThickNum = 1;       // ���������� �������
  inf->wallThickMin = 0;       // ����������� �������� ������ 
  inf->wallThickMax = trace_list[curent_trace].trace->max_data_code;  // ������������ �������� ������ 


  inf->speedMin = -100;
  inf->speedMax =  100;

  inf->shakeNum  =  1; // ��������
  inf->shakeStep =  trace_list[curent_trace].trace->virtual_trace_step;
  inf->shakeMin  = -100;
  inf->shakeMax  =  100;


  inf->pressNum =  1; // ��������
  inf->pressStep=  trace_list[curent_trace].trace->virtual_trace_step;
  inf->pressMin = -100;
  inf->pressMax =  100;


  // ��������� ��������������� �������
  ext_sens_index=0;

  inf->extSens[ext_sens_index].minValue = -2;
  inf->extSens[ext_sens_index].maxValue = +2;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "����������� ��������", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  inf->extSens[ext_sens_index].minValue = -1;
  inf->extSens[ext_sens_index].maxValue = +2;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "������������ ������",
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  inf->extSens[ext_sens_index].minValue = 0;
  inf->extSens[ext_sens_index].maxValue = 1000000;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "C�������, ��/�", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  inf->extSens[ext_sens_index].minValue = 0;
  inf->extSens[ext_sens_index].maxValue = 1024;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "����� �������� �����", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  inf->extSens[ext_sens_index].minValue = 0;
  inf->extSens[ext_sens_index].maxValue = acselerometr1_MAX_VALUE;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "������������ 1, ��.���", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  inf->extSens[ext_sens_index].minValue = 0;
  inf->extSens[ext_sens_index].maxValue = acselerometr2_MAX_VALUE;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "������������ 2, ��.���", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  if (trace_list[curent_trace].trace->add_ext_sens_thick_II > 0)
  {
      inf->extSens[ext_sens_index].minValue = 0;
      inf->extSens[ext_sens_index].maxValue = 100000;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "������� ����� �� ����� ����������, �������", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;
  }

  if (trace_list[curent_trace].trace->add_ext_sens_bps_pressure > 0)
  {
      inf->extSens[ext_sens_index].minValue = 0;
      inf->extSens[ext_sens_index].maxValue = 10000;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "�������� ������, ���", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;
  }

  inf->extSens[ext_sens_index].minValue = 0;
  inf->extSens[ext_sens_index].maxValue = 10000;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "������, D", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  inf->extSens[ext_sens_index].minValue = 0;
  inf->extSens[ext_sens_index].maxValue = 10000;
  strncpy (
   inf->extSens[ext_sens_index].name, 
   "���� ��������� ������, �", 
   EXT_SENS_NAME_LENGTH
  );
  ext_sens_index++;

  if (trace_list[curent_trace].NavData.file_data != NULL)
  {
      inf->extSens[ext_sens_index].minValue = -70*VOG_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +70*VOG_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "��� X, 0.100 ����.���", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -70*VOG_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +70*VOG_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "��� Y, 0.100 ����.���", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -70*VOG_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +70*VOG_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "��� Z, 0.100 ����.���", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -10*ACCEL_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +10*ACCEL_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "������������ X, mg", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -10*ACCEL_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +10*ACCEL_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "������������ Y, mg", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = -10*ACCEL_KOEFF_UMN;
      inf->extSens[ext_sens_index].maxValue = +10*ACCEL_KOEFF_UMN;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "������������ Z, mg", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;

      inf->extSens[ext_sens_index].minValue = 0;
      inf->extSens[ext_sens_index].maxValue = 10000;
      strncpy (
       inf->extSens[ext_sens_index].name, 
       "arrow hd", 
       EXT_SENS_NAME_LENGTH
      );
      ext_sens_index++;
  } else { // if (trace_list[curent_trace].NavData.file_data!=NULL)
  }

  // ������� ID �����
  {
       FILE * data_file;
       char file_name[1024];
       �_file_header  file_head;

       sprintf(file_name, STR_FILE_MASK, trace_list[curent_trace].trace->path_data,
                trace_list[curent_trace].trace->first_file_index);
       data_file = fopen(file_name, "rb");
       if (data_file == NULL) return KRT_ERR;

       read_file_header_nano512(data_file, &file_head);

       strcpy(trace_list[curent_trace].trace->target_name, file_head.target_name);

       fclose(data_file);
  }
  // �������� ID �����

     // �������������� ��������� �� Callback - ������� 
  inf->krtDrvFillData          = krtDrvFillData;
  inf->krtDrvGetFirstNode      = krtDrvGetFirstNode;
  inf->krtDrvGetNextNode       = krtDrvGetNextNode;
  inf->krtDrvGetFirstNodeGroup = krtDrvGetFirstNodeGroup;
  inf->krtDrvGetNextNodeGroup  = krtDrvGetNextNodeGroup;

  return KRT_OK;
}; // krtOpenTrace

long EXPORT KRTAPI krtCloseTrace ( KRTHANDLE handle) {
  int curent_trace; 

  long cur_idx;

  if (open_trace_counter==0) {
     sprintf (drvError, "��� �������� �����(krtCloseTrace)");
     return KRT_ERR;
   };

  // ������ �������� ������ � ������:
  for (curent_trace=0; curent_trace<open_trace_counter; curent_trace++) {
     if (handle==trace_list[curent_trace].handle) {

        for (cur_idx=0; cur_idx < trace_list[curent_trace].trace->idx_head.num_idx_in_table; cur_idx++)
        {
            if ( trace_list[curent_trace].trace->idx_trc[cur_idx].math_records != NULL) {
                free(trace_list[curent_trace].trace->idx_trc[cur_idx].math_records);
                trace_list[curent_trace].trace->idx_trc[cur_idx].math_records = NULL;
            };

            if ( trace_list[curent_trace].trace->idx_trc[cur_idx].revers_math_records != NULL) {
                free(trace_list[curent_trace].trace->idx_trc[cur_idx].revers_math_records);
                trace_list[curent_trace].trace->idx_trc[cur_idx].revers_math_records = NULL;
            };

            if ( trace_list[curent_trace].trace->idx_trc[cur_idx].records != NULL) {
                free(trace_list[curent_trace].trace->idx_trc[cur_idx].records);
                trace_list[curent_trace].trace->idx_trc[cur_idx].records = NULL;
            };
        };

        if (trace_list[curent_trace].trace->idx_trc != NULL)
        {
            free(trace_list[curent_trace].trace->idx_trc);
            trace_list[curent_trace].trace->idx_trc = NULL;
        }

        close_for_read_file_hispead_data(trace_list[curent_trace].trace->hispead_file_data);

        // � ������� ��
        free_opened_trace(trace_list[curent_trace].trace);

        open_trace_counter--;

        trace_list[curent_trace].handle = trace_list[open_trace_counter].handle;
        trace_list[curent_trace].trace  = trace_list[open_trace_counter].trace;

        trace_list[open_trace_counter].handle = 0;
        trace_list[open_trace_counter].trace  = NULL;

        return KRT_OK;
      };
   };

  sprintf(drvError, "�� ������ handle (krtCloseTrace)");
  return KRT_ERR; 

}; // krtCloseTrace
