grammar ECMAScript6ColoringTokens;
/* 
    This grammar contains only the tokens for coloring. 
*/

@lexer::members {
    // Basically is saying how deep is a template in templates
    // Example raw`token ${ `nested ${ `deeply` + {} } blah`}` where are three templates. One outer and two nested
    private int inTemplate = 0;
    // We need to count balance to process templates properly. If there are used object literals inside templates
    private int branceBalanceInTemplate = 0;

    // The most recently produced token id.
    private int lastTokenId = -1;

    private boolean canFollowKeyword() {
        if (lastTokenId == PUNCTUATOR_DOT) {
            return false;
        }
        return true;
    }


    private boolean canFollowReservedKeyword() {
        if (!canFollowKeyword()) {
            return false;
        }
        if (lastTokenId == PUNCTUATOR_ASSIGNMENT
            || lastTokenId == BRACKET_LEFT_BRACKET
            || lastTokenId == KEYWORD_IN) {
            return false;
        }
        return true;
    }
    
    /**
     * Return the next token from the character stream and records this last
     * token in case it resides on the default channel. This recorded token
     * is used to determine when the lexer could possibly match a regex
     * literal.
     *
     * @return the next token from the character stream.
     */
    @Override
    public Token nextToken() {
        
        // Get the next token.
        Token next = super.nextToken();
        
        // TODO this check is not needed in coloring lexer
        if (next.getChannel() == Token.DEFAULT_CHANNEL) {
            // Keep track of the last token on the default channel.
            if (next.getType() != EOL && next.getType() != WHITESPACE) {
                this.lastTokenId = next.getType();
            }
        }

        return next;
    }

    /**
     * Returns {@code true} if the lexer can match a regex literal.
     *
     * @return {@code true} if the lexer can match a regex literal.
     */
    private boolean isRegexPossible() {
                                       
        if (this.lastTokenId == -1) {
            // No token has been produced yet: at the start of the input,
            // no division is possible, so a regex literal _is_ possible.
            return true;
        }
        
        switch (this.lastTokenId) {
            case IDENTIFIER:
            case LITERAL_NULL:
            case LITERAL_TRUE:
            case LITERAL_FALSE:
            case KEYWORD_THIS:
            case BRACKET_RIGHT_BRACKET:
            case BRACKET_RIGHT_PAREN:
            case NUMERIC_DECIMAL:
            case NUMERIC_INTEGER:
            case NUMERIC_BINARY:
            case NUMERIC_OCTAL:
            case NUMERIC_HEX:
            case STRING:
                // After any of the tokens above, no regex literal can follow.
                return false;
            default:
                // In all other cases, a regex literal _is_ possible.
                return true;
        }
    }

}

/// 11.2 Whitespaces
WHITESPACE          : [\u0009\u000B\u000C\u0020\u00A0\uFEFF]+;

/// 11.3 Line Terminators
EOL                             : [\r\n\u2028\u2029];
fragment LineTerminatorSequence : '\r\n'
                                | EOL;

/// 11.4 Comments
COMMENT_LINE          : '//' ~[\r\n\u2028\u2029]*;
COMMENT_SHEBANG       : {lastTokenId == -1}? '#!' ~[\r\n\u2028\u2029]* {setType(COMMENT_LINE);}; // Only at first line
COMMENT_DOC           : '/**' .*? '*/';
COMMENT_BLOCK         : '/*' .*? '*/';

/// 11.6.2.1 Keywords
KEYWORD_BREAK     : 'break' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_DO        : 'do' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_IN        : 'in' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_TYPEOF    : 'typeof' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_CASE      : 'case' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_ELSE      : 'else' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_INSTANCEOF: 'instanceof' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_VAR       : 'var' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_CATCH     : 'catch' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_EXPORT    : 'export' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_NEW       : 'new' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_VOID      : 'void' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_CLASS     : 'class' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_EXTENDS   : 'extends' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_RETURN    : 'return' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_WHILE     : 'while' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_CONST     : 'const' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_FINALLY   : 'finally' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_SUPER     : 'super' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_WITH      : 'with' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_CONTINUE  : 'continue' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_FOR       : 'for' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_OF        : 'of' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_SWITCH    : 'switch' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_YIELD     : 'yield' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_DEBUGGER  : 'debugger' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_FUNCTION  : 'function' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_THIS      : 'this' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_DEFAULT   : 'default' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_IF        : 'if' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_THROW     : 'throw' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_DELETE    : 'delete' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_IMPORT    : 'import' {if (!canFollowKeyword()) setType(IDENTIFIER);};
KEYWORD_TRY       : 'try' {if (!canFollowKeyword()) setType(IDENTIFIER);};

