grammar ECMAScript6;

import ECMAScript6ColoringTokens;

@header {
/*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
 *
 * Copyright 2015 Oracle and/or its affiliates. All rights reserved.
 *
 * Oracle and Java are registered trademarks of Oracle and/or its affiliates.
 * Other names may be trademarks of their respective owners.
 *
 * The contents of this file are subject to the terms of either the GNU
 * General Public License Version 2 only ("GPL") or the Common
 * Development and Distribution License("CDDL") (collectively, the
 * "License"). You may not use this file except in compliance with the
 * License. You can obtain a copy of the License at
 * http://www.netbeans.org/cddl-gplv2.html
 * or nbbuild/licenses/CDDL-GPL-2-CP. See the License for the
 * specific language governing permissions and limitations under the
 * License.  When distributing the software, include this License Header
 * Notice in each file and include the License file at
 * nbbuild/licenses/CDDL-GPL-2-CP.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the GPL Version 2 section of the License file that
 * accompanied this code. If applicable, add the following below the
 * License Header, with the fields enclosed by brackets [] replaced by
 * your own identifying information:
 * "Portions Copyrighted [year] [name of copyright owner]"
 *
 * If you wish your version of this file to be governed by only the CDDL
 * or only the GPL Version 2, indicate your decision by adding
 * "[Contributor] elects to include this software in this distribution
 * under the [CDDL or GPL Version 2] license." If you do not indicate a
 * single choice of license, a recipient has the option to distribute
 * your version of this file under either the CDDL, the GPL Version 2 or
 * to extend the choice of license to its licensees as provided above.
 * However, if you add GPL Version 2 code and therefore, elected the GPL
 * Version 2 license, then the option applies only if the new code is
 * made subject to such option by the copyright holder.
 *
 * Contributor(s):
 *
 * Portions Copyrighted 2015 Sun Microsystems, Inc.
 */

package org.netbeans.modules.javascript2.editor.parser6;

}
@parser::members {
    private static String TARGET_IDENT = "target";

    private boolean lineTerminatorAhead() {

        // Get the token ahead of the current index.
        int possibleIndexEosToken = this.getCurrentToken().getTokenIndex() - 1;
        if (possibleIndexEosToken > -1) {
            Token ahead = _input.get(possibleIndexEosToken);

            if (ahead.getChannel() == Lexer.HIDDEN) {
                return true;
            }
        }
        return false;
    }
}


// 11.8.2 Boolean Literals
booleanLiteral          : LITERAL_TRUE 
                        | LITERAL_FALSE
                        ;

// 11.8.3 Numeric Literals
numericLiteral          : NUMERIC_DECIMAL
                        | NUMERIC_INTEGER
                        | NUMERIC_BINARY
                        | NUMERIC_OCTAL
                        | NUMERIC_HEX
                        ;

// 11.8.5 Regular Expression Literals
regularExpressionLiteral: REGULAR_EXPRESSION
                        ;

// 12.1 Identifiers
// lets pretend that BindingIdentifier, IdentifierReference, LabelIdentifier are just IDENTIFIER
bindingIdentifier       : IDENTIFIER
                        ;
labelIdentifier         : IDENTIFIER
                        ;

// 12.2 Primary Expression
primaryExpression       : KEYWORD_THIS
                        | IDENTIFIER
                        | literal
                        | arrayLiteral
                        | objectLiteral
//                        | functionExpression
                        | functionDeclaration
//                        | classExpression
                        | classDeclaration
//                        | generatorExpression
                        | generatorDeclaration
                        | regularExpressionLiteral
                        | templateLiteral
                        | coverParenthesizedExpressionAndArrowParameterList
                        ;
coverParenthesizedExpressionAndArrowParameterList :
                          BRACKET_LEFT_PAREN (expressionSequence | (expressionSequence PUNCTUATOR_COMMA)? PUNCTUATOR_ELLIPSIS IDENTIFIER)? BRACKET_RIGHT_PAREN
                        ;

// 12.2.4 Literals
literal                 : LITERAL_NULL 
                        | booleanLiteral
                        | numericLiteral
                        | STRING
                        ;

//12.2.5 Array Initializer
arrayLiteral            : BRACKET_LEFT_BRACKET   elementList BRACKET_RIGHT_BRACKET
                        ;

elementList             : (({_input.LA(1) != BRACKET_RIGHT_BRACKET}?elementElision|{_input.LA(1) == BRACKET_RIGHT_BRACKET}?)|assignmentExpression|spreadElement)
                            (PUNCTUATOR_COMMA (({_input.LA(1) != BRACKET_RIGHT_BRACKET}?elementElision|{_input.LA(1) == BRACKET_RIGHT_BRACKET}?) | assignmentExpression | spreadElement))*
                        //| elision? spreadElement
                        //| elementList PUNCTUATOR_COMMA elision? singleExpression
                        //| elementList PUNCTUATOR_COMMA elision? spreadElement
                        ;

elementElision          :
                        ;

elision                 : PUNCTUATOR_COMMA+
//                        | elision PUNCTUATOR_COMMA
                        ;
spreadElement           : PUNCTUATOR_ELLIPSIS assignmentExpression
                        ;

// 12.2.6 Object Initializer
objectLiteral           : BRACKET_LEFT_CURLY (propertyDefinitionList PUNCTUATOR_COMMA?)? BRACKET_RIGHT_CURLY
//                        | BRACKET_LEFT_CURLY propertyDefinitionList BRACKET_RIGHT_CURLY
//                        | BRACKET_LEFT_CURLY propertyDefinitionList PUNCTUATOR_COMMA BRACKET_RIGHT_CURLY
                        ;
propertyDefinitionList  : propertyDefinition (PUNCTUATOR_COMMA propertyDefinition)*
                        ;
propertyDefinition      : IDENTIFIER
                        | coverInitializedName
                        | propertyName PUNCTUATOR_COLON assignmentExpression
                        | methodDefinition
                        ;
