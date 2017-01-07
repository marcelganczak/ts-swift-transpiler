grammar TypeScript;
import JSLexerRules;

//TypeScript Declarations
//*****************************************************************
//  TypeScript Declaration additions
//      - Only defining items related to Declaration Source Files
//          since I am only parsing '.d.ts' files.
//
//  TODO:: Need to include newlines and other whitespace if needed.
//
// Order (TODO - Make sure all grammar definitions are arranged in teh following order)
//      Types
//      Expressions
//      Statements
//      Functions
//      Interfaces
//      Classes
//      Programs and Modules
//      Ambients
//      Declaration Source Files
//*****************************************************************
program
	: sourceFile? EOF
	;

sourceElements
	: sourceElement (sourceElement)*
	;

sourceElement
	: functionDeclaration
    | ambientDeclaration
	| statement
	;

//
//TypeScript Module
//
//*****************************************************************
//      Types
//*****************************************************************
type
        : typeName
        | typeLiteral
        ;

typeName
        : moduleOrTypeName
        ;

moduleOrTypeName
        : IDENT
        | moduleOrTypeName '.' IDENT
        ;

moduleName
        : moduleOrTypeName
        ;

typeLiteral
        : objectType
        | arrayType
        | tupleType
        | functionType
        | constructorType
        ;

//
// Object Type Literals
//
objectType
    : '{' typeBody '}'
    ;

typeBody
    : typeMemberList?
    | typeMemberList ';'
    ;

typeMemberList
    : typeMember
    | typeMemberList ';' typeMember
    ;

typeMember
    : callSignature
    | constructSignature
    | indexSignature
    | propertySignature
    | functionSignature
    ;

//
// Call Signatures
//
callSignature
    : openParen parameterList? closeParen returnTypeAnnotation?
    ;

//
// Construct Signature
//
constructSignature
    : 'new' openParen parameterList? closeParen typeAnnotation?
    ;

//
// Index Signatures
//
indexSignature
    : '[' requiredParameter ']' typeAnnotation?
    ;

//
// Property Signatures
//
propertySignature
    : IDENT question? typeAnnotation?
    ;

//
// Array Type Literals
//
arrayType
    : typeName '[' ']'
    | 'Array' '<' type '>'
    ;

tupleType
    : '[' typeList ']'
    ;

typeList
    : type
    | typeList COMMA type
    ;

//
// Function Type Literals
//
functionType
    : openParen parameterList? closeParen '=>' returnType
    ;

//
// Constructor Type Literals
//
constructorType
    : 'new' openParen parameterList? closeParen '=>' type
    ;

//*****************************************************************
//      Expressions
//*****************************************************************
//
// Function Expressions
//
functionExpression //Modified from base JavaScript implementation for TS
	: 'function' IDENT?  callSignature '{' functionBody '}'
	;

assignmentExpression //Modified to add in arrowFunctionExpression for TS
	: conditionalExpression
	| leftHandSideExpression assignmentOperator assignmentExpression
    | arrowFunctionExpression
	;

arrowFunctionExpression
    : arrowFormalParameters '=>' block
    | arrowFormalParameters '=>' assignmentExpression
    ;

arrowFormalParameters
    : callSignature
    | IDENT
    ;

unaryExpression //Modified to add in < Type > for TS
    : postfixExpression
    | 'delete' unaryExpression
    | 'void' unaryExpression
    | 'typeof' unaryExpression
    | '++' unaryExpression
    | '--' unaryExpression
    | '+' unaryExpression
    | '-' unaryExpression
    | '~' unaryExpression
    | '!' unaryExpression
    | '<' type '>'
    ;



//*****************************************************************
//      Statements
//*****************************************************************
variableDeclaration //Modified for TS
	: IDENT typeAnnotation? initialiser?
	;

variableDeclarationNoIn
	: IDENT typeAnnotation? initialiserNoIn?
	;

typeAnnotation
        : ':' type
        ;

//*****************************************************************
//      Functions
//*****************************************************************
//
//Function Declarations
//
functionDeclaration //Modified for TS
    : functionOverloads? functionImplementation
    ;

functionOverloads
    : functionOverload
    | functionOverloads functionOverload
    ;

functionOverload
    : 'function' functionSignature ';'
    ;

functionImplementation
    : 'function' functionSignature '{' functionBody '}'
    ;

