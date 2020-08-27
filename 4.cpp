#include <stdio.h>
#include <pthread.h>

#define MAX_SEQUENCE 100

//一组数据，用于创建线程时作为参数传入
struct Data{
     int num; //斐波那契数列的项数
     int Fibo[MAX_SEQUENCE];//最大容量，斐波那契数列
};

void *Fibonacci(void *data){//获得斐波那契数列
    struct Data *tmp = (struct Data*)data;//转化为实际类型
    int i;

    tmp->Fibo[0] = 0;
    tmp->Fibo[1] = 1;

    for( i=2; i < tmp->num; i++ ){
        tmp->Fibo[i] = tmp->Fibo[i-1] + tmp->Fibo[i-2]; 
    }
 }

int main(){
    struct Data data;
    pthread_t th;//线程标识符
    int ret; //pthread的返回值 ret = 0,创建线程成功
    int n;
    int i;

    printf("The fibonacci produce programe!\nPlease input an number within 1~200: ");
    scanf("%d", &n);
    if(n < 0 || n > 200){
        printf("Your input is error.");
        return -1;
    }
    data.num = n;//赋值


    //create a thread
    ret = pthread_create(&th, NULL, Fibonacci, (void *)&data);
    if( ret != 0 ){
        printf("Create thread error!\n");
        return -1;
    }

    //阻塞调用线程
    pthread_join( th, NULL);

    //输出斐波那契数列
    if( data.num == 0){
        printf("Nothing output.");
    }
    else{
        printf("The Fibonacci %d items are:\n", data.Fibo[i]);
        }
        printf("\n");
    }