propertyName            : literalPropertyName
                        | computedPropertyName
                        ;
literalPropertyName     : IDENTIFIER
                        | STRING
                        | numericLiteral
                        ;
computedPropertyName    : BRACKET_LEFT_BRACKET assignmentExpression BRACKET_RIGHT_BRACKET
                        ;
coverInitializedName    : IDENTIFIER initializer
                        ;
initializer             : PUNCTUATOR_ASSIGNMENT  assignmentExpression
                        ;

// 12.2.9 Template Literals
templateLiteral         : TEMPLATE_NOSUBSTITUTION
                        | TEMPLATE_HEAD expressionSequence templateSpans
                        ;
templateSpans           : TEMPLATE_TAIL
                        | templateMiddleList TEMPLATE_TAIL
                        ;
templateMiddleList      : TEMPLATE_MIDDLE expressionSequence
                        | templateMiddleList TEMPLATE_MIDDLE expressionSequence
                        ;

// 12.3 Left-Hand-Side Expressions
memberExpression        : memberExpression BRACKET_LEFT_BRACKET expressionSequence BRACKET_RIGHT_BRACKET
                        | memberExpression PUNCTUATOR_DOT IDENTIFIER
                        | memberExpression templateLiteral
                        | superProperty
                        | newTarget
                        | KEYWORD_NEW memberExpression arguments
                        | primaryExpression
                        ;
superProperty           : KEYWORD_SUPER  BRACKET_LEFT_BRACKET expressionSequence BRACKET_RIGHT_BRACKET
                        | KEYWORD_SUPER PUNCTUATOR_DOT IDENTIFIER
                        ;
newTarget               : KEYWORD_NEW PUNCTUATOR_DOT ident=IDENTIFIER {TARGET_IDENT.equals($ident.text)}?
                        ;

callExpressionLRR       : arguments callExpressionLRR
                        | BRACKET_LEFT_BRACKET expressionSequence BRACKET_RIGHT_BRACKET callExpressionLRR
                        |  PUNCTUATOR_DOT IDENTIFIER callExpressionLRR
                        | templateLiteral callExpressionLRR
                        |
                        ;

arguments               : BRACKET_LEFT_PAREN argumentList? BRACKET_RIGHT_PAREN
//                        | BRACKET_LEFT_PAREN argumentList BRACKET_RIGHT_PAREN
                        ;
argumentList            : PUNCTUATOR_ELLIPSIS? assignmentExpression (PUNCTUATOR_COMMA PUNCTUATOR_ELLIPSIS? assignmentExpression)*
//                        | PUNCTUATOR_ELLIPSIS assignmentExpression
//                        | argumentList PUNCTUATOR_COMMA assignmentExpression
//                        | argumentList PUNCTUATOR_COMMA PUNCTUATOR_ELLIPSIS assignmentExpression
                        ;
newExpressionRest       : memberExpression
                        | KEYWORD_NEW newExpressionRest
//newExpression           : KEYWORD_NEW memberExpression
                        ;
leftHandSideExpression  : memberExpression (arguments callExpressionLRR)?   #callExpression
                        | KEYWORD_SUPER arguments callExpressionLRR         #superCallExpression                                         // superCall
                        | KEYWORD_NEW newExpressionRest                     #newExpression
                        ;

// 12.4 Postfix Expressions
//TODO there should be check, whehtet between leftHandSideExpression and punctator is not line terminator!!!
postfixExpression       : leftHandSideExpression type=(PUNCTUATOR_INCREMENT | PUNCTUATOR_DECREMENT)?
//                        | leftHandSideExpression PUNCTUATOR_INCREMENT
//                        | leftHandSideExpression PUNCTUATOR_DECREMENT
                        ;
// 12.5 Unary Operators
unaryExpression         : postfixExpression
                        | type=(KEYWORD_DELETE | KEYWORD_VOID | KEYWORD_TYPEOF | PUNCTUATOR_INCREMENT | PUNCTUATOR_DECREMENT | PUNCTUATOR_PLUS | PUNCTUATOR_MINUS | PUNCTUATOR_BITWISE_NOT | PUNCTUATOR_NOT) unaryExpression
//                        | KEYWORD_DELETE unaryExpression
//                        | KEYWORD_VOID unaryExpression
//                        | KEYWORD_TYPEOF unaryExpression
//                        | PUNCTUATOR_INCREMENT unaryExpression
//                        | PUNCTUATOR_DECREMENT unaryExpression
//                        | PUNCTUATOR_PLUS unaryExpression
//                        | PUNCTUATOR_MINUS unaryExpression
//                        | PUNCTUATOR_BITWISE_NOT unaryExpression
//                        | PUNCTUATOR_NOT unaryExpression
                        ;

