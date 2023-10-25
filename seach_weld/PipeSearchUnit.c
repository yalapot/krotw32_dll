
#include <math.h>
#include <stdio.h>

#define False 0
#define True  1


char tmp_log_str[1024];

#define LOG_WELD_FILE "c:\\Log_weld.txt"

void Log_weld(char *LogString) {
 FILE *call_log;

 call_log = fopen(LOG_WELD_FILE, "at");
 fprintf(call_log, "%s", LogString);
 fclose(call_log);
}

 
double CalculateMean(double value[], long array_size)
{
    double sum = 0;
    int i;

    for(i = 0; i < array_size; i++) sum += value[i];

    return (sum / array_size);
}
 
double CalculateVariane(double value[], long array_size)
{
    double sum = 0;
    int i;

    double mean = CalculateMean(value, array_size);

    for(i = 0; i < array_size; i++) sum += (value[i] - mean) * (value[i] - mean) ;

    return sum / array_size;
}
 
double GetStandardDeviation(double value[], long array_size)
{
    return sqrt(CalculateVariane(value, array_size));
}


// структура выходных данных найденного шва
typedef struct {
   short      PipeType ;           // тип трубы (одна из констант TUBE_* см.выше)
   short      WeldPos1 ;           // номер датчика 1 продольного шва (-1 если нет)
   short      WeldPos2 ;           // номер датчика 2 продольного шва (-1 если нет)
} TWeldPos;


// ------------ Это "типа константы" -----------------

long  WeldIndent = 20;   // Величина отступа от поперечного шва

// ------------ Это "типа константы" закончились -----------------


// Идентификация поперечного шва
long CrossPipeSearch( KRTDATA* src_Matrix, KRTROW* src_Matrix_row, long length, long NumSens)
{
   long LimDist = 60; // Расстояние между пиками по оси Ox

   long Result;
   static long pred_Result = 0;

   long i, j;

   long * aMax;

   double * aSignal;
   long aSignalLen;

   double aSignalStd;
   double aSignalMean;

   long aMaxCount;
   long long summ;


   if (pred_Result == TUBE_UNKNOWN) WeldIndent = 0;

   Result = TUBE_UNKNOWN;

   aSignal = malloc(length * sizeof(aSignal[0]));
   aMax    = malloc(length * sizeof(aMax[0]));

   // 1. Abs(Mean(Diff(src_Matrix)))
   aSignalLen = length - WeldIndent - 1;

   for (i = 1; i < aSignalLen; i++)
   {
       summ = 0;
       for (j = 0; j < NumSens; j++)
       {
           summ +=  (src_Matrix[(i + WeldIndent    ) + j * length] -
                     src_Matrix[(i + WeldIndent - 1) + j * length]);
//           summ +=  (src_Matrix_row[(i + WeldIndent    ) + j * length] -
//                     src_Matrix_row[(i + WeldIndent - 1) + j * length]);
       };

       aSignal[i] =(long) abs(summ / NumSens);
    };

   // 2. Find(aSignal > LimAmp)
   aMaxCount = 0;
   aSignalStd = GetStandardDeviation(aSignal, aSignalLen);
   aSignalMean = CalculateMean(aSignal, aSignalLen);

   for (i = 0; i < aSignalLen; i++)
   {
       if (aSignal[i] > (aSignalMean + 5 * aSignalStd) )
       {
           aMax[aMaxCount] = i;
           aMaxCount++;
       };
   };

   // 3. Find(Max(aSignal[aMax[0]..aMax[First(Diff(aMax[]) > LimRped)]]))
   Result = 0;                            

   for (i = 0; i <= (aMaxCount - 2); i++)
   {
     if ( (aMax[i + 1] - aMax[i]) < LimDist)
     {
         if ((aSignal[aMax[i]]) > aSignal[Result]) Result = aMax[i];
     } else {
         break;
     }
   }

   if (Result > 0) {
            Result += WeldIndent;
   } else { Result = TUBE_UNKNOWN; };

   free(aMax);
   free(aSignal);

   pred_Result = Result;

   return Result;

} // long CrossPipeSearch()


