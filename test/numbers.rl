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

    # Actions
    action zparser_digit {
        fprintf(stdout, "log: %c\n", fc);
        parser->number += (fc - '0');
    }
    action zparser_number {
        fprintf(stdout, "number: %lu\n", parser->number);
        parser->number = 0;
    }

    # Errors
    action zerror_digit {
        fprintf(stderr, "not a digit: %c\n", fc);
        parser->number = 0;
        fhold; fgoto line;
    }

    line := [^\n]* '\n' @{ fgoto main; };
    
    main := (digit+ $zparser_digit
                    $!zerror_digit
             . '\n' @zparser_number
            )*;

}%%
