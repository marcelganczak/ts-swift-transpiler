import org.antlr.v4.runtime.ParserRuleContext;

import java.util.ArrayList;
import java.util.List;

public class Expression implements PrefixOrExpression {

    String code;
    AbstractType type;
    ParserRuleContext originalCtx;
    public String code() {return code;}
    public AbstractType type() {return type;}
    public ParserRuleContext originalCtx() {return originalCtx;}

    public Expression(ECMAScriptParser.ExpressionContext ctx, AbstractType type, Visitor visitor) {
        this(ctx, type, false, visitor);
    }

    public Expression(ECMAScriptParser.ExpressionContext ctx, AbstractType type, boolean skipFirst, Visitor visitor) {
        originalCtx = ctx;

        if(ctx.closure_expression() != null) {
            this.analyseClosure(ctx.closure_expression(), type, skipFirst, visitor);
            return;
        }

        List<ECMAScriptParser.Binary_expressionContext> binaries = ctx.binary_expressions() != null ? ctx.binary_expressions().binary_expression() : new ArrayList<ECMAScriptParser.Binary_expressionContext>();
        ArrayList<ParserRuleContext> operators = new ArrayList<ParserRuleContext>();
        ArrayList<Object /*ParserRuleContext or BinaryExpression*/> ctxs = new ArrayList<Object>();

        for(int i = -1 + (skipFirst ? 1 : 0); i < binaries.size(); i++) {
            if(skipFirst ? i >= 1 : i >= 0) {
                ECMAScriptParser.Binary_expressionContext binary = binaries.get(i);
                ctxs.add(binary.prefix_expression());
                operators.add(binary.binary_operator() != null ? binary.binary_operator() : binary.conditional_operator());
            }
            else {
                ctxs.add(skipFirst ? binaries.get(0).prefix_expression() : ctx.prefix_expression());
            }
        }

        for(int priority = BinaryExpression.minOperatorPriority; priority <= BinaryExpression.maxOperatorPriority; priority++) {
            for(int i = 0; i < operators.size(); i++) {
                ParserRuleContext operator = operators.get(i);
                if(BinaryExpression.priorityForOperator(operator) != priority) continue;
                Object L = ctxs.get(i);
                Object R = ctxs.get(i + 1);
                BinaryExpression LR = new BinaryExpression(L, R, operator);
                ctxs.remove(i);
                ctxs.remove(i);
                ctxs.add(i, LR);
                operators.remove(i);
                i--;
            }
        }

        if(ctxs.get(0) instanceof ECMAScriptParser.Prefix_expressionContext) {
            Prefix prefix = new Prefix((ECMAScriptParser.Prefix_expressionContext)ctxs.get(0), type, visitor);
            this.code = prefix.code();
            this.type = prefix.type();
        }
        else {
            BinaryExpression top = (BinaryExpression)ctxs.get(0);
            top.compute(type, visitor);
            this.code = top.code;
            this.type = top.type;
        }
    }

    public Expression(String code, AbstractType type) {
        this.code = code;
        this.type = type;
        this.originalCtx = null;
    }

    private void analyseClosure(ECMAScriptParser.Closure_expressionContext closureCtx, AbstractType type, boolean skipFirst, Visitor visitor) {
        ECMAScriptParser.Arrow_functionContext ctx = closureCtx instanceof ECMAScriptParser.Arrow_functionContext ? (ECMAScriptParser.Arrow_functionContext) closureCtx : null;
        if(ctx == null) return;

        FunctionType functionType = new FunctionType(ctx, visitor);
        this.type = functionType;

        ArrayList<String> parameterLocalNames = FunctionUtil.parameterLocalNames(ctx.arrowFunctionHead().formalParameterList().formalParameter());
        String code = "{ (";
        for(int i = 0; i < functionType.parameterTypes.size(); i++) {
            code += (i > 0 ? ", " : "") + parameterLocalNames.get(i) + ":" + functionType.parameterTypes.get(i).swiftType();
        }
        code += ") -> " + functionType.returnType.swiftType();
        code += " in " + visitor.visit(ctx.conciseBody());
        code += " }";

        this.code = code;
    }
}
