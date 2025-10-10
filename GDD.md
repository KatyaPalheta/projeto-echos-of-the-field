# Game Design Document (GDD) - Echoes of the Field

## 1. Título do Jogo (Provisório)

**Echoes of the Field**

## 2. Visão Geral (Elevator Pitch)

Um roguelite isométrico de sobrevivência em pixel art, onde o jogador, um fazendeiro transportado para um mundo de fantasia caótico, explora um mapa envolto em névoa, utiliza os resquícios de suas mortes anteriores (Echoes) para obter vantagens táticas e gerencia recursos em cofres seguros, enquanto enfrenta inimigos que evoluem com o tempo. O objetivo final é coletar os itens necessários para conjurar um portal de volta para casa antes que a janela mágica se feche permanentemente.

## 3. Gênero

Roguelite, Ação, Sobrevivência, Exploração Isométrica.

## 4. Plataformas

(A ser definido, mas tipicamente PC para jogos indie).

## 5. Público-Alvo

Jogadores que apreciam desafios roguelite, exploração, gerenciamento de recursos e uma narrativa envolvente com elementos de fantasia e humor.

## 6. História/Narrativa

### 6.1. Contexto

Em uma terra encantada e pacífica, um jovem aprendiz de mago, em sua busca por conhecimento, encontra tomos empoeirados na torre mais alta do castelo. Ao tentar conjurar magias antigas, ele acidentalmente desencadeia um caos mágico sem precedentes. Árvores ganham vida e atacam, dragões surgem do céu, camponeses são aterrorizados, cavalos se recusam a obedecer e espadas se tornam sencientes e perigosas. No meio dessa balbúrdia, um fazendeiro, alheio aos acontecimentos, cai em um portal que se abre sob seus pés, sendo transportado para um lugar completamente estranho e perigoso.

### 6.2. Protagonista

O protagonista é um **fazendeiro** comum, um 'aventureiro' forçado, que se vê em um mundo desconhecido e precisa encontrar uma maneira de voltar para casa. Ele começa com itens básicos e pouca habilidade de combate, mas evolui ao longo do jogo, aprendendo a sobreviver e a lutar. As habilidades de fazenda, como plantar, colher e regar, não serão o foco principal do gameplay inicial, que será centrado no combate e exploração. No entanto, essas mecânicas podem ser introduzidas em futuras atualizações se o jogo evoluir para uma proposta de sobrevivência mais longa.

### 6.3. Objetivo

O objetivo principal do jogador é encontrar os itens necessários para conjurar um portal de volta para casa. Isso envolve explorar o mapa, coletar recursos, derrotar inimigos e desvendar os segredos do mundo em que ele se encontra. O tempo é um fator crucial, pois o portal se fechará para sempre se o jogador não agir rápido o suficiente.

## 7. Jogabilidade

### 7.1. Loop Principal

O loop principal do jogo consiste em:

1.  **Exploração:** O jogador explora um mapa coberto por uma névoa de guerra, revelando novas áreas, encontrando recursos, inimigos e locais de interesse.
2.  **Combate:** O jogador enfrenta inimigos em combate de ação isométrica, utilizando uma variedade de armas e habilidades.
3.  **Coleta de Recursos:** O jogador coleta recursos de várias fontes, como inimigos, baús e o ambiente.
4.  **Gerenciamento de Inventário:** O jogador gerencia um inventário limitado, decidindo quais itens manter, usar ou armazenar.
5.  **Morte e Persistência:** A morte é um elemento central do jogo. Ao morrer, o jogador perde alguns itens, mas outros persistem, permitindo uma progressão gradual.

### 7.2. Mecânicas Principais

#### 7.2.1. Exploração e Névoa de Guerra

*   O mapa é fixo em sua topografia, mas o jogador reaparece em locais aleatórios a cada nova run.
*   A névoa de guerra obscurece o mapa, sendo revelada à medida que o jogador explora.
*   O mapa revelado persiste entre as mortes, incentivando a exploração contínua.
*   O jogo terá um único bioma de campo para as runs rápidas, com a possibilidade de variações topográficas.

