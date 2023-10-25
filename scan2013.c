#include <math.h>
#include <stdio.h>

#include "scan.h"

#define PI  3.14159265359

#define False 0
#define True  1

char tmp_log_str[1024];

#define LOG_WELD_FILE "c:\\Log_weld.txt"

void Log_weld(char *LogString)
	{
	FILE *call_log;

	call_log = fopen(LOG_WELD_FILE, "at");
	fprintf(call_log, "%s", LogString);
	fclose(call_log);
	}

double CalculateMean(double value[], long array_size)
	{
	double sum = 0;
	int i;

	for (i = 0; i < array_size; i++)
		sum += value[i];

	return (sum / array_size);
	}

double CalculateVariane(double value[], long array_size)
	{
	double sum = 0;
	int i;

	double mean = CalculateMean(value, array_size);

	for (i = 0; i < array_size; i++)
		sum += (value[i] - mean) * (value[i] - mean);

	return sum / array_size;
	}

double GetStandardDeviation(double value[], long array_size)
	{
	return sqrt(CalculateVariane(value, array_size));
	}

typedef struct
	{
	short PipeType; // ��� ����� (���� �� �������� TUBE_* ��.����)
	short WeldPos1; // ����� ������� 1 ����������� ��� (-1 ���� ���)
	short WeldPos2; // ����� ������� 2 ����������� ��� (-1 ���� ���)
	} TWeldPos; // ��������� �������� ������ ���������� ���

typedef struct
	{
	short Indent;	// ������ �� ��� (10 - 30)
	float Lim;		// ����� �����.���������� (1 - 100)
	long minTubeLen;// ����������� ����� �����
	long Pos;		// ��������������� ���
	float SKO;		// ����-�� ���������������� (1 - 10)	
	short Width;	// ����������� ������ ��� (1 - 30)	
	} TCrossWeld; // ��������� ������ ����������� ���

typedef struct
	{
	float Lim;		// ����� �����.���������� (1 - 100)	
    short Peack;	// ������ ���� ������������ ������� ��� (1 - 15)
    float SKO;		// ����-�� ���������������� (1 - 10)
    short Width;	// ����������� ������ ��� (1 - 30)
	} TLateralWeld; // ��������� ������ ����������� ���

typedef struct
	{
	float AngleMax; // ������������ ���� ������� �������
	float AngleMin; // ����������� ���� ������� �������
	short Area;		// ������ ������.������� (30 - .lenMax), �
	long Diam;		// ������� �����, ��
	float Lim;		// ����� �����.���������� (1 - 100)
	long LimPeack; // ���������� ����� ������ ��� Ox
    short OdomStep; // ��� ��������, ��
	long PointIndent; // ��� ������� ������ �������
	long SensStep; // ����� �� ��� Oy
	float SKO;		// ����-�� ���������������� (1 - 10)
    short Width;	// ����������� ������ ��� (1 - 30), �
	} TSpiralWeld; // ��������� ������ ����������� ���


// ������������� ����������� ��� ��� ������������� ���� ��������
long CrossPipeSearchForCor(KRTDATA* src_Matrix, KRTROW* src_Matrix_row, 
	long length, long NumSens, TCrossWeld cw)
	{
	long Result;
	static long pred_Result = 0;

	long aMaxLen;		// ����� �������
	long aSignalLen;	// ����� �������
	long i, j, k;		// �������

	long * aMax;		// ������ � �������� ���������, ����������� � ���� ����������������

	double * aSignal;	// ������ �������������� �������
	double * bSignal;	// ������ �� �������� ���������� �������� ��������
	
	double aSignalMean;	// ���. �������� �������� �������
	double aSignalStd;	// ��� �������� �������
	
	if (pred_Result == TUBE_UNKNOWN)
		cw.Indent = 0;

	Result = TUBE_UNKNOWN;

	aSignalLen = length - cw.Indent;

	aSignal = malloc(aSignalLen * sizeof(aSignal[0]));
	memset(aSignal, 0, aSignalLen * sizeof(aSignal[0]));
	
	bSignal = malloc(NumSens * sizeof(bSignal[0]));
	memset(bSignal, 0, NumSens * sizeof(bSignal[0]));

	aMax = malloc(length * sizeof(aMax[0]));
	memset(aMax, 0, length * sizeof(aMax[0]));

	// 1. ����������� ��������� �������� �������� ��������
	for (j = 0; j < NumSens; j++)
		{
		bSignal[j] = 0;

		for (i = 0; i < aSignalLen; i++)
			bSignal[j] += src_Matrix_row[(i + cw.Indent) + j * length];

		bSignal[j] = bSignal[j] / aSignalLen;
		}

	// 2. ������������ ������� � ���������������� ��������� �������� �������� ��������
	for (i = 0; i < aSignalLen; i++)
		{
		for (j = 0; j < NumSens; j++)
			{
			//dSignal = src_Matrix[(i + WeldIndent) + j * length] -
			//	bSignal[j];
			aSignal[i] += src_Matrix_row[(i + cw.Indent) + j * length] -
				bSignal[j];
			};

		aSignal[i] = fabs(aSignal[i] / NumSens);
		};

	for (j = 0; j <= 1; j++)	
		{
		aSignalLen--;

		for (i = 0; i < aSignalLen; i++)
			aSignal[i] = aSignal[i + 1] - aSignal[i];
		}

	for (i = 0; i < aSignalLen; i++)
		aSignal[i] = fabs(aSignal[i]);

	//3. ������������ ������� � �������� ���������, ����������� � ���� ����������������
	aMaxLen = 0;
	aSignalStd = GetStandardDeviation(aSignal, aSignalLen);
	aSignalMean = CalculateMean(aSignal, aSignalLen);

	for (i = cw.minTubeLen - cw.Indent; i < aSignalLen; i++)
		{
		if (aSignal[i] > (aSignalMean + cw.SKO * aSignalStd))
			{
			aMax[aMaxLen] = i;
			aMaxLen++;
			};
		};
	 
	// 4. ����������� �������������� ���
	i = 0;
	j = 0;
	k = 0;

	if (aMaxLen >= cw.Width)
		{
		for (i = j; i <= (aMaxLen - 2); i++)
			{
			if ((aMax[i + 1] - aMax[i]) <= cw.Width)
				{
				if (k == 0)
					j = i;

				k++;
				}
			else
				{
				if (k >= cw.Width)
					break;
				else
					k = 0;
				}
			}

		if (k >= cw.Width)
			Result = aMax[j] + (aMax[j + k - 1] - aMax[j]) / 2 + cw.Indent + 1;
		else
			Result = TUBE_UNKNOWN;
		}	

	free(aMax);
	free(aSignal);
	free(bSignal);

	pred_Result = Result;

	return Result;

	}