//
// Function Signatures
//
functionSignature
    : IDENT question? openParen parameterList? closeParen returnTypeAnnotation?
    ;

parameterList
    : requiredParameterList
    | optionalParameterList
    | restParameter
    | requiredParameterList comma optionalParameterList
    | requiredParameterList comma restParameter
    | optionalParameterList comma restParameter
    | requiredParameterList comma optionalParameterList comma restParameter
    ;

requiredParameterList
    : requiredParameter
    | requiredParameterList comma requiredParameter
    ;

requiredParameter
    : publicOrPrivate? IDENT typeAnnotation?
    ;

publicOrPrivate
    : 'public'
    | 'private'
    ;

optionalParameterList
    : optionalParameter
    | optionalParameterList comma optionalParameter
    ;

optionalParameter
    : publicOrPrivate? IDENT question typeAnnotation?
    | publicOrPrivate? IDENT typeAnnotation? initialiser
    ;

restParameter
    : '...' requiredParameter
    ;

returnTypeAnnotation
    : ':' returnType
    ;

returnType
    : type
    | 'void'
    ;

//*****************************************************************
//      Interfaces
//*****************************************************************
//
// Interface Declarations
//
interfaceDeclaration
    : 'interface' IDENT interfaceExtendsClause? objectType
    ;

interfaceExtendsClause
    : 'extends' interfaceNameList
    ;

interfaceNameList
    : interfaceName
    | interfaceNameList comma interfaceName
    ;

interfaceName
    : typeName
    ;

//*****************************************************************
//      Classes
//*****************************************************************
classDeclaration
    : 'class' IDENT classHeritage openBrace classBody closeBrace
    ;

//
// Class Heritage Specification
//
classHeritage
    : classExtendsClause? implementsClause?
    ;

classExtendsClause
    : 'extends' className
    ;

className
    : typeName
    ;

implementsClause
    : 'implements' interfaceNameList
    ;

//
// Class Body
//
classBody
    : classElements?
    ;

classElements
    : classElement
    | classElements classElement
    ;

classElement
    : constructorDeclaration
    | memberDeclaration
    ;

//
// Constructor Declarations
//
constructorDeclaration
    : constructorOverloads? constructorImplementation
    ;

constructorOverloads
    : constructorOverload
    | constructorOverloads constructorOverloads
    ;

constructorOverload
    : 'constructor' openParen parameterList? closeParen ';'
    ;

constructorImplementation
    : 'constructor' openParen parameterList closeParen '{' functionBody '}'
    ;

//
// Member Declarations
//
memberDeclaration
    : memberVariableDeclaration
    | memberFunctionDeclaration
    | memberAccessorDeclaration
    ;

//
// Member Variable Declarations
//
memberVariableDeclaration
    : publicOrPrivate? 'static'? variableDeclaration ';'
    ;

//
// Member Function Declarations
//
memberFunctionDeclaration
    : memberFunctionOverloads? memberFunctionImplementation
    ;

memberFunctionOverloads
    : memberFunctionOverload
    | memberFunctionOverloads memberFunctionOverload
    ;

memberFunctionOverload
    : publicOrPrivate? 'static'? functionSignature
    ;

memberFunctionImplementation
    : publicOrPrivate? 'static'? functionSignature openBrace functionBody closeBrace
    ;

//
// Member Accessor Declarations
//
memberAccessorDeclaration
    : publicOrPrivate? getAccessorSignature '{' functionBody '}'
    | publicOrPrivate? setAccessorSignature '{' functionBody '}'
    ;

getAccessorSignature
    : GET IDENT openParen closeParen returnTypeAnnotation?
    ;

setAccessorSignature
    : SET IDENT openParen requiredParameter closeParen
    ;

//*****************************************************************
//      Programs and Modules
//*****************************************************************
//
//Programs
//
sourceFile
    : implementationSourceFile
    | declarationSourceFile
    ;

implementationSourceFile
    : moduleElements?
    ;

moduleElements
    : moduleElement
    | moduleElements moduleElement
    ;

moduleElement
    : statement
    | functionDeclaration
    | classDeclaration
    | interfaceDeclaration
    | moduleDeclaration
    | importDeclaration
    | exportDeclaration
    | ambientDeclaration
    ;

//
// Module Declarations
//
moduleDeclaration
    : 'module' IDENT? '{' moduleBody '}'
    ;

