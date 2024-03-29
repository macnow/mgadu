/* gstdio.h - GFilename wrappers for C library functions
 *
 * Copyright 2004 Tor Lillqvist
 *
 * GLib is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * GLib is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with GLib; see the file COPYING.LIB.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifndef __G_STDIO_H__
#define __G_STDIO_H__

#include <glib/gprintf.h>

#include <sys/stat.h>

/* Wrappers for C library functions that take pathname arguments. On
 * Unix, the pathname is a file name as it literally is in the file
 * system. On well-maintained systems with consistent users who know
 * what they are doing and no exchange of files with others this would
 * be a well-defined encoding, preferrably UTF-8. On Windows, the
 * pathname is always in UTF-8, even if that is not the on-disk
 * encoding, and not the encoding accepted by the C library or Win32
 * API.
 */

int g_open      (const gchar *filename,
                 int          flags,
                 int          mode);

int g_rename    (const gchar *oldfilename,
                 const gchar *newfilename);

int g_mkdir     (const gchar *filename,
                 int          mode);

int g_stat      (const gchar *filename,
                 struct stat *buf);

int g_lstat     (const gchar *filename,
                 struct stat *buf);

int g_unlink    (const gchar *filename);

int g_remove    (const gchar *filename);

int g_rmdir (const gchar *filename);

FILE *g_fopen   (const gchar *filename,
                 const gchar *mode);

FILE *g_freopen (const gchar *filename,
                 const gchar *mode,
                 FILE        *stream);

#endif /* __G_STDIO_H__ */
