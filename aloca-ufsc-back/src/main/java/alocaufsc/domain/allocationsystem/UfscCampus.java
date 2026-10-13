package alocaufsc.domain.allocationsystem;

import java.util.List;


public final class UfscCampus {

    public record Center(String code, String name, List<String> buildings) {}

    public static final String OTHER = "OUTRO";

    public static final List<Center> CENTERS = List.of(
            new Center("CTC", "Centro Tecnológico", List.of(
                    "INE - Informática e Estatística", "EMC - Engenharia Mecânica", "ECV - Engenharia Civil",
                    "EEL - Engenharia Elétrica", "EQA - Engenharia Química e de Alimentos",
                    "EPS - Engenharia de Produção", "ENS - Engenharia Sanitária e Ambiental",
                    "DAS - Automação e Sistemas", "ARQ - Arquitetura e Urbanismo", "EFI - Espaço Físico Integrado",
                    "Bloco A - Direção do CTC")),
            new Center("CFM", "Centro de Ciências Físicas e Matemáticas", List.of(
                    "Departamento de Física", "Departamento de Matemática", "Departamento de Química")),
            new Center("CFH", "Centro de Filosofia e Ciências Humanas", List.of(
                    "Bloco A", "Bloco B", "Bloco C", "Bloco D", "Bloco E")),
            new Center("CCE", "Centro de Comunicação e Expressão", List.of(
                    "Bloco A", "Bloco B", "Bloco C", "Bloco D")),
            new Center("CSE", "Centro Socioeconômico", List.of("Bloco A", "Bloco B", "Bloco C", "Bloco F")),
            new Center("CCJ", "Centro de Ciências Jurídicas", List.of("Bloco A", "Bloco B", "Bloco C")),
            new Center("CED", "Centro de Ciências da Educação", List.of("Bloco A", "Bloco B", "Bloco C", "Bloco D")),
            new Center("CCS", "Centro de Ciências da Saúde", List.of("Bloco A", "Bloco B", "Hospital Universitário")),
            new Center("CCB", "Centro de Ciências Biológicas", List.of("Bloco A", "Bloco B", "Bloco C", "Bloco D", "Bloco E")),
            new Center("CDS", "Centro de Desportos", List.of("Ginásio 1", "Ginásio 2", "Piscina", "Pista de Atletismo")),
            new Center("CCA", "Centro de Ciências Agrárias", List.of("Bloco A", "Bloco B", "Bloco C")),
            new Center(OTHER, "Outros espaços da UFSC", List.of(
                    "Reitoria", "Biblioteca Universitária (BU)", "Restaurante Universitário (RU)",
                    "Centro de Cultura e Eventos", "Planetário"))
    );

    private UfscCampus() {}

    public static boolean isKnownCenter(String code) {
        return CENTERS.stream().anyMatch(c -> c.code().equalsIgnoreCase(code));
    }
}
