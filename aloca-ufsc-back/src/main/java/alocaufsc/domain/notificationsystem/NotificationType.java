package alocaufsc.domain.notificationsystem;

public enum NotificationType {
    GERAL,
    NOVO_ESPACO,
    EVENTO_SEM_ESPACO_3_DIAS,
    EVENTO_SEM_ESPACO_24_HORAS,
    EVENTO_SUSPENSO_DATA_PASSADA
    // TODO(alocação): acrescentar ALOCACAO_APROVADA e ALOCACAO_RECUSADA (e as ações no app).
}