/// 11.6.2.2 Future Reserved Words
RESERVED_ENUM       : 'enum' {if (!canFollowKeyword()) setType(IDENTIFIER);};
RESERVED_AWAIT      : 'await' {if (!canFollowReservedKeyword()) setType(IDENTIFIER);};
RESERVED_IMPLEMENTS : 'implements' {if (!canFollowReservedKeyword()) setType(IDENTIFIER);};
RESERVED_PACKAGE    : 'package' {if (!canFollowReservedKeyword()) setType(IDENTIFIER);};
RESERVED_PROTECTED  : 'protected' {if (!canFollowReservedKeyword()) setType(IDENTIFIER);};
RESERVED_INTERFACE  : 'interface' {if (!canFollowReservedKeyword()) setType(IDENTIFIER);};
RESERVED_PRIVATE    : 'private' {if (!canFollowReservedKeyword()) setType(IDENTIFIER);};
RESERVED_PUBLIC     : 'public' {if (!canFollowReservedKeyword()) setType(IDENTIFIER);};

// these are not defined either as keyword or reserved keywords in spec
// but we use them as keywords due using in the different expressions
RESERVED_STATIC    : 'static' {if (!canFollowReservedKeyword()) setType(IDENTIFIER);};
RESERVED_LET       : 'let' {if (!canFollowReservedKeyword()) setType(IDENTIFIER);};
RESERVED_AS        : 'as' {if (!canFollowReservedKeyword()) setType(IDENTIFIER);};
RESERVED_FROM      : 'from' {if (!canFollowReservedKeyword()) setType(IDENTIFIER);};

/// 11.7 Punctuators
BRACKET_LEFT_PAREN                              : '(';
BRACKET_RIGHT_PAREN                             : ')';
BRACKET_LEFT_CURLY                              : '{' { if (inTemplate > 0 ) { branceBalanceInTemplate++; } };
BRACKET_RIGHT_CURLY                             : '}' { if (inTemplate > 0 ) { branceBalanceInTemplate--; } };
BRACKET_LEFT_BRACKET                            : '[';
BRACKET_RIGHT_BRACKET                           : ']';

PUNCTUATOR_DOT                                  : '.';
PUNCTUATOR_ELLIPSIS                             : '...';
PUNCTUATOR_SEMICOLON                            : ';';
PUNCTUATOR_COMMA                                : ',';
PUNCTUATOR_LOWER                                : '<';	
PUNCTUATOR_GREATER                              : '>';
PUNCTUATOR_LOWER_EQUALS                         : '<=';
PUNCTUATOR_GREATER_EQUALS                       : '>=';	
PUNCTUATOR_EQUALS                               : '==';	
PUNCTUATOR_NOT_EQUALS                           : '!=';	
PUNCTUATOR_EQUALS_EXACTLY                       : '===';
PUNCTUATOR_NOT_EQUALS_EXACTLY                   : '!==';
PUNCTUATOR_PLUS                                 : '+';	
PUNCTUATOR_MINUS                                : '-';	
PUNCTUATOR_MULTIPLICATION                       : '*';	
PUNCTUATOR_DIVISION                             : '/';
PUNCTUATOR_DIVISION_ASSIGNMENT                  : '/=';
PUNCTUATOR_MODULUS                              : '%';	
PUNCTUATOR_INCREMENT                            : '++';	
PUNCTUATOR_DECREMENT                            : '--';
PUNCTUATOR_LEFT_SHIFT_ARITHMETIC                : '<<';	
PUNCTUATOR_RIGHT_SHIFT_ARITHMETIC               : '>>';	
PUNCTUATOR_RIGHT_SHIFT                          : '>>>';	
PUNCTUATOR_BITWISE_AND                          : '&';	
PUNCTUATOR_BITWISE_OR                           : '|';	
PUNCTUATOR_BITWISE_XOR                          : '^';
PUNCTUATOR_NOT                                  : '!';	
PUNCTUATOR_BITWISE_NOT                          : '~';	
PUNCTUATOR_AND                                  : '&&';	
PUNCTUATOR_OR                                   : '||';	
PUNCTUATOR_TERNARY                              : '?';	
PUNCTUATOR_COLON                                : ':';
PUNCTUATOR_ASSIGNMENT                           : '=';
PUNCTUATOR_PLUS_ASSIGNMENT                      : '+=';	
PUNCTUATOR_MINUS_ASSIGNMENT                     : '-=';
PUNCTUATOR_MULTIPLICATION_ASSIGNMENT            : '*=';	
PUNCTUATOR_MODULUS_ASSIGNMENT                   : '%=';	
PUNCTUATOR_LEFT_SHIFT_ARITHMETIC_ASSIGNMENT     : '<<=';
PUNCTUATOR_RIGHT_SHIFT_ARITHMETIC_ASSIGNMENT    : '>>=';
PUNCTUATOR_RIGHT_SHIFT_ASSIGNMENT               : '>>>=';	
PUNCTUATOR_BITWISE_AND_ASSIGNMENT               : '&=';	
PUNCTUATOR_BITWISE_OR_ASSIGNMENT                : '|=';	
PUNCTUATOR_BITWISE_XOR_ASSIGNMENT               : '^=';	
PUNCTUATOR_ARROW                                : '=>';