moduleBody
    : moduleElements?
    ;

//
// Export Declarations
//
exportDeclaration
    : 'export' variableStatement
    | 'export' functionDeclaration
    | 'export' classDeclaration
    | 'export' interfaceDeclaration
    | 'export' moduleDeclaration
    | 'export' ambientDeclaration
    ;

//
// Import Declarations
//
importDeclaration
    : 'import' IDENT '=' moduleReference ';'
    ;

moduleReference
    : externalModuleReference
    | moduleName
    ;

externalModuleReference
    : 'module' openParen STRING_LITERAL closeParen
    ;

//*****************************************************************
//      Ambients
//*****************************************************************
//
// Ambient Declarations
//
ambientDeclaration
        : 'declare' ambientVariableDeclaration
        | 'declare' ambientFunctionDeclaration
        | 'declare' ambientClassDeclaration
        | 'declare' ambientModuleDeclaration
	;

//
// Ambient Variable Declarations
//
ambientVariableDeclaration
        : 'var' IDENT typeAnnotation? ';'
        ;

//
// Ambient Function Declarations
//
ambientFunctionDeclaration
        : 'function' functionSignature ';'
        ;

//
// Ambient Class Declarations
//
ambientClassDeclaration
        : 'class' IDENT classHeritage openBrace ambientClassBody closeBrace
        ;

ambientClassBody
    : ambientClassBodyElements?
    ;

ambientClassBodyElements
    : ambientClassBodyElement
    | ambientClassBodyElements ambientClassBodyElement
    ;

ambientClassBodyElement
    : ambientConstructorDeclaration
    | ambientMemberDeclaration
    | ambientStaticDeclaration
    ;

ambientConstructorDeclaration
    : 'constructor' openParen parameterList closeParen ';'
    ;

ambientMemberDeclaration
    : publicOrPrivate? IDENT typeAnnotation? ';'
    | publicOrPrivate? functionSignature ';'
    ;

ambientStaticDeclaration
    : 'static' IDENT typeAnnotation? ';'
    | 'static' functionSignature ';'
    ;

//
// Ambient Module Declarations
//
ambientModuleDeclaration
	: 'module' ambientModuleIdentification '{' ambientModuleBody '}'
	;

ambientModuleIdentification
    : IDENT
    | STRING_LITERAL
    ;

ambientModuleBody
	: ambientElements?
	;

ambientElements
        : ambientElement
        | ambientElements ambientElement
        ;

ambientElement
        : 'export'? ambientVariableDeclaration
        | 'export'? ambientFunctionDeclaration
        | 'export'? ambientClassDeclaration
        | 'export'? interfaceDeclaration
        | 'export'? ambientModuleDeclaration
        | importDeclaration
        ;

//
// Declaration Source Files
//
declarationSourceFile
    : ambientElements?
    ;


//*********************************************************
// JavaScript Grammar
//      Grammar from Annotaded ES5
//      http://es5.github.io
//*********************************************************
functionBody
    : sourceElements?
    ;

conditionalExpression
    : logicalORExpression
    | logicalORExpression QUESTION assignmentExpression ':' assignmentExpression
    ;

block
	: '{' statementList? '}'
	;

leftHandSideExpression
    : newExpression
    | callExpression
    ;

newExpression
    : memberExpression
    | 'new' newExpression
    ;

callExpression
    : memberExpression arguments
    | callExpression arguments
    | callExpression '[' expression ']'
    | callExpression '.' IDENT
    ;

arguments
    : openParen closeParen
    | openParen argumentList closeParen
    ;

argumentList
    : assignmentExpression
    | argumentList comma assignmentExpression
    ;

assignmentOperator
    : '='
    | '*='
    | '/='
    | '%='
    | '+='
    | '-='
    | '<<='
    | '>>='
    | '>>>='
    | '&='
    | '^='
    | '|='
    ;

postfixExpression
    : leftHandSideExpression
    | leftHandSideExpression NEWLINE* '++'
    | leftHandSideExpression NEWLINE* '--'
    ;

initialiser
	: '=' assignmentExpression
	;

initialiserNoIn
	: '=' assignmentExpressionNoIn
	;

statementList
    : statement
    | statementList statement
    ;