// ������������� ����������� ��� ��� ����������� ���� ��������
long CrossPipeSearchForPrf(KRTDATA* src_Matrix, KRTROW* src_Matrix_row, 
	long length, long NumSens, TCrossWeld cw)
	{
	long Result;
	static long pred_Result = 0;

	long aMaxLen;		// ����� �������
	long aSignalLen;	// ����� �������
	long i, j, k;		// �������

	long * aMax;		// ������ � �������� ���������, ����������� � ���� ����������������

	double * aSignal;	// ������ �������������� �������
	double * bSignal;	// ������ �� �������� ���������� �������� ��������
	double * aMatrix;	// �������� ������

	double aSignalMean;	// ���. �������� �������� �������
	double aSignalStd;	// ��� �������� �������
	
	if (pred_Result == TUBE_UNKNOWN)
		cw.Indent = 0;

	Result = TUBE_UNKNOWN;

	aSignalLen = length - cw.Indent;

	aSignal = malloc(aSignalLen * sizeof(aSignal[0]));
	memset(aSignal, 0, aSignalLen * sizeof(aSignal[0]));
	
	bSignal = malloc(NumSens * sizeof(bSignal[0]));
	memset(bSignal, 0, NumSens * sizeof(bSignal[0]));

	aMatrix = malloc(aSignalLen * NumSens * sizeof(aMatrix[0]));
	memset(aMatrix, 0, aSignalLen * NumSens * sizeof(aMatrix[0]));

	aMax = malloc(length * sizeof(aMax[0]));
	memset(aMax, 0, length * sizeof(aMax[0]));

	// 0. ������� ������ �� ������������� � ����� � ��������� �������
	for (j = 0; j < NumSens; j++)
		{
		for (i = 0; i < aSignalLen; i++)
			{
			aMatrix[i + j * aSignalLen] = src_Matrix[(i + cw.Indent) + j * length];
			}
		}

	// 1. ���������� �������� �������� ����������� �������� �� ���� �����
	/*for (j = 0; j < NumSens; j++)
		{
		for (i = 1; i < aSignalLen; i++)
			{
			d = aMatrix[i + j * aSignalLen] - aMatrix[i - 1 + j * aSignalLen];
			
			if (abs(d) > cw.Lim)
				{
				for (k = i; k < aSignalLen; k++)
					{
					aMatrix[k + j * aSignalLen] += - d;
					}
				}
			}
		}*/

	// 2. ����������� ��������� �������� �������� ��������
	for (j = 0; j < NumSens; j++)
		{
		for (i = 0; i < aSignalLen; i++)
			bSignal[j] += aMatrix[i + j * aSignalLen];

		bSignal[j] = bSignal[j] / aSignalLen;
		}

	// 3. ��������������� ��������� �������� �������� ��������
	for (i = 0; i < aSignalLen; i++)
		{
		for (j = 0; j < NumSens; j++)
			{
			aMatrix[i + j * aSignalLen] += - bSignal[j];
			};
		};

	// 4. ���������� ��������� �������� � ���������� �����������
	/*for (i = 0; i < aSignalLen; i++)
		{
		for (j = 1; j < NumSens; j++)
			{
			aMatrix[i + j * aSignalLen] += 0.1 * aMatrix[i + j * aSignalLen] +
				0.9 * aMatrix[i + (j - 1) * aSignalLen];
			};
		};

	for (i = 0; i < aSignalLen; i++)
		{
		aMatrix[i + 0] += 0.1 * aMatrix[i] +	0.9 * aMatrix[i + aSignalLen];
		};*/

	// 5. ������������ �������������� �������
	for (i = 0; i < aSignalLen; i++)
		{
		for (j = 0; j < NumSens; j++)
			{
			aSignal[i] += aMatrix[i + j * aSignalLen];
			};

		aSignal[i] = aSignal[i] / NumSens;
		};


	//6. ������������ ������� � �������� ���������, ����������� � ���� ����������������
	aMaxLen = 0;
	aSignalStd = GetStandardDeviation(aSignal, aSignalLen);
	aSignalMean = CalculateMean(aSignal, aSignalLen);

	for (i = cw.minTubeLen - cw.Indent; i < aSignalLen; i++)
		{
		if (aSignal[i] > (aSignalMean + cw.SKO * aSignalStd))
			{
			aMax[aMaxLen] = i;
			aMaxLen++;
			};
		};
	 
	// 7. ����������� �������������� ���
	i = 0;
	j = 0;
	k = 0;

	if (aMaxLen >= cw.Width)
		{
		for (i = j; i <= (aMaxLen - 2); i++)
			{
			if ((aMax[i + 1] - aMax[i]) <= cw.Width)
				{
				if (k == 0)
					j = i;

				k++;
				}
			else
				{
				if (k >= cw.Width)
					break;
				else
					k = 0;
				}
			}

		if (k >= cw.Width)
			Result = aMax[j] + (aMax[j + k - 1] - aMax[j]) / 2 + cw.Indent;
		else
			Result = TUBE_UNKNOWN;
		}	

	free(aMax);
	free(aMatrix);
	free(aSignal);
	free(bSignal);

	pred_Result = Result;

	return Result;

	}

	// ������������� ����������� ��� ��� ������-������������� ���� ��������
