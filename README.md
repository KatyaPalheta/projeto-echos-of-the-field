# Informações sobre o projeto

Historico de Atualizações e alterações:

1 - criada a cena de personagem_base (adicionada: colisão, textura, animação e camera2D)
2 - adicionado script de movimento basico e seleção de animação com base na direção
3 - criada a cena gerenciador de terreno (adicionadas as layers agua, grama e areia)
4 - terrenos configurados
5 - adicionado script de geração de terreno apeatorio com base em mascara pré definida sorteada de ua lista de possibilidades
6 - criada cena componente de decoração com sorteio aleatorio de texturas de decoração sendo elas grama, flores e arvores
7 - adicionado script de controle de decoração onde o algoritmo escolhe 5 texturas, e soteia a posição para ser carregada em um tile de 32x32
8 - geração aleatoria de componente de decoração adicionado ao script de geração de terreno
9 - criada cena game level e adicinados os componentes gerador de terreno e player (cenas herdadas)
10 - configurados os ySorts para que a posição relativa dos elementos no mapa façam sentido
11 - correção de desenho de borda para naturalidade dos encaixes de tiles
12 - configuração do rect do elemento de load e descarregamento fora da tela
13 - adicionadas animações de peteleco na grama
14 - adicionados sons de efeito ao passar pela grama
15 - adicionamos efeito sonoro de passos na areia e na grama
16 - inicio da criação de combate
17 - adicionadas animações de golpe simples e golpe duplo
18 - adicionada mecanica de numero de dano flutuante
19 - criada mecanica inicial de vida
20 - adicionado efeito sonoro de golpe de espada
21 - inicio da criação de inimigo base
22 - adicionado inimigo smile com movimento aos pulos e spaw ao lado do player
23 - adicioando o sistema do inimigo receber golpe
24 - adicionado o movimento passeio do inimigo
25 - adicionado efeitos sonoros do inimigo
26 - adicionado spaw aleatorio do inimigo com desativação longe do player
27 - bugs simples corrigidos e refinamento de hitbox
28 - refatoração dos botões de ataque - agora X e 1mouse é ataque simples e Y e 2mouse é ataque especial
29 - D-Pad do controle do xbox agora tambem controla o movimento
30 - LB e RB agora tem função de usar magia e arco (ainda não implementado)
40 - logica do agro dos inimigos adicionada - smile detecta o player e o persegue
41 - o player pode se afastar do inimigo para desativar o agro
42 - incluida logica de zona de ataque - os inimigos param a 15px do personagem e preparam o ataque
43 - o player agora tem animação ao ser atingido
44 - o inimifgo agora tem animação de ataque
45 - o ataque do inimigo agora causa 10 de dano ao HP do player
46 - primeio hud adicionado - agora uma barra de vida reflete a quantidade do HP do player em tempo real
47 - corrigod bugs visuais de proporção da barra de progressão do HP
49 - agora o player executa animação de morte ao zerar seu HP
50 - agora os inimigos correm pra fora da tela quando o player morre 
