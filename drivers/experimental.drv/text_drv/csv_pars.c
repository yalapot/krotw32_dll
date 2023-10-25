
long pars_csv_string (   int row_header,
                         char * str,
                         long * row_buf,
                         long column_num
                     )
{
   char seps[32]   = " \t,;";
   char *token;
   long column = 0;

   token = strtok(str, seps );

   while (token != NULL) {
      if (!row_header)
      {
         row_buf[column] = atoi(token);
         column ++;
         if (column >=column_num) break;
      };

      row_header = 0;
      token = strtok(NULL, seps );
   };

   return KRT_OK;

};  // pars_csv_string


long get_csv_table (   int row_header,
                       int column_header,
                       char * table_str,
                       long * table,
                       long row_num,
                       long column_num
                    )
{
   char seps[32]   = "\n";
   char *row_str;
   long row = 0;
   long row_pos_in_table = 0;

   char * cur_table_str = table_str;

   row_str = strtok(cur_table_str, seps );
   while (row_str != NULL) {
      cur_table_str = row_str + strlen(row_str)+1;

      if (!column_header) {

         pars_csv_string( row_header, row_str, &(table[row_pos_in_table]), column_num);
         row_pos_in_table += column_num;
         row++;
         if (row >= row_num) break;
      }

      column_header = 0;
      row_str = strtok(cur_table_str, seps );
   };

   return KRT_OK;
}; // get_csv_table


long get_row_num (   int column_header,
                     char * file_str,
                     long file_str_size
                    )
{
   char seps[32]   = "\n";
   char *row_str;

   long row = 0;

   char * table_str;
   char * cur_table_str;


   table_str = malloc(file_str_size);
   strncpy(table_str, file_str, file_str_size);
   cur_table_str = table_str;

   row_str = strtok(cur_table_str, seps );
   while (row_str != NULL)
   {
       if (!column_header)
       {
          row++;
       }
       column_header = 0;
       row_str = strtok(NULL, seps );
   }

   free (table_str);

   return row;
}; // get_row_num

long get_column_num (  int row_header,
                       int column_header,
                       char * file_str,
                       long file_str_size
                    )
{
   char seps[32]   = "\n";
   char *cur_str;
   char *token;

   char * table_str;
   char * cur_table_str;

   long row_pos_in_str = 0;

   long column = 0;

   long str_len = 0;
   long cur_str_pos = 0;

   table_str = malloc(file_str_size);
   strncpy(table_str, file_str, file_str_size);
   cur_table_str = & table_str[row_pos_in_str];

   cur_str = strtok(cur_table_str, seps );
   if (column_header)
   {
       cur_str = strtok(NULL, seps );
   }

   if ( cur_str != NULL)
   {
       strcpy(seps, " \t,;");
       cur_str_pos = 0;

       token = strtok(cur_str, seps );
       while (token != NULL)
       {
          if (!column_header)
          {
             column++;
          }
          column_header = 0;
          token = strtok(NULL, seps );
       };
   }

   free (table_str);

   return column;
}; // get_column_num