double * aSignal;

double * aSignalMean;
double * aSignalVec;

double aSignalMedian;
double aSignalStd;

double * bSignal;
long bSignalLen;

short * cSignal;
short * dSignal;


// Идентификация продольного шва
TWeldPos LateralPipeSearch(long CrossWeldPos, KRTDATA* src_Matrix, KRTROW * src_Matrix_row, long length, long NumSens)
{
    byte LimCube = 20; // 20// Порог по оси Oz
    byte LimPeack = 10; // 10// Ширина зоны местонахождения второго пика оси Ox
    byte coefficient_SKO = 3;


    TWeldPos Result;

    long i, j, k, n, p;

    long PointCount; // Ширина анализируемой области
    long PointPos;



    long status = 0;


    Result.PipeType = TUBE_WITHOUT;
    Result.WeldPos1 = -1;
    Result.WeldPos2 = -1;

    PointCount = CrossWeldPos - 2 * WeldIndent;

    aSignal     = malloc(NumSens * PointCount * sizeof(aSignal[0]));
    if (aSignal == NULL) {status=-1; goto crash;  };

    aSignalMean = malloc(NumSens * PointCount * sizeof(aSignalMean[0]));
    if (aSignalMean == NULL) {status=-2; goto crash;  };

    bSignal     = malloc(NumSens * PointCount * sizeof(bSignal[0]));
    if (bSignal == NULL) {status=-3; goto crash;  };

    cSignal     = malloc(NumSens * PointCount * sizeof(cSignal[0]));
    if (cSignal == NULL) {status=-4; goto crash;  };

    dSignal     = malloc(NumSens * PointCount * sizeof(dSignal[0]));
    if (dSignal == NULL) {status=-5; goto crash;  };

    // 1. Приведение к общему нулю сигналов. Abs(Diff(src_Matrix[]))
    for (i = 0; i <= (PointCount - 2); i++)
    {
        for (j = 0; j < NumSens; j++)
        {
            aSignal[NumSens * i + j] = abs(src_Matrix[i + WeldIndent + 1 + (j * length)] -
                                           src_Matrix[i + WeldIndent     + (j * length)]);
//            aSignal[NumSens * i + j] = abs(src_Matrix_row[i + WeldIndent + 1 + (j * length)] -
//                                           src_Matrix_row[i + WeldIndent     + (j * length)]);
        }
    }

    // 2. Пороговый фильтр. Find(aSignal[i, j] > LimAmp)
    for (i = 0; i <= (PointCount - 2); i++)
    {
        for (j = 0; j < NumSens; j++)
        {
            if (aSignal[NumSens * i + j] > LimCube) aSignal[NumSens * i + j] = LimCube;
        };
    };

    // 3. Кольцевой фильтр.
    for (i = 0; i <= (PointCount - 2); i++)
        aSignalMean[i] = CalculateMean(&aSignal[i*NumSens], NumSens);

    aSignalStd = GetStandardDeviation(aSignalMean, PointCount-1);
    aSignalMedian = CalculateMean(aSignalMean, PointCount-1);

    for (i = 0; i <= (PointCount - 2); i++)
    {
        if (aSignalMean[i] > (aSignalStd + aSignalMedian))
        {
            if ( (i > 1) && ( i < PointCount - 2))
            {
                for (j = 0; j <= 2; j++)
                  for (k = 0; k < NumSens; k++)
                     aSignal[NumSens * (i - 1 + j) + k] = 0;
            } else {
                if ( i == 0 )
                {
                    for (j = 0; j <= 1; j++)
                       for (k = 0; k < NumSens; k++)
                          aSignal[NumSens * (i + j) + k] = 0;
                } else {
                    for (j = 0; j <= 1; j++)
                      for (k = 0; k < NumSens; k++)
                         aSignal[NumSens * (i - 1 + j) + k] = 0;
                }
            }
        }
    }

    // 4. Полуоборотный цилиндрический фильтр
    bSignalLen = NumSens / 2;

    for (j = 0; j < bSignalLen; j++)
    {
        bSignal[j] = 0;

        for (i = 0; i <= (PointCount - 2); i++)
        {
           bSignal[j] += (aSignal[NumSens * i + j] * aSignal[NumSens * i + j + bSignalLen]);
        }
        bSignal[j] /=  (PointCount - 1);
    }

    // 5. Идентификация срабатывания алгоритма
    k = 0;
    aSignalMedian = CalculateMean(bSignal, bSignalLen);
    aSignalStd = GetStandardDeviation(bSignal, bSignalLen);

    for (i = 0; i < bSignalLen; i++)
    {
        if (bSignal[i] > (aSignalMedian + coefficient_SKO * aSignalStd))
        {
          cSignal[k] = (short) i;
          k++;
        }
    }

    n = 0;
    p = 0;

    if (k > 0)
    {
        for (i = 1; i < k; i++)
        {
            if ( (cSignal[i] - cSignal[i - 1]) > LimPeack)
            {
                dSignal[p] = cSignal[n];

                for (j = n + 1; j < i; j++)
                {
                    if (bSignal[cSignal[j]] > bSignal[cSignal[j - 1]])
                       dSignal[p] = cSignal[j];
                }
                n = i;
                p++;
            }
        }

        dSignal[p] = cSignal[n];

        for (i = n + 1; i < k; i++)
          if (bSignal[cSignal[i]] > bSignal[cSignal[i - 1]])
             dSignal[p] = cSignal[i];

        p++;

        if (p == 1)
        {
            PointPos = dSignal[0];

            // 6. Осредняющий фильтр
            for (j = 0; j < NumSens; j++)
            {
               bSignal[j] = 0;
               for (i = 0; i <= (PointCount - 2); i++)
               {
                  bSignal[j] += aSignal[NumSens * i + j];
               }
               bSignal[j] /= (PointCount - 1);

            }
                         
            // 7. Индентификация точек пересечения швов
            k = 0;
            aSignalStd = GetStandardDeviation(bSignal, NumSens);
            aSignalMedian = CalculateMean(bSignal, NumSens);

            for (i = 0; i < NumSens; i++)
            {
               if (bSignal[i] > (aSignalMedian + coefficient_SKO * aSignalStd))
               {
                   cSignal[k] = (short) i;
                   k++;
               }
            }


            n = 0;
            p = 0;

            for (i = 1; i < k; i++)
            {
              if ((cSignal[i] - cSignal[i - 1]) > LimPeack)
              {
                  dSignal[p] = cSignal[n];

                  for (j = n + 1; j < i; j++)
                    if (bSignal[cSignal[j]] > bSignal[cSignal[j - 1]])
                      dSignal[p] = cSignal[j];

                  n = i;
                  p++;
              }
            }

            dSignal[p] = cSignal[n];

            for (i = n + 1; i < k; i++)
              if (bSignal[cSignal[i]] > bSignal[cSignal[i - 1]])
                dSignal[p] = cSignal[i];

            p++;

           for (i = 1; i < k; i++)
           {
               dSignal[i] = cSignal[i];
           }
           p=k;

            // 8. Типизация трубы
            Result.PipeType = TUBE_DIRECT;
            bSignalLen = NumSens / 2;

            for (i = 0; i < p; i++)
            {
                if ((dSignal[i] >= PointPos - LimPeack) &&
                    (dSignal[i] <= PointPos + LimPeack))
                    Result.WeldPos1 = (short) PointPos;

                if ( (dSignal[i] >= PointPos + bSignalLen - LimPeack) &&
                     (dSignal[i] <= PointPos + bSignalLen + LimPeack) ) 
                    if(Result.WeldPos1 == -1)
                    {
                       Result.WeldPos1 = (short) (PointPos + bSignalLen);
                    } else Result.WeldPos2 = (short) (PointPos + bSignalLen);

            }

//            sprintf(tmp_log_str, "%d\n", Result.WeldPos1);
//            Log_weld(tmp_log_str);
        } // if (p == 1)

    } // if (k > 0)

    free(dSignal);
    free(cSignal);
    free(bSignal);
    free(aSignalMean);
    free(aSignal);

crash:

    return Result;

}; // TWeldPos LateralPipeSearch(long CrossWeldPos)