#### 7.2.2. Combate

*   Combate de ação em tempo real com perspectiva isométrica.
*   O jogador pode usar uma variedade de armas, incluindo espadas, arcos e magia.
*   As animações de combate do asset pack 'Tiny Farm RPG' serão utilizadas, focando em espada, arco e flecha e magia/cura.

#### 7.2.3. Morte e Persistência

*   A morte é uma parte integrante do ciclo de jogo.
*   Ao morrer, o jogador deixa para trás um **Echo do Mapa**, que pode ser recuperado na próxima run para revelar uma parte do mapa instantaneamente.
*   Se o jogador morrer com um **Cristal Elemental** no inventário (e não o tiver depositado no cofre), o cristal 'explode', criando uma **Zona de Perigo** no local da morte. Esta zona terá uma contagem regressiva para a perda total do loot, sendo consumido por fogo, e uma cratera ficará no chão onde ocorreu. Um aviso sonoro pode alertar o jogador se o cristal deteriorar antes de ser alcançado, especialmente se estiver em uma zona escura. Se o jogador morrer novamente dentro de uma Zona de Perigo sem um cristal no inventário, a morte será comum, sem efeitos adicionais na zona existente.
*   Itens depositados em **Cofres Seguros** persistem entre as runs.

#### 7.2.4. Sistema de Crafting e Ferreiro

*   O jogador pode encontrar uma **Casa do Ferreiro Abandonada** no mapa.
*   Para utilizá-la, o jogador precisa reparar as bancadas com materiais de construção (pedra, ferro, corda, argamassa) encontrados nas torres, além de minérios como cobre, prata e ouro, e joias como ametista, esmeralda, rubi e diamante.
*   O ferreiro permite criar e reparar armas e armaduras básicas. O 'Conhecimento de Crafting' é adquirido através de receitas compradas ou dropadas, com um número limitado (cerca de 20) divididas por tier, com foco em complexidade para futuras atualizações.
*   A 'defesa' da casa do ferreiro envolve literalmente construir portas, janelas ou até uma torreta mágica para protegê-la. Há o risco de grupos de orcs encontrarem, saquearem ou tomarem a casa, resultando na perda de itens do baú ou bancadas danificadas ao ser recuperada.
*   O ferreiro também terá uma mesa e fogão para o uso de ingredientes em receitas de magia e comida.
*   Duplicatas de Cristais Elementais podem ser refinadas no Ferreiro para criar materiais raros/alternativos, que podem ser usados em crafting avançado ou vendidos a NPCs.

#### 7.2.5. NPCs e Comércio

*   NPCs aparecerão aleatoriamente no mapa, como uma bruxa em uma carroça ou um comerciante em uma barraca.
*   Eles oferecerão itens para venda, dicas e a possibilidade de vender itens do jogador.
*   A interação será simples, com uma janela de diálogo e uma lista de itens, sem um HUD complexo inicialmente.

### 7.3. Itens

#### 7.3.1. Equipamentos

*   **Armas:** Espadas, adagas, arcos, cajados, varinhas.
*   **Defesa:** Escudos, capas.

#### 7.3.2. Consumíveis

*   **Cura:** Comida, poções.
*   **Mana:** Poções.

#### 7.3.3. Recursos

*   **Materiais de Construção:** Pedra, ferro, corda, argamassa.
*   **Minérios:** Cobre, prata, ouro.
*   **Joias:** Ametista, esmeralda, rubi, diamante.
*   **Ingredientes:** Para receitas de magia e comida.

#### 7.3.4. Itens de Missão

*   **Cristais Elementais:** Fogo, Água, Terra, Ar e Espírito. Necessários para o portal.
*   **Páginas de Magia:** Fragmentos de um pergaminho que, quando combinados, formam a receita do portal.

## 8. Arte e Estilo Visual

### 8.1. Estilo Geral

