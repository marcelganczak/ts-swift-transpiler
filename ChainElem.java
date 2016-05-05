import org.antlr.v4.runtime.ParserRuleContext;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;

public class ChainElem {
    public String code;
    public String accessorType;
    public AbstractType type;
    public String functionCallParams;
    public ChainElem(String code, String accessorType, AbstractType type, String functionCallParams) { this.code = code; this.accessorType = accessorType; this.type = type; this.functionCallParams = functionCallParams; }
    
    static public ChainElem get(ParserRuleContext rChild, AbstractType declaredType, SwiftParser.Function_call_expressionContext functionCall, List<SwiftParser.Expression_elementContext> functionCallParams, SwiftParser.Prefix_expressionContext ctx, ArrayList<ParserRuleContext> chain, int chainPos, AbstractType lType, TranspilerVisitor visitor) {

        if(chainPos == 0 && WalkerUtil.isDirectDescendant(SwiftParser.Parenthesized_expressionContext.class, rChild)) {
            return getTuple(rChild, declaredType, visitor);
        }
        else if(chainPos == 0 && WalkerUtil.isDirectDescendant(SwiftParser.Array_literalContext.class, rChild)) {
            return getConstructor(rChild, functionCall, functionCallParams, declaredType, visitor);
        }
        else if(chainPos == 0 && rChild instanceof SwiftParser.Primary_expressionContext && ((SwiftParser.Primary_expressionContext) rChild).generic_argument_clause() != null) {
            return getTemplatedConstructor(rChild, functionCall, functionCallParams, declaredType, visitor);
        }
        else {
            return getBasic(rChild, functionCall, functionCallParams, chain, chainPos, lType, visitor);
        }
    }

    static private ChainElem getTuple(ParserRuleContext rChild, AbstractType tupleType, TranspilerVisitor visitor) {

        SwiftParser.Expression_element_listContext tupleLiteral = ((SwiftParser.Primary_expressionContext) rChild).parenthesized_expression().expression_element_list();
        List<SwiftParser.Expression_elementContext> elementList = tupleLiteral.expression_element();
        String code = "";
        LinkedHashMap<String, AbstractType> types = new LinkedHashMap<String, AbstractType>();

        ArrayList<String> keys = null;
        if(tupleType != null) {
            if(tupleType instanceof NestedByIndexType) keys = ((NestedByIndexType) tupleType).keys();
        }

        code += "{";
        for(int i = 0; i < elementList.size(); i++) {
            String key = keys != null ? keys.get(i) : elementList.get(i).identifier() != null ? elementList.get(i).identifier().getText() : i + "':";
            String val = visitor.visit(elementList.get(i).expression());
            if(i > 0) code += ",";
            code += "'" + key + "':" + val;
        }
        code += "}";

        for(int i = 0, elementI = 0; i < tupleLiteral.getChildCount(); i++) {
            if(!(tupleLiteral.getChild(i) instanceof SwiftParser.Expression_elementContext)) continue;
            SwiftParser.Expression_elementContext child = (SwiftParser.Expression_elementContext) tupleLiteral.getChild(i);
            String index = child.identifier() != null ? child.identifier().getText() : Integer.toString(elementI);
            if(tupleType == null) types.put(index, Type.infer(child.expression(), visitor));
            elementI++;
        }

        return new ChainElem(code, "", tupleType == null ? new NestedByIndexType(types) : tupleType, null);
    }

    static private ChainElem getConstructor(ParserRuleContext rChild, SwiftParser.Function_call_expressionContext functionCall, List<SwiftParser.Expression_elementContext> functionCallParams, AbstractType arrayType, TranspilerVisitor visitor) {

        SwiftParser.Array_literalContext arrayLiteral = ((SwiftParser.Primary_expressionContext) rChild).literal_expression().array_literal();

        if(arrayType == null) {
            AbstractType wrappedType = Type.infer(arrayLiteral.array_literal_items().array_literal_item(0).expression(), visitor);
            arrayType = new NestedType("Array", new BasicType("Int"), wrappedType);
        }

        String code;
        if(functionCall != null) {
            String arraySize = "", fill = "";
            if(functionCallParams != null) {
                if(functionCallParams.size() == 2 && functionCallParams.get(0).identifier().getText().equals("count") && functionCallParams.get(1).identifier().getText().equals("repeatedValue")) {
                    arraySize = visitor.visit(functionCallParams.get(0).expression());
                    fill = ".fill(" + visitor.visit(functionCallParams.get(1).expression()) + ")";
                }
            }
            code = "new Array(" + arraySize + ")" + fill;
        }
        else {
            code = visitor.visit(rChild);
        }

        return new ChainElem(code, "", arrayType, null);
    }

