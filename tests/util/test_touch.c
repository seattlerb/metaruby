/*************************************************************************
 *   test_touch.c		* simple 'touch' program
 *************************************************************************
 *
 * Because the interface to touch is not standard across Unix platforms,
 * we've written our own.
 *
 *   test_touch -a|-m [-t] mmddhhmmyyyy file
 *
 *
 *************************************************************************
 * Copyright (c) 2000 The Pragmatic Programmers, LLC
 *************************************************************************/

#include <sys/stat.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#ifndef _WIN32
#  include <unistd.h>
#  include <utime.h>
#else
#  include <sys/utime.h>
#endif


#define NOTIME  0

#define MTIME   1
#define ATIME   2

static void usage(const char *msg)
{
  fprintf(stderr, "usage: test_touch -a|-m [-t] mmddhhmmyyyy file\n\n%s\n\n", msg);
  exit(1);
}

static time_t parsetime(const char *str)
{
  struct tm tm;
  time_t time;
  
  memset(&tm, 0, sizeof(tm));
  
  if (sscanf(str, "%2d%2d%2d%2d%4d",
             &tm.tm_mon, &tm.tm_mday, &tm.tm_hour, &tm.tm_min, &tm.tm_year) != 5)
    usage("Invalid time format");

  tm.tm_year -= 1900;
  tm.tm_mon--;
  tm.tm_isdst = -1;
  /*  printf("%d %d %d %d %d\n",
	 tm.tm_year, tm.tm_mon, tm.tm_mday, tm.tm_hour, tm.tm_min);
  */
  time = mktime(&tm);

  if (time == (time_t)-1)
    usage("Can't convert time");

  /*printf("%ld\n", time);*/
  return time;
}

int main(int argc, char **argv)
{
  int which = NOTIME;
  char *file    = 0;
  time_t time;
  struct stat sb;
  struct utimbuf times;
  
  argc--;
  argv++;
  while (argc && (*argv[0] == '-')) {
    if (strcmp("-a", *argv) == 0)
      which = ATIME;
    else if (strcmp("-m", *argv) == 0)
      which = MTIME;
    else if (strcmp("-t", *argv) != 0)
      usage("Illegal parameter");
    argv++;
    argc--;
  }

  if (which == NOTIME)
    usage("Missing -a or -m argument");
  
  if (argc != 2)
    usage("Missing time or file name");

  time = parsetime(*argv++);

  file = *argv;
  
  if (stat(file, &sb) == -1) {
    if (creat(file, 0644) == -1) {
      perror(file);
      exit(2);
    }
    if (stat(file, &sb) == -1) {
      perror(file);
      exit(3);
    }
  }      

  if (which == MTIME) {
    times.actime = sb.st_atime;
    times.modtime = time;
  }
  else {
    times.actime = time;
    times.modtime = sb.st_mtime;
  }

  if (utime(file, &times) == -1) {
    perror(file);
    exit(4);
  }

  exit(0);
}

