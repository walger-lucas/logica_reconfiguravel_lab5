LUCAS WALGER DO NASCIMENTO
LUIZ EDUARDO PASSONI

TRABALHO 5 - FIFO

Em geral, a maior dificuldade encontrada foi remover erros durante o começo de leitura de dados, visto que a fifo possuia um valor inicial 0 que se mantinha até que fosse lido, ajustar os estados para isto foi necessário.

Durante o signal tap, com o trigger sendo a entrada no estado de leitura da fifo, foi-se observado os sinais do endereçamento na bram2, é possível ver ele subindo de 0 para 1,2 3 ..., mostrando que os dados estão passando para a a bram2.

Durante a simulação gate_level, diversos sinais foram criados que não estavam ali, produzidos por interações com a fifo e o bram.