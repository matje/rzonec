/*
 * zparser.rl -- ragel grammar for DNS zone files.
 *
 * Copyright (c) 2013, Matthijs Mekking, NLnet Labs. All rights reserved.
 *
 * See LICENSE for the license.
 *
 */


%%{
    machine zparser;

    # Actions.

    # Actions: line parsing.
    action zparser_newline {
        parser->line++;
    }
    action zparser_comment {
        parser->comments++;
    }

    # Actions: numbers and time values.
    action zparser_decimal_digit {
        parser->number *= 10;
        parser->number += (fc - '0');
    }
    action zparser_timeformat {
        switch (fc) {
            case 'w':
            case 'W':
                parser->number *= (60*60*24*7);
                break;
            case 'd':
            case 'D':
                parser->number *= (60*60*24);
                break;
            case 'h':
            case 'H':
                parser->number *= (60*60);
                break;
            case 'm':
            case 'M':
                parser->number *= 60;
                break;
            case 's':
            case 'S':
            default:
                break;
        }
        parser->seconds += parser->number;
        parser->number = 0;
    }
    action zparser_ttl_start {
        parser->seconds = 0;
        parser->number = 0;
    }
    action zparser_ttl_end {
        parser->seconds += parser->number;
        parser->number = parser->seconds;
    }
    action zparser_dollar_ttl {
        parser->ttl = parser->number;
        fprintf(stderr, "[zparser] line %d: ttl %u\n", parser->line,
            (unsigned int) parser->ttl);
    }

    # Actions: labels and domain names.
    action zparser_label_start {
        parser->label_head = parser->dname_size;
        parser->dname_size++;
    }
    action zparser_label_char2wire {
        if (parser->dname_size < DNAME_MAXLEN) {
            parser->dname_wire[parser->dname_size] = fc;
            parser->dname_size++;
        } else {
            fprintf(stderr, "[zparser] error: line %d: domain name overflow\n",
                parser->line);
            parser->totalerrors++;
            fhold; fgoto line;
        }
    }
    action zparser_label_octet2wire_init {
        if (parser->dname_size < DNAME_MAXLEN) {
            parser->dname_wire[parser->dname_size] = 0;
            parser->dname_size++;
        } else {
            fprintf(stderr, "[zparser] error: line %d: domain name overflow\n",
                parser->line);
            parser->totalerrors++;
            fhold; fgoto line;
        }
    }
    action zparser_label_octet2wire {
        parser->dname_wire[parser->dname_size-1] *= 10;
        parser->dname_wire[parser->dname_size-1] += (fc - '0');
    }
    action zparser_label_end {
        parser->dname_wire[parser->label_head] =
            (parser->dname_size - parser->label_head - 1);
    }
    action zparser_dname_start {
        bzero(&parser->dname_wire[0], DNAME_MAXLEN);
        bzero(&parser->label_offsets[0], DNAME_MAXLEN);
        parser->dname_size = 0;
        parser->label_count = 0;
        parser->label = parser->dname_wire;
    }
    action zparser_dname_origin {
        parser->dname = parser->origin;
    }
    action zparser_rel_dname_end {
        fprintf(stdout, "relative dname: parsed\n");
    }
    action zparser_abs_dname_end {
        int i;
        parser->dname_size++;
        if (parser->dname_size < DNAME_MAXLEN) {
            parser->dname_wire[parser->dname_size] = 0;
        } else {
            fprintf(stderr, "[zparser] line %d: domain name overflow\n",
                parser->line);
            parser->totalerrors++;
            fhold; fgoto line;
        }
        while (1) {
            if (label_is_pointer(parser->label)) {
                fprintf(stderr, "[zparser] line %d: domain has pointer label\n",
                    parser->line);
                parser->totalerrors++;
                fhold; fgoto line;
            }
            parser->label_offsets[parser->label_count] =
                (uint8_t)(parser->label - parser->dname_wire);
            ++parser->label_count;
            if (label_is_root(parser->label)) {
                break;
            }
            parser->label = label_next(parser->label);
        }
        assert(parser->label_count <= DNAME_MAXLEN / 2 + 1);
        /* reverse label offsets. */
        for (i = 0; i < parser->label_count / 2; ++i) {
            uint8_t tmp = parser->label_offsets[i];
            parser->label_offsets[i] =
                parser->label_offsets[parser->label_count - i - 1];
            parser->label_offsets[parser->label_count - i - 1] = tmp;
        }
        parser->dname = (dname_type *) region_alloc(parser->region,
            (sizeof(dname_type) +
            (parser->label_count + parser->dname_size) * sizeof(uint8_t)));
        if (!parser->dname) {
            fprintf(stderr, "[zparser] line %d: domain create failed\n",
                parser->line);
            parser->totalerrors++;
            fhold; fgoto line;
        }
        parser->dname->size = parser->dname_size;
        parser->dname->label_count = parser->label_count;
        memcpy((uint8_t *) dname_label_offsets(parser->dname),
            parser->label_offsets, parser->label_count * sizeof(uint8_t));
        memcpy((uint8_t *) dname_name(parser->dname), parser->dname_wire,
            parser->dname_size * sizeof(uint8_t));
    }
    action zparser_dollar_origin {
        parser->origin = parser->dname;
        fprintf(stderr, "[zparser] line %d: origin ", parser->line);
        dname_print(stderr, parser->origin);
        fprintf(stderr, "\n");
    }
    # Actions: resource records.
    action zparser_rr_start {
        parser->current_rr.owner = NULL;
        parser->current_rr.ttl = parser->ttl;
        parser->current_rr.klass = parser->klass;
        parser->current_rr.type = 0;
        parser->current_rr.rdlen = 0;
        parser->current_rr.rdata = parser->tmp_rdata;
    }
    action zparser_rr_owner {
        parser->current_rr.owner = parser->dname;
    }
    action zparser_rr_class {
        parser->current_rr.klass = DNS_CLASS_IN;
    }
    action zparser_rr_ttl {
        parser->current_rr.ttl = parser->number;
    }
    action zparser_rr_end {
        int i;
        rzonec_process_rr();
        fprintf(stderr, "[zparser] line %d: resource record ", parser->line);
        dname_print(stderr, parser->current_rr.owner);
        fprintf(stderr, "\t%u", parser->current_rr.ttl);
        fprintf(stderr, "\t");
        rr_print_class(stderr, parser->current_rr.klass);
        fprintf(stderr, "\t");
        rr_print_rrtype(stderr, parser->current_rr.type);
        for (i = 0; i < parser->current_rr.rdlen; i++) {
            fprintf(stderr, " ");
            rdata_print(stderr, &parser->current_rr.rdata[i],
                parser->current_rr.type, i);
        }
        fprintf(stderr, "\n");
    }
    action zparser_rdata_start {
        bzero(&parser->rdbuf[0], DNS_RDLEN_MAX);
        parser->rdsize = 0;
    }
    action zparser_rdata_char {
        parser->rdbuf[parser->rdsize] = fc;
        parser->rdsize++;
    }
    action zparser_rdata_ipv4 {
        parser->rdbuf[parser->rdsize] = '\0';
        if (!zonec_rdata_add(parser->rr_region, &parser->current_rr,
            DNS_RDATA_IPV4, parser->rdbuf, parser->rdsize)) {
            fprintf(stderr, "[zparser] error: line %d: bad IPv4 address "
                "'%s'\n", parser->line, parser->rdbuf);
            parser->totalerrors++;
            fhold; fgoto line;
        }
    }


    # Errors.
    action zerror_digit {
        fprintf(stderr, "[zparser] error: line %d: not a digit: %c\n",
            parser->line, fc);
        parser->number = 0;
        fhold; fgoto line;
    }
    action zerror_entry {
        fprintf(stderr, "[zparser] error: line %d: bad entry\n", parser->line);
        parser->totalerrors++;
        fhold; fgoto line;
    }
    action zerror_dollar_origin {
        fprintf(stderr, "[zparser] error: line %d: bad origin directive\n",
            parser->line);
        parser->totalerrors++;
        fhold; fgoto line;
    }
    action zerror_dollar_ttl {
        fprintf(stderr, "[zparser] error: line %d: bad ttl directive\n",
            parser->line);
        parser->totalerrors++;
        fhold; fgoto line;
    }
    action zerror_label_ddd {
        fprintf(stderr, "[zparser] error: line %d: bad octet in label\n",
            parser->line);
        parser->totalerrors++;
        fhold; fgoto line;
    }
    action zerror_label_x {
        fprintf(stderr, "[zparser] error: line %d: bad escape in label\n",
            parser->line);
        parser->totalerrors++;
        fhold; fgoto line;
    }
    action zerror_label_overflow {
        fprintf(stderr, "[zparser] error: line %d: label overflow\n",
            parser->line);
        parser->totalerrors++;
        fhold; fgoto line;
    }
    action zerror_timeformat {
        fprintf(stderr, "[zparser] error: line %d: ttl time format error\n",
            parser->line);
        parser->totalerrors++;
        fhold; fgoto line;
    }
    action zerror_rr {
        fprintf(stderr, "[zparser] error: line %d: bad rr format\n",
            parser->line);
        parser->totalerrors++;
        fhold; fgoto line;
    }
    action zerror_rr_typedata {
        fprintf(stderr, "[zparser] error: line %d: bad rr typedata\n",
            parser->line);
        parser->totalerrors++;
        fhold; fgoto line;
    }
    action zerror_rdata_ipv4 {
        fprintf(stderr, "[zparser] error: line %d: bad IPv4 address format\n",
            parser->line);
        parser->totalerrors++;
        fhold; fgoto line;
    }



    ## Utility parsing, newline, comments, delimeters, numbers, time values.

    newline = '\n' $zparser_newline;

    # RFC 1035: Any combination of tabs and spaces act as a
    # delimiter between the separate items that make up an entry.
    delim = [ \t]+;

    # RFC 1035: Semicolon is used to start a comment; the remainder of the
    # line is ignored.
    comment = ';' . (^newline)* >zparser_comment;

    # http://www.zytrax.com/books/dns/apa/time.html
    timeformat = ( 's'i | 'm'i | 'h'i | 'd'i | 'w'i )
                                     $zparser_timeformat
                                     $!zerror_timeformat;
    decimal_number = digit+          $zparser_decimal_digit;
    time_value     = (decimal_number . timeformat)+ . decimal_number?;
    
    ## Domain name parsing, absolute dnames, relative dnames, labels.

    # RFC 1035: \DDD where each D is a digit is the octet corresponding to
    #                the decimal number described by DDD.  The resulting
    #                octet is assumed to be text and is not checked for
    #                special meaning.
    label_ddd = [0-7] {3}                >zparser_label_octet2wire_init
                                         $zparser_label_octet2wire
                                         $!zerror_label_ddd;

    # RFC 1035: \X where X is any character other than a digit (0-9), is
    #              used to quote that character so that its special meaning
    #              does not apply.  For example, "\." can be used to place
    #              a dot character in a label.
    label_x = ^digit                     $zparser_label_char2wire
                                         $!zerror_label_x;

    label_escape = '\\' . (label_x | label_ddd);

    label_char = ([^@().\"\$\\] -- space -- comment) $zparser_label_char2wire;

    label_character = (label_char | label_escape);

    # RFC 1035: The labels in the domain name are expressed as character
    # strings. MM: But requires different processing then for non-labels.
    label = label_character{1,63}        >zparser_label_start
                                         %zparser_label_end
                                         $!zerror_label_overflow;

    labels = (label . '.')* . label;

    # RFC 1035: Domain names which do not end in a dot are called relative.
    rel_dname = labels                   >zparser_dname_start
                                         %zparser_abs_dname_end;

    # RFC 1035: Domain names that end in a dot are called absolute.
    abs_dname = (labels? . '.')          >zparser_dname_start
                                         %zparser_abs_dname_end;

    owner = abs_dname | rel_dname | ('@' $zparser_dname_origin);

    # RFC 1035: TTL is a decimal integer
    # The $TTL field may take any time value.
    ttl = (decimal_number | time_value)  >zparser_ttl_start
                                         %zparser_ttl_end;

    rrttl = ttl . delim                  %zparser_rr_ttl;

    rrclass = "IN" . delim               %zparser_rr_class;
    # We could parse CS, CH, HS, NONE, ANY and CLASS<%d>

    # RDATAs
    rdata_ipv4       = ((digit {1,3}) . '.' . (digit {1,3}) . '.'
                     .  (digit {1,3}) . '.' . (digit {1,3}))
                     >zparser_rdata_start $zparser_rdata_char
                     %zparser_rdata_ipv4  $!zerror_rdata_ipv4;

    rdata_a          = delim . rdata_ipv4 %zparser_rdata_ipv4;

    rdata_ns         = delim . "RDATA_NS";
    rdata_md         = delim . "RDATA_MD";
    rdata_mf         = delim . "RDATA_MF";
    rdata_cname      = delim . "RDATA_CNAME";
    rdata_soa        = delim . "RDATA_SOA";

    rrtype_and_rdata =
        ( "A"          . rdata_a         >{parser->current_rr.type = DNS_TYPE_A;}
#        | "NS"         . rdata_ns        >{parser->current_rr.type = DNS_TYPE_NS;}
#        | "MD"         . rdata_md        >{parser->current_rr.type = DNS_TYPE_MD;}
#        | "MF"         . rdata_mf        >{parser->current_rr.type = DNS_TYPE_MF;}
#        | "CNAME"      . rdata_cname     >{parser->current_rr.type = DNS_TYPE_CNAME;}
#        | "SOA"        . rdata_soa       >{parser->current_rr.type = DNS_TYPE_SOA;}
        )                                $!zerror_rr_typedata;

    # RFC 1035: <rr> contents take one of the following forms:
    # [<TTL>] [<class>] <type> <RDATA>
    # [<class>] [<TTL>] <type> <RDATA>
    rr = ( owner                         %zparser_rr_owner
         . delim 
         . ( (rrclass? . (rrttl %zparser_rr_ttl)?)
         |   ((rrttl %zparser_rr_ttl)? . rrclass?)
         | delim
           )
         . rrtype_and_rdata
         )                               >zparser_rr_start
                                         %zparser_rr_end
                                         $!zerror_rr;

    ## Main line parsing, entries, directives, records.

    dollar_origin = "$ORIGIN" . delim . abs_dname %zparser_dollar_origin
                                                  $!zerror_dollar_origin;
    dollar_ttl    = "$TTL"    . delim . ttl       %zparser_dollar_ttl
                                                  $!zerror_dollar_ttl;

    # RFC 1035: The following entries are defined:
    # delim?:        <blank>[<comment>]
    # dollar_origin: $ORIGIN <domain-name> [<comment>]
    # rr:            <domain-name><rr> [<comment>]
    # RFC 2038: The Master File format is extended to include the following...
    # dollar_ttl:    $TTL <TTL> [comment]
    entry = (
            delim? | rr | dollar_origin | dollar_ttl
            )
            . delim? . comment? . newline $!zerror_entry;

    line := [^\n]* newline @{ fgoto main; };

    # RFC 1035: The format of these files is a sequence of entries.
    main := entry*;


    # TODO
    # RFC 1035: $INCLUDE <file-name> [<domain-name>] [<comment>]
    # RFC 1035: <blank><rr> [<comment>]
    # RRtypes
    # special region for dnames? 
    # Unknown records

}%%