/// 11.8.1  Null Literal
LITERAL_NULL        : 'null';

/// 11.8.2. Boolean Literal
LITERAL_TRUE        : 'true';
LITERAL_FALSE       : 'false';

/// 11.8.3 Numeric Literal
NUMERIC_DECIMAL         : NUMERIC_INTEGER '.' DecimalDigits? ExponentPart?
                        | '.' DecimalDigits ExponentPart?
                        | NUMERIC_INTEGER ExponentPart?;
NUMERIC_INTEGER         : '0'
                       | NonZeroDigit DecimalDigits?;
fragment DecimalDigits  : DecimalDigit+;
fragment DecimalDigit   : [0123456789];
fragment NonZeroDigit   : [123456789];
fragment ExponentPart   : ExponentIndicator SignedInteger;
fragment ExponentIndicator : [eE];
fragment SignedInteger  : [+-]? DecimalDigits;

NUMERIC_BINARY      : '0' [bB] BinaryDigits;
fragment BinaryDigits: BinaryDigit+;
fragment BinaryDigit : [01];

NUMERIC_OCTAL       : '0' [oO] OctalDigits;
fragment OctalDigits: OctalDigit+;
fragment OctalDigit : 'ahoj';

NUMERIC_HEX         : '0' [xX] HexDigits;
fragment HexDigits  : HexDigit+;
fragment HexDigit   : [0123456789abcdefABCDEF];

/// 11.8.4 String Literal

STRING                          : '"' DoubleStringCharacter* '"'
                                | '\'' SingleStringCharacter* '\'';
