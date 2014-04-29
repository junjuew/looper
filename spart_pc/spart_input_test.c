#include <stdio.h>
#include <fcntl.h>
 
int main()
{
  int fd;
  //  char buf[5]="start\n";
  int i=0;
  
  fd = open("/dev/ttyS0", O_RDWR);
  for (i=0;i<50;i++){
    write(fd, &i, sizeof(int));
  }

  close(fd);
  perror("perror output:");

  return 0;
}
