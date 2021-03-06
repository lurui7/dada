#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <cstdlib>
#include <unistd.h>
#include <sys/types.h>
#include <semaphore.h>
#include <pthread.h>
#include <iostream>

using namespace std;

#define MAX_RAND 1000

int data = 0;
int read_count = 0;// 记录读者的数量
sem_t writer, mutex;// 临界区对象writer和mutex分别用于阻塞读写操作和改变读者数量

struct command
{
    int pid;// 线程号
    char type;// 线程角色（R：读者；W：写者）
    int startTime;// 操作开始的时间
    int lastTime;// 操作的持续时间
};

// 写操作函数
void write() {
    int rd = rand() % MAX_RAND;
    cout << "Write data " << rd << endl;
    data = rd;
}

// 读操作函数
void read() {
    cout << "Read data " << data << endl;
}

// 写者线程
void *Writer(void *param) {
    struct command* c = (struct command*)param;
    while (true) {
        sleep(c->startTime);
        cout << "Writer(the " << c->pid << " pthread) requests to write." << endl;
        sem_wait(&writer);

        cout << "Writer(the " << c->pid << " pthread) begins to write." << endl;
        write();

        sleep(c->lastTime);
        cout << "Writer(the " << c->pid << " pthread) stops writing." << endl;
        sem_post(&writer);

        pthread_exit(0);
    }
}

// 读者线程
void *reader(void *param) {
    struct command* c = (struct command*)param;
    while (true) {
        sleep(c->startTime);
        cout << "Reader(the " << c->pid << " pthread) requests to read." << endl;
        sem_wait(&mutex);

        read_count++;
        if (read_count == 1) 
            sem_wait(&writer);
        sem_post(&mutex);

        cout << "Reader(the " << c->pid << " pthread) begins to read." << endl;
        read();

        sleep(c->lastTime);
        cout << "Reader(the " << c->pid << " pthread) stops reading." << endl;
        sem_wait(&mutex);

        read_count--;
        if (read_count == 0) 
            sem_post(&writer);
        sem_post(&mutex);

        pthread_exit(0);
    }
}

int main(int argc, char *argv[]) {
    int number_person = atoi(argv[1]);
    sem_init(&writer, 0, 1);
    sem_init(&mutex, 0, 1);
    struct command information[number_person];
    pthread_t pid[number_person];

    for (int i = 0; i < number_person; i++) {
        cin >> information[i].pid >> information[i].type 
            >> information[i].startTime >> information[i].lastTime;
    }

    for (int i = 0; i < number_person; i++) {
        if (information[i].type == 'R') {
            cout << "Create a reader pthread, it's the " << information[i].pid << " pthread." << endl;
            pthread_create(&pid[i], NULL, reader, &information[i]);
        }

        if (information[i].type == 'W') {
            pthread_create(&pid[i], NULL, Writer, &information[i]);
            cout << "Create a writer pthread, it's the " << information[i].pid << " pthread." << endl;
        }
    }

    for (int i = 0; i < number_person; i++) {
         pthread_join(pid[i], NULL);
    }

    //释放信号量
    sem_destroy(&writer);
    sem_destroy(&mutex);
}
