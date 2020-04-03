#ifndef TERM_H
#define TERM_H

int StartProcess(char *process);
int StartProcessDir(char *process, char *dir);
int ProcessFinished();
int WriteToProcess(char *buf, int len);
int ReadFromProcess(char *buf, int *len, int limit);
int RunProcess(char *cmd, char *buf, int limit, int *len, int *err);
int MySearchPath(char *filename, char* result, int limit);

#endif
