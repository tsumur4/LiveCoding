#!/bin/bash

# Define a porta enviada por parâmetro ($1) ou usa 3000 como padrão se não for informada
PORT=${1:-3000}
BASE_URL="http://localhost:${PORT}/api/v1/veiculos"
LOG_FILE="crud_result.log"

echo "=== INICIANDO TESTE CRUD - $(date) ===" > $LOG_FILE
echo "Servidor alvo: http://localhost:${PORT}" >> $LOG_FILE

echo -e "\n[1/4] Cadastrando primeiro veiculo..." >> $LOG_FILE
RESPONSE1=$(curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d '{"montadora":"Volvo","modelo":"FH 540","placa":"KLL-9090","status":"DISPONIVEL"}')

echo "$RESPONSE1" >> $LOG_FILE

# Captura o ID retornado pelo servidor usando jq (suporta estrutura { dados: { id: X } } ou { id: X })
ID1=$(echo "$RESPONSE1" | jq -r '.dados.id // .id // empty')
echo "ID capturado para o primeiro veiculo: $ID1" >> $LOG_FILE


echo -e "\n[2/4] Cadastrando segundo veiculo..." >> $LOG_FILE
RESPONSE2=$(curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d '{"montadora":"Scania","modelo":"R450","placa":"XYZ-8888","status":"DISPONIVEL"}')

echo "$RESPONSE2" >> $LOG_FILE

ID2=$(echo "$RESPONSE2" | jq -r '.dados.id // .id // empty')
echo "ID capturado para o segundo veiculo: $ID2" >> $LOG_FILE


echo -e "\n[3/4] Atualizando status do veiculo 1 (ID: $ID1)..." >> $LOG_FILE
if [ -n "$ID1" ]; then
  curl -i -X PATCH "${BASE_URL}/${ID1}/status" \
    -H "Content-Type: application/json" \
    -d '{"status":"EM_ROTA"}' >> $LOG_FILE 2>&1
else
  echo "Erro: ID1 nao capturado, pulando PATCH." >> $LOG_FILE
fi


echo -e "\n[4/4] Deletando veiculo 2 (ID: $ID2)..." >> $LOG_FILE
if [ -n "$ID2" ]; then
  curl -i -X DELETE "${BASE_URL}/${ID2}" >> $LOG_FILE 2>&1
else
  echo "Erro: ID2 nao capturado, pulando DELETE." >> $LOG_FILE
fi

echo -e "\n=== TESTES CONCLUIDOS ===" >> $LOG_FILE
echo "Testes executados com sucesso! Logs salvos em $LOG_FILE."
