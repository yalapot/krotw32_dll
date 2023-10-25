

#define DRIVE_WHEEL_FILE_NAME "drivewheel.idx"

char drive_wheel_file_path[1024];

FILE *drive_wheel_file_data;

char *drive_wheel_data = NULL;

long file_len;

int open_for_write_file_drive_wheel_data(char *data_path)
{
    strcpy(drive_wheel_file_path, data_path);
    strcat(drive_wheel_file_path, DRIVE_WHEEL_FILE_NAME);

    drive_wheel_file_data = fopen(drive_wheel_file_path, "wb");
    if ( drive_wheel_file_data == NULL) {
        return 0;
    };

    return 1;
}

int write_file_drive_wheel_data(char data)
{
    if (drive_wheel_file_data != NULL)
    {
        return fwrite(&data, 1, sizeof(data), drive_wheel_file_data);
    }

    return 0;
}

void close_for_write_file_drive_wheel_data()
{
    if (drive_wheel_file_data != NULL)
    {
        fclose(drive_wheel_file_data);
        drive_wheel_file_data = NULL;
    }
}

int read_file_drive_wheel_data(char *data_path)
{
    strcpy(drive_wheel_file_path, data_path);
    strcat(drive_wheel_file_path, DRIVE_WHEEL_FILE_NAME);

    drive_wheel_file_data = fopen(drive_wheel_file_path, "rb");
    if ( drive_wheel_file_data == NULL) {
        return 0;
    };

    // файл присутствует
    // посчитаем его длинну
    fseek(drive_wheel_file_data, 0, SEEK_END);
    file_len = ftell(drive_wheel_file_data);

    drive_wheel_data = malloc(file_len);

    fseek(drive_wheel_file_data, 0, SEEK_SET);

    fread(drive_wheel_data, 1, file_len, drive_wheel_file_data);

    fclose(drive_wheel_file_data);

    return 1;
}; // int init_file_drive_wheel_data()
