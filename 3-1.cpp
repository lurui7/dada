#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include <sys/wait.h>
#include <sys/shm.h>

#define MAX_LINE 80
#define HISTORYNUM 10

struct Queue{
    char history[HISTORYNUM][MAX_LINE];
    int front;
    int rear;

}queue;

int getNum(){
    return (queue.rear + HISTORYNUM - queue.front + 1) % HISTORYNUM;
}

void add( char *str){
    if( queue.front == -1)//history是否为空 
    {
        strcpy(queue.history[queue.rear], str);
        queue.front = queue.rear;
        return;
    }

    queue.rear = (queue.rear + 1) % HISTORYNUM;
    strcpy(queue.history[queue.rear], str);
    if(queue.front == queue.rear) queue.front++;
}

char *gethistory(int index){
    if(index > getNum() || index <= 0)
        return NULL;

    int count = 1;
    int temp = queue.front;
    while(count < index){
        count++;
        temp = (temp + 1) % HISTORYNUM;
    }
    return queue.history[temp];
}


void setup(char *inputBuffer, char *args[], int *background){
    int length;//命令的字符数目
    int i;//循环变量
    int start;//命令的第一个字符位置
    int ct;//下一个参数存入args[]的位置

    ct = 0;

    /**
    *读入命令行字符，存入inputBuffer
    */
    length = read(STDIN_FILENO, inputBuffer, MAX_LINE);
    start = -1;
    if(length == 0) exit(0);
    if(length < 0){//ctrl+c will read error, and return null
        args[0] = NULL;
        //perror("error reading the command.");
        return;//输入ctrl+c时，会进入错误读取。从而退出setup函数，避免异常
    }
    //int len = strlen(inputBuffer);
    /*
    for(int i = 0; i < len; i++){
        printf("%c\n",inputBuffer[i]);
    }
    */
    //printf("%d\n", len);
    if(inputBuffer[0] == 'r' && isdigit(inputBuffer[1]) && (inputBuffer[2] == '\n' || inputBuffer[2] == '\t')){
    //按下rx，重载第x条命令
        char *str;
        if((str = gethistory(inputBuffer[1] - '0')) == NULL){
            perror("error input command!");//x 大于现有历史记录条数
            return;
        }
        else
            strcpy(inputBuffer, str);

        //printf("%s\n", str);

        inputBuffer[strlen(str)] = '\n';//便于下面代码统一读取inputBuffer
        inputBuffer[strlen(str)+1] = '\0';//添加结束符
        length = strlen(str)+1;
    }

    //检查inputBuffer中每一个char
    for(int i = 0; i<length; i++ ){
        switch(inputBuffer[i]){
            case ' ':
            case '\t'://字符为参数的空格或者Tab
                if(start != -1){
                    args[ct] = &inputBuffer[start];
                    ct++;
                }
                inputBuffer[i] = '\0'; //设置c string 的结束符
                start= -1;
                break;

            case '\n': //命令行结束符
                if(start != -1){
                    args[ct] = &inputBuffer[start];
                    ct++;
                }
                inputBuffer[i] = '\0';
                args[ct] = NULL;
                break;

            default: //其他字符
               if(start == -1)  start = i;
               if(inputBuffer[i] == '&'){
                   *background = 1;
                   inputBuffer[i] = '\0';
               }
        }
    }
    add(inputBuffer);//添加历史记录
    args[ct] = NULL;//命令字符数 > 80
}


void print(){
    if(queue.front == -1){
        printf("No comand!");
        return;
    }
    int index = queue.front;
    printf("\n");
    fflush(stdout);
    while((index % HISTORYNUM) != (queue.rear + 1)){
        printf("%s\n", queue.history[index]);
        fflush(stdout);
        index++;
    }
}


void handle_SIGINT(){
    print();
    signal(SIGINT, SIG_IGN);
    //exit(0);
}

int main(void){
    char inputBuffer[MAX_LINE];//这个缓存用来存放输入的命令
    int background;// == 1时，表示在后台运行命令，即在命令后加上“*”
    char *args[MAX_LINE/2+1];//命令最多40个参数
    pid_t pid;
    struct sigaction hander;

    queue.front = -1;
    queue.rear = 0;

    while(1){//程序在setup中正常结束
        background = 0;
        printf("COMMAND->");

        fflush(stdout);//输出
        setup(inputBuffer, args, &background);

        //这一步要做
        if((pid = fork()) == -1) { printf("Fork Error.\n"); }
        if(pid == 0) { execvp(args[0], args); exit(0); }
        if(background == 0) { wait(0); }

        /**
        *生成输出消息
        */
        //strcpy(buffer, "Caught Control C\n");

        /**
        *创建信号处理器
        */
        hander.sa_handler = (void (*)(int))handle_SIGINT;
        sigaction(SIGINT, &hander, NULL);

        /**
        *循环运行，直到收到ctrl+c
        */
        //while(1);
    }
    return 0;
}

