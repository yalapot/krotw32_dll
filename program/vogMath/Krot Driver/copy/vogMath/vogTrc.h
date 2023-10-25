// vogTrc.h (C) Vitaly Bogomolov 2006
// Определения секций и ключей для навигационных данных в trc файле.

// секция навигац.данных в файле описания прогона
#define VOG_DATA         "VogData"    

// ключ в trc-файле, где храниться путь к файлу 
// сконвертированных навигационных данных
#define VOG_DATA_FIELD   "dataField"  
// ключ в trc-файле, где храниться путь к файлу 
// с рассчитанными координатами навигационных данных
#define VOG_DATA_COORD   "dataCoord"  

// рекомендуемые имена файлов для этих ключей
#define VOG_FILE_FIELD  "vogField.idx"  
#define VOG_FILE_COORD  "vogCoord.idx"  
