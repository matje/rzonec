/*
 * zonec.c -- zone compiler functions.
 *
 * Copyright (c) 2013, Matthijs Mekking, NLnet Labs. All rights reserved.
 *
 * See LICENSE for the license.
 *
 */

#include "zonec.h"

#include <arpa/inet.h>
#include <string.h>

static const char* logstr = "zonec";


/**
 * Allocate memory for RDATA element and initialize with data.
 *
 */
static uint16_t*
zonec_rdata_init(region_type *region, const void *data, size_t size)
{
    uint16_t *result = region_alloc(region, sizeof(uint16_t) + size);
    *result = size;
    memcpy(result + 1, data, size);
    return result;
}


/**
 * Convert IPv4 address into RDATA element.
 *
 */
uint16_t*
zonec_rdata_ipv4(region_type* region, const char* buf)
{
    in_addr_t address;
    uint16_t *r = NULL;
    if (inet_pton(AF_INET, buf, &address) != 1) {
        fprintf(stderr, "[%s] invalid IPv4 address '%s'", buf);
    } else {
        r = zonec_rdata_init(region, &address, sizeof(address));
    }
    return r;
}

