#ifndef TERM_H
#define TERM_H

int StartProcessIn(char *process, char *dir);
int ProcessFinished();
int WriteToProcess(char *buf, int len);
int ReadFromProcess(char *buf, int *len, int limit);
int RunProcessIn(char *cmd, char *dir, char *buf, int limit, int *len, int *err);
int MySearchPath(char *filename, char* result, int limit);

#endif
