

#define HI_SPEAD_FILE_NAME "hispead.idx"

char hispead_file_path[1024];

FILE *hispead_file_data;

long *hispead_data = NULL;

long file_len;

int open_for_write_file_hispead_data(char *data_path)
{
    strcpy(hispead_file_path, data_path);
    strcat(hispead_file_path, HI_SPEAD_FILE_NAME);

    hispead_file_data = fopen(hispead_file_path, "wb");
    if ( hispead_file_data == NULL) {
        return 0;
    };

    return 1;
}

int write_file_hispead_data(long data)
{
    if (hispead_file_data != NULL)
    {
        return fwrite(&data, 1, sizeof(data), hispead_file_data);
    }

    return 0;
}

void close_for_write_file_hispead_data()
{
    if (hispead_file_data != NULL)
    {
        fclose(hispead_file_data);
        hispead_file_data = NULL;
    }
}

int read_file_hispead_data(char *data_path)
{
    strcpy(hispead_file_path, data_path);
    strcat(hispead_file_path, HI_SPEAD_FILE_NAME);

    hispead_file_data = fopen(hispead_file_path, "rb");
    if ( hispead_file_data == NULL) {
        return 0;
    };

    // файл присутствует
    // посчитаем его длинну
    fseek(hispead_file_data, 0, SEEK_END);
    file_len = ftell(hispead_file_data);

    hispead_data = malloc(file_len * sizeof(hispead_data[0]));

    fseek(hispead_file_data, 0, SEEK_SET);

    fread(hispead_data, 1, file_len, hispead_file_data);

    fclose(hispead_file_data);

    return 1;
}; // int read_file_hispead_data(char *data_path)


FILE * open_for_read_file_hispead_data(char *data_path)
{
    strcpy(hispead_file_path, data_path);
    strcat(hispead_file_path, HI_SPEAD_FILE_NAME);

    hispead_file_data = fopen(hispead_file_path, "rb");
    if ( hispead_file_data == NULL) {
        return NULL;
    };

    return hispead_file_data;
}

int read_one_hispead_data(FILE * file_descriptor, long file_pos)
{
    long hispead_value;

    if ( file_descriptor == NULL) {
        return 0;
    };

    // файл присутствует

    fseek(file_descriptor, file_pos*sizeof(hispead_value), SEEK_SET);

    fread(&hispead_value, 1, sizeof(hispead_value), file_descriptor);


    return hispead_value;
}; // int read_file_hispead_data(char *data_path)

void close_for_read_file_hispead_data(FILE * file_descriptor)
{
    if (file_descriptor != NULL)
    {
        fclose(file_descriptor);
        file_descriptor = NULL;
    }
}
