package alocaufsc.technicalservices.rest;

import alocaufsc.domain.calculadora.Calculator;
import org.apache.coyote.Response;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/calculadora")
public class CalculatorController {

    @GetMapping("/sum")
    public ResponseEntity<Float> processSum(@RequestParam("num1") float num1, @RequestParam("num2") float num2) {
        return new ResponseEntity<>(Calculator.sum(num1, num2), HttpStatusCode.valueOf(200));
    }

    @GetMapping("/minus")
    public ResponseEntity<Float> processMinus(@RequestParam("num1") float num1, @RequestParam("num2") float num2) {
        return new ResponseEntity<>(Calculator.minus(num1, num2), HttpStatusCode.valueOf(200));
    }

    @GetMapping("/times")
    public ResponseEntity<Float> processTimes(@RequestParam("num1") float num1, @RequestParam("num2") float num2) {
        return new ResponseEntity<>(Calculator.times(num1, num2), HttpStatusCode.valueOf(200));
    }

    @GetMapping("/div")
    public ResponseEntity<?> processDiv(@RequestParam("num1") float num1, @RequestParam("num2") float num2) {
        Float result = Calculator.div(num1, num2);
        return result != null
                ? new ResponseEntity<>(result, HttpStatusCode.valueOf(200))
                : new ResponseEntity<>("Não é possível dividir por 0\n", HttpStatusCode.valueOf(400));
    }
}
