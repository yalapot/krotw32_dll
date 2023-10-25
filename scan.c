/////////////////////////////////////////////////////////////////////////////
//
// ������ ���� �������� ����������� ��� ������� ProccessPage
// 
/////////////////////////////////////////////////////////////////////////////
//
// ��� ������� ����������� �������� ��������� � ����� ����������� ���������� �����, 
// ����������� � ���� ���������. 
//
// ������� ��������� ��� ������� ���������� � ��������� T_SCAN_INPUT (�������� inp), 
//
// ���������� ������� ������������ � ��������� T_SCAN_OUTPUT (�������� out).
// ��� ���� ��������� ���������� � ����� scan.h
// 
// �������� ��������� ���������� ������� ���������� � ���� ��������, ���������� ������
// row � dat ��������� T_SCAN_INPUT. 
// 
// ��� ������� �������� ��������� �������� ������������ ��������� ��� ����� � ��� �� ��������
// ������������. ������ dat �������� ����������� �� ������� row � ��������������� ��� �������� 
// ������������ ������� ������� ��������� ���������.
// 
// ���� row ��������� �� ������ ��������� ���� long, ������� �������� ����� (��������������) 
// ������ ��������.
// ���� dat ��������� �� ������ ��������� ���� unsigned char, ������� �������� ������������ ������,
// ������� ��� ������������ � ���� �������� �����.
// 
// ��� ������� ����� �������������� ����� �� �������� dat � row, ���� ���.
// ��� ������� ����� ���������� ������, ���������� ������ x � y ��������� T_SCAN_INPUT.
// ����� ������� ������� ������ ���������� ���������� ���. 
// 
// ��������� ���� ��������� T_SCAN_INPUT �������� ���������-��������������� � ��������
// ������������� ��� ������ ������� ����������� ����. ��������� ����� ��������� �� ��� 
// ����������� �������� ������� ���� ������������.
// 
// sensitiv - ����-�� ����������������, �������� ���������� "�������" ���� �� ���������. (1-100)
// noDRC    - ���� 1, �� � �������������� ��������� ������ ��� ����������� ����
// noSPR    - �� �� ��� �������������
// noWTO    - �� �� ��� ���������
// 
// ������ ������ ������� ����������� � ���, ����� ����� ��������� (����� ������� �������) 
// �������� ������ ����������� ��� �� ���������� ���������.
// ���� ����� ���� ��������� � ���� wldIndex ��������� T_SCAN_OUTPUT
// 
// ������ ������ ����������� � ������� ������� ����� ����� �������� ������� ������ � ���������
// ���������� ���� � ����������� ���� ����� ����� ����� ����������� �����.
// ��� ����� ����� ��������� �������� ����� �� ���� ��������, ������������ � ����� scan.h :
// TUBE_DIRECT (�����������), TUBE_SPIRAL (�������������), TUBE_WITHOUT (���������)
// ���������� �������� ���� ����� ���� ��������� � ���� wldTyp ��������� T_SCAN_OUTPUT
// 
// ������ ������ ����������� � ������� ������� ����� ����� �������� ������� ������ � ���������
// ���������� ���� � ����������� ��������� ���������� ���� � ������ ����������� ����� ���
// ���� ���������� ����������� ��� � ����������� � ������ ������������� �����.
// 
// ���� ��� ����� ��������� ��� ���������, �� ������ ������ ��������� �� �����.
// 
// ���� ��� ����� ��������� ��� �������������, �� ���� ���������� ����� ���������� ����������� 
// ��� � ����� ������� ������� ��� ����� ������, ��� ������������ ����� ������� � ���������� ��� 
// � ��������� ��������� �������� � ���� slit1 ��������� T_SCAN_OUTPUT
// ����� ���� ���������� ����� ���������� �����������  ��� � ������� ���������� ����������� ���
// ��� ����� ������, ��� ������������ ������� ����������� ��� � ���������� ��� 
// � ��������� ��������� �������� � ���� slit2 ��������� T_SCAN_OUTPUT
// 
// ���� ��� ����� ��������� ��� �����������, �� ���� ���������� ����� ������ �������, ����������
// �������� ������ � ������ ����������� ��� � ��������� ��������� �������� � ���� 
// slit1 ��������� T_SCAN_OUTPUT.
// ���� �������� �������� ������� ������� ����������� ���, �� ����� ������ �������, ������������
// ��� ��������� ���� ��������� � ���� slit2 ��������� T_SCAN_OUTPUT. 
// ���� ������ ���������� ��� �� �������, � ��� ���� ���� �������� �������� -1.
//
// � ������ ��������� ���������� ������� ������� ������ ������� 0. 
// ���� � �������� ������� �������� ������, ������� ������ ������� ��� ������ ������� 0.

