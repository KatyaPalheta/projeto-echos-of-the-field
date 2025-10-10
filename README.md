# Informações sobre o projeto


Épico 1: Fundação do Jogador e do Mundo

Este épico cobre a criação do personagem jogável básico, seu movimento e a interação com o ambiente fundamental do jogo.

| ID | User Story | Critérios de Aceite -| | US-01 | Como jogador, eu quero poder mover meu personagem nas 8 direções usando um controle ou teclado. | 1. O personagem responde ao input do analógico esquerdo do controle e/ou das teclas WASD/Setas.
2. O personagem se move suavemente nas 8 direções (cima, baixo, esquerda, direita e diagonais).  
3. A animação de "andar" (Walk) é ativada durante o movimento.  
4. O personagem para de se mover quando o input cessa, retornando à animação "parado" (Idle). -| | US-02 | Como jogador, eu quero que a câmera siga meu personagem, mantendo-o no centro da tela. | 1. A câmera permanece focada no personagem enquanto ele se move pelo mapa.  
2. O movimento da câmera é suave e não causa solavancos.  
3. A perspectiva isométrica é mantida consistentemente. -| | US-03 | Como desenvolvedor, eu quero criar um mapa de jogo estático usando o tileset do asset pack. | 1. O mapa é construído usando o tileset de 16x16 do "Farm RPG Asset Pack".  
2. O mapa contém os elementos básicos do bioma de campo (grama, árvores, pedras, etc.).  
3. O personagem pode colidir com os objetos do cenário (árvores, pedras, etc.) e não pode atravessá-los.  
4. O mapa tem limites definidos que o personagem não pode ultrapassar. -|