// simplification 
// 12.4 Postfix Expressions -> PostfixExpression
// 12.5 Unary Operators -> UnaryExpression
// 12.6 Multiplicative Operators -> BinaryExpression
// 12.7 Additive Operators -> BinaryExpression
// 12.8 Bitwise Shift Operators -> BinaryExpression
// 12.9 Relational Operators -> BinaryExpression
// 12.10 Equality Operators -> -> BinaryExpression
// 12.11 Binary Bitwise Operators -> BinaryExpression
// 12.12 Binary Logical Operators -> BinaryExpression
// 12.13 Conditional Operator ( ? : ) -> ConditionalExpression
//singleExpression        : KEYWORD_THIS  #ThisExpression
//                        | IDENTIFIER    #IdentExpression
//                        | literal       #LiteralExpression 
//                        | arrayLiteral  #ArrayLiteralExpression
//                        | objectLiteral  #ObjectLiteralExpression
//                        | functionDeclaration #FunctionExpression
//                        | classDeclaration #ClassExpression
//                        | KEYWORD_FUNCTION PUNCTUATOR_MULTIPLICATION bindingIdentifier? BRACKET_LEFT_PAREN formalParameters BRACKET_RIGHT_PAREN BRACKET_LEFT_CURLY generatorBody BRACKET_RIGHT_CURLY #GeneratorExpression
//                        | regularExpressionLiteral #RegularLiteralExpression
//                        | templateLiteral #TemplateLiteralExpression
//                        | coverParenthesizedExpressionAndArrowParameterList # ParenthesizedExpression
//                        //| leftHandSideExpression  #LeftHandSideExpression2
// member
//                        | object=singleExpression BRACKET_LEFT_BRACKET singleExpression BRACKET_RIGHT_BRACKET #MemberExpression
//                       | object=singleExpression PUNCTUATOR_DOT IDENTIFIER    #MemberExpression
//                        | object=singleExpression TEMPLATE #MemberExpression
//                        | KEYWORD_SUPER  BRACKET_LEFT_BRACKET expressionSequence BRACKET_RIGHT_BRACKET #SuperProperty     // superProperty
//                        | KEYWORD_SUPER PUNCTUATOR_DOT IDENTIFIER   #SuperProperty                                // superProperty
//                        | KEYWORD_NEW PUNCTUATOR_DOT 'target'       #NewTarget
//                        | KEYWORD_NEW singleExpression arguments    #MemberExpression
// member
// callExpression
//                        | singleExpression arguments    #CallExpression
//                        | KEYWORD_SUPER arguments       #CallExpression                                                // superCall
//                        | singleExpression BRACKET_LEFT_BRACKET expressionSequence BRACKET_RIGHT_BRACKET #CallExpression
//                        | singleExpression PUNCTUATOR_DOT IDENTIFIER #CallExpression
//                        | singleExpression TEMPLATE     #CallExpression
//                        | KEYWORD_NEW callee=singleExpression                 #NewExpression
//                        | arrowParameters PUNCTUATOR_ARROW conciseBody        #ArrowFunction // TODO ArrowParameters[no LineTerminator here] => ConciseBody
//                        | left=singleExpression operator=PUNCTUATOR_ASSIGNMENT right=expressionSequence                                # AssignmentExpression
                        
//                        | left=singleExpression assignmentOperator right=expressionSequence                 # AssignmentOperatorExpression
//                        | left=singleExpression operator=(PUNCTUATOR_MULTIPLICATION | PUNCTUATOR_DIVISION | PUNCTUATOR_MODULUS) right=singleExpression #BinaryExpression  //multiplicativeExpression
//                        | left=singleExpression operator=(PUNCTUATOR_PLUS | PUNCTUATOR_MINUS) right=singleExpression  #BinaryExpression                                  // additiveExpression
//                        | left=singleExpression operator=(PUNCTUATOR_LEFT_SHIFT_ARITHMETIC | PUNCTUATOR_RIGHT_SHIFT_ARITHMETIC | PUNCTUATOR_RIGHT_SHIFT) right=singleExpression #BinaryExpression //shiftExpression
//                        | left=singleExpression operator=(PUNCTUATOR_LOWER | PUNCTUATOR_GREATER | PUNCTUATOR_LOWER_EQUALS | PUNCTUATOR_GREATER_EQUALS | KEYWORD_INSTANCEOF | KEYWORD_IN ) right=singleExpression #BinaryExpression //relationalExpression
//                        | left=singleExpression operator=(PUNCTUATOR_EQUALS | PUNCTUATOR_NOT_EQUALS | PUNCTUATOR_EQUALS_EXACTLY | PUNCTUATOR_NOT_EQUALS_EXACTLY) right=singleExpression #BinaryExpression //equalityExpression
//                        | left=singleExpression operator=(PUNCTUATOR_BITWISE_AND | PUNCTUATOR_BITWISE_XOR | PUNCTUATOR_BITWISE_OR) right=singleExpression #BinaryExpression  //bitwiseExpression 
//                        | left=singleExpression operator=(PUNCTUATOR_AND | PUNCTUATOR_OR) right=singleExpression #BinaryExpression//logicalExpression 
//                        | singleExpression (PUNCTUATOR_INCREMENT | PUNCTUATOR_DECREMENT)  #PostfixExpression // TODO missing is not line terminator
//                        | (KEYWORD_DELETE | KEYWORD_VOID | KEYWORD_TYPEOF | PUNCTUATOR_INCREMENT | PUNCTUATOR_DECREMENT | PUNCTUATOR_PLUS | PUNCTUATOR_MINUS | PUNCTUATOR_BITWISE_NOT | PUNCTUATOR_NOT) singleExpression #UnaryExpression
//                        | test=singleExpression PUNCTUATOR_TERNARY consequent=singleExpression PUNCTUATOR_COLON alternate=singleExpression #ConditionalExpression
//                        ;


//assignmentExpression    : left=singleExpression operator=PUNCTUATOR_ASSIGNMENT right=expressionSequence      
//                        | left=singleExpression assignmentOperator right=expressionSequence
//destructuringAssignmentExpression : left=assignmentPattern operator=PUNCTUATOR_ASSIGNMENT right=expressionSequence
//                        ;

//expression              : destructuringAssignmentExpression
//                        | lhs
//                        ;

// 12.6 Multiplicative Operators
//multiplicativeExpression: unaryExpression
//                        | multiplicativeExpression PUNCTUATOR_MULTIPLICATION unaryExpression
//                        | multiplicativeExpression PUNCTUATOR_DIVISION unaryExpression
//                        | multiplicativeExpression PUNCTUATOR_MODULUS unaryExpression
//                        ;

// 12.7 Additive Operators
//additiveExpression      : multiplicativeExpression
//                        | additiveExpression PUNCTUATOR_PLUS multiplicativeExpression
//                        | additiveExpression PUNCTUATOR_MINUS multiplicativeExpression
//                        ;

// 12.8 Bitwise Shift Operators
//shiftExpression         : additiveExpression
//                        | shiftExpression PUNCTUATOR_LEFT_SHIFT_ARITHMETIC additiveExpression
//                        | shiftExpression PUNCTUATOR_RIGHT_SHIFT_ARITHMETIC additiveExpression
//                        | shiftExpression PUNCTUATOR_RIGHT_SHIFT additiveExpression
//                        ;

