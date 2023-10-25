

#define PRIORITY_WHEEL_FILE_NAME "priority_wheel.idx"

char priority_wheel_file_path[1024];

FILE *priority_wheel_file_data;

u16 *priority_wheel_data = NULL;

long file_len;

int open_for_write_file_priority_wheel_data(char *data_path)
{
    strcpy(priority_wheel_file_path, data_path);
    strcat(priority_wheel_file_path, PRIORITY_WHEEL_FILE_NAME);

    priority_wheel_file_data = fopen(priority_wheel_file_path, "wb");
    if ( priority_wheel_file_data == NULL) {
        return 0;
    };

    return 1;
}

int write_file_priority_wheel_data(u16 data)
{
    if (priority_wheel_file_data != NULL)
    {
        return fwrite(&data, 1, sizeof(data), priority_wheel_file_data);
    }

    return 0;
}

void close_for_write_file_priority_wheel_data()
{
    if (priority_wheel_file_data != NULL)
    {
        fclose(priority_wheel_file_data);
        priority_wheel_file_data = NULL;
    }
}

int read_file_priority_wheel_data(char *data_path)
{
    strcpy(priority_wheel_file_path, data_path);
    strcat(priority_wheel_file_path, PRIORITY_WHEEL_FILE_NAME);

    priority_wheel_file_data = fopen(priority_wheel_file_path, "rb");
    if ( priority_wheel_file_data == NULL) {
        return 0;
    };

    // файл присутствует
    // посчитаем его длинну
    fseek(priority_wheel_file_data, 0, SEEK_END);
    file_len = ftell(priority_wheel_file_data);
    
    priority_wheel_data = malloc(file_len);

    fseek(priority_wheel_file_data, 0, SEEK_SET);

    fread(priority_wheel_data, 1, file_len, priority_wheel_file_data);

    fclose(priority_wheel_file_data);

    return 1;
}; // int init_file_priority_wheel_data()
