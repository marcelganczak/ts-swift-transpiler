import org.antlr.v4.runtime.tree.ParseTree;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;

class BasicType extends AbstractType {
    private String tsType;
    public BasicType(String tsType) {
        this.tsType = tsType;
    }
    public String tsType() {
        return tsType;
    }
    public String swiftType() {
        return Type.basicToSwift(tsType);
    }
    public AbstractType resulting(String accessor) {
        return null;
    }
    public AbstractType copy() {
        return new BasicType(this.tsType);
    }
}
class FunctionType extends AbstractType {
    public List<AbstractType> parameterTypes;
    public int numParametersWithDefaultValue;
    public AbstractType returnType;
    public FunctionType(ECMAScriptParser.Arrow_functionContext ctx, Visitor visitor) {
        List<ECMAScriptParser.FormalParameterContext> parameters = ctx.arrowFunctionHead().formalParameterList().formalParameter();
        parameterTypes = new ArrayList<AbstractType>();
        for(int i = 0; i < parameters.size(); i++) {
            parameterTypes.add(Type.fromDefinition(parameters.get(i).typeAnnotation().type()));
        }
        returnType = new BasicType(ctx.typeAnnotation().type().getText());
        numParametersWithDefaultValue = 0;
    }
    public FunctionType(List<AbstractType> parameterTypes, int numParametersWithDefaultValue, AbstractType returnType) {
        this.parameterTypes = parameterTypes;
        this.numParametersWithDefaultValue = numParametersWithDefaultValue;
        this.returnType = returnType;
    }
    public String tsType() {
        return "Function";
    }
    public String swiftType() {
        return "Function";
    }
    public AbstractType resulting(String accessor) {
        return returnType;
    }
    public AbstractType copy() {
        return new FunctionType(this.parameterTypes, this.numParametersWithDefaultValue, this.returnType);
    }
    /*public boolean sameAs(FunctionType otherType) {
        if(parameterTypes.size() != otherType.parameterTypes.size()) return false;
        if(!returnType.swiftType().equals(otherType.returnType.swiftType())) return false;
        for(int i = 0; i < parameterTypes.size(); i++) if(!parameterTypes.get(i).swiftType().equals(otherType.parameterTypes.get(i).swiftType())) return false;
        return true;
    }*/
}
class NestedType extends AbstractType {
    private String wrapperType;//array/Object
    public AbstractType keyType;
    public AbstractType valueType;
    public NestedType(String wrapperType, AbstractType keyType, AbstractType valueType) {
        this.wrapperType = wrapperType;
        this.keyType = keyType;
        this.valueType = valueType;
    }
    public String tsType() {
        return wrapperType;
    }
    public String swiftType() {
        return wrapperType.equals("Object") ? "[" + keyType.swiftType() + ":" + valueType.swiftType() + "]" : "[" + valueType.swiftType() + "]";
    }
    public AbstractType resulting(String accessor) {
        return valueType;
    }
    public AbstractType copy() {
        return new NestedType(this.wrapperType, this.keyType, this.valueType);
    }
}
class NestedByIndexType extends AbstractType {
    private HashMap<String, AbstractType> swiftType;
    public NestedByIndexType(HashMap<String, AbstractType> swiftType) {
        this.swiftType = swiftType;
    }
    public ArrayList<String> keys() {
        return new ArrayList<String>(swiftType.keySet());
    }
    public String swiftType() {
        return "Tuple";
    }
    public String tsType() {
        return "any";
    }
    public AbstractType resulting(String accessor) {
        return swiftType.get(accessor);
    }
    public AbstractType copy() {
        return new NestedByIndexType(this.swiftType);
    }
}

public class Type {

    public static String basicToSwift(String swiftType) {
        if (swiftType.equals("string")) {
            return "String";
        }
        else if(swiftType.equals("number")) {
            return "Double";
        }
        else if(swiftType.equals("boolean")) {
            return "Bool";
        }
        else if(swiftType.equals("void")) {
            return "Void";
        }
        return null;
    }

    public static AbstractType fromDefinition(ECMAScriptParser.TypeContext ctx) {
        return new BasicType(ctx.getText());
        /*AbstractType type;
        if(ctx.typeLiteral() != null) {
            if(ctx.typeLiteral().objectType() != null) type = fromObjectDefinition(ctx.typeLiteral().objectType());
            else if(ctx.typeLiteral().arrayType() != null) type = fromArrayDefinition(ctx.typeLiteral().arrayType());
            else if(ctx.typeLiteral().tupleType() != null) type = fromTupleDefinition(ctx.typeLiteral().tupleType());
            else if(ctx.typeLiteral().functionType() != null) type = fromFunctionDefinition(ctx.typeLiteral().functionType());
            else if(ctx.typeLiteral().constructorType() != null) type = fromConstructorDefinition(ctx.typeLiteral().constructorType());
            else throw new Error("unknown type literal");
        }
        else if(ctx.typeName() != null) {
            String typeName = ctx.typeName().getText();
            if(typeName.equals("boolean") || typeName.equals("number") || typeName.equals("string")) {
                type = new BasicType(typeName);
            }
            else if(typeName.equals("any")) {
                throw new Error("type 'any' not supported");
            }
            else {
                //TODO work out form class name
                throw new Error("not implemented");
            }
        }
        else throw new Error("unknown type");
        return type;*/
    }

    /*private static AbstractType fromObjectDefinition(ECMAScriptParser.ObjectTypeContext ctx) {
        throw new Error("not implemented");
    }

    private static AbstractType fromArrayDefinition(ECMAScriptParser.ArrayTypeContext ctx) {
        throw new Error("not implemented");
    }

    private static AbstractType fromTupleDefinition(ECMAScriptParser.TupleTypeContext ctx) {
        throw new Error("not implemented");
    }

    private static AbstractType fromFunctionDefinition(ECMAScriptParser.FunctionTypeContext ctx) {
        throw new Error("not implemented");
    }

    private static AbstractType fromConstructorDefinition(ECMAScriptParser.ConstructorTypeContext ctx) {
        throw new Error("not implemented");
    }*/

    public static AbstractType infer(ECMAScriptParser.ExpressionContext ctx, Visitor visitor) {
        return new Expression(ctx, null, visitor).type;
    }

    public static AbstractType resulting(AbstractType lType, String accessor, ParseTree ctx, Visitor visitor) {
        if(accessor == null) return null;
        if(lType == null) return visitor.cache.getType(accessor, ctx);
        return lType.resulting(accessor);
    }

    public static AbstractType alternative(PrefixOrExpression L, PrefixOrExpression R) {
        if(L.type().tsType().equals(R.type().tsType())) return L.type();
        if(L.type().tsType().equals("Void")) {
            AbstractType rClone = R.type().copy();
            return rClone;
        }
        if(R.type().tsType().equals("Void")) {
            AbstractType lClone = L.type().copy();
            return lClone;
        }
        System.out.println("//Ambiguous return type: " + L.type().tsType() + " || " + R.type().tsType());
        return L.type();
    }
}
