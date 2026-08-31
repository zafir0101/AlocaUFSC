package alocaufsc.domain.calculadora;

public class Calculator {

    public static Float sum(float num1, float num2) {
        return num1 + num2;
    }

    public static Float minus(float num1, float num2) {
        return num1 - num2;
    }

    public static Float times(float num1, float num2) {
        return num1 * num2;
    }

    public static Float div(float num1, float num2) throws ArithmeticException {
       return num2 != 0 ? num1 / num2 : null;
    }
}