long CrossPipeSearchForStr(KRTDATA* src_Matrix, KRTROW* src_Matrix_row, 
	long length, long NumSens, TCrossWeld cw)
	{
	long Result;
	static long pred_Result = 0;

	long aMaxLen;		// ����� �������
	long aSignalLen;	// ����� �������
	long i, j, k;		// �������

	long * aMax;		// ������ � �������� ���������, ����������� � ���� ����������������

	double * aSignal;	// ������ �������������� �������
	double * bSignal;	// ������ �� �������� ���������� �������� ��������
	double * aMatrix;	// �������� ������

	double aSignalMean;	// ���. �������� �������� �������
	double aSignalStd;	// ��� �������� �������
	
	if (pred_Result == TUBE_UNKNOWN)
		cw.Indent = 0;

	Result = TUBE_UNKNOWN;

	aSignalLen = length - cw.Indent;

	aSignal = malloc(aSignalLen * sizeof(aSignal[0]));
	memset(aSignal, 0, aSignalLen * sizeof(aSignal[0]));
	
	bSignal = malloc(NumSens * sizeof(bSignal[0]));
	memset(bSignal, 0, NumSens * sizeof(bSignal[0]));

	aMatrix = malloc(aSignalLen * NumSens * sizeof(aMatrix[0]));
	memset(aMatrix, 0, aSignalLen * NumSens * sizeof(aMatrix[0]));

	aMax = malloc(length * sizeof(aMax[0]));
	memset(aMax, 0, length * sizeof(aMax[0]));

	// 1. ������� ������ �� ������������� � ����� � ��������� �������
	for (j = 0; j < NumSens; j++)
		{
		for (i = 0; i < aSignalLen; i++)
			{
			aMatrix[i + j * aSignalLen] = src_Matrix[(i + cw.Indent) + j * length];
			}
		}

	// 2. ����������� ��������� �������� �������� ��������
	for (j = 0; j < NumSens; j++)
		{
		for (i = 0; i < aSignalLen; i++)
			bSignal[j] += aMatrix[i + j * aSignalLen];

		bSignal[j] = bSignal[j] / aSignalLen;
		}

	// 3. ��������������� ��������� �������� �������� ��������
	for (i = 0; i < aSignalLen; i++)
		{
		for (j = 0; j < NumSens; j++)
			{
			aMatrix[i + j * aSignalLen] += - bSignal[j];
			};
		};

	// 4. ���������� ��������� �������� � ���������� �����������
	for (i = 0; i < aSignalLen; i++)
		{
		for (j = 1; j < NumSens; j++)
			{
			aMatrix[i + j * aSignalLen] = 0.1 * aMatrix[i + j * aSignalLen] +
				0.9 * aMatrix[i + (j - 1) * aSignalLen];
			};
		};

	for (i = 0; i < aSignalLen; i++)
		{
		aMatrix[i] = 0.1 * aMatrix[i] + 0.9 * aMatrix[i + aSignalLen];
		};

	// 5. ������������ �������������� �������
	for (i = 0; i < aSignalLen; i++)
		{
		for (j = 0; j < NumSens; j++)
			{
			aSignal[i] += aMatrix[i + j * aSignalLen];
			};

		aSignal[i] = aSignal[i] / NumSens;
		};


	//6. ������������ ������� � �������� ���������, ����������� � ���� ����������������
	aMaxLen = 0;
	aSignalStd = GetStandardDeviation(aSignal, aSignalLen);
	aSignalMean = CalculateMean(aSignal, aSignalLen);

	for (i = cw.minTubeLen - cw.Indent; i < aSignalLen; i++)
		{
		if (aSignal[i] > (aSignalMean + cw.SKO * aSignalStd))
			{
			aMax[aMaxLen] = i;
			aMaxLen++;
			};
		};
	 
	// 7. ����������� �������������� ���
	i = 0;
	j = 0;
	k = 0;

	if (aMaxLen >= cw.Width)
		{
		for (i = j; i <= (aMaxLen - 2); i++)
			{
			if ((aMax[i + 1] - aMax[i]) <= cw.Width)
				{
				if (k == 0)
					j = i;

				k++;
				}
			else
				{
				if (k >= cw.Width)
					break;
				else
					k = 0;
				}
			}

		if (k >= cw.Width)
			Result = aMax[j] + (aMax[j + k - 1] - aMax[j]) / 2 + cw.Indent;
		else
			Result = TUBE_UNKNOWN;
		}	

	free(aMax);
	free(aMatrix);
	free(aSignal);
	free(bSignal);

	pred_Result = Result;

	return Result;

	}