// Идентификация спирального шва
TWeldPos SpiralPipeSearch(long CrossWeldPos, KRTDATA* src_Matrix, KRTROW* src_Matrix_row, long length, long NumSens)
{
    long LimCube = 50;     // Порог по оси Oz
    long LimPeack = 10;    // Расстояние между пиками оси Ox
    long PointCount = 100;  // Ширина анализируемой области
    long PointIndent = 5;  // Шаг анализа внутри области
    long SensStep = NumSens/10; // Сдвиг по оси Oy
    byte coefficient_SKO = 5;

    TWeldPos Result;

    long isSpiralPipe;
    long isClearPipe;

    long i, j, k, n, p, z;

    long PointAngle;
    long PointPos = 0;
    long PointShift;
    long PointStep;


    Result.PipeType = TUBE_UNKNOWN;
    Result.WeldPos1 = -1;
    Result.WeldPos2 = -1;


    aSignal     = malloc(NumSens * PointCount * sizeof(aSignal[0]));
    aSignalVec  = malloc(NumSens * PointCount * sizeof(aSignalVec[0]));
    aSignalMean = malloc(NumSens * PointCount * sizeof(aSignalMean[0]));
    bSignal     = malloc(NumSens * PointCount * sizeof(bSignal[0]));
    cSignal     = malloc(NumSens * PointCount * sizeof(cSignal[0]));
    dSignal     = malloc(NumSens * PointCount * sizeof(dSignal[0]));

    // |<- .. ->|
    for (z = 1; z <= 2; z++)
    {
        isClearPipe = False;
        isSpiralPipe = False;

        // 1. Приведение к общему нулю сигналов. Abs(Diff(src_Matrix[]))
        if (z == 1)
        {
            PointStep = WeldIndent;
        } else {
            PointStep = CrossWeldPos - WeldIndent - PointCount;
            if (PointStep < 0) PointStep = 0;
        }

        for (i = 0; i <= (PointCount - 2); i++)
          for (j = 0; j < NumSens; j++)
            aSignal[NumSens * i + j] =
              abs( src_Matrix[(i + PointStep + 1) + j * length] - 
                   src_Matrix[(i + PointStep    ) + j * length] );
//              abs( src_Matrix_row[(i + PointStep + 1) + j * length] - 
//                   src_Matrix_row[(i + PointStep    ) + j * length] );

        // 2. Пороговый фильтр. Find(aSignal[i, j] > LimAmp)
        for (i = 0; i <= (PointCount - 2); i++)
          for (j = 0; j < NumSens; j++)
            if (aSignal[NumSens * i + j] > LimCube) aSignal[NumSens * i + j] = LimCube;

        // 3. Кольцевой фильтр.
        for (i = 0; i <= (PointCount - 2); i++)
            aSignalMean[i] = CalculateMean(&(aSignal[i*NumSens]), NumSens);

        aSignalStd = GetStandardDeviation(aSignalMean, PointCount-1);
        aSignalMedian = CalculateMean(aSignalMean, PointCount-1);

        for (i = 0; i <= (PointCount - 2); i++)
        {
            if (aSignalMean[i] > (aSignalStd + aSignalMedian))
            {
                if ( !( (i-1 < 1) || ( i+1 < PointCount - 1)))
                {
                    for (j = 0; j <= 2; j++)
                      for (k = 0; k < NumSens; k++)
                         aSignal[NumSens * (i - 1 + j) + k] = 0;
                } else {
                    if ( i-1 < 1 )
                    {
                        for (j = 0; j <= 1; j++)
                           for (k = 0; k < NumSens; k++)
                              aSignal[NumSens * (i + j) + k] = 0;
                    } else {
                        for (j = 0; j <= 1; j++)
                          for (k = 0; k < NumSens; k++)
                             aSignal[NumSens * (i - 1 + j) + k] = 0;
                    }
                }
            }
        }

        // 4. Скручивающийся цилиндрический фильтр. |---| -> |///|
        bSignalLen = PointCount - PointIndent - 1;

        for (i=0; i <= SensStep; i++)
        {
            bSignal[i] = 0;
        }

        for (i = 0; i < bSignalLen; i++)
        {
           for (j = 0; j <= SensStep; j++)
           {
              for (k = 0; k <= NumSens - j; k++)
              {
                 bSignal[j] += 
                   ((aSignal[NumSens * i + k] * aSignal[NumSens * (i + PointIndent) + j + k]) /
                   (NumSens - j + 1)) / (SensStep + 1);
              };
           }
        }

        PointShift = 0;
        for (i = 1; i <= SensStep; i++)
          if (bSignal[i] > bSignal[PointShift])  PointShift = i;


        // 5. Выпрямляющий цилиндрический фильтр. |///| -> |---|
        for (i = 1; i <= (PointCount - 2); i++)
        {
            PointAngle = (long) (i * PointShift / PointIndent);

            if (PointAngle > 0)
            {
                for (j = 0; j < PointAngle; j++)
                   aSignalVec[j] = aSignal[NumSens * i + j];

                for (j = 0; j <= (NumSens - PointAngle); j++)
                   aSignal[NumSens * i + j] = aSignal[NumSens * i + j + PointAngle];

                for (j = 0; j < PointAngle; j++)
                  aSignal[NumSens * i + NumSens - PointAngle + j + 1] = aSignalVec[j];
            }
        }

        // 6. Осредняющий фильтр. -->|   |
        for (j = 0; j < NumSens; j++) aSignalMean[j] = 0;

        for (j = 0; j < NumSens; j++)
          for (i = 0; i <= (PointCount - 2); i++)
            aSignalMean[j] += aSignal[NumSens * i + j] / (PointCount - 1);

        // 7. Идентификация срабатывания алгоритма
        k = 0;

        aSignalStd = GetStandardDeviation(aSignalMean, NumSens);
        aSignalMedian = CalculateMean(aSignalMean, NumSens);

        for (i = 0; i < NumSens; i++)
        {
           if (aSignalMean[i] > (aSignalMedian + coefficient_SKO * aSignalStd))
           {
               cSignal[k] = (short) i;
               k++;
           }
        }

        n = 0;
        p = 0;

        if (k > 1)
        {
            for (i = 1; i < k; i++)
            {
               if ( (cSignal[i] - cSignal[i - 1]) > LimPeack)
               {
                   dSignal[p] = cSignal[n];

                   for (j = n + 1; j < i; j++)
                     if (aSignalMean[cSignal[j]] > aSignalMean[cSignal[j - 1]])
                        dSignal[p] = cSignal[j];

                   n = i;
                   p++;
               }
            }

            dSignal[p] = cSignal[n];

            for (i = n + 1; i < k; i++)
              if (aSignalMean[cSignal[i]] > aSignalMean[cSignal[i - 1]])
                dSignal[p] = cSignal[i];

            p++;

            PointPos = dSignal[0];
        }

        if (p == 0) isClearPipe = True;
        else
           if (p == 1) isSpiralPipe = True;
           else
             if ( (p == 2) && (dSignal[0] < LimPeack) && (NumSens - dSignal[1] < LimPeack) )
             {
                 if (dSignal[1] > PointPos) PointPos = dSignal[1];
                 isSpiralPipe = True;
             }

        // 8. Локализация точек пересечения швов
        if (z == 1)
        {
            if (isSpiralPipe)
            {
                Result.WeldPos1 = (short) (PointPos - (WeldIndent * PointShift / PointIndent));

                if (Result.WeldPos1 < 0)
                  Result.WeldPos1 = (short) (Result.WeldPos1 + NumSens);
            } else {
              if (isClearPipe) Result.WeldPos1 = -2;
            }
        } else {
            if (isSpiralPipe)
            {
                Result.WeldPos2 = (short) ( PointPos +
                                            ((WeldIndent + PointCount) * PointShift / PointIndent));

                if (Result.WeldPos2 > NumSens)
                  Result.WeldPos2 = (short) (Result.WeldPos2 - NumSens);
            } else {
              if (isClearPipe) Result.WeldPos1 = -2;
            }
        }
    }; //for (z = 1; z <= 2; z++)

    // 9. Типизация трубы
    Result.PipeType = TUBE_WITHOUT;

//    if ((Result.WeldPos1 == -2) || (Result.WeldPos2 == -2))
//    {
//       Result.PipeType = TUBE_WITHOUT;
//    } else {
       if ((Result.WeldPos1 >= 0) && (Result.WeldPos2 >= 0))
         Result.PipeType = TUBE_SPIRAL;
//    }

//    sprintf(tmp_log_str, "9\n");
//    Log_weld(tmp_log_str);

    free(aSignal);
    free(aSignalVec);
    free(aSignalMean);
    free(bSignal);
    free(cSignal);
    free(dSignal);

    return Result;

} // TWeldPos SpiralPipeSearch(long CrossWeldPos)