statement
    : block
    | variableStatement
    | emptyStatement
    | expressionStatement
    | ifStatement
    | iterationStatement
    | continueStatement
    | breakStatement
    | returnStatement
    | withStatement
    | labelledStatement
    | switchStatement
    | throwStatement
    | tryStatement
    | debuggerStatement
    ;

variableStatement
    : varVariableStatement
    | letVariableStatement
    ;

varVariableStatement
    : 'var' variableDeclarationList ';'
    ;

letVariableStatement
    : 'let' variableDeclarationList ';'
    ;

variableDeclarationList
    : variableDeclaration
    | variableDeclarationList comma variableDeclaration
    ;

variableDeclarationListNoIn
    : variableDeclarationNoIn
    | variableDeclarationListNoIn comma variableDeclarationNoIn
    ;

logicalORExpression
    : logicalANDExpression
    | logicalORExpression '||' logicalANDExpression
    ;

logicalANDExpression
    : bitwiseORExpression
    | logicalANDExpression '&&' bitwiseORExpression
    ;

bitwiseORExpression
    : bitwiseXORExpression
    | bitwiseORExpression '|' bitwiseXORExpression
    ;

bitwiseXORExpression
    : bitwiseANDExpression
    | bitwiseXORExpression '^' bitwiseANDExpression
    ;

bitwiseANDExpression
    : equalityExpression
    | bitwiseANDExpression '&' equalityExpression
    ;

equalityExpression
    : relationalExpression
    | equalityExpression '==' relationalExpression
    | equalityExpression '!=' relationalExpression
    | equalityExpression '===' relationalExpression
    | equalityExpression '!==' relationalExpression
    ;
      
relationalExpression
    : shiftExpression
    | relationalExpression '<' shiftExpression
    | relationalExpression '>' shiftExpression
    | relationalExpression '<=' shiftExpression
    | relationalExpression '>=' shiftExpression
    | relationalExpression 'instanceof' shiftExpression
    | relationalExpression 'in' shiftExpression
    ;

shiftExpression
    : additiveExpression
    | shiftExpression '<<' additiveExpression
    | shiftExpression '>>' additiveExpression
    | shiftExpression '>>>' additiveExpression
    ;

additiveExpression
    : multiplicativeExpression
    | additiveExpression '+' multiplicativeExpression
    | additiveExpression '-' multiplicativeExpression
    ;  

multiplicativeExpression
    : unaryExpression
    | multiplicativeExpression '*' unaryExpression
    | multiplicativeExpression '/' unaryExpression
    | multiplicativeExpression '%' unaryExpression
    ;

memberExpression
    : primaryExpression
    | functionExpression
    | memberExpression '[' expression ']'
    | memberExpression '.' IDENT
    | 'new' memberExpression arguments
    ;

primaryExpression
	: 'this'
	| IDENT
	| literal
	| arrayLiteral
	| objectLiteral
	| openParen expression closeParen
	;

literal
	: nullLiteral
	| booleanLiteral
	| NUMERIC_LITERAL
	| STRING_LITERAL
      //Omitting regularExpressionLiteral for now
        ;

nullLiteral
    : 'null'
    ;

booleanLiteral
    : 'true'
    | 'false'
    ;

arrayLiteral
    : '[' elision? ']'
    | '[' elementList ']'
    | '[' elementList comma elision? ']'
    ;

elementList
    : elision? assignmentExpression
    | elementList comma elision? assignmentExpression
    ;

elision
    : comma
    | elision comma
    ;

objectLiteral
    : '{' '}'
    | '{' propertyNameAndValueList '}'
    | '{' propertyNameAndValueList comma '}'
    ;

propertyNameAndValueList
    : propertyAssignment
    | propertyNameAndValueList comma propertyAssignment
    ;

propertyAssignment
    : propertyName ':' assignmentExpression
    | GET propertyName openParen closeParen '{' functionBody '}'
    | SET propertyName openParen propertySetParameterList closeParen '{' functionBody '}'
    ;

propertyName
    : IDENT
    | STRING_LITERAL
    | NUMERIC_LITERAL
    ;

propertySetParameterList
    : IDENT
    ;

expression
    : assignmentExpression
    | expression comma assignmentExpression
    ;

expressionNoIn
    : assignmentExpressionNoIn
    | expressionNoIn comma assignmentExpressionNoIn
    ;

assignmentExpressionNoIn
    : conditionalExpressionNoIn
    | leftHandSideExpression assignmentOperator assignmentExpressionNoIn
    ;