double * aSignal; // ������ �������������� �������
double * aSignalMean;
double * aSignalVec;
double * bSignal;

short * cSignal;
short * dSignal;

double aSignalMedian; // ���. �������� �������� �������
double aSignalStd; // ��� �������� �������

long bSignalLen; // ����� �������

// ������������� ����������� ��� ��� ������������� ���� ��������
TWeldPos LateralPipeSearchForCorAndStr(KRTDATA* src_Matrix,	KRTROW * src_Matrix_row, 
	long length, long NumSens, TCrossWeld cw, TLateralWeld lw)
	{
	TWeldPos Result;

	long i, j, k, n, p; // �������
	long PointCount; // ������ ������������� �������
	long PointPos; // ����� ���������� ���
	long status = 0;

	Result.PipeType = TUBE_WITHOUT;
	Result.WeldPos1 = -1;
	Result.WeldPos2 = -1;

	PointCount = cw.Pos - 2 * cw.Indent;

	aSignal = malloc(NumSens * PointCount*sizeof(aSignal[0]));
	if (aSignal == NULL)
		{
		status = -1;
		goto crash;
		};

	aSignalMean = malloc(NumSens * PointCount*sizeof(aSignalMean[0]));
	if (aSignalMean == NULL)
		{
		status = -2;
		goto crash;
		};

	bSignal = malloc(NumSens * PointCount*sizeof(bSignal[0]));
	if (bSignal == NULL)
		{
		status = -3;
		goto crash;
		};

	cSignal = malloc(NumSens * PointCount*sizeof(cSignal[0]));
	if (cSignal == NULL)
		{
		status = -4;
		goto crash;
		};

	dSignal = malloc(NumSens * PointCount*sizeof(dSignal[0]));
	if (dSignal == NULL)
		{
		status = -5;
		goto crash;
		};

	// 1. ������������ �������������� �������
	for (i = 0; i <= (PointCount - 2); i++)
		{
		for (j = 0; j < NumSens; j++)
			{
			// aSignal[NumSens * i + j] = (src_Matrix[i + WeldIndent + 1 + (j * length)] -
			// src_Matrix[i + WeldIndent     + (j * length)]);
			aSignal[NumSens * i + j] =
			  src_Matrix_row[i + cw.Indent + 1 + (j * length)] -
			  src_Matrix_row[i + cw.Indent + (j * length)];

			aSignal[NumSens * i + j] = fabs(aSignal[NumSens * i + j]);
			}
		}

	// 2. ���������� ������� ��������� ��������
	for (i = 0; i <= (PointCount - 2); i++)
		{
		for (j = 0; j < NumSens; j++)
			{
			if (aSignal[NumSens * i + j] > lw.Lim)
				aSignal[NumSens * i + j] = lw.Lim;
			}
		}

	// 3. ��������� ������.
	for (i = 0; i <= (PointCount - 2); i++)
		aSignalMean[i] = CalculateMean(&aSignal[i * NumSens], NumSens);
		
	aSignalStd = GetStandardDeviation(aSignalMean, PointCount - 1);
	aSignalMedian = CalculateMean(aSignalMean, PointCount - 1);

	for (i = 0; i <= (PointCount - 2); i++)
		{
		if (aSignalMean[i] > (aSignalStd + aSignalMedian))
			if ((i > 1) && (i < PointCount - 3))
				for (j = 0; j <= 2; j++)
					for (k = 0; k < NumSens; k++)
						aSignal[NumSens * (i - 1 + j) + k] = 0;
			else
				if (i <= 1)
					for (j = 0; j <= 1; j++)
						for (k = 0; k < NumSens; k++)
							aSignal[NumSens * (i + j) + k] = 0;
				else
					for (j = 0; j <= 1; j++)
						for (k = 0; k < NumSens; k++)
							aSignal[NumSens * (i - 1 + j) + k] = 0;
		}

	// 4. ������������� �������������� ������
	bSignalLen = NumSens / 2;

	for (j = 0; j < bSignalLen; j++)
		{
		bSignal[j] = 0;

		for (i = 0; i <= (PointCount - 2); i++)
			bSignal[j] +=
			  (aSignal[NumSens * i + j] * aSignal[NumSens * i + j +
					bSignalLen]);
					
		bSignal[j] /= (PointCount - 1);
		}

	// 5. ������������� ������������ ���������
	k = 0;
	aSignalMedian = CalculateMean(bSignal, bSignalLen);
	aSignalStd = GetStandardDeviation(bSignal, bSignalLen);

	for (i = 0; i < bSignalLen; i++)
		if (bSignal[i] > (aSignalMedian + lw.SKO * aSignalStd))
			{
			cSignal[k] = (short) i;
			k++;
			}
			
	// ���������� �����������
	n = 0;

	if (k > 0)
		{
		// �������� �� ������ �� ����� �������
		for (i = 0; i < k - 1; i++)
			{
			if ((cSignal[i + 1] - cSignal[i]) < lw.Peack)
				n++;
			else
				{
				if (n < lw.Width)
					for (j = 0; j < n; j++)
						cSignal[i - j] = 0;

				n = 0;
				}
			}

		// �������� �� ����� �� ������ �������
		for (i = k - 1; i > 0; i--)
			{
			if ((cSignal[i] - cSignal[i - 1]) < lw.Peack)
				n++;
			else
				{
				if (n < lw.Width)
					for (j = 0; j < n; j++)
						cSignal[i + j] = 0;

				n = 0;
				break;
				}
			}

		// ����������� ��������� ����� � ������ �������
		for (i = 0; i < k; i++)
			{
			if (cSignal[i] == 0)
				{
				for (j = i; j < k; j++)
					cSignal[j] = cSignal[j + 1];

				cSignal[k - 1] = 0;
				}
			}
		}

	n = 0;
	p = 0;

	if (k > 0)
		{
		for (i = 1; i < k; i++)
			{
			if ((cSignal[i] - cSignal[i - 1]) > lw.Peack)
				{
				dSignal[p] = cSignal[n];

				for (j = n + 1; j < i; j++)
					if (bSignal[cSignal[j]] > bSignal[dSignal[p]])
						dSignal[p] = cSignal[j];
						
				n = i;
				p++;
				}
			}

		dSignal[p] = cSignal[n];

		for (i = n + 1; i < k; i++)
			{
			if (bSignal[cSignal[i]] > bSignal[dSignal[p]])
				dSignal[p] = cSignal[i];
			}

		p++;

		if (p == 1)
			{
			PointPos = dSignal[0];

			// 6. ����������� ������
			for (j = 0; j < NumSens; j++)
				{
				bSignal[j] = 0;

				for (i = 0; i <= (PointCount - 2); i++)
					{
					bSignal[j] += aSignal[NumSens * i + j];
					}
				bSignal[j] /= (PointCount - 1);

				}

			// 7. �������������� ����� ����������� ����
			k = 0;
			aSignalStd = GetStandardDeviation(bSignal, NumSens);
			aSignalMedian = CalculateMean(bSignal, NumSens);

			for (i = 0; i < NumSens; i++)
				if (bSignal[i] > (aSignalMedian + lw.SKO * aSignalStd))
					{
					cSignal[k] = (short) i;
					k++;
					}

			n = 0;
			p = 0;

			for (i = 1; i < k; i++)
				if ((cSignal[i] - cSignal[i - 1]) > lw.Peack)
					{
					dSignal[p] = cSignal[n];

					for (j = n + 1; j < i; j++)
						if (bSignal[cSignal[j]] > bSignal[dSignal[p]])
							dSignal[p] = cSignal[j];

					n = i;
					p++;
					}

			dSignal[p] = cSignal[n];

			for (i = n + 1; i < k; i++)
				if (bSignal[cSignal[i]] > bSignal[dSignal[p]])
					dSignal[p] = cSignal[i];

			p++;

			// 8. ��������� �����
			Result.PipeType = TUBE_DIRECT;
			bSignalLen = NumSens / 2;

			for (i = 0; i < p; i++)
				{
				if ((dSignal[i] >= PointPos - lw.Peack) && (dSignal[i] <=
						PointPos + lw.Peack))
					Result.WeldPos1 = (short) PointPos;

				if ((dSignal[i] >= PointPos + bSignalLen - lw.Peack) &&
					(dSignal[i] <= PointPos + bSignalLen + lw.Peack))
					if (Result.WeldPos1 == -1)
						Result.WeldPos1 = (short)(PointPos + bSignalLen);
					else
						if (dSignal[i] - PointPos > bSignalLen)
							{
							Result.WeldPos1 +=
							  (short)((dSignal[i] - PointPos - bSignalLen) / 2);
						Result.WeldPos2 = 
						  (short)(Result.WeldPos1 + bSignalLen);
						}
						else
							Result.WeldPos2 =
							  (short) (Result.WeldPos1 + bSignalLen);
				}

			// sprintf(tmp_log_str, "%d\n", Result.WeldPos1);
			// Log_weld(tmp_log_str);
			} // if (p == 1)

		} // if (k > 0)

	free(dSignal);
	free(cSignal);
	free(bSignal);
	free(aSignalMean);
	free(aSignal);

crash:
	return Result;
	};