// 12.9 Relational Operators
//relationalExpression    : shiftExpression
//                        | relationalExpression PUNCTUATOR_LOWER shiftExpression
//                        | relationalExpression PUNCTUATOR_GREATER shiftExpression
//                        | relationalExpression PUNCTUATOR_LOWER_EQUALS shiftExpression
//                        | relationalExpression PUNCTUATOR_GREATER_EQUALS shiftExpression
//                        | relationalExpression KEYWORD_INSTANCEOF shiftExpression
//                        | relationalExpression KEYWORD_IN shiftExpression
//                        ;

// 12.10 Equality Operators
//equalityExpression      : relationalExpression
//                        | equalityExpression PUNCTUATOR_EQUALS relationalExpression
//                        | equalityExpression PUNCTUATOR_NOT_EQUALS relationalExpression
//                        | equalityExpression PUNCTUATOR_EQUALS_EXACTLY relationalExpression
//                        | equalityExpression PUNCTUATOR_NOT_EQUALS_EXACTLY relationalExpression
//                        ;

// 12.11 Binary Bitwise Operators
//bitwiseANDExpression    : equalityExpression
//                        | bitwiseANDExpression PUNCTUATOR_BITWISE_AND equalityExpression
//                        ;
//bitwiseXORExpression    : bitwiseANDExpression
//                        | bitwiseXORExpression PUNCTUATOR_BITWISE_XOR bitwiseANDExpression
//                        ;
//bitwiseORExpression     : bitwiseXORExpression
//                        | bitwiseORExpression PUNCTUATOR_BITWISE_OR bitwiseXORExpression
//                        ;

// 12.12 Binary Logical Operators
//logicalANDExpression    : bitwiseORExpression
//                        | logicalANDExpression PUNCTUATOR_AND bitwiseORExpression
//                        ;
//logicalORExpression     : logicalANDExpression
//                        | logicalORExpression PUNCTUATOR_OR logicalANDExpression
//                        ;

binaryExpression            : unaryExpression
                            | left=binaryExpression operator=(PUNCTUATOR_MULTIPLICATION | PUNCTUATOR_DIVISION | PUNCTUATOR_MODULUS) right=binaryExpression
                            | left=binaryExpression operator=(PUNCTUATOR_PLUS | PUNCTUATOR_MINUS) right=binaryExpression  
                            | left=binaryExpression operator=(PUNCTUATOR_LEFT_SHIFT_ARITHMETIC | PUNCTUATOR_RIGHT_SHIFT_ARITHMETIC | PUNCTUATOR_RIGHT_SHIFT) right=binaryExpression
                            | left=binaryExpression operator=(PUNCTUATOR_LOWER | PUNCTUATOR_GREATER | PUNCTUATOR_LOWER_EQUALS | PUNCTUATOR_GREATER_EQUALS | KEYWORD_INSTANCEOF | KEYWORD_IN ) right=binaryExpression
                            | left=binaryExpression operator=(PUNCTUATOR_EQUALS | PUNCTUATOR_NOT_EQUALS | PUNCTUATOR_EQUALS_EXACTLY | PUNCTUATOR_NOT_EQUALS_EXACTLY) right=binaryExpression
                            | left=binaryExpression operator=(PUNCTUATOR_BITWISE_AND | PUNCTUATOR_BITWISE_XOR | PUNCTUATOR_BITWISE_OR) right=binaryExpression
                            | left=binaryExpression operator=(PUNCTUATOR_AND | PUNCTUATOR_OR) right=binaryExpression
                            ;
// 12.13 Conditional Operator ( ? : )
conditionalExpression       : binaryExpression (PUNCTUATOR_TERNARY consequent=assignmentExpression PUNCTUATOR_COLON alternate=assignmentExpression)?
//                            | binaryExpression
                            ;

// 12.14 Assignment Operators
assignmentExpression        : assignmentPattern PUNCTUATOR_ASSIGNMENT right=assignmentExpression
//                            | leftHandSideExpression PUNCTUATOR_ASSIGNMENT right=assignmentExpression
                            | leftHandSideExpression (PUNCTUATOR_ASSIGNMENT | PUNCTUATOR_DIVISION_ASSIGNMENT | PUNCTUATOR_PLUS_ASSIGNMENT | PUNCTUATOR_MINUS_ASSIGNMENT | PUNCTUATOR_MULTIPLICATION_ASSIGNMENT | PUNCTUATOR_MODULUS_ASSIGNMENT | PUNCTUATOR_LEFT_SHIFT_ARITHMETIC_ASSIGNMENT | PUNCTUATOR_RIGHT_SHIFT_ARITHMETIC_ASSIGNMENT | PUNCTUATOR_RIGHT_SHIFT_ASSIGNMENT | PUNCTUATOR_BITWISE_AND_ASSIGNMENT | PUNCTUATOR_BITWISE_OR_ASSIGNMENT | PUNCTUATOR_BITWISE_XOR_ASSIGNMENT) right=assignmentExpression
//                            | leftHandSideExpression assignmentOperator right=assignmentExpression
                            | conditionalExpression
                            | arrowFunction
                            | yieldExpression
                            ;

//assignmentOperator      : PUNCTUATOR_DIVISION_ASSIGNMENT
//                        | PUNCTUATOR_PLUS_ASSIGNMENT
//                        | PUNCTUATOR_MINUS_ASSIGNMENT
//                        | PUNCTUATOR_MULTIPLICATION_ASSIGNMENT
//                        | PUNCTUATOR_MODULUS_ASSIGNMENT
//                        | PUNCTUATOR_LEFT_SHIFT_ARITHMETIC_ASSIGNMENT
//                        | PUNCTUATOR_RIGHT_SHIFT_ARITHMETIC_ASSIGNMENT
//                        | PUNCTUATOR_RIGHT_SHIFT_ASSIGNMENT
//                        | PUNCTUATOR_BITWISE_AND_ASSIGNMENT
//                        | PUNCTUATOR_BITWISE_OR_ASSIGNMENT
//                        | PUNCTUATOR_BITWISE_XOR_ASSIGNMENT
//                        ;

