const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

let veiculos = [
  { id: 1, modelo: 'Gol', placa: 'ABC-1234', status: 'disponivel' },
  { id: 2, modelo: 'Ka', placa: 'XYZ-5678', status: 'em_manutencao' }
];

app.get('/api/v1/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    timestamp: new Date().toISOString(),
    uptime: `${Math.floor(process.uptime())}s`,
    memoryUsage: process.memoryUsage()
  });
});

app.get('/api/v1/veiculos', (req, res) => {
  res.status(200).json({ status: 'sucesso', dados: veiculos });
});

app.post('/api/v1/veiculos', (req, res) => {
  const { modelo, placa } = req.body;
  if (!modelo || !placa) {
    return res.status(400).json({ erro: 'Modelo e placa sao obrigatorios.' });
  }
  const novoVeiculo = { id: veiculos.length + 1, modelo, placa, status: 'disponivel' };
  veiculos.push(novoVeiculo);
  res.status(201).json({ status: 'criado', dados: novoVeiculo });
});

app.put('/api/v1/veiculos/:id', (req, res) => {
  const { id } = req.params;
  const { modelo, placa, status } = req.body;
  const index = veiculos.findIndex(v => v.id === parseInt(id));
  if (index === -1) {
    return res.status(404).json({ erro: 'Veiculo nao encontrado.' });
  }
  veiculos[index] = { id: parseInt(id), modelo, placa, status };
  res.status(200).json({ status: 'atualizado', dados: veiculos[index] });
});

app.patch('/api/v1/veiculos/:id/status', (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  const veiculo = veiculos.find(v => v.id === parseInt(id));
  if (!veiculo) {
    return res.status(404).json({ erro: 'Veiculo nao encontrado.' });
  }
  veiculo.status = status;
  res.status(200).json({ status: 'status_atualizado', dados: veiculo });
});

app.delete('/api/v1/veiculos/:id', (req, res) => {
  const { id } = req.params;
  const index = veiculos.findIndex(v => v.id === parseInt(id));
  if (index === -1) {
    return res.status(404).json({ erro: 'Veiculo nao encontrado.' });
  }
  veiculos.splice(index, 1);
  res.status(200).json({ status: 'removido', mensagem: `Veiculo ID ${id} removido com sucesso.` });
});

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