// ������������� ����������� ��� ��� ������������� ���� ��������
TWeldPos SpiralPipeSearchForCorAndStr(KRTDATA* src_Matrix, KRTROW* src_Matrix_row, 
	long length, long NumSens,	int spin_direct, TCrossWeld cw, TSpiralWeld sw) // ����������� ������� ����������� ���
	{
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

	aSignal = malloc(NumSens * sw.Area*sizeof(aSignal[0]));
	aSignalVec = malloc(NumSens * sw.Area*sizeof(aSignalVec[0]));
	aSignalMean = malloc(NumSens * sw.Area*sizeof(aSignalMean[0]));
	bSignal = malloc(NumSens * sw.Area*sizeof(bSignal[0]));
	cSignal = malloc(NumSens * sw.Area*sizeof(cSignal[0]));
	dSignal = malloc(NumSens * sw.Area*sizeof(dSignal[0]));

	// |<- .. ->|
	for (z = 1; z <= 2; z++)
		{
		isClearPipe = False;
		isSpiralPipe = False;

		// 1. ���������� � ������ ���� ��������
		if (z == 1)
			{
			PointStep = cw.Indent;
			}
		else
			{
			PointStep = cw.Pos - cw.Indent - sw.Area;
			if (PointStep < 0)
				PointStep = 0;
			}

		if (spin_direct == True)
			{
			for (i = 0; i <= (sw.Area - 2); i++)
				for (j = 0; j < NumSens; j++)
					aSignal[NumSens * i + j] = fabs(
					// src_Matrix[(i + PointStep + 1) + j * length] -
					// src_Matrix[(i + PointStep    ) + j * length]);
					src_Matrix_row[(i + PointStep + 1) + j * length] -
					src_Matrix_row[(i + PointStep) + j * length]);
			}
		else
			{
			for (i = 0; i <= (sw.Area - 2); i++)
				for (j = 0; j < NumSens; j++)
					aSignal[NumSens * i + (NumSens - 1 - j)] = fabs(
					// src_Matrix[(i + PointStep + 1) + j * length] -
					// src_Matrix[(i + PointStep    ) + j * length]);
					src_Matrix_row[(i + PointStep + 1) + j * length] -
					src_Matrix_row[(i + PointStep) + j * length]);
			}

		// 2. ��������� ������. Find(aSignal[i, j] > LimAmp)
		for (i = 0; i <= (sw.Area - 2); i++)
			for (j = 0; j < NumSens; j++)
				if (aSignal[NumSens * i + j] > sw.Lim)
					aSignal[NumSens * i + j] = sw.Lim;

		// 3. ��������� ������.
		for (i = 0; i <= (sw.Area - 2); i++)
			aSignalMean[i] = CalculateMean(&(aSignal[i * NumSens]), NumSens);

		aSignalStd = GetStandardDeviation(aSignalMean, sw.Area - 1);
		aSignalMedian = CalculateMean(aSignalMean, sw.Area - 1);

		for (i = 0; i <= (sw.Area - 2); i++)
			{
			if (aSignalMean[i] > (aSignalStd + aSignalMedian))
				{
				if (!((i - 1 < 1) || (i + 1 > sw.Area - 1)))
					{
					for (j = 0; j <= 2; j++)
						for (k = 0; k < NumSens; k++)
							aSignal[NumSens * (i - 1 + j) + k] = 0;
					}
				else
					{
					if (i - 1 < 1)
						{
						for (j = 0; j <= 1; j++)
							for (k = 0; k < NumSens; k++)
								aSignal[NumSens * (i + j) + k] = 0;
						}
					else
						{
						for (j = 0; j <= 1; j++)
							for (k = 0; k < NumSens; k++)
								aSignal[NumSens * (i - 1 + j) + k] = 0;
						}
					}
				}
			}

		// 4. �������������� �������������� ������. |---| -> |///|
		bSignalLen = sw.Area - sw.PointIndent - 1;

		for (i = 0; i <= sw.SensStep; i++)
			{
			bSignal[i] = 0;
			}

		for (i = 0; i < bSignalLen; i++)
			{
			for (j = 0; j <= sw.SensStep; j++)
				{
				for (k = 0; k < NumSens - j; k++)
					{
					bSignal[j] +=
					  ((aSignal[NumSens * i + k] * aSignal[NumSens * (i +
									sw.PointIndent) + j + k]) / (NumSens - j)) /
					  (sw.SensStep + 1);
					};
				}
			}

		PointShift = 0;
		for (i = 1; i <= sw.SensStep; i++)
			if (bSignal[i] > bSignal[PointShift])
				PointShift = i;

		// ����������� �� ���� ����������� ���
			{
			double k1, k2, alfa;

			k1 = sw.Diam * PI / NumSens * PointShift;
			k2 = sw.PointIndent * sw.OdomStep;

			alfa = atan(k1 / k2) * 180 / PI;

			if (!((sw.AngleMin < alfa) && (alfa < sw.AngleMax)))
				{
				Result.WeldPos1 = -1;
				Result.WeldPos2 = -1;
				break;
				}
			}

		// 5. ������������ �������������� ������. |///| -> |---|
		for (i = 1; i <= (sw.Area - 2); i++)
			{
			PointAngle = (long)(i * PointShift / sw.PointIndent);

			if (PointAngle > 0)
				{
				for (j = 0; j < PointAngle; j++)
					aSignalVec[j] = aSignal[NumSens * i + j];

				for (j = 0; j < (NumSens - PointAngle); j++)
					aSignal[NumSens * i + j] =
					  aSignal[NumSens * i + j + PointAngle];

				for (j = 0; j < PointAngle; j++)
					aSignal[NumSens * i + NumSens - PointAngle + j] =
					  aSignalVec[j];
				}
			}

		// 6. ����������� ������. -->|   |
		for (j = 0; j < NumSens; j++)
			aSignalMean[j] = 0;

		for (j = 0; j < NumSens; j++)
			for (i = 0; i <= (sw.Area - 2); i++)
				aSignalMean[j] += aSignal[NumSens * i + j] / (sw.Area - 1);

		// 7. ������������� ������������ ���������
		k = 0;

		aSignalStd = GetStandardDeviation(aSignalMean, NumSens);
		aSignalMedian = CalculateMean(aSignalMean, NumSens);

		for (i = 0; i < NumSens; i++)
			{
			if (aSignalMean[i] > (aSignalMedian + sw.SKO * aSignalStd))
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
				if ((cSignal[i] - cSignal[i - 1]) > sw.LimPeack)
					{
					dSignal[p] = cSignal[n];

					for (j = n + 1; j < i; j++)
						if (aSignalMean[cSignal[j]] > aSignalMean[dSignal[p]])
							dSignal[p] = cSignal[j];

					n = i;
					p++;
					}
				}

			dSignal[p] = cSignal[k / 2 - 1];

			p++;

			PointPos = dSignal[0];
			}

		if (p == 0)
			isClearPipe = True;
		else
			if (p == 1)
				isSpiralPipe = True;
			else
				if ((p == 2) && (dSignal[0] < sw.LimPeack) && ((NumSens - 1) -
						dSignal[1] < sw.LimPeack))
					{
					if (dSignal[1] > PointPos)
						PointPos = dSignal[1];
					isSpiralPipe = True;
					}

		// 8. ����������� ����� ����������� ����
		if (z == 1)
			{
			if (isSpiralPipe)
				{
				Result.WeldPos1 =
				  (short)(PointPos - (cw.Indent * PointShift / sw.PointIndent));

				if (Result.WeldPos1 < 0)
					Result.WeldPos1 = (short)(Result.WeldPos1 + NumSens);
				}
			else
				{
				if (isClearPipe)
					Result.WeldPos1 = -2;
				}
			}
		else
			{
			if (isSpiralPipe)
				{
				Result.WeldPos2 =
				  (short)(PointPos +
					((cw.Indent + sw.Area) * PointShift / sw.PointIndent));

				if (Result.WeldPos2 > (NumSens - 1))
					Result.WeldPos2 = (short)(Result.WeldPos2 - NumSens);

				if (spin_direct == False)
					{
					Result.WeldPos1 = (short)(NumSens - 1 - Result.WeldPos1);
					Result.WeldPos2 = (short)(NumSens - 1 - Result.WeldPos2);
					}

				}
			else
				{
				if (isClearPipe)
					Result.WeldPos1 = -2;
				}
			}

		}; // for (z = 1; z <= 2; z++)

	// 9. ��������� �����
	Result.PipeType = TUBE_WITHOUT;

	if ((Result.WeldPos1 >= 0) && (Result.WeldPos2 >= 0))
		Result.PipeType = TUBE_SPIRAL;

	// sprintf(tmp_log_str, "9\n");
	// Log_weld(tmp_log_str);

	free(aSignal);
	free(aSignalVec);
	free(aSignalMean);
	free(bSignal);
	free(cSignal);
	free(dSignal);

	return Result;

	}

