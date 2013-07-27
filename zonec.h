/*
 * zonec.h -- zone compiler functions.
 *
 * Copyright (c) 2013, Matthijs Mekking, NLnet Labs. All rights reserved.
 *
 * See LICENSE for the license.
 *
 */

#ifndef _NLNETLABS_UTIL_ZONEC_H_
#define _NLNETLABS_UTIL_ZONEC_H_

#include "region.h"

#include <stdint.h>

/**
 * Convert IPv4 address into RDATA element.
 * @param region: memory region.
 * @param buf:    buffer containing human-readable IPv4 address.
 * @return:       (uint16_t*) RDATA element.
 *
 */
uint16_t* zonec_rdata_ipv4(region_type* region, const char* buf);

#endif /* _NLNETLABS_UTIL_ZONEC_H_ */

