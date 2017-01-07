import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ParseTree;

import java.util.*;

public class PrefixElem {
    public String code;
    public String accessor;
    public AbstractType type;
    public String functionCallParams;
    public boolean isOptional;
    public PrefixElem(String code, String accessor, AbstractType type, String functionCallParams) { this.code = code; this.accessor = accessor; this.type = type; this.functionCallParams = functionCallParams; this.isOptional = false; }

    static public PrefixElem get(ParserRuleContext rChild, List<ParserRuleContext/*Expression_elementContext or Closure_expressionContext*/> functionCallParams, ArrayList<ParserRuleContext> chain, int chainPos, AbstractType lType, AbstractType rType, Visitor visitor) {

        if(chainPos == 0 && WalkerUtil.isDirectDescendant(ECMAScriptParser.Parenthesized_expressionContext.class, rChild)) {
            Expression parenthesized = new Expression(((ECMAScriptParser.Primary_expressionContext) rChild).parenthesized_expression().expression_list().expression(0), rType, visitor);
            return new PrefixElem("(" + parenthesized.code + ")", "", parenthesized.type, null);
        }
        if(chainPos == 0 && WalkerUtil.isDirectDescendant(ECMAScriptParser.Array_literalContext.class, rChild)) {
            return getArray(rChild, rType, functionCallParams, visitor);
        }
        if(chainPos == 0 && WalkerUtil.isDirectDescendant(ECMAScriptParser.Object_literalContext.class, rChild)) {
            return getObject(rChild, rType, functionCallParams, visitor);
        }
        if(chainPos == 0 && WalkerUtil.isDirectDescendant(ECMAScriptParser.LiteralContext.class, rChild)) {
            return getLiteral(rChild, rType, visitor);
        }
        if(chainPos == 0 && WalkerUtil.isDirectDescendant(ECMAScriptParser.Closure_expressionContext.class, rChild)) {
            return getClosure(rChild, rType, visitor);
        }
        return getBasic(rChild, functionCallParams, chain, chainPos, lType, rType, visitor);
    }

    static private PrefixElem getArray(ParserRuleContext rChild, AbstractType type, List<ParserRuleContext/*Expression_elementContext or Closure_expressionContext*/> functionCallParams, Visitor visitor) {

        ECMAScriptParser.Array_literalContext arrayLiteral = ((ECMAScriptParser.Is_array_literalContext)((ECMAScriptParser.Primary_expressionContext) rChild).literal()).array_literal();

        if(arrayLiteral.elementList() != null) {
            ECMAScriptParser.ExpressionContext wrappedExpression = arrayLiteral.elementList().expression(0);
            AbstractType wrappedType = functionCallParams != null ? new BasicType(wrappedExpression.getText()) : null;//Type.infer(wrappedExpression, visitor);
            //if(type == null) type = new NestedType("Array", new BasicType("Int"), wrappedType, false);
        }

        String code;
        if(functionCallParams != null) {
            /*String arraySize = "", fill = "";
            if(functionCallParams != null) {
                if(functionCallParams.size() == 2 && functionCallParams.get(0) instanceof ECMAScriptParser.Expression_elementContext && ((ECMAScriptParser.Expression_elementContext) functionCallParams.get(0)).identifier().getText().equals("count") && functionCallParams.get(1) instanceof ECMAScriptParser.Expression_elementContext && ((ECMAScriptParser.Expression_elementContext) functionCallParams.get(1)).identifier().getText().equals("repeatedValue")) {
                    arraySize = visitor.visit(((ECMAScriptParser.Expression_elementContext) functionCallParams.get(0)).expression());
                    fill = ".fill(" + visitor.visit(((ECMAScriptParser.Expression_elementContext) functionCallParams.get(1)).expression()) + ")";
                }
            }
            code = "new Array(" + arraySize + ")" + fill;*/
            code = "TODO";
        }
        else {
            code = visitor.visit(rChild);
            if(type != null && type.swiftType().equals("Set")) code = "new Set(" + code + ")";
        }

        return new PrefixElem(code, "", type, null);
    }