// 12.14.5 Destructuring Assignment

assignmentPattern       : objectAssignmentPattern
                        | arrayAssignmentPattern
                        ;

objectAssignmentPattern : BRACKET_LEFT_CURLY (assignmentPropertyList PUNCTUATOR_COMMA?)? BRACKET_RIGHT_CURLY
//                          BRACKET_LEFT_CURLY BRACKET_RIGHT_CURLY
//                        | BRACKET_LEFT_CURLY assignmentPropertyList BRACKET_RIGHT_CURLY
//                        | BRACKET_LEFT_CURLY assignmentPropertyList PUNCTUATOR_COMMA BRACKET_RIGHT_CURLY
                        ;

arrayAssignmentPattern  : BRACKET_LEFT_BRACKET elision? assignmentRestElement? BRACKET_RIGHT_BRACKET
                        | BRACKET_LEFT_BRACKET assignmentElementList BRACKET_RIGHT_BRACKET
                        | BRACKET_LEFT_BRACKET assignmentElementList PUNCTUATOR_COMMA elision? assignmentRestElement? BRACKET_RIGHT_BRACKET
                        ;

assignmentPropertyList  : assignmentProperty (PUNCTUATOR_COMMA assignmentProperty)*
//                        | assignmentPropertyList PUNCTUATOR_COMMA assignmentProperty
                        ;

assignmentElementList   : assignmentElisionElement (PUNCTUATOR_COMMA assignmentElisionElement)*
//                        | assignmentElementList PUNCTUATOR_COMMA assignmentElisionElement
                        ;

assignmentElisionElement: elision? assignmentElement
                        ;

assignmentProperty      : IDENTIFIER initializer?
                        | propertyName PUNCTUATOR_COLON assignmentElement
                        ;

assignmentElement       : leftHandSideExpression initializer?
                        ;

assignmentRestElement   : PUNCTUATOR_ELLIPSIS leftHandSideExpression
                        ;

//destructuringAssignmentTarget: leftHandSideExpression
//                        ;
//destructuringAssignmentTarget: singleExpression
//                        ;

// 12.15 Comma Operator ( , )
expressionSequence      : assignmentExpression (PUNCTUATOR_COMMA assignmentExpression)*
                        ;

// 13 ECMAScript Language: Statements and Declarations
statement               : block
                        | variableStatement
                        | emptyStatement
                        | expressionStatement
                        | ifStatement
                        | iterationStatement
                        | switchStatement
                        | continueStatement
                        | breakStatement
                        | returnStatement
                        | withStatement
                        | labelledStatement
                        | throwStatement
                        | tryStatement
                        | debuggerStatement
                        ;
declaration             : hoistableDeclaration
                        | classDeclaration
                        | lexicalDeclaration
                        ;
hoistableDeclaration    : functionDeclaration
                        | generatorDeclaration
                        ;
//breakableStatement      : iterationStatement
//                        | switchStatement
//                        ;

// 13.2 Block
//blockStatement          : block
//                        ;
block                   : BRACKET_LEFT_CURLY statementList? BRACKET_RIGHT_CURLY 
                        ;
statementList           : (statement | declaration)+
//                        | statementList statementListItem
                        ;
//statementListItem       : statement 
//                        | declaration
//                        ;

// 13.3.1 Let and Const Declarations
lexicalDeclaration      : letOrConst bindingList eos 
                        ;
letOrConst              : RESERVED_LET
                        | KEYWORD_CONST
                        ;
bindingList             : lexicalBinding (PUNCTUATOR_COMMA lexicalBinding)*
                        ;
lexicalBinding          : bindingIdentifier initializer?
                        | bindingPattern initializer?
                        ;

// 13.3.2 Variable Statement
variableStatement       : KEYWORD_VAR variableDeclarationList eos
                        ;
variableDeclarationList : variableDeclaration (PUNCTUATOR_COMMA variableDeclaration)*
                        ;
variableDeclaration     : ident=IDENTIFIER initializer?
                        | reservedKeyword initializer?
                        | bindingPattern initializer?
                        ;

// 13.3.3 Destructuring Binding Patterns
bindingPattern          : objectBindingPattern
                        | arrayBindingPattern
                        ;
objectBindingPattern    : BRACKET_LEFT_CURLY BRACKET_RIGHT_CURLY
                        | BRACKET_LEFT_CURLY bindingPropertyList BRACKET_RIGHT_CURLY
                        | BRACKET_LEFT_CURLY bindingPropertyList PUNCTUATOR_COMMA BRACKET_RIGHT_CURLY
                        ;
arrayBindingPattern     : BRACKET_LEFT_BRACKET elision? bindingRestElement? BRACKET_RIGHT_BRACKET
                        | BRACKET_LEFT_BRACKET bindingElementList BRACKET_RIGHT_BRACKET
                        | BRACKET_LEFT_BRACKET bindingElementList PUNCTUATOR_COMMA elision? bindingRestElement? BRACKET_RIGHT_BRACKET
                        ;
bindingPropertyList     : bindingProperty (PUNCTUATOR_COMMA bindingProperty)*
                        //| bindingPropertyList PUNCTUATOR_COMMA bindingProperty
                        ;
bindingElementList      : bindingElisionElement (PUNCTUATOR_COMMA bindingElisionElement)*
                        //| bindingElementList PUNCTUATOR_COMMA bindingElisionElement
                        ;
bindingElisionElement   : elision? bindingElement
                        ;
bindingProperty         : singleNameBinding
                        | propertyName PUNCTUATOR_COLON bindingElement
                        ;
bindingElement          : singleNameBinding
                        | bindingPattern initializer?
                        ;
