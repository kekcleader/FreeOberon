/* Copyright 2017 Arthur Yefimov

This file is part of Free Oberon.

Free Oberon is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Free Oberon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <windows.h>
#include <tchar.h>
#include <stdio.h>

#define BUFSIZE 4096

HANDLE g_hChildStd_IN_Rd = NULL;
HANDLE g_hChildStd_IN_Wr = NULL;
HANDLE g_hChildStd_OUT_Rd = NULL;
HANDLE g_hChildStd_OUT_Wr = NULL;

HANDLE g_hInputFile = NULL;

PROCESS_INFORMATION piProcInfo;
DWORD exit_code;

void CreateChildProcess(void);
void WriteToPipe(void);
void ReadFromPipe(void);
void ErrorExit(PTSTR);

OVERLAPPED oOverlap;

ULONG PipeSerialNumber;

BOOL MyCreatePipeEx(
    OUT LPHANDLE lpReadPipe,
    OUT LPHANDLE lpWritePipe,
    IN LPSECURITY_ATTRIBUTES lpPipeAttributes,
    IN DWORD nSize,
    DWORD dwReadMode,
    DWORD dwWriteMode)
{
	HANDLE ReadPipeHandle, WritePipeHandle;
	DWORD dwError;
	UCHAR PipeNameBuffer[ MAX_PATH ];

	//
	// Only one valid OpenMode flag - FILE_FLAG_OVERLAPPED
	//

	if ((dwReadMode | dwWriteMode) & (~FILE_FLAG_OVERLAPPED)) {
		SetLastError(ERROR_INVALID_PARAMETER);
		return FALSE;
	}

	//
	//  Set the default timeout to 120 seconds
	//

	if (nSize == 0) {
		nSize = 4096;
	}

  //PipeSerialNumber++;
  InterlockedIncrement(&PipeSerialNumber);
  
	sprintf( PipeNameBuffer,
					 "\\\\.\\Pipe\\RemoteExeAnon.%08x.%08x",
					 GetCurrentProcessId(),
					 PipeSerialNumber
				 );

	ReadPipeHandle = CreateNamedPipeA(
											 PipeNameBuffer,
											 PIPE_ACCESS_INBOUND | dwReadMode,
											 PIPE_TYPE_BYTE | PIPE_WAIT,
											 1,             // Number of pipes
											 nSize,         // Out buffer size
											 nSize,         // In buffer size
											 120 * 1000,    // Timeout in ms
											 lpPipeAttributes
											 );

	if (! ReadPipeHandle) {
		return FALSE;
	}

	WritePipeHandle = CreateFileA(
											PipeNameBuffer,
											GENERIC_WRITE,
											0,                         // No sharing
											lpPipeAttributes,
											OPEN_EXISTING,
											FILE_ATTRIBUTE_NORMAL | dwWriteMode,
											NULL                       // Template file
										);

	if (INVALID_HANDLE_VALUE == WritePipeHandle) {
		dwError = GetLastError();
		CloseHandle( ReadPipeHandle );
		SetLastError(dwError);
		return FALSE;
	}

	*lpReadPipe = ReadPipeHandle;
	*lpWritePipe = WritePipeHandle;
	return( TRUE );
}

int StartProcess(char *process) {
  SECURITY_ATTRIBUTES saAttr;

// Set the bInheritHandle flag so pipe handles are inherited.

  saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
  saAttr.bInheritHandle = TRUE;
  saAttr.lpSecurityDescriptor = NULL;

// Create a pipe for the child process's STDOUT.

  if ( ! MyCreatePipeEx(&g_hChildStd_OUT_Rd, &g_hChildStd_OUT_Wr, &saAttr, 0, FILE_FLAG_OVERLAPPED, 0) )
   ErrorExit(TEXT("StdoutRd CreatePipe"));
  //if ( ! CreatePipe(&g_hChildStd_OUT_Rd, &g_hChildStd_OUT_Wr, &saAttr, 0) )
  // ErrorExit(TEXT("StdoutRd CreatePipe"));

// Ensure the read handle to the pipe for STDOUT is not inherited.

  if ( ! SetHandleInformation(g_hChildStd_OUT_Rd, HANDLE_FLAG_INHERIT, 0) )
   ErrorExit(TEXT("Stdout SetHandleInformation"));

// Create a pipe for the child process's STDIN.

  if (! MyCreatePipeEx(&g_hChildStd_IN_Rd, &g_hChildStd_IN_Wr, &saAttr, 0, FILE_FLAG_OVERLAPPED, 0))
   ErrorExit(TEXT("Stdin CreatePipe"));

// Ensure the write handle to the pipe for STDIN is not inherited.

  if ( ! SetHandleInformation(g_hChildStd_IN_Wr, HANDLE_FLAG_INHERIT, 0) )
   ErrorExit(TEXT("Stdin SetHandleInformation"));

  ZeroMemory(&oOverlap, sizeof(oOverlap));
 
  // ACTUAL START PROCESS



  //TCHAR szCmdline[]=TEXT(process);
  STARTUPINFO siStartInfo;
  BOOL bSuccess = FALSE;

// Set up members of the PROCESS_INFORMATION structure.

  ZeroMemory( &piProcInfo, sizeof(PROCESS_INFORMATION) );

// Set up members of the STARTUPINFO structure.
// This structure specifies the STDIN and STDOUT handles for redirection.

  ZeroMemory( &siStartInfo, sizeof(STARTUPINFO) );
  siStartInfo.cb = sizeof(STARTUPINFO);
  siStartInfo.hStdError = g_hChildStd_OUT_Wr;
  siStartInfo.hStdOutput = g_hChildStd_OUT_Wr;
  siStartInfo.hStdInput = g_hChildStd_IN_Rd;
  siStartInfo.dwFlags |= STARTF_USESTDHANDLES;
  siStartInfo.wShowWindow = SW_HIDE;

// Create the child process.
  
  bSuccess = CreateProcess(NULL,
   process, //szCmdline,    // command line
   NULL,      // process security attributes
   NULL,      // primary thread security attributes
   TRUE,      // handles are inherited
   CREATE_NO_WINDOW,      // creation flags
   NULL,      // use parent's environment
   NULL,      // use parent's current directory
   &siStartInfo,  // STARTUPINFO pointer
   &piProcInfo);  // receives PROCESS_INFORMATION
  
  // If an error occurs, exit the application.
  if ( ! bSuccess )
   ErrorExit(TEXT("CreateProcess"));
  else
  {
   // Close handles to the child process and its primary thread.
   // Some applications might keep these handles to monitor the status
   // of the child process, for example.

   //CloseHandle(piProcInfo.hProcess);
   //CloseHandle(piProcInfo.hThread);
  }
  return bSuccess ? 1 : 0;
}

int ProcessFinished(int *err) {
  GetExitCodeProcess(piProcInfo.hProcess, &exit_code);
  int result = exit_code != STILL_ACTIVE;
  if (result) {
    CloseHandle(piProcInfo.hProcess);
    *err = exit_code;
    DWORD dwAvail = 0;
    if (PeekNamedPipe(g_hChildStd_OUT_Rd, NULL, 0, NULL, &dwAvail, NULL)) {
      result = (dwAvail == 0);
    }
  } else {
    *err = 0;
  }
  return result;
}

void WriteToProcess(char *buf, int len) {
  DWORD dwWritten;
//  CHAR chBuf[BUFSIZE];
//  BOOL bSuccess = FALSE;

 //bSuccess = ReadFile(hParentStdIn, chBuf, BUFSIZE, &dwRead, NULL);
 //if ( ! bSuccess || dwRead == 0 ) break;
  WriteFile(g_hChildStd_IN_Wr, buf, len, &dwWritten, NULL);

// Close the pipe handle so the child process stops reading.

  //if ( ! CloseHandle(g_hChildStd_IN_Wr) )
    //ErrorExit(TEXT("StdInWr CloseHandle"));
}

void ReadFromProcess(char *buf, int *len, int limit) {
  static int last_read_finished = 1;
  //HANDLE hParentStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
  DWORD len2, dwError;
  BOOL result;
  if (last_read_finished) {
    oOverlap.hEvent = NULL;
    ZeroMemory(&oOverlap, sizeof(oOverlap));
    result = ReadFile(g_hChildStd_OUT_Rd, buf, limit, &len2, &oOverlap);
    //printf("ReadFile returned %c\n", result ?'Y':'N');
  } else {
    result = 0;
  }
  if (result) {if (len2) *len = len2;} else *len = 0;
  if (!result) {
    if (last_read_finished) {
      dwError = GetLastError();
      //printf("dwError=%d\n", dwError);
    } else {
      dwError = ERROR_IO_PENDING;
      //printf("dwError set to %d\n", dwError);
    }
    if (dwError == ERROR_NO_DATA) {
      *len = 0;
    } else if (dwError == ERROR_IO_PENDING) {
      len2 = 0;
      BOOL rr;
      rr = GetOverlappedResult(g_hChildStd_OUT_Rd, &oOverlap, &len2, FALSE);
      //printf("GetOverlappedResult returned %c\n", rr ? 'Y' : 'N');
      last_read_finished = rr ? 1 : 0;
      *len = len2;
    } else {
      *len = 0;
    }
  }
  //printf("len = %u\n===============\n", *len);
}

/*
int _tmain(int argc, TCHAR *argv[])
{
  SECURITY_ATTRIBUTES saAttr;

  printf("\n->Start of parent execution.\n");

// Set the bInheritHandle flag so pipe handles are inherited.

  saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
  saAttr.bInheritHandle = TRUE;
  saAttr.lpSecurityDescriptor = NULL;

// Create a pipe for the child process's STDOUT.

  if ( ! CreatePipe(&g_hChildStd_OUT_Rd, &g_hChildStd_OUT_Wr, &saAttr, 0) )
   ErrorExit(TEXT("StdoutRd CreatePipe"));

// Ensure the read handle to the pipe for STDOUT is not inherited.

  if ( ! SetHandleInformation(g_hChildStd_OUT_Rd, HANDLE_FLAG_INHERIT, 0) )
   ErrorExit(TEXT("Stdout SetHandleInformation"));

// Create a pipe for the child process's STDIN.

  if (! CreatePipe(&g_hChildStd_IN_Rd, &g_hChildStd_IN_Wr, &saAttr, 0))
   ErrorExit(TEXT("Stdin CreatePipe"));

// Ensure the write handle to the pipe for STDIN is not inherited.

  if ( ! SetHandleInformation(g_hChildStd_IN_Wr, HANDLE_FLAG_INHERIT, 0) )
   ErrorExit(TEXT("Stdin SetHandleInformation"));

// Create the child process.
  
  CreateChildProcess();

  WriteToPipe();
  printf( "\n->Contents of %s written to child STDIN pipe.\n", argv[1]);

// Read from pipe that is the standard output for child process.

  printf( "\n->Contents of child process STDOUT:\n\n", argv[1]);
  ReadFromPipe();

  printf("\n->End of parent execution.\n");

// The remaining open handles are cleaned up when this process terminates.
// To avoid resource leaks in a larger application, close handles explicitly.

  return 0;
}
*/

