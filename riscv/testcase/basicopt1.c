#include "io.h"
//#include<iostream>
//#include<stdio.h>
//using namespace std;
int main()
{
    int a[100][100];
    int i;
	int j;
    int sum = 0;

    for (i = 0;i < 10;i++)
        for (j = 0;j < 10;j++)
            a[i][j] = 0;
    int quotient;
    int remainder;
    for (i = 0;i < 10;i++)
    	if (i > 2 && i < 8) {
        	for (j = 0;j < 10;j++)
            	if (j > 5 || i < 9) {
//                    printf("%d\n", i);
//                    outlln(i);
                    quotient = j * 4 / 10;
                    remainder = j * 4 % 10;
//                    printf("%d\t%d", quotient, remainder);
//                    outlln(quotient);
//                    printf("\n");
                	a[i + quotient][remainder] = j + (100 - 1 + 1 - 1 + 1) / 2;
                }
    	}
    for (i = 0;i < 10;i++)
    for (j = 0;j < 10;j++)
//        printf("%d\n", a[i][j]);
//        outlln(a[i][j]);

    for (i = 0;i < 10;i++)
        for (j = 0;j < 10;j++)
            sum = sum + a[i][j];
//    printf("%d", sum);
    outlln(sum);
}
