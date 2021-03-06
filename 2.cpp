#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/shm.h>
#include <sys/stat.h>

#define MAX_SIZE 20

typedef struct {
	int fib_sequence[MAX_SIZE];
	int sequence_size;
}share_data;

int main(int argc, char const *argv[]) {
	if(argc != 2) {
		printf("Error: the number of arguments is not enough!\n");
		exit(0);
	}
	else if (atoi(argv[1]) <= 0 || atoi(argv[1]) > 20) {
		printf("Error: argument should be between 0 and 20.\n");
		exit(0);
	}

	//共享存储区id
	int segment_id;
	const int size = sizeof(share_data);
	share_data *shared_memory;
	//创建或打开shmget,并连接
	segment_id = shmget(IPC_PRIVATE, size, S_IRUSR | S_IWUSR);
	shared_memory = (share_data *)shmat(segment_id, NULL, 0);
	shared_memory -> sequence_size = atoi(argv[1]);
	int pid;
	pid = fork();
	if(pid < 0) {
		printf("Error: failed to create a child process.\n");
		exit(0);
	}
	//子进程执行中，共享内存
	else if(pid == 0) {
		shared_memory ->fib_sequence[0] = 0;
		shared_memory ->fib_sequence[1] = 1;
		if(atoi(argv[1]) > 2) {
			int i = 2; 
			for( ; i < shared_memory ->sequence_size; i++){
				shared_memory -> fib_sequence[i] = shared_memory ->fib_sequence[i-1] + shared_memory -> fib_sequence[i-2];

			}
		}
	}

	//子进程执行结束，main从共享内存中读取并输出结果
	else {
		wait(0);
		printf("The result is:\n");
		for (int j = 0; j < atoi(argv[1]); j++){
			printf("%d\n", shared_memory -> fib_sequence[j]);
		}
		printf("\n");
	}
	shmdt(shared_memory);
	shmctl(segment_id, IPC_RMID, NULL);
	return 0;
}
