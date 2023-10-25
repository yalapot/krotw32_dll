

#define RESET_FILE_FILE_NAME "resetfile.idx"

char reset_file_file_path[1024];

FILE *reset_file_file_data;

u16 *reset_file_data = NULL;

long file_len;

int open_for_write_file_reset_file_data(char *data_path)
{
    strcpy(reset_file_file_path, data_path);
    strcat(reset_file_file_path, RESET_FILE_FILE_NAME);

    reset_file_file_data = fopen(reset_file_file_path, "wb");
    if ( reset_file_file_data == NULL) {
        return 0;
    };

    return 1;
}

int write_file_reset_file_data(u16 data)
{
    if (reset_file_file_data != NULL)
    {
        return fwrite(&data, 1, sizeof(data), reset_file_file_data);
    }

    return 0;
}

void close_for_write_file_reset_file_data()
{
    if (reset_file_file_data != NULL)
    {
        fclose(reset_file_file_data);
        reset_file_file_data = NULL;
    }
}

int read_file_reset_file_data(char *data_path)
{
    strcpy(reset_file_file_path, data_path);
    strcat(reset_file_file_path, RESET_FILE_FILE_NAME);

    reset_file_file_data = fopen(reset_file_file_path, "rb");
    if ( reset_file_file_data == NULL) {
        return 0;
    };

    // файл присутствует
    // посчитаем его длинну
    fseek(reset_file_file_data, 0, SEEK_END);
    file_len = ftell(reset_file_file_data);
    
    reset_file_data = malloc(file_len);

    fseek(reset_file_file_data, 0, SEEK_SET);

    fread(reset_file_data, 1, file_len, reset_file_file_data);

    fclose(reset_file_file_data);

    return 1;
}; // int init_file_reset_file_data()
