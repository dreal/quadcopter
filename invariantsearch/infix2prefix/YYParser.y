%{
%}

%language "Java"

%token NUMBER
%token IDENTIFIER
%token PLUS
%token MINUS
%token TIMES
%token DIVIDE
%token POWER
%token NEWLINE
%token LPAREN
%token RPAREN
%token COMPARATOR
%token COMMA

%left COMPARATOR /* <, >, <=, >=, =, != */
%left MINUS PLUS
%left TIMES DIVIDE
%left NEGATIVE
%right POWER

%token AND
%token OR
%token NOT
%token IMPLIES

%right IMPLIES
%right OR
%right AND
%left NOT


%%
input:
	NEWLINE
	| logic NEWLINE 			{ System.out.println( $1 ); }
	;

logic:
	comparison 				{ $$ = $1; }
	| logic AND logic			{ $$ = "(and " + (String)$1 + " " + (String)$3 + " )"; }
	| logic OR logic			{ $$ = "(or " + (String)$1 + " " + (String)$3 + " )"; }
	| NOT logic				{ $$ = "(not " + (String)$2 + " )"; }
	| LPAREN logic RPAREN			{ $$ = "( " + (String)$2 + ")"; }
	| logic IMPLIES logic			{ $$ = "(implies " + (String)$1 + " " + (String)$3 + " )"; }


comparison:
	term COMPARATOR term			{ $$ = "(" + (String)$2 +" "+ (String)$1 + " " + (String)$3 + ")"; }
	;


term:
	IDENTIFIER LPAREN argumentlist RPAREN	{ $$ = "(" + (String)$1 + " " + (String)$3 + ")";		}
	| NUMBER				{ $$ = (String)$1; 						}
	| IDENTIFIER				{ $$ = (String)$1; 						}
	| LPAREN term RPAREN 			{ $$ = "("+ (String)$2 +")"; 					}
	| term PLUS term			{ $$ = "(+ " + (String)$1 + " " + (String)$3+ " )";		}
	| term MINUS term			{ $$ = "(- " + (String)$1 + " " + (String)$3 + ")";		}
	| term TIMES term			{ $$ = "(* " + (String)$1 + " " + (String)$3 +")";		}
	| term DIVIDE term			{ $$ = "(/ " + (String)$1 + " " + (String)$3 + ")";		}
	| term POWER term			{ $$ = "(^ " + (String)$1 + " " + (String)$3 + ")";		}
	| MINUS term %prec NEGATIVE		{ $$ = "(- 0 " + (String)$2 + " )";					}
	;

argumentlist:
	term                                              { $$ = (String)$1; /*System.out.println(" found arglist");*/                                        }
        | argumentlist COMMA term                         { $$ = (String)$1 + ", " + (String)$3; /*System.out.println("found arglist, lots");*/               }   
        ;

	
%%



