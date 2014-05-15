
%%

%public
%class Lexer
%implements YYParser.Lexer
%int
%unicode
%line
%column

%{
	public Object getLVal() {
		//System.out.println("YYTEXT is: " + yytext() );
		return yytext();
	}

	public void yyerror ( String S ) {
		System.err.println( S );
	}
%}

Identifier = [a-z0-9A-Z]*
DecIntegerLiteral = [0-9]+(\.[0-9]*?)?
ComparatorLiteral = < | > | <= | >= | = | \!=

%%
{DecIntegerLiteral}	{	//System.out.println("Detected number");
				return YYParser.NUMBER;}
{ComparatorLiteral}	{return YYParser.COMPARATOR;}
" "			{	//System.out.println("Detected space");
				/* ignore */}
"and"			{ return YYParser.AND; }
"or"			{ return YYParser.OR; }
"not"			{ return YYParser.NOT; }
"implies"		{ return YYParser.IMPLIES; }
{Identifier}		{ return YYParser.IDENTIFIER;}
"+"			{ return YYParser.PLUS;}
"*"			{ return YYParser.TIMES;}
"-"			{ return YYParser.MINUS;}
"/"			{ return YYParser.DIVIDE;}
"^"			{ return YYParser.POWER;}
"("			{ return YYParser.LPAREN;}
")"			{ return YYParser.RPAREN;}
","			{ return YYParser.COMMA;}
"\n"			{ return YYParser.NEWLINE;}
[^]			{	System.out.println("Lexer: I'm confused, throwing error");
				return YYParser.YYERROR;}