singleNameBinding       : bindingIdentifier initializer?
                        ;
bindingRestElement      : PUNCTUATOR_ELLIPSIS bindingIdentifier
                        ;

// 13.4 Empty Statement
emptyStatement          :   PUNCTUATOR_SEMICOLON
                        ;

// 13.5 Expression Statement
expressionStatement     : { _input.LA(1) != BRACKET_LEFT_CURLY && _input.LA(1) != KEYWORD_FUNCTION && _input.LA(1) != KEYWORD_CLASS && _input.LA(1) != RESERVED_LET }? expressionSequence eos
                        ;
// TODO [lookahead ∉ {{, function, class, let [}] Expression[In, ?Yield] ;

// 13.6 The if Statement
ifStatement             : KEYWORD_IF BRACKET_LEFT_PAREN test=expressionSequence BRACKET_RIGHT_PAREN consequent=statement (KEYWORD_ELSE alternate=statement)?
                        //| KEYWORD_IF BRACKET_LEFT_PAREN test=expresoinSequence BRACKET_RIGHT_PAREN consequent=statement
                        ;

// 13.7 Iteration Statements
iterationStatement      : KEYWORD_DO statement KEYWORD_WHILE BRACKET_LEFT_PAREN expressionSequence BRACKET_RIGHT_PAREN eos #DoWhileStatement
                        | KEYWORD_WHILE BRACKET_LEFT_PAREN expressionSequence BRACKET_RIGHT_PAREN statement #WhileStatement
                        | KEYWORD_FOR BRACKET_LEFT_PAREN init=expressionSequence? PUNCTUATOR_SEMICOLON test=expressionSequence? PUNCTUATOR_SEMICOLON update=expressionSequence? BRACKET_RIGHT_PAREN body=statement #ForStatement // TODO for ( [lookahead ∉ {let [}] Expression[?Yield]opt ; Expression[In, ?Yield]opt ; Expression[In, ?Yield]opt ) Statement[?Yield, ?Return]
                        | KEYWORD_FOR BRACKET_LEFT_PAREN KEYWORD_VAR init=variableDeclarationList PUNCTUATOR_SEMICOLON test=expressionSequence? PUNCTUATOR_SEMICOLON update=expressionSequence? BRACKET_RIGHT_PAREN body=statement #ForVarStatement
                        | KEYWORD_FOR BRACKET_LEFT_PAREN lexicalDeclaration test=expressionSequence? PUNCTUATOR_SEMICOLON update=expressionSequence? BRACKET_RIGHT_PAREN body=statement #ForLCStatement
                        | KEYWORD_FOR BRACKET_LEFT_PAREN left=leftHandSideExpression KEYWORD_IN right=expressionSequence BRACKET_RIGHT_PAREN body=statement #ForInStatement // TODO for ( [lookahead ∉ {let [}] singleExpression[?Yield] in Expression[In, ?Yield] ) Statement[?Yield, ?Return]
                        | KEYWORD_FOR BRACKET_LEFT_PAREN KEYWORD_VAR left=variableDeclaration KEYWORD_IN right=expressionSequence BRACKET_RIGHT_PAREN body=statement #ForVarInStatement
                        | KEYWORD_FOR BRACKET_LEFT_PAREN left=forDeclaration KEYWORD_IN right=expressionSequence BRACKET_RIGHT_PAREN body=statement #ForCLInStatement
                        | KEYWORD_FOR BRACKET_LEFT_PAREN left=leftHandSideExpression KEYWORD_OF right=assignmentExpression BRACKET_RIGHT_PAREN body=statement #ForOfStatement // TODO for ( [lookahead ≠ let ] singleExpression[?Yield] of AssignmentExpression[In, ?Yield] ) Statement[?Yield, ?Return]
                        | KEYWORD_FOR BRACKET_LEFT_PAREN KEYWORD_VAR left=forBinding KEYWORD_OF right=assignmentExpression BRACKET_RIGHT_PAREN body=statement #ForVarOfStatement
                        | KEYWORD_FOR BRACKET_LEFT_PAREN left=forDeclaration KEYWORD_OF right=assignmentExpression BRACKET_RIGHT_PAREN body=statement #ForCLOfStatement
                        ;
forDeclaration          : letOrConst forBinding
                        ;
forBinding              : bindingIdentifier
                        | bindingPattern
                        ;

// 13.8 The continue Statement
continueStatement       : KEYWORD_CONTINUE labelIdentifier? eos
                        //| KEYWORD_CONTINUE labelIdentifier eos // TODO KEYWORD_CONTINUE [no LineTerminator here] IDENTIFIER
                        ;

// 13.9 The break Statement
breakStatement          : KEYWORD_BREAK labelIdentifier? eos
                        //| KEYWORD_BREAK labelIdentifier eos // TODO break [no LineTerminator here] LabelIdentifier[?Yield] ;
                        ;

// 13.10 The return Statement
returnStatement         : KEYWORD_RETURN expressionSequence? eos // TODO return [no LineTerminator here] Expression[In, ?Yield] ;
                        //| KEYWORD_RETURN singleExpression eos
                        ;

// 13.11 The with Statement
withStatement           : KEYWORD_WITH BRACKET_LEFT_PAREN object=expressionSequence BRACKET_RIGHT_PAREN body=statement
                        ;

// 13.12 The switch Statement
switchStatement         : KEYWORD_SWITCH BRACKET_LEFT_PAREN expressionSequence BRACKET_RIGHT_PAREN caseBlock
                        ;
caseBlock               : BRACKET_LEFT_CURLY caseClauses? BRACKET_RIGHT_CURLY
                        | BRACKET_LEFT_CURLY caseClauses? defaultClause caseClauses? BRACKET_RIGHT_CURLY
                        ;
caseClauses             : caseClause
                        | caseClauses caseClause
                        ;
caseClause              : KEYWORD_CASE expressionSequence PUNCTUATOR_COLON statementList?
                        ;
defaultClause           : KEYWORD_DEFAULT PUNCTUATOR_COLON statementList?
                        ;

