/*
 * $Id: dns.h 6501 2012-08-06 10:52:03Z matthijs $
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

#ifndef _NLNETLABS_DNS_DNS_H_
#define _NLNETLABS_DNS_DNS_H_

/** CLASS */
#define DNS_CLASS_IN     1 /* RFC 1035: Internet class */
#define DNS_CLASS_CS     2 /* RFC 1035: CS class */
#define DNS_CLASS_CH     3 /* RFC 1035: Chaos class */
#define DNS_CLASS_HS     4 /* RFC 1035: Hesiod class */
#define DNS_CLASS_NONE 254 /* Class NONE */
#define DNS_CLASS_ANY  255 /* Class ANY */

/** TYPE */
#define DNS_TYPE_A       1 /* RFC 1035: an IPv4 host address */
#define TYPE_NS          2 /* RFC 1035: an authoritative name server */
#define TYPE_MD          3 /* RFC 1035: a mail destination (Obsolete - use MX) */
#define TYPE_MF          4 /* RFC 1035: a mail forwarder (Obsolete - use MX) */
#define TYPE_CNAME       5 /* RFC 1035: the canonical name for an alias */
#define DNS_TYPE_SOA     6 /* RFC 1035: marks the start of authority of a zone */

#endif /* _NLNETLABS_DNS_DNS_H_ */