    static private PrefixElem getObject(ParserRuleContext rChild, AbstractType type, List<ParserRuleContext/*Expression_elementContext or Closure_expressionContext*/> functionCallParams, Visitor visitor) {

        ECMAScriptParser.Object_literalContext objectLiteral = ((ECMAScriptParser.Is_object_literalContext)((ECMAScriptParser.Primary_expressionContext) rChild).literal()).object_literal();
        String code;
        List<String> identifiers = null;
        List<AbstractType> valTypes = null;

        ECMAScriptParser.PropertyNameAndValueListContext assignment = objectLiteral.propertyNameAndValueList();
        if(assignment != null) {
            identifiers = new ArrayList<String>();
            valTypes = new ArrayList<AbstractType>();
            for(int i = 0; i < assignment.propertyAssignment().size(); i++) {
                ECMAScriptParser.PropertyExpressionAssignmentContext keyVal = (ECMAScriptParser.PropertyExpressionAssignmentContext)assignment.propertyAssignment().get(i);
                String identifier = keyVal.propertyName().getText();
                boolean removeQuotes = keyVal.propertyName().StringLiteral() != null;
                if(removeQuotes) identifier = identifier.substring(1, identifier.length() - 1);
                identifiers.add(identifier);
                valTypes.add(Type.infer(keyVal.expression(), visitor));
            }
        }

        if(type == null && identifiers != null) {
            HashMap<String, AbstractType> map = new LinkedHashMap<String, AbstractType>();
            boolean allTypesAreTheSame = true;
            String firstType = null;
            for(int i = 0; i < identifiers.size(); i++) {
                map.put(identifiers.get(i), valTypes.get(i));
                if(i == 0) firstType = valTypes.get(i).swiftType();
                else if(!firstType.equals(valTypes.get(i).swiftType())) allTypesAreTheSame = false;
            }
            boolean isTuple = !allTypesAreTheSame;
            if(isTuple) {
                type = new NestedByIndexType(map);
            }
            else {
                type = new NestedType("Object", new BasicType("string"), valTypes.get(0));
            }
        }

        code = "";
        boolean isTuple = type instanceof NestedByIndexType;
        if(identifiers != null) {
            for(int i = 0; i < identifiers.size(); i++) {
                code += (code.length() > 0 ? ", " : isTuple ? "(" : "[") + (!isTuple ? "\"" : "") + identifiers.get(i) + (!isTuple ? "\"" : "") + ": " + visitor.visit(((ECMAScriptParser.PropertyExpressionAssignmentContext)assignment.propertyAssignment().get(i)).expression());
            }
        }
        if(code.length() == 0) code += isTuple ? "(" : "[";
        code += isTuple ? ")" : "]";

        return new PrefixElem(code, "", type, null);
    }

    static private PrefixElem getLiteral(ParserRuleContext rChild, AbstractType type, Visitor visitor) {
        String code = visitor.visit(rChild);
        if(WalkerUtil.isDirectDescendant(ECMAScriptParser.Null_literalContext.class, rChild)) {
            type = new BasicType("void");
            code = "null ";
        }
        else if(type == null) {
            if(WalkerUtil.isDirectDescendant(ECMAScriptParser.Numeric_literalContext.class, rChild)) type = new BasicType("number");
            else if(WalkerUtil.isDirectDescendant(ECMAScriptParser.String_literalContext.class, rChild)) type = new BasicType("string");
            else if(WalkerUtil.isDirectDescendant(ECMAScriptParser.Boolean_literalContext.class, rChild)) type = new BasicType("boolean");
        }
        return new PrefixElem(code, "", type, null);
    }

    static private PrefixElem getClosure(ParserRuleContext rChild, AbstractType type, Visitor visitor) {
        //return new PrefixElem(FunctionUtil.closureExpression(((ECMAScriptParser.Primary_expressionContext) rChild).closure_expression(), (FunctionType)type, visitor), "", type, null);
        return null;
    }

    static private PrefixElem getBasic(ParserRuleContext rChild, List<ParserRuleContext/*Expression_elementContext or Closure_expressionContext*/> functionCallParams, ArrayList<ParserRuleContext> chain, int chainPos, AbstractType lType, AbstractType rType, Visitor visitor) {
        String code = null, accessor = ".", functionCallParamsStr = null;
        AbstractType type = null;
        if(rChild instanceof ECMAScriptParser.Explicit_member_expressionContext) {
            code = ((ECMAScriptParser.Explicit_member_expressionContext) rChild).Identifier().getText();
            accessor = ".";
        }
        else if(rChild instanceof ECMAScriptParser.Primary_expressionContext) {
            code = ((ECMAScriptParser.Primary_expressionContext) rChild).Identifier() != null ? ((ECMAScriptParser.Primary_expressionContext) rChild).Identifier().getText() : visitor.visit(rChild);
            accessor = ".";
        }
        else if(rChild instanceof ECMAScriptParser.Subscript_expressionContext) {
            code = visitor.visit(((ECMAScriptParser.Subscript_expressionContext) rChild).expression_list());
            accessor = "[]";
        }
        else {
            code = visitor.visit(rChild);
        }

        if(lType != null && (lType.tsType().equals("Object"))) {
            accessor = "[]";
            boolean keyIsLiteral = rChild instanceof ECMAScriptParser.Explicit_member_expressionContext || WalkerUtil.isDirectDescendant(ECMAScriptParser.LiteralContext.class, rChild);
            if(keyIsLiteral) code = "\"" + code + "\"";
        }

        if(functionCallParams != null) {
            //code = FunctionUtil.nameFromCall(code, functionCallParams, rChild, visitor);
            functionCallParamsStr = "";
            for(int i = 0; i < functionCallParams.size(); i++) functionCallParamsStr += (i > 0 ? ", " : "") + visitor.visit(functionCallParams.get(i));
        }
        /*else if(rType instanceof FunctionType) {
            code = FunctionUtil.nameFromCall(code, (FunctionType)rType, rChild, visitor);
        }*/

        if(type == null) {
            type = Type.resulting(lType, code, chain.get(0), visitor);
            //if(functionCallParams != null && type instanceof FunctionType) type = type.resulting("()");
        }

        /*if(WalkerUtil.isDirectDescendant(ECMAScriptParser.Implicit_parameterContext.class, rChild)) {
            code = "arguments[" + code.substring(1) + "]";
        }*/

        return new PrefixElem(code, accessor, type, functionCallParamsStr);
    }
}
