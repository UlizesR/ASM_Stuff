#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAGIC_NUMBER 0x2000000

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <syscall number>\n", argv[0]);
        return 1;
    }

    // take a positive integer representing the Unix syscall number
    int syscall_number = atoi(argv[1]);
    // check if the syscall number is valid
    if (syscall_number < 0) {
        printf("Invalid syscall number\n");
        return 1;
    }

    // Add the magic number to the syscall number
    int magic_syscall_number = syscall_number + MAGIC_NUMBER;

    // convert magic_syscall_number to a hex string
    char hex_string[20];
    sprintf(hex_string, "0x%x", magic_syscall_number);

    // print the magic syscall number
    printf("MacOS syscall number: %s\n", hex_string);


    return 0;
}