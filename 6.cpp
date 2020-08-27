#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cstdlib>
#include <pthread.h>
#include <sys/types.h>
#include <semaphore.h>
#include <unistd.h>
#include <iostream>

#define MAX 20
#define BUFFER_SIZE 5
using namespace std;

typedef int buffer_item;

struct Buffer{
    Buffer(){
        count = 0;
        front = 0;
        rear = 0;
        for(int i = 0; i < BUFFER_SIZE; i++){
            items[i] = 0;
        }
    }
    buffer_item items[BUFFER_SIZE];
    int count;
    int front;
    int rear;
};

Buffer *buffer = new Buffer();
int insert_item(buffer_item item){
    if(buffer->count < BUFFER_SIZE){
        buffer->items[buffer->rear] = item;
        cout << "Product: " << buffer->items[buffer->rear] << endl;
        buffer->count++;
        buffer->rear++;
        if(buffer->rear % BUFFER_SIZE == 0) buffer->rear = 0;
        return 0;
    }

    return -1;
}

int remove_item(){
    if(buffer->count > 0){
        cout<< "Consume: " << buffer->items[buffer->front] << endl;
        buffer->items[buffer->front] = 0;
        buffer->count--;
        buffer->front++;
        if(buffer->front % BUFFER_SIZE == 0) buffer->front = 0;
        return 0;
    }

    return -1;
}


typedef struct Data{
    Data(){
        serial_num = 0;
        character = ' ';
        start = 0;
        last = 0;
    }

    int serial_num;
    char character;
    int start;
    int last;
} Instruction;

Instruction *Deal(char file[]){
    Instruction *ins = new Data();
    int i;
    int j = 0;
    string tmp = "";

    int len = strlen(file);
    for(i = 0; i < len; i++){
        if(file[i] != ' ' && file[i] != '\n')
            tmp += file[i];

        else{
            if(tmp != ""){
                switch(j){
                    case 0: ins->serial_num = atoi(tmp.c_str());
                            tmp = "";
                            break;
                    case 1: ins->character = tmp.at(0);
                            tmp = "";
                            break;
                    case 2: ins->start = atoi(tmp.c_str());
                            tmp = "";
                        break;
                    case 3: ins->last = atoi(tmp.c_str());
                            tmp = "";
                        break;
                }
                j++;
            }
        }
    }
    return ins;
}

struct sto{
    sem_t mutex;
    sem_t wrt;
};
struct sto shared;
int readcount;

void *Read(void *arg)
{
    Instruction *ins = (Instruction*)arg;
    sleep(ins->start);//等待一段时间，开始申请资源

    //有读者请求资源，则读者数目加1
    //判断是否有写者在使用共享数据段，有的话，等待
    sem_wait(&shared.mutex);
    readcount++;
    if(readcount == 1) sem_wait(&shared.wrt);
    sem_post(&shared.mutex);

    //开始读取共享数据段
    cout<<"Reader "<<ins->serial_num<<" is reading."<<endl;
    sleep(ins->last);
    cout<<"Reader "<<ins->serial_num<<" end reading."<<endl;

    //读取完毕后,读者数目减去1。
    //只有全部读者读取完毕后，唤醒写者线程
    sem_wait(&shared.mutex);
    readcount--;
    if(readcount == 0) sem_post(&shared.wrt);
    sem_post(&shared.mutex);

    return(NULL);
}

void *Write(void *arg)
{
    Instruction *ins = (Instruction*)arg;
    sleep(ins->start);

    //写者读取共享数据段
    sem_wait(&shared.wrt);
    cout<<"Writer "<<ins->serial_num<<" is writing."<<endl;
    sleep(ins->last);
    cout<<"Writer "<<ins->serial_num<<" end writing."<<endl;
    sem_post(&shared.wrt);

    return(NULL);
}

int main()
{
    FILE *fp;
    char file[MAX];
    int i;

    pthread_t tid_read;
    pthread_t tid_write;
    Instruction *ins = new Data();
    sem_init(&shared.mutex, 0, 1);
    sem_init(&shared.wrt, 0, 1);
    readcount = 0;

    fp = fopen("test.txt", "r");
    while(fgets(file, MAX, fp)){
        ins = Deal(file);
        if(ins->character == 'R'){
            pthread_create(&tid_read, NULL, Read, (void*)ins);
        }
        else{
            pthread_create(&tid_write, NULL, Write, (void*)ins);
        }

    }

    sem_destroy(&shared.mutex);
    sem_destroy(&shared.wrt);

    sleep(50);

    return 0;
}
