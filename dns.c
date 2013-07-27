/*
 * $Id: dns.c 6501 2012-08-06 10:52:03Z matthijs $
 *
 * Copyright (c) 2013 NLNet Labs. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/**
 * DNS definitions.
 *
 */

#include "dns.h"

static rrstruct_type rrstructs[(DNS_NUMRRTYPES+1)] = {
/* 0 */ { NULL, 0, 1, 1, { DNS_RDATA_BINARY } },
/* 1 */ { "A", DNS_TYPE_A, 1, 1, { DNS_RDATA_IPV4 } },
/* 2 */ { "NS", DNS_TYPE_NS, 1, 1, { DNS_RDATA_COMPRESSED_DNAME } },
/* 3 */ { "MD", DNS_TYPE_MD, 1, 1, { DNS_RDATA_UNCOMPRESSED_DNAME } },
/* 4 */ { "MF", DNS_TYPE_MF, 1, 1, { DNS_RDATA_UNCOMPRESSED_DNAME } },
/* 5 */ { "CNAME", DNS_TYPE_CNAME, 1, 1, { DNS_RDATA_COMPRESSED_DNAME } },
/* 6 */ { "SOA", DNS_TYPE_SOA, 7, 7,
          { DNS_RDATA_COMPRESSED_DNAME, DNS_RDATA_COMPRESSED_DNAME,
            DNS_RDATA_INT32, DNS_RDATA_INT32, DNS_RDATA_INT32,
            DNS_RDATA_INT32, DNS_RDATA_INT32 } },
};

