import org.antlr.v4.runtime.ParserRuleContext;

import java.util.ArrayList;

public class CacheVisitor extends Visitor {

    public CacheVisitor(EntityCache cache) {
        super();
        this.cache = cache;
    }

    @Override public String visitVariableDeclaration(ECMAScriptParser.VariableDeclarationContext ctx) {
        String varName = ctx.Identifier().getText();
        AbstractType varType =
                ctx.typeAnnotation() != null && ctx.typeAnnotation().type() != null ? Type.fromDefinition(ctx.typeAnnotation().type())
                : Type.infer(ctx.initialiser().expression(), this);
        cache.cacheOne(varName, varType, ctx);
        return null;
    }

    @Override public String visitArrow_function(ECMAScriptParser.Arrow_functionContext ctx) {
        FunctionType functionType = new FunctionType(ctx, this);
        //cache.cacheOne(ctx.functionSignature().IDENT().getText(), functionType, ctx);

        ArrayList<String> parameterLocalNames = FunctionUtil.parameterLocalNames(ctx.arrowFunctionHead().formalParameterList().formalParameter());
        for(int i = 0; i < parameterLocalNames.size(); i++) {
            cache.cacheOne(parameterLocalNames.get(i), functionType.parameterTypes.get(i), ctx.conciseBody());
        }

        visit(ctx.conciseBody());

        return null;
    }

    /*@Override public String visitFor_in_statement(SwiftParser.For_in_statementContext ctx) {

        if(ctx.expression() != null && ctx.expression().binary_expressions() != null) {
            String varName = ctx.pattern().getText().equals("_") ? "$" : ctx.pattern().getText();
            cache.cacheOne(varName, new BasicType("Int"), ctx.code_block());
        }
        else {
            Expression iteratedObject = new Expression(ctx.expression(), null, this);
            AbstractType iteratedType = iteratedObject.type;
            String indexVar = "$", valueVar;
            if(ctx.pattern().tuple_pattern() != null) {
                indexVar = ctx.pattern().tuple_pattern().tuple_pattern_element_list().tuple_pattern_element(0).getText();
                valueVar = ctx.pattern().tuple_pattern().tuple_pattern_element_list().tuple_pattern_element(1).getText();
            }
            else {
                valueVar = ctx.pattern().identifier_pattern().getText();
            }
            cache.cacheOne(indexVar, iteratedType.swiftType().equals("String") ? new BasicType("Int"): ((NestedType)iteratedType).keyType, ctx.code_block());
            cache.cacheOne(valueVar, iteratedType.swiftType().equals("String") ? new BasicType("String"): ((NestedType)iteratedType).valueType, ctx.code_block());
        }

        visit(ctx.code_block());

        return null;
    }

    private void cacheIfLet(ParserRuleContext ctx, SwiftParser.Code_blockContext codeBlock) {
        IfLet ifLet = new IfLet(ctx, this);
        for(int i = 0; i < ifLet.varNames.size(); i++) {
            cache.cacheOne(ifLet.varNames.get(i), ifLet.varTypes.get(i), codeBlock);
        }
        visit(codeBlock);
    }

    @Override public String visitIf_statement(SwiftParser.If_statementContext ctx) {
        cacheIfLet(ctx, ctx.code_block());
        if(ctx.else_clause() != null) visit(ctx.else_clause());
        return null;
    }

    @Override public String visitGuard_statement(SwiftParser.Guard_statementContext ctx) {
        cacheIfLet(ctx, ctx.code_block());
        return null;
    }*/
}