void CreateChildProcess()
// Create a child process that uses the previously created pipes for STDIN and STDOUT.
{
  TCHAR szCmdline[]=TEXT("prog.exe");
  PROCESS_INFORMATION piProcInfo;
  STARTUPINFO siStartInfo;
  BOOL bSuccess = FALSE;

// Set up members of the PROCESS_INFORMATION structure.

  ZeroMemory( &piProcInfo, sizeof(PROCESS_INFORMATION) );

// Set up members of the STARTUPINFO structure.
// This structure specifies the STDIN and STDOUT handles for redirection.

  ZeroMemory( &siStartInfo, sizeof(STARTUPINFO) );
  siStartInfo.cb = sizeof(STARTUPINFO);
  siStartInfo.hStdError = g_hChildStd_OUT_Wr;
  siStartInfo.hStdOutput = g_hChildStd_OUT_Wr;
  siStartInfo.hStdInput = g_hChildStd_IN_Rd;
  siStartInfo.dwFlags |= STARTF_USESTDHANDLES;

// Create the child process.
  
  bSuccess = CreateProcess(NULL,
   szCmdline,    // command line
   NULL,      // process security attributes
   NULL,      // primary thread security attributes
   TRUE,      // handles are inherited
   0,      // creation flags
   NULL,      // use parent's environment
   NULL,      // use parent's current directory
   &siStartInfo,  // STARTUPINFO pointer
   &piProcInfo);  // receives PROCESS_INFORMATION
  
  // If an error occurs, exit the application.
  if ( ! bSuccess )
   ErrorExit(TEXT("CreateProcess"));
  else
  {
   // Close handles to the child process and its primary thread.
   // Some applications might keep these handles to monitor the status
   // of the child process, for example.

   CloseHandle(piProcInfo.hProcess);
   CloseHandle(piProcInfo.hThread);
  }
}