    static private ChainElem getTemplatedConstructor(ParserRuleContext rChild, SwiftParser.Function_call_expressionContext functionCall, List<SwiftParser.Expression_elementContext> functionCallParams, AbstractType type, TranspilerVisitor visitor) {

        SwiftParser.Generic_argument_clauseContext template = ((SwiftParser.Primary_expressionContext) rChild).generic_argument_clause();
        String typeStr = visitor.visit(rChild.getChild(0)).trim();

        if(typeStr.equals("Set")) {
            if(type == null) type = new NestedType("Set", new BasicType("Int"), new BasicType(template.generic_argument_list().generic_argument(0).getText()));
            return new ChainElem("new " + type.jsType() + "()", "", type, null);
        }

        return null;
    }

    static private ChainElem getBasic(ParserRuleContext rChild, SwiftParser.Function_call_expressionContext functionCall, List<SwiftParser.Expression_elementContext> functionCallParams, ArrayList<ParserRuleContext> chain, int chainPos, AbstractType lType, TranspilerVisitor visitor) {
        String identifier = null, accessorType = ".", LR = null, functionCallParamsStr = null;
        if(rChild instanceof SwiftParser.Explicit_member_expressionContext) {
            identifier = ((SwiftParser.Explicit_member_expressionContext) rChild).identifier().getText();
            accessorType = ".";
        }
        else if(rChild instanceof SwiftParser.Primary_expressionContext) {
            identifier = ((SwiftParser.Primary_expressionContext) rChild).identifier() != null ? ((SwiftParser.Primary_expressionContext) rChild).identifier().getText() : visitor.visit(rChild);
            accessorType = ".";
        }
        else if(rChild instanceof SwiftParser.Subscript_expressionContext) {
            identifier = visitor.visit(((SwiftParser.Subscript_expressionContext) rChild).expression_list());
            accessorType = "[]";
        }
        else if(rChild instanceof SwiftParser.Explicit_member_expression_numberContext) {
            identifier = visitor.visitWithoutStrings(rChild, ".");
            accessorType = "[]";
        }
        else if(rChild instanceof SwiftParser.Explicit_member_expression_number_doubleContext) {
            String[] split = visitor.visit(rChild).split("\\.");
            int pos = 1, i = chainPos;
            while(i > 0 && chain.get(i - 1) instanceof SwiftParser.Explicit_member_expression_number_doubleContext) {i--; pos = pos == 1 ? 2 : 1;}
            identifier = split[pos];
            accessorType = "[]";
        }
        else {
            identifier = visitor.visit(rChild);
        }

        ChainElem replacement = ChainElem.replacement(lType, identifier);
        if(replacement != null) {
            identifier = replacement.code;
            accessorType = replacement.accessorType;
        }

        if(identifier.equals("println") && chainPos == 0) identifier = "console.log";

        if(replacement == null && functionCall != null) {
            identifier = visitor.functionNameWithExternalParams(identifier, functionCall.parenthesized_expression().expression_element_list().expression_element());
            functionCallParamsStr = visitor.visitWithoutStrings(functionCall.parenthesized_expression(), "()");
        }

        return new ChainElem(identifier, accessorType, null, functionCallParamsStr);
    }

    static private ChainElem replacement(AbstractType lType, String R) {
        if(R == null) return null;
        if(lType != null && lType.swiftType().equals("Dictionary")) {
            if(R.equals("count")) {
                return new ChainElem("size", "_.()", new BasicType("Int"), null);
            }
            if(R.equals("updateValue")) {
                return new ChainElem("updateValue", "_.()", new BasicType("Void"), null);
            }
        }
        if(lType != null && lType.swiftType().equals("Array")) {
            if(R.equals("count")) {
                return new ChainElem("length", ".", new BasicType("Int"), null);
            }
        }
        return null;
    }
}