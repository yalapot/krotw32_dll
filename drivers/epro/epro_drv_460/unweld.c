// Быстрое преобразование Фурье
// Входные параметры:
//   N-количество точек, должно быть кратно степени двойки
//   x,y- массивы данных x[0]..x[N-1], x для прямого преобразования, x и y для обратного преобразования фурье
//   I =1-BPF, =-1 -OBPF
// Выходные данные:
//   x-действительная часть сигнала
//   y-мнимая часть сигнала
void BPF(double *x,double *y,int N,int I)
{
        double c,s,t1,t2,t3,t4,u1,u2,u3;
        int i,j,p,l,L,M,M1,K;
        L=N;
        M=N/2;
        M1=N-1;

        while(L>=2)
        {
                l=L/2;
                u1=1.0;
                u2=0.0;
                t1 =   PI / ((double)l) ;
                c=cos(t1);
                s=-I*sin(t1);
                for(j=0;j <l;j++)
                {
                        for(i=j; i<N; i+=L)
                        {
                                p=i+l;
                                t1=*(x+i) + *(x+p);
                                t2=*(y+i) + *(y+p);
                                t3=*(x+i) - *(x+p);
                                t4=*(y+i) - *(y+p);
                                *(x+p)=t3*u1-t4*u2;
                                *(y+p)=t4*u1+t3*u2;
                                *(x+i)=t1;
                                *(y+i)=t2;
                        }
                        u3=u1*c-u2*s;
                        u2=u2*c+u1*s; u1=u3;
                }
                L/=2;
        }
        j=0;
        for(i=0; i < M1; i++)
        {
                if(i > j)
                {
                        t1=*(x+j);
                        t2=*(y+j);
                        *(x+j)=*(x+i);
                        *(y+j)=*(y+i);
                        *(x+i)=t1;
                        *(y+i)=t2;
                }
                K=M;
                while( (j >=K) && (K!=0) )
                {
                        j-=K;
                        K/=2;
                }
                j+=K;
        }
}

// комплексное умножение
void CMpl(double a1,double b1,double a2,double b2,double *a3)
{
        a3[0]=(a2*a1-b2*b1); // действительная часть
        a3[1]=(b1*a2+a1*b2); // мнимая часть
}


byte screen [4096 * 4096];

double Re [4096];  //массив действительной части
double Im [4096];  //массив мнимой части
double Func_Re [4096];
double Func_Im [4096];
double screen1 [4096 * 4096];

double Orig[4096]; 
double Orig_Im[4096];

double Hemming[4096]; 
double Hemming_Im[4096];

double Prois[4096]; 
double screen2 [4096 * 4096];



double s;
double a3[2];

int nm=0;
int i, j, t, r, z;


//Функция фильрации бесшовных труб
DWORD WINAPI unweld(  KRTDATA *src_screen, long sensors, long length)
{

    memset(screen, 0 , 4096 * 4096);
    memcpy(screen, src_screen, sensors * length);

    for(i=0;i<length * length;i+=length)
    {
        //обнуление массивов
        for(t=0;t<length;t++)
        {
            Re[t]=0;
            Im[t]=0;
            Func_Im[t]=0;
            Func_Re[t]=1.0;
            s=0.00000000000000000000000;

            if(t>=0&&t<=14){Func_Re[t]=s;}
            if(t>=54&&t<=82){Func_Re[t]=s;}
            if(t>=114&&t<=148){Func_Re[t]=s;}
            if(t>=166&&t<=190){Func_Re[t]=s;}
            if(t>=240&&t<=272){Func_Re[t]=s;}
            if(t>=302&&t<=326){Func_Re[t]=s;}
            if(t>=364&&t<=400){Func_Re[t]=s;}
            if(t>=498&&t<=510){Func_Re[t]=s;}
            if(t>512){Func_Re[t]=s;}
        }
        for (j=0;j<length;j++)
        {
            Re[j]=(screen[j+i]-99)*exp(-0.5*(5*((1/length)*j)*((1/length)*j))); //окно усеченное Гауссовское
        }

        BPF(Re,Im,length,1);      //прямое быстрое преобразование Фурье

        for(r=0;r<length;r++)
        {
            CMpl(Re[r],Im[r],Func_Re[r],Func_Im[r],a3);
            Re[r]=a3[0];
            Im[r]=a3[1];
        }

        BPF(Re,Im,length,-1);     //обратное быстрое преобразование Фурье

        for(z=0;z<length;z++)
        {
            screen1[nm] = floor(Re[z]/length + 0.49);
            nm++;
        }
    }


    //Фильрация по Y**********************************************************************
    for(i=0;i<length;i++)
    {
	    int k=0;
        //обнуление массивов
        for(t=0;t<length;t++)
        {
            Re[t]=0;
            Im[t]=0;

            Func_Im[t]=0;
            Func_Re[t]=1.1;

            if(t==1){Func_Re[t]=0.0;}
            if(t==2){Func_Re[t]=0.0;}
            if(t==3){Func_Re[t]=0.0;}
            if(t==4){Func_Re[t]=0.5;}
            if(t==5){Func_Re[t]=0.7;}
            if(t==6){Func_Re[t]=0.9;}
            if(t==511){Func_Re[t]=0.0;}
            if(t==510){Func_Re[t]=0.0;}
            if(t==509){Func_Re[t]=0.0;}
            if(t==508){Func_Re[t]=0.5;}
            if(t==507){Func_Re[t]=0.7;}
            if(t==506){Func_Re[t]=0.9;}
        }
        for (j=0;j<length * length;j+=length)
        {
             Re[k]=(screen1[j+i]);           // окно прямоугольное(равномерное)
             k++;
        }
        BPF(Re,Im,length,1);                 // прямое быстрое преобразование Фурье

        //расчет производной от спектра окна Хемминнга после разложения в ряд Фурье
        for(r=0;r<length;r++)
        {
             CMpl(Re[r],Im[r],Func_Re[r],Func_Im[r],a3);
             Re[r]=a3[0];
             Im[r]=a3[1];
        }
        BPF(Re,Im,length,-1);     //обратное быстрое преобразование Фурье

        for (z=0;z<sensors;z++)
        {
             src_screen[z*length + i]= (byte) (floor(Re[z]/length)+99);
        }
    }

    return 0;
}