//	������� �������� ������ ����:
//  1. �������� ������ ������ �������� �� � ������ size  � �� Y ������ numberdat
//	2. ������������ �������� ���������� ������������ ��� ����������� ������� � ������� �������
//		preobraz, ��� ����� ����������� �� ���������, ������ � ������� � ������� � ������ ������...
//		���������� ���������� ���������� � ������� filtr_mass(� ���������� ������ ��������) � filtr_mass1
//	3. ��������� ������� filtr_mass � filtr_mass1 � ������� ������� PSOBY_X, ������� ��������� ��������
//		������������ ������ � ������� ������� ����.
//	4. �������� ����� �������� ������ ���, ����������� �������� ����� �������� maska(3) �� ���������� ��������
//		���� � ����� ���������� ������� ���������� ��������, ����������� �������� ������� ����������������, ��
//		��� ��������, ��� � ���� ����� ��������� ���. �� �� ��� ��� ������, ��-������, ��� ������ ����� �������
//      ����������� ������ �����, ������� �� ���� ��� ������� ��������� �����, �� ������� ����� �������
//		�������� � ������������ ����������� �������� ����������� �������� ����� ����������������. ��-������,
//		����� ����� ������ �� X �� 3 �� 5 (��� �����), ������� ����� ��� ������ ����� ����� ����� ������������
//		���. 
//	5. ����� ��������� ���������� ����������� ���, ����� ���������� ��� ���� (�����������, �������������).
//		����� ��������� ���� �� �����������, ������ ��� �������� ������ �� ����� ��������� ���� ���������
//		������ ������� (�������������, ����-������� ��������). �������, �������������� ����� ���������� ���� � �����
//		����������� �������� ����� �� Y ������ ����. ����� ��������� ��� ���� (������ ����.�����/����� ���).
//		���� ���������� ��� �� ����������, ���������� ����� ���������� ���� (����� ���� ����� ������ ���� ��������
//		����� �������� 3 �� ���������� ��������). ���� �� ������� �� ����������, �� ���������� ���, �� �����
//		��������� ����������� ��� ���������� ���� (��� ����� ���������).     

#include "scan.h"
#include "filter.h"

#include "debuglog.h"

#define WELD 0				//����� ���������� ����
#define SLIT 1				//����� ���������� ����

typedef struct{
 int x;						//������ ������� �� �    
 int y;						//���������� ��������    
 int msk;					//������ �����           
 double mat;				//�������������� ��������
 int lvl;					//������� ������� 
}T_COMMON;

//��������� ���������� ����
typedef struct{
 double  percent;			//���������������� ������ 
 int min_tube;				//����������� ����� �����
}T_POPER;

//��������� ���������� ����
typedef struct{
 double  percent_spir;		//���������������� ������ 
 int weigth;				//������ ���������� �����
 short spirweld1;			//������ ���������� ���
 short spirweld2;			//������ ���������� ���
 short spir;				//������/�� ������
}T_SPIR;

//��������� ���������� ����
typedef struct{
 double  percent_prod;		//���������������� ������
 int number_prod_weld;		//���������� ���������� ����(1 ��� 2)
 short prodweld1;			//������ ���������� ���
 short prodweld2;			//������ ���������� ���
 short prod;				//������/�� ������
}T_PROD;