void WriteToPipe(void)

// Read from a file and write its contents to the pipe for the child's STDIN.
// Stop when there is no more data.
{
  DWORD dwRead, dwWritten;
  CHAR chBuf[BUFSIZE];
  BOOL bSuccess = FALSE;

   //bSuccess = ReadFile(hParentStdIn, chBuf, BUFSIZE, &dwRead, NULL);
   //if ( ! bSuccess || dwRead == 0 ) break;
	  chBuf[0] = '3';
	  chBuf[1] = '5';
	  chBuf[2] = 13;
	  chBuf[3] = 10;
   dwRead = 4;
   bSuccess = WriteFile(g_hChildStd_IN_Wr, chBuf, dwRead, &dwWritten, NULL);

// Close the pipe handle so the child process stops reading.

  if ( ! CloseHandle(g_hChildStd_IN_Wr) )
   ErrorExit(TEXT("StdInWr CloseHandle"));
}

void ReadFromPipe(void)

// Read output from the child process's pipe for STDOUT
// and write to the parent process's pipe for STDOUT.
// Stop when there is no more data.
{
  DWORD dwRead, dwWritten;
  CHAR chBuf[BUFSIZE];
  BOOL bSuccess = FALSE;
  HANDLE hParentStdOut = GetStdHandle(STD_OUTPUT_HANDLE);

  for (;;)
  {
   bSuccess = ReadFile( g_hChildStd_OUT_Rd, chBuf, BUFSIZE, &dwRead, NULL);
   if( ! bSuccess || dwRead == 0 ) break;

   bSuccess = WriteFile(hParentStdOut, chBuf,
             dwRead, &dwWritten, NULL);
   if (! bSuccess ) break;
  }
}

