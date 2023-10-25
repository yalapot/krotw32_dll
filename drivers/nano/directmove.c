

#define DIRECT_MOVE_FILE_NAME "directmove.idx"

char direct_move_file_path[1024];

FILE *direct_move_file_data;

char *direct_move_data = NULL;

long file_len;

int open_for_write_file_direct_move_data(char *data_path)
{
    strcpy(direct_move_file_path, data_path);
    strcat(direct_move_file_path, DIRECT_MOVE_FILE_NAME);

    direct_move_file_data = fopen(direct_move_file_path, "wb");
    if ( direct_move_file_data == NULL) {
        return 0;
    };

    return 1;
}

int write_file_direct_move_data(char data)
{
    if (direct_move_file_data != NULL)
    {
        return fwrite(&data, 1, sizeof(data), direct_move_file_data);
    }

    return 0;
}

void close_for_write_file_direct_move_data()
{
    if (direct_move_file_data != NULL)
    {
        fclose(direct_move_file_data);
        direct_move_file_data = NULL;
    }
}

int read_file_direct_move_data(char *data_path)
{
    strcpy(direct_move_file_path, data_path);
    strcat(direct_move_file_path, DIRECT_MOVE_FILE_NAME);

    direct_move_file_data = fopen(direct_move_file_path, "rb");
    if ( direct_move_file_data == NULL) {
        return 0;
    };

    // файл присутствует
    // посчитаем его длинну
    fseek(direct_move_file_data, 0, SEEK_END);
    file_len = ftell(direct_move_file_data);

    direct_move_data = malloc(file_len);

    fseek(direct_move_file_data, 0, SEEK_SET);

    fread(direct_move_data, 1, file_len, direct_move_file_data);

    fclose(direct_move_file_data);

    return 1;
}; // int init_file_direct_move_data()