int invpreobraz (
KRTDATA* screen,    // ������� ������     
int numberdat,      // ���������� ��������
int between,        // ������ ������� �� X
KRTDATA* screen1    // �������� ������    
) {
        int n=0;
		int j,i;
        for(j=0;j<numberdat;j++) {
           for(i=0;i<numberdat*between;i+=numberdat) {
              screen1[n]=screen[i+j];
              n++;
           }
        }
		return n;
}
void turnArray (
KRTDATA* inp,    // ������� ������     
int y,			 // ���������� ��������
int x,			 // ������ ������� �� X
KRTDATA* out     // �������� ������    
) {
int j,i;
        
for(i=0; i < y; i++)
 for(j=0; j < x; j++)
  out[y*j+i] = inp[i*x+j];
}

//������� ������ ���������� ����
int findweld (
T_COMMON* cmn,           //������� ���������        
KRTDATA *sob_mass,
KRTDATA *sob_mass1,
T_POPER* p,
int type
) {

 int distance=0;		//������� ���������
 int number_shov=0;		//���������� ��������, ����������� �������� �������
 int in_maska=0; 
 int number_shov_maska=0;	//���������� ��������, ����������� �������� ������� ������ �����
 int distance_maska=0;		//��������� ��� � �����
												
 int i=0;
 int j=0;
 int k=0;
 int X=-1;			//��������� ��� ����������� (�� X )
 int number=0;		//���������� ��������, ����������� �������� �������

    //���������� ������ �� ����� ������� ������
    for(i=0;i<cmn->y*(cmn->x-cmn->msk);i+=cmn->y)
    {
		for(j=0;j<cmn->y*cmn->msk;j++)
        {
			//if((sob_mass[i+j]>mat+level)||( (sob_mass1[i+j]>(mat+level))&&(sob_mass[i+j]<(mat+level))))
			if((sob_mass[i+j]>(cmn->mat+cmn->lvl))||( (sob_mass1[i+j]>(cmn->mat+cmn->lvl))&&(sob_mass[i+j]<(cmn->mat+cmn->lvl))))
			  //if(filtr_mass[i+j]>(mat+level))
            {
				number_shov++;//������� ���������� �������� ����������� �������� �������
            }
        }
		//�������� ������� ���������� ���������� �������� ��� �������� ������� ����������������
        if(number_shov>p->percent*cmn->y*cmn->msk)
        {
			in_maska=0;				//����� �������� � �����	
            number_shov_maska=0;	//���������� ��������, ����������� �������� ������� ������ �����
            distance_maska=0;		//��������� ��� � �����
			//����� ����������� ��������� �������� ����. ���. ������� � �����
            for (j=0;j<cmn->y*cmn->msk;j+=cmn->y)
            {
				for(k=0;k<cmn->y;k++)
                {
					if((sob_mass[i+j+k]>cmn->mat+cmn->lvl)||(sob_mass1[i+j+k]>cmn->mat+cmn->lvl))
                    {
						number_shov_maska++;						number_shov_maska++;

                    }
                }
                if(number_shov_maska>in_maska)
                {
					in_maska=number_shov_maska;
                    distance_maska++;
                }
                number_shov_maska=0;
			}
			//����������� ��������� �������� ������ ��� � ������ ����������� ����� �����
			if(number_shov>number&&((distance+distance_maska)>p->min_tube))
			{
				
				if((distance-X)>p->min_tube&&number!=0&&X>p->min_tube&&type==WELD)
				{
					i=cmn->y*cmn->x;
					j=cmn->y*cmn->msk;
				}
				else
				{
					number=number_shov;
					X=distance+distance_maska;
				}
			}
           
		}
        number_shov=0;
        distance++;
	}
	return X;
}

