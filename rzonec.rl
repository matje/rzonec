/*
 * zonec.rl -- zone compiler based on ragel.
 *
 * Copyright (c) 2013, Matthijs Mekking, NLnet Labs. All rights reserved.
 *
 * See LICENSE for the license.
 *
 */

#include "dname.h"
#include "rzonec.h"

#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#define MAX_BUFSIZE 1024
#define DEFAULT_TTL 3600

static zparser_type* parser;


/**
 * State machine.
 *
 */
%%{
    machine zparser;

    include "zparser.rl";
 
    write data;
}%%


/**
 * Process resource record
 *
 */
static int
process_rr(void)
{
    /* all fine */
    return 1;
}


/**
 * Create parser.
 *
 */
static void
zparser_create()
{
    region_type* r = region_create();
    region_type* rrr = region_create();
    if (!r || !rrr) {
        return;
    }
    parser = (zparser_type*) region_alloc(r, sizeof(zparser_type));
    if (!parser) {
        return;
    }
    parser->region = r;
    parser->rr_region = rrr;
    parser->origin = NULL;
    parser->ttl = DEFAULT_TTL;
    parser->line = 0;
    parser->comments = 0;
    parser->numrrs = 0;
    parser->totalerrors = 0;
    parser->number = 0;
    parser->seconds = 0;
    parser->dname = NULL;
    parser->label = NULL;
    parser->dname_size = 0;
    parser->label_head = 0;
    parser->label_count = 0;
    return;
}

/**
 * Cleanup parser.
 *
 */
static void
zparser_cleanup(void)
{
    region_cleanup(parser->rr_region);
    region_cleanup(parser->region);
    parser = NULL;
    return;
}


/**
 * Reads the specified zone into the memory.
 *
 */
static void
rzonec_read_zone(const char* name, const char* file)
{
    char buf[MAX_BUFSIZE];
    ssize_t r;
    int fd = open(file, O_RDONLY);
    if (fd == -1) {
        fprintf(stderr, "rzonec: cannot open file %s: %s\n", file,
            strerror(errno));
        return;
    }
    r = read(fd, buf, MAX_BUFSIZE);
    fprintf(stdout, "rzonec: read %lu bytes.\n", r);
    if (r > 0) {
        int cs = 0;
        int res = 0;
        char* p = &buf[0];
        char* pe = p + r + 1;
        char* eof = NULL;
        %% write init;
        %% write exec;
    }

    close(fd);
    fflush(stdout);
    return;
}


/**
 * Print usage.
 *
 */
static void
usage(void)
{
    fprintf(stderr, "usage: zonec [-h] [-o origin] [-f database] [-z zonefile]\n\n");
    fprintf(stderr, "zone compiler, creates database from zone files.\n");
    fprintf(stderr, "-h\tPrint this help information.\n");
    fprintf(stderr, "-o\tSpecify a zone's origin (only used with -z).\n");
    fprintf(stderr, "-f\tSpecify database file to use.\n");
    fprintf(stderr, "-z\tSpecify a zonefile to read (read from stdin with \'-\').\n");
    return;
}


extern char *optarg;
extern int optind;

int
main(int argc, char **argv)
{
    char* origin = NULL;
    char* dbfile = NULL;
    char* zonefile = NULL;
    int ret = 0;
    int c;
/*
    namedb_type* db = NULL;
*/

    /* Parse the command line... */
    while ((c = getopt(argc, argv, "f:ho:z:")) != -1) {
        switch (c) {
            case 'f':
                dbfile = optarg;
                break;
            case 'o':
                origin = optarg;
                break;
            case 'z':
                zonefile = optarg;
                break;
            case 'h':
                usage();
                exit(0);
            case '?':
            default:
                usage();
                exit(1);
        }
    }
    argc -= optind;
    argv += optind;
    if (argc != 0) {
        usage();
        exit(1);
    }
    if (!zonefile || !dbfile || !origin) {
        fprintf(stderr, "rzonec: missing arguments: %s%s%s\n",
            zonefile?"":"zonefile ", dbfile?"":"dbfile ", origin?"":"origin");
        exit(1);
    }
    /* Create the database */
/*
    if ((db = namedb_create(dbfile)) == NULL) {
        fprintf(stderr, "rzonec: error creating the database (%s)\n", dbfile);
        exit(1);
    }
*/
    /* Create the parser */
    zparser_create();
    if (!parser) {
        fprintf(stderr, "rzonec: error creating the parser\n");
        exit(1);
    }

    /*
     * Read zone file with the specified origin
     */
    fprintf(stdout, "rzonec: reading zone %s file %s db %s.\n", origin,
        zonefile, dbfile);
    parser->line = 1;
    rzonec_read_zone(origin, zonefile);
    ret = parser->totalerrors;

    fprintf(stdout, "rzonec: read %d lines in zone %s.\n",
        parser->line, origin);
    fprintf(stdout, "rzonec: encountered %d comments in zone %s.\n",
        parser->comments, origin);
    fprintf(stdout, "rzonec: processed %d RRs in zone %s.\n",
        parser->numrrs, origin);

    /* Close the database */
/*
    if (namedb_save(db) != 0) {
        fprintf(stderr, "rzonec: error writing the database (%s)\n",
            db->filename);
        namedb_cleanup(db);
        exit(1);
    }
*/
    /* Cleanup the parser */
    zparser_cleanup();

    /* Print the total number of errors */
    if (ret > 0) {
        fprintf(stderr, "rzonec: done with %d errors.\n", ret);
    } else {
        fprintf(stdout, "rzonec: done with no errors.\n");
    }
    return ret;
}
