/*
SMS Server Tools 3
Copyright (C) 2006- Keijo Kasvi
http://smstools3.kekekasvi.com/

Based on SMS Server Tools 2 from Stefan Frings
http://www.meinemullemaus.de/
SMS Server Tools version 2 and below are Copyright (C) Stefan Frings.

This program is free software unless you got it under another license directly
from the author. You can redistribute it and/or modify it under the terms of
the GNU General Public License as published by the Free Software Foundation.
Either version 2 of the License, or (at your option) any later version.
*/

#include "locking.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <limits.h>
#include <unistd.h>

int lockfile( char*  filename)
{
  char lockfilename[PATH_MAX +5];
  int lockfile;
  struct stat statbuf;
  char pid[20];

  if (!filename)
    return 0;
  if (strlen(filename) + 5 >= sizeof(lockfilename))
    return 0;

  strcpy(lockfilename,filename);
  strcat(lockfilename,".LOCK");
  if (stat(lockfilename,&statbuf))
  {
    lockfile=open(lockfilename,O_CREAT|O_EXCL|O_WRONLY,0644);
    if (lockfile>=0)
    {
      sprintf(pid,"%i\n",(int)getpid());
      write(lockfile, pid, strlen(pid));
      close(lockfile);
      return 1;
    }
  }
  return 0;
}

int islocked( char*  filename)
{
  char lockfilename[PATH_MAX +5];
  struct stat statbuf;

  if (!filename)
    return 0;
  if (strlen(filename) + 5 >= sizeof(lockfilename))
    return 0;

  strcpy(lockfilename,filename);
  strcat(lockfilename,".LOCK");
  if (stat(lockfilename,&statbuf))
    return 0;
  return 1;
}

int unlockfile( char*  filename)
{
  char lockfilename[PATH_MAX +5];

  if (!filename)
    return 0;
  if (strlen(filename) + 5 >= sizeof(lockfilename))
    return 0;

  strcpy(lockfilename,filename);
  strcat(lockfilename,".LOCK");
  if (unlink(lockfilename))
    return 0;
  return 1;
}