DWORD WINAPI unweld1(  KRTDATA *src_screen, long sensors, long length)
{
   int nm=0; //номер числа в массиве, который записывается в файл

   memcpy(screen, src_screen, sensors * length);

   for(i=0;i<sensors*length;i+=length)
   {
           int k=0;

           //обнуление массивов
           for(t=0;t<length;t++)
           {
                   Re[t]=0;
                   Im[t]=0;
                   Hemming[t]=0;
                   Hemming_Im[t]=0;

                   Orig[t]=0;
                   Orig_Im[t]=0;

                   Func_Im[t]=0;
                   Func_Re[t]=1.0;

                   s=0.00000000000000000000000;

                   if(t>=0&&t<=14){Func_Re[t]=s;}
                   if(t>=54&&t<=82){Func_Re[t]=s;}
                   if(t>=114&&t<=148){Func_Re[t]=s;}
                   if(t>=166&&t<=190){Func_Re[t]=s;}
                   if(t>=240&&t<=272){Func_Re[t]=s;}
                   if(t>=302&&t<=326){Func_Re[t]=s;}
                   if(t>=364&&t<=400){Func_Re[t]=s;}
                   if(t>=498&&t<=510){Func_Re[t]=s;}
                   if(t>512){Func_Re[t]=s;}
           }

           for (j=0;j<length;j++)
           {
                   //Hemming[k]=(screen[j+i]-99)*(0.54-0.46*cos(((2*3.14)/length)*k)); //окно Хемминга
                   //Re[k]=(screen[j+i]-99)*(1-2*((1/length)*k)); //окно Бартлетта
                   Re[k]=(screen[j+i]-99)*exp(-0.5*(5*((1/length)*k)*((1/length)*k))); //окно усеченное Гауссовское
                   //Re[k]=(screen[j+i]-99);      //окно прямоугольное(равномерное)
                   //Orig[k]=(screen[j+i]-99);      //окно прямоугольное(равномерное)
                   k++;
           }
           BPF(Re,Im,length,1);      //прямое быстрое преобразование Фурье

           for(r=0;r<length;r++)
           {
                   double a3[2];
                   CMpl(Re[r],Im[r],Func_Re[r],Func_Im[r],a3);
                   Re[r]=a3[0];
                   Im[r]=a3[1];
           }

           BPF(Re,Im,length,-1);     //обратное быстрое преобразование Фурье
           BPF(Orig,Orig_Im,length,-1);

           for(z=0;z<length;z++)
           {
                   src_screen[nm]=ceil(Re[z]/length);
//                   screen1[nm]=ceil(Re[z]/length);
                   nm++;
           }
   }

   //Фильрация по Y**********************************************************************
   nm=0;
   for(i=0;i<length;i++)
   {
           int k=0;
           //обнуление массивов
           for(t=0;t<length;t++)
           {
                   Re[t]=0;
                   Im[t]=0;
                   Hemming[t]=0;
                   Hemming_Im[t]=0;

                   Orig[t]=0;
                   Orig_Im[t]=0;

                   Func_Im[t]=0;
                   Func_Re[t]=1.1;

                   if(t==1){Func_Re[t]=0.0;}
                   if(t==2){Func_Re[t]=0.0;}
                   if(t==3){Func_Re[t]=0.0;}
                   if(t==4){Func_Re[t]=0.5;}
                   if(t==5){Func_Re[t]=0.7;}
                   if(t==6){Func_Re[t]=0.9;}
                   if(t==511){Func_Re[t]=0.0;}
                   if(t==510){Func_Re[t]=0.0;}
                   if(t==509){Func_Re[t]=0.0;}
                   if(t==508){Func_Re[t]=0.5;}
                   if(t==507){Func_Re[t]=0.7;}
                   if(t==506){Func_Re[t]=0.9;}

           }
           for (j=0;j<sensors*length;j+=length)
           {
                   Re[k]=(screen1[j+i]);           //окно прямоугольное(равномерное)
                   Orig[k]=(screen1[j+i]);         //окно прямоугольное(равномерное)
                   k++;
           }
           BPF(Re,Im,length,1);                      //прямое быстрое преобразование Фурье
           BPF(Hemming,Hemming_Im,length,1);         //прямое быстрое преобразование Фурье
           BPF(Orig,Orig_Im,length,1);               //прямое быстрое преобразование Фурье
           //расчет производной от спектра окна Хемминнга после разложения в ряд Фурье
           for(r=0;r<length;r++)
           {
                   a3[2];
                   CMpl(Re[r],Im[r],Func_Re[r],Func_Im[r],a3);
                   Re[r]=a3[0];
                   Im[r]=a3[1];
           }
           BPF(Re,Im,length,-1);     //обратное быстрое преобразование Фурье
           BPF(Orig,Orig_Im,length,-1);

           for (z=0;z<sensors;z++)
           {
                src_screen[z*length + i]= (byte) (floor(Re[z]/length)+99);
           }
   }

  return 0;
}