O jogo utilizará um estilo de pixel art 16x16, inspirado no asset pack **Tiny Farm RPG** da Emanuelle. O estilo é limpo, colorido e evoca uma sensação de calor e diversão, apesar do tema de sobrevivência.

### 8.2. Personagens

O protagonista será um fazendeiro, com um design simples e amigável. Os inimigos, como os orcs, terão um design que se encaixa no estilo de fantasia feudal.

### 8.3. Ambiente

O jogo se passará em um único bioma de campo, com variações na topografia. O ambiente será composto por grama, arbustos, pedras, árvores e pequenos animais. Haverá também estruturas como torres, a casa do ferreiro e o altar do portal. A decisão sobre a inclusão de ciclos de dia e noite será feita em uma fase posterior do desenvolvimento.

## 9. Som e Música

(A ser definido)

## 10. Interface do Usuário (UI)

*   A interface será minimalista, sem um HUD constante na tela.
*   As informações de vida e mana serão exibidas visualmente no personagem ou em barras que aparecem brevemente ao usar habilidades.
*   O inventário será acessado através de um menu.
*   O Consumível de Visão (Raio-X) será de uso instantâneo: ao coletá-lo, uma luz aparecerá e uma porção do mapa será revelada imediatamente.

## 11. Controles

Os controles serão baseados em um controle de Xbox, com a seguinte configuração:

*   **Analógico Esquerdo:** Movimento do personagem.
*   **Analógico Direito:** Mira.
*   **A:** Ataque primário.
*   **B:** Esquiva.
*   **X:** Interagir/Usar item.
*   **Y:** Magia.
*   **D-Pad:** Seleção rápida de itens.

## 12. Progressão do Jogador

### 12.1. Diário de Aventura e Árvore de Habilidades

*   O **Diário de Aventura** registrará as descobertas do jogador, como receitas, locais e informações sobre inimigos.
*   A **Árvore de Habilidades** permitirá que o jogador aprimore seus atributos básicos: Força, Destreza, Conhecimento e Saúde.
*   Os pontos de habilidade serão ganhos ao usar duplicatas de Cristais Elementais no diário. Por exemplo, um cristal de fogo extra pode ser usado para evoluir a Força.

## 13. Monetização

(A ser definido, mas provavelmente um preço único pelo jogo).

## 14. Referências