#define SensCount 192   // Количество датчиков, начиная с нулевого датчика;
#define MatrCount 2800  // Количество анализируемых записей;

//KRTROW  isxMatrix [MatrCount * SensCount];
//long   GlobalCrossWeldPos;
TWeldPos  Weld;


int call_count = 0;
char str[10];

// Промежуточная процедура
long AnalyseData(const T_SCAN_INPUT *inp, T_SCAN_OUTPUT *out)
{
    long CrossWeldPos;

    out->wldTyp = TUBE_UNKNOWN;
    out->slit1  = -1;               
    out->slit2  = -1;               

    call_count++;
    WeldIndent = inp->minTubeLen;

    out->wldIndex = CrossWeldPos = CrossPipeSearch(inp->dat, inp->row, inp->x, inp->y);

    if (CrossWeldPos > 0)
    {
        Weld.PipeType = TUBE_WITHOUT;
        Weld.WeldPos1 = -1;
        Weld.WeldPos2 = -1;
/*
//        GlobalCrossWeldPos = GlobalCrossWeldPos + CrossWeldPos;
// short           noDRC;            // если 1, то труба не может быть прямошовной
// short           noSPR;            // --- спиралешовной
// short           noWTO;            // --- бесшовной

//        if (inp->noSPR != 1) Weld = SpiralPipeSearch(CrossWeldPos, inp->dat, inp->row, inp->x, inp->y);
        Weld = LateralPipeSearch(CrossWeldPos, inp->dat, inp->row, inp->x, inp->y);

        if ( Weld.PipeType != TUBE_DIRECT )
//        if ( Weld.PipeType != TUBE_SPIRAL )
        {
//              if (inp->noDRC != 1) Weld = LateralPipeSearch(CrossWeldPos, inp->dat, inp->row, inp->x, inp->y);
            Weld = SpiralPipeSearch(CrossWeldPos, inp->dat, inp->row, inp->x, inp->y);
        }
*/
    }

    out->wldTyp = Weld.PipeType ;
    out->slit1  = Weld.WeldPos1 ;
    out->slit2  = Weld.WeldPos2 ;

   return 0;
}
