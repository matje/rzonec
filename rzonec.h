/*
 * rzonec.h -- zone compiler based on ragel.
 *
 * Copyright (c) 2013, Matthijs Mekking, NLnet Labs. All rights reserved.
 *
 * See LICENSE for the license.
 *
 */

#ifndef RZONEC_H
#define RZONEC_H

#include <stdint.h>

#include "dname.h"
#include "region.h"



/**
 * Zone parser structure.
 *
 */
typedef struct zparser zparser_type;
struct zparser {
    region_type* region;
    dname_type* origin;
    uint64_t ttl;

    unsigned int line;        /* number of lines */
    unsigned int comments;    /* number of comments */
    unsigned int numrrs;      /* number of rrs */
    unsigned int totalerrors; /* number of errors */

    /* Temporary storage: numbers */
    uint64_t number;
    uint64_t seconds;

    /* Temporary storage: domain names */
    dname_type* dname;
    const uint8_t* label;
    size_t dname_size;
    size_t label_head;
    uint8_t dname_wire[DNAME_MAXLEN];
    uint8_t label_offsets[DNAME_MAXLEN];
    uint8_t label_count;
};

#endif /* RZONEC_H */