*   **Asset Pack:** [Tiny Farm RPG - Asset Pack [16x16] by Emanuelle](https://emanuelledev.itch.io/farm-rpg)

## 15. Análise Detalhada das Mecânicas

### 15.1. Ciclo de Jogo Detalhado

O ciclo de jogo de "Echoes of the Field" é projetado para ser rápido e recompensador, com um forte incentivo para a exploração e o combate estratégico. A seguir, uma descrição detalhada do que um jogador pode esperar em uma única run:

1.  **Início da Run:** O jogador aparece em um ponto aleatório do mapa. O mapa está coberto por uma névoa de guerra, com exceção das áreas já reveladas em runs anteriores.

2.  **Exploração Inicial:** O jogador começa a explorar o mapa, revelando novas áreas, coletando recursos básicos e enfrentando inimigos de baixo nível.

3.  **Encontrando Locais de Interesse:** Durante a exploração, o jogador pode encontrar:
    *   **Torres:** Estruturas que contêm inimigos e recompensas valiosas, como materiais de construção e, potencialmente, Cristais Elementais.
    *   **Casa do Ferreiro Abandonada:** Um local que pode ser reparado para se tornar uma base de operações para crafting.
    *   **Cofres Seguros:** Locais para armazenar itens permanentemente.
    *   **NPCs:** Personagens que oferecem comércio e dicas.
    *   **Altar do Portal:** O local onde o portal para casa pode ser conjurado.

4.  **Combate e Evolução:** O combate é constante e a dificuldade dos inimigos aumenta com o tempo, especialmente com o toque do **Sino de Alerta**, que anuncia a chegada de novos e mais fortes inimigos.

5.  **Morte e Consequências:** A morte é inevitável. As consequências da morte dependem do que o jogador carregava:
    *   **Morte Comum:** O jogador perde os itens não depositados no cofre e deixa um **Echo do Mapa**.
    *   **Morte com Cristal Elemental:** O cristal explode, criando uma **Zona de Perigo** com um temporizador para a perda total do loot.

6.  **Progressão Permanente:** Entre as runs, o jogador pode usar os Cristais Elementais depositados no cofre para aprimorar seus atributos na **Árvore de Habilidades** do **Diário de Aventura**.

7.  **Objetivo Final:** O ciclo se repete até que o jogador colete os 5 Cristais Elementais e as 4 Páginas de Magia para conjurar o portal no Altar.

### 15.2. Tabela de Itens e Recursos

| Categoria           | Exemplos                                                              | Obtenção                                                                | Uso                                                                         |
| ------------------- | --------------------------------------------------------------------- | ----------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| **Equipamentos**    | Espadas, Adagas, Arcos, Cajados, Varinhas, Escudos, Capas               | Crafting, Drop de Inimigos, Baús, Comércio com NPCs                     | Equipar para combate e defesa                                               |
| **Consumíveis**     | Comida, Poções de Cura, Poções de Mana                                | Crafting, Drop de Inimigos, Baús, Comércio com NPCs                     | Recuperar vida e mana                                                       |
| **Materiais de Construção** | Pedra, Ferro, Corda, Argamassa                                        | Torres, Drop de Inimigos                                                | Reparar a Casa do Ferreiro, construir defesas                               |
| **Minérios e Joias** | Cobre, Prata, Ouro, Ametista, Esmeralda, Rubi, Diamante                | Torres, Mineração                                                       | Crafting de equipamentos avançados                                          |
| **Ingredientes**    | Ervas, cogumelos, etc.                                                | Coleta no mapa, Drop de Inimigos                                        | Crafting de poções e comida                                                 |
| **Itens de Missão** | Cristais Elementais (Fogo, Água, Terra, Ar, Espírito), Páginas de Magia | Torres (Cristais), Drop de Inimigos (Páginas)                           | Conjurar o portal de volta para casa                                        |

### 15.3. Detalhamento da Árvore de Habilidades

A Árvore de Habilidades no Diário de Aventura é o principal meio de progressão permanente do jogador. Ela é dividida em quatro atributos principais:

*   **Força:** Aumenta o dano de ataques corpo a corpo.
*   **Destreza:** Aumenta a velocidade de ataque e o dano de ataques à distância.
*   **Conhecimento:** Aumenta a eficácia das magias e a quantidade de mana.
*   **Saúde:** Aumenta a quantidade de vida do jogador.

Para evoluir um atributo, o jogador precisa gastar uma duplicata de um Cristal Elemental. Cada tipo de cristal pode ser associado a um atributo (ex: Fogo para Força, Ar para Destreza, etc.), ou o jogador pode ter a liberdade de escolher qual atributo evoluir com qualquer cristal duplicado.

## 16. Roadmap (Pós-Lançamento)

O desenvolvimento de "Echoes of the Field" não termina no lançamento. O plano é continuar a expandir o jogo com novos conteúdos e funcionalidades, com base no feedback da comunidade. Algumas das ideias para o pós-lançamento incluem:

*   **Novos Biomas:** Introduzir novos biomas com inimigos, recursos e desafios únicos.
*   **Sistema de Sobrevivência:** Adicionar mecânicas de sobrevivência mais profundas, como a necessidade de comer, beber e dormir.
*   **Mais Receitas de Crafting:** Expandir o sistema de crafting com mais receitas de armas, armaduras, poções e comidas.
*   **Novos NPCs e Quests:** Adicionar novos personagens com histórias e missões secundárias.
*   **Eventos Sazonais:** Criar eventos especiais com recompensas exclusivas.
*   **Modo Multiplayer:** Explorar a possibilidade de um modo cooperativo online.