fragment DoubleStringCharacter  : ~["\\\r\n\u2028\u2029]
                                | '\\' EscapeSequence
                                | LineContinuation;  
fragment SingleStringCharacter  : ~['\\\r\n\u2028\u2029]
                                | '\\' EscapeSequence
                                | LineContinuation;
fragment LineContinuation       : '\\' LineTerminatorSequence;
fragment EscapeSequence         : CharacterEscapeSequence
                                | '0' // TODO no digits
                                | HexEscapeSequence
                                | UnicodeEscapeSequence;
fragment CharacterEscapeSequence: SingleEscapeCharacter
                                | NonEscapeCharacter;
fragment EscapeCharacter        : SingleEscapeCharacter
                                | DecimalDigit
                                | [xu];
fragment SingleEscapeCharacter  : ['"\\bfnrtv];
fragment NonEscapeCharacter     : ~['"\\bfnrtv0-9xu\r\n\u2028\u2029];
fragment HexEscapeSequence      : 'x' HexDigit HexDigit;
fragment UnicodeEscapeSequence  : 'u' Hex4Digits
                                | 'u{' HexDigits '}';
fragment Hex4Digits             : HexDigit HexDigit HexDigit HexDigit;
  
/// 11.8.5 Regular Expression
REGULAR_EXPRESSION                  : {isRegexPossible()}? '/' RegularExpressionBody '/' RegularExpressionFlags;
fragment RegularExpressionBody      :RegularExpressionFirstChar RegularExpressionChar*;
fragment RegularExpressionFlags     : IdentifierPart*;
fragment RegularExpressionFirstChar : ~[\r\n\u2028\u2029*\\/\[]
                                    | RegularExpressionBackslashSequence
                                    | RegularExpressionClass;
fragment RegularExpressionChar      : ~[\r\n\u2028\u2029\\/\[]
                                    | RegularExpressionBackslashSequence
                                    | RegularExpressionClass;
fragment RegularExpressionNonTerminator : ~[\r\n\u2028\u2029];
fragment RegularExpressionBackslashSequence :'\\' RegularExpressionNonTerminator;
fragment RegularExpressionClass     : '[' RegularExpressionClassChar* ']';
fragment RegularExpressionClassChar : ~[\r\n\u2028\u2029\]\\]
                                    | RegularExpressionBackslashSequence;

// 11.8.6 Template

TEMPLATE_HEAD                       : '`' TemplateCharacter* '${' { inTemplate++; };
TEMPLATE_NOSUBSTITUTION             : '`' TemplateCharacter* '`';
TEMPLATE_MIDDLE                     : { inTemplate > 0 && branceBalanceInTemplate == 0 }? '}' TemplateCharacter* '${' { inTemplate++; };
TEMPLATE_TAIL                       : { inTemplate > 0 && branceBalanceInTemplate == 0 }? '}' TemplateCharacter* '`' { inTemplate--; };
fragment TemplateCharacter          : '$' { _input.LA(1) != '{'}?
                                    | '\\' EscapeSequence
                                    | LineContinuation
                                    | LineTerminatorSequence
                                    | ~[`\\$\r\n\u2028\u2029];
    
/// 11.6 Identifier
//  needs to be defined after keywords and reserved words, else eats the keywords
IDENTIFIER                  : IdentifierStart IdentifierPart*;
fragment IdentifierStart    : UnicodeLetter
                            | [$_]
                            | '\\' UnicodeEscapeSequence;

fragment IdentifierPart     : IdentifierStart
                            | UnicodeCombiningMark
                            | UnicodeDigit
                            | UnicodeConnectorPunctuation
                            | [\u200C\u200D];
fragment UnicodeLetter
 : [\u0041-\u005A]
 | [\u0061-\u007A]
 | [\u00AA]
 | [\u00B5]
 | [\u00BA]
 | [\u00C0-\u00D6]
 | [\u00D8-\u00F6]
 | [\u00F8-\u021F]
 | [\u0222-\u0233]
 | [\u0250-\u02AD]
 | [\u02B0-\u02B8]
 | [\u02BB-\u02C1]
 | [\u02D0-\u02D1]
 | [\u02E0-\u02E4]
 | [\u02EE]
 | [\u037A]
 | [\u0386]
 | [\u0388-\u038A]
 | [\u038C]
 | [\u038E-\u03A1]
 | [\u03A3-\u03CE]
 | [\u03D0-\u03D7]
 | [\u03DA-\u03F3]
 | [\u0400-\u0481]
 | [\u048C-\u04C4]
 | [\u04C7-\u04C8]
 | [\u04CB-\u04CC]
 | [\u04D0-\u04F5]
 | [\u04F8-\u04F9]
 | [\u0531-\u0556]
 | [\u0559]
 | [\u0561-\u0587]
 | [\u05D0-\u05EA]
 | [\u05F0-\u05F2]
 | [\u0621-\u063A]
 | [\u0640-\u064A]
 | [\u0671-\u06D3]
 | [\u06D5]
 | [\u06E5-\u06E6]
 | [\u06FA-\u06FC]
 | [\u0710]
 | [\u0712-\u072C]
 | [\u0780-\u07A5]
 | [\u0905-\u0939]
 | [\u093D]
 | [\u0950]
 | [\u0958-\u0961]
 | [\u0985-\u098C]
 | [\u098F-\u0990]
 | [\u0993-\u09A8]
 | [\u09AA-\u09B0]
 | [\u09B2]
 | [\u09B6-\u09B9]
 | [\u09DC-\u09DD]
 | [\u09DF-\u09E1]
 | [\u09F0-\u09F1]
 | [\u0A05-\u0A0A]
 | [\u0A0F-\u0A10]
 | [\u0A13-\u0A28]
 | [\u0A2A-\u0A30]
 | [\u0A32-\u0A33]
 | [\u0A35-\u0A36]
 | [\u0A38-\u0A39]
 | [\u0A59-\u0A5C]
 | [\u0A5E]
 | [\u0A72-\u0A74]
 | [\u0A85-\u0A8B]
 | [\u0A8D]
 | [\u0A8F-\u0A91]
 | [\u0A93-\u0AA8]
 | [\u0AAA-\u0AB0]
 | [\u0AB2-\u0AB3]
 | [\u0AB5-\u0AB9]
 | [\u0ABD]
 | [\u0AD0]
 | [\u0AE0]
 | [\u0B05-\u0B0C]
 | [\u0B0F-\u0B10]
 | [\u0B13-\u0B28]
 | [\u0B2A-\u0B30]
 | [\u0B32-\u0B33]
 | [\u0B36-\u0B39]
 | [\u0B3D]
 | [\u0B5C-\u0B5D]
 | [\u0B5F-\u0B61]
 | [\u0B85-\u0B8A]
 | [\u0B8E-\u0B90]
 | [\u0B92-\u0B95]
 | [\u0B99-\u0B9A]
 | [\u0B9C]
 | [\u0B9E-\u0B9F]
 | [\u0BA3-\u0BA4]
 | [\u0BA8-\u0BAA]
 | [\u0BAE-\u0BB5]
 | [\u0BB7-\u0BB9]
 | [\u0C05-\u0C0C]
 | [\u0C0E-\u0C10]
 | [\u0C12-\u0C28]
 | [\u0C2A-\u0C33]
 | [\u0C35-\u0C39]
 | [\u0C60-\u0C61]
 | [\u0C85-\u0C8C]
 | [\u0C8E-\u0C90]
 | [\u0C92-\u0CA8]
 | [\u0CAA-\u0CB3]
 | [\u0CB5-\u0CB9]
 | [\u0CDE]
 | [\u0CE0-\u0CE1]
 | [\u0D05-\u0D0C]
 | [\u0D0E-\u0D10]
 | [\u0D12-\u0D28]
 | [\u0D2A-\u0D39]
 | [\u0D60-\u0D61]
 | [\u0D85-\u0D96]
 | [\u0D9A-\u0DB1]
 | [\u0DB3-\u0DBB]
 | [\u0DBD]
 | [\u0DC0-\u0DC6]
 | [\u0E01-\u0E30]
 | [\u0E32-\u0E33]
 | [\u0E40-\u0E46]
 | [\u0E81-\u0E82]
 | [\u0E84]
 | [\u0E87-\u0E88]
 | [\u0E8A]
 | [\u0E8D]
 | [\u0E94-\u0E97]
 | [\u0E99-\u0E9F]
 | [\u0EA1-\u0EA3]
 | [\u0EA5]
 | [\u0EA7]
 | [\u0EAA-\u0EAB]
 | [\u0EAD-\u0EB0]
 | [\u0EB2-\u0EB3]
 | [\u0EBD-\u0EC4]
 | [\u0EC6]
 | [\u0EDC-\u0EDD]
 | [\u0F00]
 | [\u0F40-\u0F6A]
 | [\u0F88-\u0F8B]
 | [\u1000-\u1021]
 | [\u1023-\u1027]
 | [\u1029-\u102A]
 | [\u1050-\u1055]
 | [\u10A0-\u10C5]
 | [\u10D0-\u10F6]
 | [\u1100-\u1159]
 | [\u115F-\u11A2]
 | [\u11A8-\u11F9]
 | [\u1200-\u1206]
 | [\u1208-\u1246]
 | [\u1248]
 | [\u124A-\u124D]
 | [\u1250-\u1256]
 | [\u1258]
 | [\u125A-\u125D]
 | [\u1260-\u1286]
 | [\u1288]
 | [\u128A-\u128D]
 | [\u1290-\u12AE]
 | [\u12B0]
 | [\u12B2-\u12B5]
 | [\u12B8-\u12BE]
 | [\u12C0]
 | [\u12C2-\u12C5]
 | [\u12C8-\u12CE]
 | [\u12D0-\u12D6]
 | [\u12D8-\u12EE]
 | [\u12F0-\u130E]
 | [\u1310]
 | [\u1312-\u1315]
 | [\u1318-\u131E]
 | [\u1320-\u1346]
 | [\u1348-\u135A]
 | [\u13A0-\u13B0]
 | [\u13B1-\u13F4]
 | [\u1401-\u1676]
 | [\u1681-\u169A]
 | [\u16A0-\u16EA]
 | [\u1780-\u17B3]
 | [\u1820-\u1877]
 | [\u1880-\u18A8]
 | [\u1E00-\u1E9B]
 | [\u1EA0-\u1EE0]
 | [\u1EE1-\u1EF9]
 | [\u1F00-\u1F15]
 | [\u1F18-\u1F1D]
 | [\u1F20-\u1F39]
 | [\u1F3A-\u1F45]
 | [\u1F48-\u1F4D]
 | [\u1F50-\u1F57]
 | [\u1F59]
 | [\u1F5B]
 | [\u1F5D]
 | [\u1F5F-\u1F7D]
 | [\u1F80-\u1FB4]
 | [\u1FB6-\u1FBC]
 | [\u1FBE]
 | [\u1FC2-\u1FC4]
 | [\u1FC6-\u1FCC]
 | [\u1FD0-\u1FD3]
 | [\u1FD6-\u1FDB]
 | [\u1FE0-\u1FEC]
 | [\u1FF2-\u1FF4]
 | [\u1FF6-\u1FFC]
 | [\u207F]
 | [\u2102]
 | [\u2107]
 | [\u210A-\u2113]
 | [\u2115]
 | [\u2119-\u211D]
 | [\u2124]
 | [\u2126]
 | [\u2128]
 | [\u212A-\u212D]
 | [\u212F-\u2131]
 | [\u2133-\u2139]
 | [\u2160-\u2183]
 | [\u3005-\u3007]
 | [\u3021-\u3029]
 | [\u3031-\u3035]
 | [\u3038-\u303A]
 | [\u3041-\u3094]
 | [\u309D-\u309E]
 | [\u30A1-\u30FA]
 | [\u30FC-\u30FE]
 | [\u3105-\u312C]
 | [\u3131-\u318E]
 | [\u31A0-\u31B7]
 | [\u3400]
 | [\u4DB5]
 | [\u4E00]
 | [\u9FA5]
 | [\uA000-\uA48C]
 | [\uAC00]
 | [\uD7A3]
 | [\uF900-\uFA2D]
 | [\uFB00-\uFB06]
 | [\uFB13-\uFB17]
 | [\uFB1D]
 | [\uFB1F-\uFB28]
 | [\uFB2A-\uFB36]
 | [\uFB38-\uFB3C]
 | [\uFB3E]
 | [\uFB40-\uFB41]
 | [\uFB43-\uFB44]
 | [\uFB46-\uFBB1]
 | [\uFBD3-\uFD3D]
 | [\uFD50-\uFD8F]
 | [\uFD92-\uFDC7]
 | [\uFDF0-\uFDFB]
 | [\uFE70-\uFE72]
 | [\uFE74]
 | [\uFE76-\uFEFC]
 | [\uFF21-\uFF3A]
 | [\uFF41-\uFF5A]
 | [\uFF66-\uFFBE]
 | [\uFFC2-\uFFC7]
 | [\uFFCA-\uFFCF]
 | [\uFFD2-\uFFD7]
 | [\uFFDA-\uFFDC]
 ;

fragment UnicodeCombiningMark
 : [\u0300-\u034E]
 | [\u0360-\u0362]
 | [\u0483-\u0486]
 | [\u0591-\u05A1]
 | [\u05A3-\u05B9]
 | [\u05BB-\u05BD]
 | [\u05BF] 
 | [\u05C1-\u05C2]
 | [\u05C4]
 | [\u064B-\u0655]
 | [\u0670]
 | [\u06D6-\u06DC]
 | [\u06DF-\u06E4]
 | [\u06E7-\u06E8]
 | [\u06EA-\u06ED]
 | [\u0711]
 | [\u0730-\u074A]
 | [\u07A6-\u07B0]
 | [\u0901-\u0903]
 | [\u093C]
 | [\u093E-\u094D]
 | [\u0951-\u0954]
 | [\u0962-\u0963]
 | [\u0981-\u0983]
 | [\u09BC-\u09C4]
 | [\u09C7-\u09C8]
 | [\u09CB-\u09CD]
 | [\u09D7]
 | [\u09E2-\u09E3]
 | [\u0A02]
 | [\u0A3C]
 | [\u0A3E-\u0A42]
 | [\u0A47-\u0A48]
 | [\u0A4B-\u0A4D]
 | [\u0A70-\u0A71]
 | [\u0A81-\u0A83]
 | [\u0ABC]
 | [\u0ABE-\u0AC5]
 | [\u0AC7-\u0AC9]
 | [\u0ACB-\u0ACD]
 | [\u0B01-\u0B03]
 | [\u0B3C]
 | [\u0B3E-\u0B43]
 | [\u0B47-\u0B48]
 | [\u0B4B-\u0B4D]
 | [\u0B56-\u0B57]
 | [\u0B82-\u0B83]
 | [\u0BBE-\u0BC2]
 | [\u0BC6-\u0BC8]
 | [\u0BCA-\u0BCD]
 | [\u0BD7]
 | [\u0C01-\u0C03]
 | [\u0C3E-\u0C44]
 | [\u0C46-\u0C48]
 | [\u0C4A-\u0C4D]
 | [\u0C55-\u0C56]
 | [\u0C82-\u0C83]
 | [\u0CBE-\u0CC4]
 | [\u0CC6-\u0CC8]
 | [\u0CCA-\u0CCD]
 | [\u0CD5-\u0CD6]
 | [\u0D02-\u0D03]
 | [\u0D3E-\u0D43]
 | [\u0D46-\u0D48]
 | [\u0D4A-\u0D4D]
 | [\u0D57]
 | [\u0D82-\u0D83]
 | [\u0DCA]
 | [\u0DCF-\u0DD4]
 | [\u0DD6]
 | [\u0DD8-\u0DDF]
 | [\u0DF2-\u0DF3]
 | [\u0E31]
 | [\u0E34-\u0E3A]
 | [\u0E47-\u0E4E]
 | [\u0EB1]
 | [\u0EB4-\u0EB9]
 | [\u0EBB-\u0EBC]
 | [\u0EC8-\u0ECD]
 | [\u0F18-\u0F19]
 | [\u0F35]
 | [\u0F37]
 | [\u0F39]
 | [\u0F3E-\u0F3F]
 | [\u0F71-\u0F84]
 | [\u0F86-\u0F87]
 | [\u0F90-\u0F97]
 | [\u0F99-\u0FBC]
 | [\u0FC6]
 | [\u102C-\u1032]
 | [\u1036-\u1039]
 | [\u1056-\u1059]
 | [\u17B4-\u17D3]
 | [\u18A9]
 | [\u20D0-\u20DC]
 | [\u20E1]
 | [\u302A-\u302F]
 | [\u3099-\u309A]
 | [\uFB1E]
 | [\uFE20-\uFE23]
 ;

fragment UnicodeDigit
 : [\u0030-\u0039]
 | [\u0660-\u0669]
 | [\u06F0-\u06F9]
 | [\u0966-\u096F]
 | [\u09E6-\u09EF]
 | [\u0A66-\u0A6F]
 | [\u0AE6-\u0AEF]
 | [\u0B66-\u0B6F]
 | [\u0BE7-\u0BEF]
 | [\u0C66-\u0C6F]
 | [\u0CE6-\u0CEF]
 | [\u0D66-\u0D6F]
 | [\u0E50-\u0E59]
 | [\u0ED0-\u0ED9]
 | [\u0F20-\u0F29]
 | [\u1040-\u1049]
 | [\u1369-\u1371]
 | [\u17E0-\u17E9]
 | [\u1810-\u1819]
 | [\uFF10-\uFF19]
 ;

fragment UnicodeConnectorPunctuation
 : [\u005F]
 | [\u203F-\u2040]
 | [\u30FB]
 | [\uFE33-\uFE34]
 | [\uFE4D-\uFE4F]
 | [\uFF3F]
 | [\uFF65];

/// other
ERROR               : '/*' (~'*' | ('*'+ ~[*/]))*? EOF
                    //| '/**' (~'*' | ('*'+ ~[*/]))*? EOF
                    | . 
                    ;

