package scanner;

import java_cup.runtime.*;
import parser.sym;

%%

%class Lexer
%public
%unicode
%cup
%line
%column

%{
    // Helper method to create token without value
    private Symbol createToken(int tokenType) {
        return new Symbol(tokenType, yyline + 1, yycolumn + 1);
    }

    // Helper method to create token with value
    private Symbol createToken(int tokenType, Object tokenValue) {
        return new Symbol(tokenType, yyline + 1, yycolumn + 1, tokenValue);
    }
%}

/* Macro Definitions for Pattern Matching */
NewLine        = \r|\n|\r\n
Space          = [ \t\f]
Whitespace     = {NewLine}|{Space}
LineComment    = "//"[^\r\n]*

/* Token Patterns */
Letter         = [A-Za-z_]
Digit          = [0-9]
Identifier     = {Letter}({Letter}|{Digit})*
IntegerLiteral = 0|[1-9]{Digit}*
StringLiteral  = \"([^\\\"]|\\.)*\"

%%

/* Keyword Recognition */
<YYINITIAL> {
    "config"        { return createToken(sym.CONFIG); }
    "base_url"      { return createToken(sym.BASE_URL); }
    "header"        { return createToken(sym.HEADER); }
    "let"           { return createToken(sym.LET); }
    "test"          { return createToken(sym.TEST); }
    "GET"           { return createToken(sym.GET); }
    "POST"          { return createToken(sym.POST); }
    "PUT"           { return createToken(sym.PUT); }
    "DELETE"        { return createToken(sym.DELETE); }
    "expect"        { return createToken(sym.EXPECT); }
    "status"        { return createToken(sym.STATUS); }
    "body"          { return createToken(sym.BODY); }
    "contains"      { return createToken(sym.CONTAINS); }

    /* Symbol Tokens */
    "="             { return createToken(sym.EQUALS); }
    ";"             { return createToken(sym.SEMICOLON); }
    "{"             { return createToken(sym.LBRACE); }
    "}"             { return createToken(sym.RBRACE); }

    /* Literal Values */
    {Identifier}    { return createToken(sym.IDENTIFIER, yytext()); }
    
    {IntegerLiteral} { 
        Integer num = Integer.parseInt(yytext()); 
        return createToken(sym.NUMBER, num); 
    }
    
    {StringLiteral} { 
        // Extract string content and process escape sequences
        String content = yytext();
        content = content.substring(1, content.length() - 1);
        content = content.replace("\\\"", "\"");
        content = content.replace("\\\\", "\\");
        return createToken(sym.STRING, content); 
    }

    /* Ignore whitespace and comments */
    {Whitespace}    { /* skip whitespace */ }
    {LineComment}   { /* skip comments */ }
}

/* Error Handling */
[^] { 
    throw new Error("Illegal character <" + yytext() + "> at line " + (yyline + 1) + ", column " + (yycolumn + 1)); 
}