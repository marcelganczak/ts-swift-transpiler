public class TranspilerVisitor extends Visitor {

    public TranspilerVisitor(EntityCache cache) {
        super();
        this.cache = cache;
    }

    @Override public String visitStatement(ECMAScriptParser.StatementContext ctx) {
        return visitChildren(ctx) + "\n";
    }

    /*@Override public String visitType(ECMAScriptParser.TypeContext ctx) {
        return Type.fromDefinition(ctx).swiftType();
    }*/

    /*@Override public String visitFor_in_statement(ECMAScriptParser.For_in_statementContext ctx) {
        return ControlFlow.forIn(ctx, this);
    }

    @Override public String visitWhile_statement(ECMAScriptParser.While_statementContext ctx) {
        return ControlFlow.whileRepeat(ctx, this);
    }

    @Override public String visitRepeat_while_statement(ECMAScriptParser.Repeat_while_statementContext ctx) {
        return ControlFlow.repeatWhile(ctx, this);
    }

    @Override public String visitIf_statement(ECMAScriptParser.If_statementContext ctx) {
        return ControlFlow.ifThen(ctx, this);
    }

    @Override public String visitGuard_statement(ECMAScriptParser.Guard_statementContext ctx) {
        return ControlFlow.guard(ctx, this);
    }

    @Override public String visitFunction_declaration(ECMAScriptParser.Function_declarationContext ctx) {
        return FunctionUtil.functionDeclaration(ctx, this);
    }*/

    @Override public String visitExpression(ECMAScriptParser.ExpressionContext ctx) {
        return new Expression(ctx, null, this).code;
    }

    /*@Override public String visitPattern_initializer(ECMAScriptParser.Pattern_initializerContext ctx) {
        return AssignmentUtil.handleInitializer(ctx, this);
    }

    @Override public String visitExpression_element(ECMAScriptParser.Expression_elementContext ctx) {
        return visit(ctx.expression());
    }

    @Override public String visitParameter(ECMAScriptParser.ParameterContext ctx) {
        if(ctx.range_operator() == null) return visitChildren(ctx);
        return visit(ctx.range_operator()) + visitWithoutClasses(ctx, ECMAScriptParser.Range_operatorContext.class);
    }

    @Override public String visitDictionary_literal_item(ECMAScriptParser.Dictionary_literal_itemContext ctx) {
        boolean keyIsLiteral = WalkerUtil.isDirectDescendant(ECMAScriptParser.LiteralContext.class, ctx.expression(0));
        return (keyIsLiteral ? "" : "[") + visit(ctx.expression(0)) + (keyIsLiteral ? "" : "]") + ":" + visit(ctx.expression(1));
    }

    @Override public String visitExternal_parameter_name(ECMAScriptParser.External_parameter_nameContext ctx) {
        return "";
    }*/

    @Override public String visitNumeric_literal(ECMAScriptParser.Numeric_literalContext ctx) {
        return visitChildren(ctx).trim() + ".0";
    }
}