//������� ������ ���������� ����
int findspirweld (
int tube_space,          //������ ������� �� �                
int numberdat,           //���������� ��������                
int maska,               //������ �����                       
double mat,              //�������������� ��������	     
int level,               //������� �������                    
KRTDATA *screen2,        //�������  ������, � ������� ���� ���
T_SPIR* spr
) {
        //����������� ��� � ������ �����
        double num_spir=0;              //����� �������� ����������� ������
        double num_spir_inv=0;		//����� �������� ����������� ������
        int spirtube=0;
        int spirtube1=0;
        short dist_num_spir=0;
	int t,j,z;
        int number_spir=0;
        int number_spir_inv=0;
        int sensor=0;
        int x=0;			//���������� ������
        int x_inv=0;			//�������� ������ ���������� ����� 
	int zap=0;
	int zap_inv=0;
        if (tube_space>numberdat)
        {
                for(t=0;t<numberdat*tube_space;t+=tube_space)
                {
                        number_spir=0;
                        number_spir_inv=0;
                        sensor=0;

                        for (j=t;j<numberdat*tube_space;j+=tube_space)
                        {
                                x=(sensor*spr->weigth)/numberdat;						//���������� ������
                                x_inv=((numberdat-sensor)*spr->weigth)/numberdat;		//�������� ������ ���������� �����
                                for(z=0;z<maska;z++)
                                {
                                        if(screen2[z+j+(x)]>mat+level)
                                        {
                                                number_spir++;
                                        }
                                      /*  if(screen2[z+j+(x_inv)]>mat+level)
                                        {
                                                number_spir_inv++;
                                        }*/
                                }
                                sensor++;
                        }
                        for (j=0;j<t;j+=tube_space)
                        {
                                x=(sensor*spr->weigth)/numberdat;
                                x_inv=((numberdat-sensor)*spr->weigth)/numberdat;		//�������� ������ ���������� �����
                                for(z=0;z<maska;z++)
                                {
                                        if(screen2[z+j+(x)]>mat+level)
                                        {
                                                number_spir++;
                                        }
                                        /*if(screen2[z+j+(x_inv)]>mat+level)
                                        {
                                                number_spir_inv++;
                                        }*/
                                }
                                sensor++;
                        }
                        if(number_spir>((spr->percent_spir)*(numberdat)*maska))
                        {
                                if (num_spir<number_spir)
                                {
                                        num_spir=number_spir;
                                        dist_num_spir=(short)(t/tube_space);
                                        //t=0;
                                        spirtube=1;
                                }
                        }
                        if(number_spir_inv>((spr->percent_spir)*(numberdat)*maska))
                        {
                                if (num_spir_inv<number_spir_inv)
                                {
                                        num_spir_inv=number_spir_inv;
                                        dist_num_spir=(short)(t/tube_space);
                                        //t=0;
                                        spirtube=1;
                                }
                        }
                        number_spir=0;
                        number_spir_inv=0;
                }
                if(spirtube==1)
                {
                        spr->spirweld1=dist_num_spir;
						spr->spir=1;
                }
                num_spir=0;
                num_spir_inv=0;
                //����������� ��� � ����� �����
                for(t=numberdat*tube_space;t>0;t-=tube_space)
                {
                        number_spir=0;
                        number_spir_inv=0;
                        sensor=0;
                        for (j=t;j>0;j-=tube_space)
                        {
                                x=(sensor*spr->weigth)/numberdat;
                                x_inv=((numberdat-sensor)*spr->weigth)/numberdat;
                                for(z=0;z<maska;z++)
                                {
                                        zap=j-z-x;
                                        zap_inv=j-z-x_inv;
                                        if(screen2[abs(zap)]>mat+level)
                                        {
                                                number_spir++;
                                        }
                                       /*f(screen2[abs(zaplatka_inv)]>mat+level)
                                        {
                                                number_spir_inv++;
                                        }*/
                                }
                                sensor++;
                        }
                        for (j=numberdat*tube_space;j>t;j-=tube_space)
                        {
                                x=(sensor*spr->weigth)/numberdat;
                                x_inv=((numberdat-sensor)*spr->weigth)/numberdat;
                                for(z=0;z<maska;z++)
                                {
                                        if(screen2[j-z-(x)]>mat+level)
                                        {
                                                number_spir++;
                                        }
                                        /*(screen2[j-z-(int)(floor(x_inv))]>mat+level)
                                        {
                                                number_spir_inv++;
                                        }*/
                                }
                                sensor++;
                        }
                        if(number_spir>((spr->percent_spir)*(numberdat)*maska))
                        {
                                if (num_spir<number_spir)
                                {
                                        num_spir=number_spir;
                                        dist_num_spir=(short)(t/tube_space);
                                        //t=0;
                                        spirtube1=1;
                                }
                        }
                        if(number_spir_inv>((spr->percent_spir)*(numberdat)*maska))
                        {
                                if (num_spir_inv<number_spir_inv)
                                {
                                        num_spir_inv=number_spir_inv;
                                        dist_num_spir=(short)(t/tube_space);
                                        //t=0;
                                        spirtube1=1;
                                }
                        } 
                        number_spir=0;
                        number_spir_inv=0;
                }
                if(spirtube1==1)
                {
                        spr->spirweld2=dist_num_spir;
						spr->spir=1;
                }
        }

        if (spirtube!=1) {
         return (spirtube1==1) ? 1 : 0;
        }  
        return 1;
}
// ������� ������� ������, ���������� �������
short ProccessPage (
const T_SCAN_INPUT *inp,		// ������� ������
T_SCAN_OUTPUT *out				// ����� ��� ����������� �������
) {

KRTDATA *flt1, *flt2, *tube1, *tube2;
long i,x,arrSize;
double mat=0.0;					// �����������
//��������� ����
T_COMMON cmn;
T_POPER p;
T_SPIR spr;
T_PROD prd;

 //����� ������	
 cmn.x=inp->x;					//������ ������� �� �    
 cmn.y=inp->y;					//���������� ��������    
 cmn.msk=inp->maskSize;			//������ �����           
 cmn.mat=0.0;					//�������������� ��������
 cmn.lvl=inp->signalLevel;		//������� ������� 
 //��������� ���
 p.percent=1.0-inp->weldSensitiv/100.0;		// ���������������� ������ ���������� ����
 p.min_tube=inp->minTubeLen;	// ����������� ����� �����

 //���������� ���
 spr.percent_spir=1.0-inp->spirSensitiv/100.0;	// ���������������� ������ 
 spr.weigth=inp->listSize;		// ������ ���������� �����
 spr.spirweld1=-1;				// ������ ���������� ���
 spr.spirweld2=-1;				// ������ ���������� ���
 spr.spir=-1;
 
 //���������� ���
 prd.percent_prod=1.0-inp->slitSensitiv/100.0;
 prd.number_prod_weld=inp->slitNum;		// ���������� ���������� ����(1 ��� 2)
 prd.prodweld1=-1;						// ������ ���������� ���
 prd.prodweld2=-1;						// ������ ���������� ���
 prd.prod=-1;							// ������/�� ������

 // ������ ����� ������ �� ������������, ������ �� ���� ������ �������� �������
 // ��� ��������� ����
 arrSize = inp->y * inp->x;
 flt1    = (KRTDATA*) inp->row;   //������ ����������� � ����������� ������� ���������
 flt2    = flt1 + arrSize;
 tube1   = flt2 + arrSize;
 tube2   = tube1 + arrSize;
 // ������ �������� ���������� ������������ (������� ��������)
 fltDerivation(inp->dat, inp->x, inp->y, flt1, flt2);
    
 //���������� �������� �������
 fltSobel(flt1,inp->x,inp->y,tube1);
 fltSobel(flt2,inp->x,inp->y,tube2);
 //������� ��������������� �������� ��� �������� ���, ����� �������, �������� ���������������
 for(i=0; i < arrSize; i++) {
	mat+=tube1[i];
 }
 cmn.mat=mat/arrSize;
 //����� ���������� ����
 x = findweld(&cmn, tube1, tube2, &p,WELD);

 //����� ���������� ���� ��������
 if(inp->noSPR!=1||inp->noDRC!=1&&x>0) {
  arrSize = x * inp->y;
	
	//fltSobel(inp->dat,inp->x,inp->y,flt1);
  fltDerivationY(inp->dat,inp->x,inp->y, tube2);
  //�������� �������� ���������� ����
  for (i=0; i < arrSize; i++) {
	  tube1[i] = (KRTDATA) (tube2[i]+ MIDLE_LEVEL);
	 // tube1[i] = (KRTDATA) (tube2[i]);
  }
  //tube1   = flt1 + arrSize;
  //������ ����������� �������
  mat=0.0;
  for(i=0; i < arrSize; i++) {
	mat+=tube1[i];
  }
  mat=mat/arrSize;
  //����� ���������� ����
  if(inp->noSPR!=1) {
   invpreobraz(tube1,inp->y,x, flt1);
   findspirweld(x, inp->y, inp->maskSize, mat, inp->signalLevel, tube1, &spr);
  }
  //����� ���������� ����
  if(inp->noDRC!=1&&spr.spir!=1) {
   //��������� ������� ��� ������ ���������� ����;
   turnArray(tube1,x,inp->y/inp->slitNum, flt1);  
   cmn.x=inp->y/inp->slitNum;					//������ ������� �� �    
   cmn.y=x;										//���������� ��������    
   cmn.msk=inp->maskSize;						//������ �����           
   cmn.mat=mat;									//�������������� �������� 
   cmn.lvl=inp->signalLevel;					//������� �������  
   p.min_tube=0;								//����������� ����� �����
   p.percent=prd.percent_prod;					//���������������� ������ ���������� ����
   prd.prodweld1 = (short)(findweld(&cmn,flt1,flt1, &p,SLIT));
   if(prd.prodweld1>0) {
		prd.prod=1;
   }
   if(inp->slitNum==2) //���������� ��� ���
   {
	for (i=arrSize/2; i < arrSize; i++) {
	  tube1[i-arrSize/2] = (KRTDATA) (tube2[i]+ MIDLE_LEVEL);
	}
	turnArray(tube1,x,inp->y/inp->slitNum, flt1);
	cmn.x=inp->y/inp->slitNum;					//������ ������� �� �    
	cmn.y=x;									//���������� ��������    
    cmn.msk=inp->maskSize;						//������ �����           
    cmn.mat=mat;								//�������������� �������� 
    cmn.lvl=inp->signalLevel;					//������� �������  
    p.min_tube=0;								//����������� ����� �����
    p.percent=prd.percent_prod;					//���������������� ������ ���������� ����
    prd.prodweld2 = (short)(findweld(&cmn,flt1,flt1, &p,SLIT)+inp->y/2);
    if(prd.prodweld1>0) {
		prd.prod=1;
	}
   }
  }

 }
 //��������� ����������� ���
 out->wldIndex = x;

 // ��� ����� - �������������
 if(spr.spir==1) {
  out->wldTyp = TUBE_SPIRAL;
  out->slit1 =spr.spirweld1;
  out->slit2 =spr.spirweld2;

 } else if(prd.prod==1)	{

  out->wldTyp = TUBE_DIRECT;
  if (prd.prodweld1!=-1&&prd.prodweld2!=-1&&abs(prd.prodweld1-prd.prodweld2) < 10) {
   out->slit1 =(short)((prd.prodweld1+prd.prodweld2)/2);
   out->slit2 =-1;		
  } else {
   out->slit1 =prd.prodweld1;
   out->slit2 =prd.prodweld2;
  }

 }

 if(prd.prod!=1&&spr.spir!=1) {
  out->wldTyp = TUBE_DIRECT;
  out->slit1 =-1;
  out->slit2 =-1;
 }

 return 0;
}