void ErrorExit(PTSTR lpszFunction)

// Format a readable error message, display a message box,
// and exit from the application.
{
   LPVOID lpMsgBuf;
   LPVOID lpDisplayBuf;
   DWORD dw = GetLastError();

   FormatMessage(
    FORMAT_MESSAGE_ALLOCATE_BUFFER |
    FORMAT_MESSAGE_FROM_SYSTEM |
    FORMAT_MESSAGE_IGNORE_INSERTS,
    NULL,
    dw,
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
    (LPTSTR) &lpMsgBuf,
    0, NULL );

   lpDisplayBuf = (LPVOID)LocalAlloc(LMEM_ZEROINIT,
    (lstrlen((LPCTSTR)lpMsgBuf)+lstrlen((LPCTSTR)lpszFunction)+40)*sizeof(TCHAR));

   snprintf((LPTSTR)lpDisplayBuf,
    LocalSize(lpDisplayBuf) / sizeof(TCHAR),
    TEXT("%s failed with error %d: %s"),
    lpszFunction, dw, lpMsgBuf);

   MessageBox(NULL, (LPCTSTR)lpDisplayBuf, TEXT("Error"), MB_OK);

   LocalFree(lpMsgBuf);
   LocalFree(lpDisplayBuf);
   ExitProcess(1);
}

int RunProcess(char *cmd, char *buf, int limit, int *len, int *err) {
  int success = 0;
  if (StartProcess(cmd)) {
    int n, i = 0;
    do {
      ReadFromProcess(&buf[i], &n, limit - i); //!FIXME add inner loop
      if (n > 0) i += n;
      Sleep(10);
    } while (!ProcessFinished(err) && (i < limit));
    *len = i;
    success = 1;
  }
  return success;
}

int MySearchPath(char *filename, char* result, int limit) {
  int success = 0;
  if (limit > 0) {
    result[0] = '\0';
    int n = SearchPath(
      NULL, // Path to search in
      filename,
      NULL, // File name extension
      limit, // Result buffer length
      result, // Pointer to result buffer
      NULL
    );
    if ((n > 0) && (n <= limit)) success = 1;
  }
  return success;
}
