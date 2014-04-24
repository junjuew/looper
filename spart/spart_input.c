#include <stdio.h>
#include <fcntl.h>
 
int main()
{
  int fd;
  char buf[5]="abcd\n";

  fd = open("/dev/ttyS0", O_RDWR);
  write(fd, &buf, 5);
  close(fd);
  perror("perror output:");

  return 0;
}
