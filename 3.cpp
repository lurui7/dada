#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

#define MAX_LINE 80
#define BUFFER_SIZE 50
char buffer[BUFFER_SIZE];
char *history[10][10];
int pos = 0;//下一条指令的位置
int com_1[11] = {0};

void setup(char inputBuffer[], char *args[], int *background) {
    /*
    * length:命令的字符数量
    * i:循环变量
    * start:命令的第一个字符的位置
    * ct:下一个参数存入args[]的位置
    */
    int length, i, start, ct;
    ct = 0;
    //读入命令行字符，存入inputBuffer
    length = read(STDIN_FILENO, inputBuffer, MAX_LINE);
    start = -1;
    //输入ctrl+d,结束shell程序
    if(length == 0)
        exit(0);
    //出错时用错误码-1结束shell程序
    if(length < 0){
        printf("Error in reading command.\n");
        exit(-1);
    }
    //检查inputBuffer中的每一个字符
    for(i == 0; i < length; i++) {
        switch(inputBuffer[i]) {
            case ' ':
            case '\t':
                if(start != -1) {
                    args[ct] = &inputBuffer[start];
                    ct++;
                }
                inputBuffer[i] = '\0'; //设置C string的结束符
                start = -1;
                break;
            //命令行结束
            case '\n':
                if (start != -1) {
                    args[ct] = &inputBuffer[start];
                    ct++;
                }
                inputBuffer[i] = '\0';
                args[ct] = NULL;//命令及参数结束
                break;
            //命令在后台运行
            case '&':
                *background = 1;
                inputBuffer[i] = '\0';
                break;
            //其他
            default:
                if(start == -1)
                    start = i;
        }
    }
    if(ct != 0)
        args[ct] = NULL;
}

//命令在histroy中的历史记录
void handle_SIGINT(int signum) {
	write(STDOUT_FILENO, buffer, strlen(buffer));
	printf("The command history is:\n");
	int i = pos;
	for(int count = 10; count > 0; count--) {
		for(int j = 0;j < com_1[i]; j++) {
			printf("%s ", history[i][j]);
		}
		printf("\n");
		i = (i + 1) % 10;
	}
	printf("\nCOMMAND->");
	fflush(stdout);
	return;
}

int main() {
    char inputBuffer[MAX_LINE];
    int background;
    char *args[MAX_LINE / 2 + 1];
    int i, j;
    for(i = 0; i < 10; i++) {
        for(j = 0; j < 10; j++){
            history[i][j] = (char*)malloc(80 * sizeof(char));
        }
    }
    strcpy(buffer, "\nCaught Control C\n");
    signal(SIGINT, handle_SIGINT);


    while(1) {
        background = 0;
        printf("COMMAND->");
        fflush(stdout);//输出缓存内容
        setup(inputBuffer, args, &background);

        //如果不是r型指令
        if((args[0] != NULL) && (strcmp(args[0], "r") != 0)) {
            if(args[0] != "\n") {
                for(i = 0; args[i] != NULL; i++) {
                    strcpy(history[pos][i], args[i]);
                }
                com_1[pos] = i;
                pos = (pos + 1) % 10;
            }
        }
        //如果是r型指令
        if((args[0] != NULL) && (strcmp(args[0], "r") == 0)) {
            /*只是r型指令，存入二维数组history中*/
            if(args[1] == NULL) {
                i = (pos + 9) % 10;
                for(j = 0; j < com_1[i]; j++) {
                    strcpy(history[pos][j], history[i][j]);
                }
                com_1[pos] = j;
                pos = (pos + 1) % 10;
            }
            //是 r x指令
            else {
                i = pos;
                for(int count = 10; count > 0; count--) {
                    i = (i + 9) % 10;
                    if(strncmp(args[1], history[i][0], 1) == 0) {
                        for(j = 0;j < com_1[i]; j++) {
                            strcpy(history[pos][j], history[i][j]);
                        }
                        com_1[pos] = j;
                        pos = (pos + 1) % 10;
                    }
                }
            }
        }

        //用fork()创建子进程
        pid_t pid = fork();
        if(pid < 0) {//创建失败
            printf("failed to fork.\n");
        }
        //子进程调用execvp()执行命令
        else if(pid == 0) {
            if(strcmp(args[0], "r") != 0) {
                execvp(args[0],args);
                pos = (pos - 1) % 10;
            }
            else {
                char *newargs[MAX_LINE / 2 + 1];
                for (i = 0; i < MAX_LINE /2 + 1; i++) {
                    newargs[i] = (char*)malloc((MAX_LINE / 2 + 1) * sizeof(char));
                }
                pos = (pos + 9) % 10;
                history[pos][0] = '\0';
                if(args[1] == NULL) {
                    i = (pos + 9) % 10;
                    for(j =0 ;j < com_1[i]; j++) {
                        strcpy(newargs[j], history[i][j]);
                    }
                    newargs[j] = NULL;
                    execvp(newargs[0],newargs);
                    exit(0);
                }
                else {
                    i = pos;
                    for(int count1 = 10; count1 > 0; count1--) {
                        i = (i + 9) % 10;
                        if(strncmp(args[1], history[i][0], 1) == 0) {
                            for(j = 0;j < com_1[i]; j++) {
                                strcpy(newargs[j],history[i][j]);
                            }
                            newargs[j] = NULL;
                            execvp(newargs[0], newargs);
                        }
                    }
                }
                exit(0);
            }
            exit(0);
        }
        else {
            /*如果background == 0，父进程将等待子进程结束
            *否则将回到函数setup()中等待新的命令输入
            */
           if(background == 0) {
               wait(NULL);
           }
           else {
               setup(inputBuffer, args, &background);
           }
        }

    }

}
