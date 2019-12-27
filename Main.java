package com.smartbear.demo;
import java.util.Scanner;

// Change one
// Change Two
// Change Three
// Four
// Five
// Six
// Seven
// Eight
// Nine
// Ten

public class Main {

		   
    // Recursion
    public static long fibonacciRecursion(long number){
        if(number == 1 || number == 2){
            return 1;
        }

        return fibonacciRecursion(number-1) + fibonacciRecursion(number -2); //tail recursion
    }

    // Java program for Fibonacci number using Loop.
    public static long fibonacciLoop(int number){
        if(number == 1 || number == 2){
            return 1;
        }
        long fibo1=1, fibo2=1, fibonacci=1;
        for(int i= 3; i<= number; i++){
            fibonacci = fibo1 + fibo2; //Fibonacci number is sum of previous two Fibonacci number
            fibo1 = fibo2;
            fibo2 = fibonacci;

        }
        return fibonacci; //Fibonacci number
    }
}