TWeldPos Weld;

// ������������� ���������
short AnalyseData(const T_TRACE *trc, const VB_TUBE_SCAN_IN *inpData, T_SCAN_2013_OUTPUT *out)
	{
	// ��������� ������ ����������� ���
	TCrossWeld cw;
	TLateralWeld lw;
	TSpiralWeld sw;

	// *************************************************************
	// ������������ � ������� �� ���� ������
	// *************************************************************
	long zones_number;   // ����� ����� ������ ��������
	long inp_x;          // ������ �������� ������ �� X
	long inp_y;          // ������ �������� ������ �� Y

	KRTDATA *inp_dat;    // ��������� �� ����� ������������ ������
	KRTROW *inp_row;     // ��������� �� ����� ����� ������

	long inp_type;       // ��� ��������. SENS_TYPE_* �� krtBase.h
	                     //
                         // SENS_TYPE_RESIDUAL  ���������� ���������������
                         // SENS_TYPE_PROFIL    ���������� �������
                         // SENS_TYPE_TFI       ���������� ��������������� (������)
                         // SENS_TYPE_MFL       ���������� ��������������� (������������)
                         //
                         // ���� �� ��������� �� � ����� �� ��������, �� ��� �������� �� ��������� (������ �������� �� ��������� ��� ���������)

	// ��������� �� ������� ��������    
	short noDRC;         // ���� 1, �� ����� �� ����� ���� �����������
    short noSPR;         // --- �������������
    short noWTO;         // --- ���������	
       
	// ������ ��� ������� ����� � ������� ����� �������� (������ 0)
	short corozZoneIndex = 0;

    zones_number = trc->record.sensGroups;

    inp_y = trc->crz[corozZoneIndex].sNum;
    inp_x = inpData->lenMax / trc->record.stepSize;
    inp_type = trc->crz[corozZoneIndex].sType;

    cw.Width = inpData->Weld1_width; 
    cw.SKO = inpData->Weld1_sens;  
    cw.Lim = inpData->Weld1_bord;  
    cw.Indent = inpData->Weld1_otst;  
    cw.minTubeLen = inpData->lenMin / trc->record.stepSize;

    lw.Width = inpData->Weld2_width; 
    lw.SKO = inpData->Weld2_sens;  
    lw.Lim = inpData->Weld2_bord;  
    lw.Peack = inpData->Weld2_second;
     
	sw.AngleMax = 70;
	sw.AngleMin = 30;
    sw.Area = inpData->Spiral_area; 
	sw.Diam = inpData->maskSize;	
    sw.Lim = inpData->Spiral_bord;
	sw.LimPeack = 10; 
	sw.OdomStep = trc->record.odoStep;
	sw.PointIndent = 5;
	sw.SensStep = inp_y / 10;
    sw.SKO = inpData->Spiral_sens; 
	sw.Width = inpData->Spiral_width;	
	    
    noDRC = inpData->noDRC;  
    noSPR = inpData->noSPR;  
    noWTO = inpData->noWTO;  

	inp_dat = trc->crz[corozZoneIndex].scan.dat;
	inp_row = trc->crz[corozZoneIndex].scan.row;
	// *************************************************************
	// ����� ������������ � ������� �� ���� ������
	// *************************************************************

	out->crzIndex = corozZoneIndex; // ��������, �� ������ ����� ���������� ���������� ���
	out->wldTyp = TUBE_UNKNOWN;
	out->slit1 = -1;
	out->slit2 = -1;

	// sprintf(tmp_log_str, "start\n");
	// Log_weld(tmp_log_str);

	cw.Pos = TUBE_UNKNOWN;

	switch (inp_type)
		{
		case SENS_TYPE_INTROSCOPE:
		case SENS_TYPE_MFL:
			out->wldIndex = cw.Pos = CrossPipeSearchForCor(inp_dat, inp_row, inp_x, inp_y, cw);
			break;
		case SENS_TYPE_PROFIL:
			out->wldIndex = cw.Pos = CrossPipeSearchForPrf(inp_dat, inp_row, inp_x, inp_y, cw);
			break;
		case SENS_TYPE_TFI:
			out->wldIndex = cw.Pos = CrossPipeSearchForStr(inp_dat, inp_row, inp_x, inp_y, cw);
			break;
		default:
			MessageBox(NULL, (LPCWSTR)"����������� ���������� � ���� �������� ��������!\n��� ���������� ���������� ���������� � �������� �.�.",
				(LPCWSTR)"ASIEP.������������� ���������� ����������", MB_OK | MB_ICONERROR);
			return 1;
			break;
		}

	// sprintf(tmp_log_str, "label 1\n");
	// Log_weld(tmp_log_str);

	if (cw.Pos > 0)
		{
		Weld.PipeType = TUBE_WITHOUT;
		Weld.WeldPos1 = -1;
		Weld.WeldPos2 = -1;

		if ((inp_type == SENS_TYPE_TFI) || (inp_type == SENS_TYPE_MFL))
			{
			if (noSPR != 1)
				{
				// sprintf(tmp_log_str, "label 2\n");
				// Log_weld(tmp_log_str);
				Weld = SpiralPipeSearchForCorAndStr(inp_dat, inp_row, inp_x, inp_y, True, cw, sw);
				// sprintf(tmp_log_str, "label 3\n");
				// Log_weld(tmp_log_str);
				if (Weld.PipeType != TUBE_SPIRAL)
					Weld = SpiralPipeSearchForCorAndStr(inp_dat, inp_row, inp_x, inp_y, False, cw, sw);
				}

			if (Weld.PipeType != TUBE_SPIRAL)
				{
				// sprintf(tmp_log_str, "label 4\n");
				// Log_weld(tmp_log_str);
				if (noDRC != 1)
					Weld = LateralPipeSearchForCorAndStr(inp_dat, inp_row, inp_x, inp_y, cw, lw);
				}
			}

		}

	// sprintf(tmp_log_str, "end %d, %d, %d\n", Weld.PipeType, Weld.WeldPos1, Weld.WeldPos2);
	// Log_weld(tmp_log_str);

	out->wldTyp = Weld.PipeType;
	out->slit1 = Weld.WeldPos1;
	out->slit2 = Weld.WeldPos2;

	return 0;
	}