conditionalExpressionNoIn
    : logicalORExpressionNoIn
    | logicalORExpressionNoIn QUESTION assignmentExpressionNoIn ':' assignmentExpressionNoIn
    ;

logicalORExpressionNoIn
    : logicalANDExpressionNoIn
    | logicalORExpressionNoIn '||' logicalANDExpressionNoIn
    ;

logicalANDExpressionNoIn
    : bitwiseORExpressionNoIn
    | logicalANDExpressionNoIn '&&' bitwiseORExpressionNoIn
    ;

bitwiseORExpressionNoIn
    : bitwiseXORExpressionNoIn
    | bitwiseORExpressionNoIn '|' bitwiseXORExpressionNoIn
    ;

bitwiseXORExpressionNoIn
    : bitwiseANDExpressionNoIn
    | bitwiseXORExpressionNoIn '^' bitwiseANDExpressionNoIn
    ;

bitwiseANDExpressionNoIn
    : equalityExpressionNoIn
    | bitwiseANDExpressionNoIn '&' equalityExpressionNoIn
    ;

equalityExpressionNoIn
    : relationalExpressionNoIn
    | equalityExpressionNoIn '==' relationalExpressionNoIn
    | equalityExpressionNoIn '!=' relationalExpressionNoIn
    | equalityExpressionNoIn '===' relationalExpressionNoIn
    | equalityExpressionNoIn '!==' relationalExpressionNoIn
    ;

relationalExpressionNoIn
    : shiftExpression
    | relationalExpressionNoIn '<' shiftExpression
    | relationalExpressionNoIn '>' shiftExpression
    | relationalExpressionNoIn '<=' shiftExpression
    | relationalExpressionNoIn '>=' shiftExpression
    | relationalExpressionNoIn 'instanceof' shiftExpression
    ;

emptyStatement
    : ';'
    ;

// http://es5.github.io/#x12.4
//ExpressionStatement :
//  [lookahead ? {{, function}] Expression ;
//FIXME weird????
expressionStatement
    : expression
    ;

ifStatement
    : 'if' openParen expression closeParen statement 'else' statement
    | 'if' openParen expression closeParen statement
    ;

iterationStatement
    : 'do' statement 'while' openParen expression closeParen ';'
    | 'while' openParen expression closeParen statement
    | 'for' openParen expressionNoIn? ';' expression? ';' expression? closeParen statement
    | 'for' openParen 'var' variableDeclarationListNoIn ';' expression? ';' expression? closeParen statement
    | 'for' openParen leftHandSideExpression 'in' expression closeParen statement
    | 'for' openParen 'var' variableDeclarationNoIn 'in' expression closeParen statement
    ;


continueStatement
    : 'continue' ';'
    | 'continue' NEWLINE* IDENT? ';'
    ;

breakStatement
    : 'break' ';'
    | 'break' NEWLINE* IDENT? ';'
    ;

returnStatement
    : 'return' ';'
    | 'return' NEWLINE* expression ';'
    ;

withStatement
    : 'with' openParen expression closeParen statement
    ;

labelledStatement
    : IDENT ':' statement
    ;

switchStatement
    : 'switch' openParen expression closeParen caseBlock
    ;

caseBlock
    : '{' caseClauses? '}'
    | '{' caseClauses? defaultClause caseClauses? '}'
    ;

caseClauses
    : caseClause
    | caseClauses caseClause
    ;

caseClause
    : 'case' expression ':' statementList?
    ;

defaultClause
    : 'default' ':' statementList?
    ;

throwStatement
    : 'throw' NEWLINE* expression ';'
    ;

tryStatement //Can't use catch or finally, check to see if they are reserved words in ANTLR4.
    : 'try' block catchClause
    | 'try' block finallyClause
    | 'try' block catchClause finallyClause
    ;

catchClause
    : 'catch' openParen IDENT closeParen block
    ;
   
finallyClause
    : 'finally' block
    ;

debuggerStatement
    : 'debugger' ';'
    ;

//
//  These parser rules are to make it easier to find seams in the language for
//      later translation.
//
openParen
    : OPEN_PAREN
    ;

closeParen
    : CLOSE_PAREN
    ;

comma
    : COMMA
    ;

openBrace
    : OPEN_BRACE
    ;

closeBrace
    : CLOSE_BRACE
    ;

question
    : QUESTION
    ;