// 13.13 Labelled Statements
labelledStatement       : labelIdentifier PUNCTUATOR_COLON labelledItem
                        ;
labelledItem            : statement
                        | functionDeclaration
                        ;

// 13.14 The throw Statement
throwStatement          : KEYWORD_THROW expressionSequence eos // TODO throw [no LineTerminator here] Expression[In, ?Yield] ;
                        ;

// 13.15 The try Statement
tryStatement            : KEYWORD_TRY block (catchBlock | finallyBlock | catchBlock finallyBlock)
//                        | KEYWORD_TRY block finallyBlock
//                        | KEYWORD_TRY block catchBlock finallyBlock
                        ;
catchBlock              : KEYWORD_CATCH BRACKET_LEFT_PAREN catchParameter BRACKET_RIGHT_PAREN block
                        ;
finallyBlock            : KEYWORD_FINALLY block
                        ;
catchParameter          : bindingIdentifier
                        | bindingPattern
                        ;

// 13.16 The debugger statement
debuggerStatement       : KEYWORD_DEBUGGER eos
                        ;

//14.1 Function Definitions
functionDeclaration     
locals [String idName = null]
                        : KEYWORD_FUNCTION bindingIdentifier? BRACKET_LEFT_PAREN formalParameters BRACKET_RIGHT_PAREN BRACKET_LEFT_CURLY functionBody BRACKET_RIGHT_CURLY
                        //| KEYWORD_FUNCTION BRACKET_LEFT_PAREN formalParameters BRACKET_RIGHT_PAREN BRACKET_LEFT_CURLY functionBody BRACKET_RIGHT_CURLY
                        ;
//functionExpression      : KEYWORD_FUNCTION bindingIdentifier? BRACKET_LEFT_PAREN formalParameters BRACKET_RIGHT_PAREN BRACKET_LEFT_CURLY functionBody BRACKET_RIGHT_CURLY
//                        ;
strictFormalParameters  : formalParameters
                        ;
formalParameters        : formalParameterList?
                        ;
formalParameterList     : functionRestParameter
                        | formalParameter (PUNCTUATOR_COMMA formalParameter)* (PUNCTUATOR_COMMA functionRestParameter)?
//                        | formalsList PUNCTUATOR_COMMA functionRestParameter
                        ;
//formalsList             : formalParameter (PUNCTUATOR_COMMA formalParameter)*
//                        | formalsList PUNCTUATOR_COMMA formalParameter
//                        ;
functionRestParameter   : bindingRestElement
                        ;
formalParameter         : bindingElement
                        ;
functionBody            : statementList?
                        ;

// 14.2 Arrow Function Definitions
arrowFunction           : arrowParameters PUNCTUATOR_ARROW conciseBody // TODO ArrowParameters[no LineTerminator here] => ConciseBody
                        ;
arrowParameters         : bindingIdentifier
                        | assignmentPattern
                        | coverParenthesizedExpressionAndArrowParameterList
                        ;
conciseBody             : assignmentExpression // TODO [lookahead ≠ { ] AssignmentExpression[?In]
                        | BRACKET_LEFT_CURLY functionBody BRACKET_RIGHT_CURLY
                        ;

// 14.3 Method Definitions
methodDefinition        : propertyName BRACKET_LEFT_PAREN strictFormalParameters BRACKET_RIGHT_PAREN BRACKET_LEFT_CURLY functionBody BRACKET_RIGHT_CURLY
                        | generatorMethod
                        | getterPrefix propertyName BRACKET_LEFT_PAREN BRACKET_RIGHT_PAREN BRACKET_LEFT_CURLY functionBody BRACKET_RIGHT_CURLY
                        | setterPrefix propertyName BRACKET_LEFT_PAREN propertySetParameterList BRACKET_RIGHT_PAREN BRACKET_LEFT_CURLY functionBody BRACKET_RIGHT_CURLY
                        ;
getterPrefix            : {"get".equals(_input.LT(1).getText())}? IDENTIFIER
                        ;
setterPrefix            : {"set".equals(_input.LT(1).getText())}? IDENTIFIER
                        ;
propertySetParameterList: formalParameter
                        ;

// 14.4 Generator Function Definitions
generatorMethod         : PUNCTUATOR_MULTIPLICATION propertyName BRACKET_LEFT_PAREN strictFormalParameters BRACKET_RIGHT_PAREN BRACKET_LEFT_CURLY functionBody BRACKET_RIGHT_CURLY
                        ;    
generatorDeclaration    : KEYWORD_FUNCTION PUNCTUATOR_MULTIPLICATION bindingIdentifier? BRACKET_LEFT_PAREN formalParameters BRACKET_RIGHT_PAREN BRACKET_LEFT_CURLY functionBody BRACKET_RIGHT_CURLY
//                        | KEYWORD_FUNCTION PUNCTUATOR_MULTIPLICATION BRACKET_LEFT_PAREN formalParameters BRACKET_RIGHT_PAREN BRACKET_LEFT_CURLY generatorBody BRACKET_RIGHT_CURLY
                        ;
//generatorExpression     : KEYWORD_FUNCTION PUNCTUATOR_MULTIPLICATION bindingIdentifier? BRACKET_LEFT_PAREN formalParameters BRACKET_RIGHT_PAREN BRACKET_LEFT_CURLY generatorBody BRACKET_RIGHT_CURLY
//                        ;
//generatorBody           : functionBody
//                        ;
yieldExpression         : KEYWORD_YIELD
                        | KEYWORD_YIELD assignmentExpression                            // TODO yield [no LineTerminator here] AssignmentExpression
                        | KEYWORD_YIELD PUNCTUATOR_MULTIPLICATION assignmentExpression // TODO yield [no LineTerminator here] * AssignmentExpression
                        ;

// 14.5 Class Definitions
classDeclaration        : KEYWORD_CLASS id=bindingIdentifier? (KEYWORD_EXTENDS extend=leftHandSideExpression)? BRACKET_LEFT_CURLY classBody? BRACKET_RIGHT_CURLY
                        //| KEYWORD_CLASS classTail
                        ;
//classExpression         : KEYWORD_CLASS bindingIdentifier? classTail
//                        ;
//classTail               : classHeritage? BRACKET_LEFT_CURLY classBody? BRACKET_RIGHT_CURLY
//                        ;
//classHeritage           : KEYWORD_EXTENDS singleExpression
//                        ;
classBody               : classElement+
                        ;
//classElementList        : classElement
///                        | classElementList classElement
//                        ;
classElement            : methodDefinition
                        | RESERVED_STATIC methodDefinition
                        | emptyStatement
                        ;

// 15.1 Scripts
//script                  : scriptBody?
//script                  : statementList+
//                        ;
//scriptBody              : statementList
//                        ;

// 15.2 Modules
//module                  : moduleItem* // moduleBody?
//                        ;
//moduleBody              : moduleItem+
//                        ;
//moduleItemList          : moduleItem 
//                        | moduleItemList moduleItem
//                        ;
//moduleItem              : importDeclaration
//                        | exportDeclaration
//                        | statement 
//                        | declaration
//                        ;

program                 : sourceElements? EOF
                        ;

sourceElements          : sourceElement+
                        ;

sourceElement           : statement
                        | declaration
                        | importDeclaration
                        | exportDeclaration
                        ;

// 15.2.2 Imports
importDeclaration       : KEYWORD_IMPORT importClause fromClause PUNCTUATOR_SEMICOLON
                        | KEYWORD_IMPORT moduleSpecifier PUNCTUATOR_SEMICOLON
                        ;
importClause            : importedDefaultBinding
                        | nameSpaceImport
                        | namedImports
                        | importedDefaultBinding PUNCTUATOR_COMMA nameSpaceImport
                        | importedDefaultBinding PUNCTUATOR_COMMA namedImports
                        ;
importedDefaultBinding  : importedBinding
                        ;
nameSpaceImport         : PUNCTUATOR_MULTIPLICATION RESERVED_AS importedBinding
                        ;
namedImports            : BRACKET_LEFT_CURLY BRACKET_RIGHT_CURLY
                        | BRACKET_LEFT_CURLY importsList BRACKET_RIGHT_CURLY
                        | BRACKET_LEFT_CURLY importsList PUNCTUATOR_COMMA BRACKET_RIGHT_CURLY
                        ;
fromClause              : RESERVED_FROM moduleSpecifier
                        ;
importsList             : importSpecifier (PUNCTUATOR_COMMA importSpecifier)*
                        //| importsList PUNCTUATOR_COMMA importSpecifier
                        ;
importSpecifier         : importedBinding
                        | IDENTIFIER RESERVED_AS importedBinding
                        ;
moduleSpecifier         : STRING
                        ;
importedBinding         : bindingIdentifier
                        ;

// 15.2.3 Exports
exportDeclaration       : KEYWORD_EXPORT PUNCTUATOR_MULTIPLICATION fromClause PUNCTUATOR_SEMICOLON
                        | KEYWORD_EXPORT exportClause fromClause PUNCTUATOR_SEMICOLON
                        | KEYWORD_EXPORT exportClause PUNCTUATOR_SEMICOLON
                        | KEYWORD_EXPORT variableStatement
                        | KEYWORD_EXPORT declaration
                        | KEYWORD_EXPORT KEYWORD_DEFAULT hoistableDeclaration
                        | KEYWORD_EXPORT KEYWORD_DEFAULT classDeclaration
                        | KEYWORD_EXPORT KEYWORD_DEFAULT assignmentExpression PUNCTUATOR_SEMICOLON// TODO export default [lookahead ∉ {function, class}] AssignmentExpression[In] ;
                        ;
exportClause            : BRACKET_LEFT_CURLY BRACKET_RIGHT_CURLY
                        | BRACKET_LEFT_CURLY exportsList BRACKET_RIGHT_CURLY
                        | BRACKET_LEFT_CURLY exportsList PUNCTUATOR_COMMA BRACKET_RIGHT_CURLY
                        ;
exportsList             : exportSpecifier (PUNCTUATOR_COMMA exportSpecifier)*
                        // | exportsList PUNCTUATOR_COMMA exportSpecifier
                        ;
exportSpecifier         : (IDENTIFIER | KEYWORD_DEFAULT)  (RESERVED_AS (IDENTIFIER | KEYWORD_DEFAULT))?
//                        | IDENTIFIER RESERVED_AS IDENTIFIER
                        ;

// Redefine some lexer tokens to be hidden for parser

// 11.2 Whitespaces
WHITESPACE          : [\u0009\u000B\u000C\u0020\u00A0\uFEFF]+ -> skip;

// 11.3 Line Terminators
EOL                 : [\r\n\u2028\u2029] -> channel(HIDDEN);

/// 11.4 Comments
COMMENT_LINE          : '//' ~[\r\n\u2028\u2029]* -> skip;
COMMENT_DOC           : '/**' .*? '*/' -> skip;
COMMENT_BLOCK         : '/*' .*? '*/' -> skip;



reservedKeyword                     : RESERVED_ENUM 
                                    | RESERVED_AWAIT 
                                    | RESERVED_IMPLEMENTS 
                                    | RESERVED_PACKAGE 
                                    | RESERVED_PROTECTED
                                    | RESERVED_INTERFACE 
                                    | RESERVED_PRIVATE 
                                    | RESERVED_PUBLIC
                                    | RESERVED_STATIC
                                    | RESERVED_LET
                                    | RESERVED_AS
                                    | RESERVED_FROM
                                    ;
eos
                                    : PUNCTUATOR_SEMICOLON
                                    | EOF
                                    | {_input.LA(1) == BRACKET_RIGHT_CURLY || _input.LA(1) == BRACKET_LEFT_CURLY || lineTerminatorAhead()}?
                                    ;