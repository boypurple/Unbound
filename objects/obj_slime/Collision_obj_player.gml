// Exemplo de Formação: 2 na frente protegendo 1 atrás
NewEncounter(
	[
		{data: global.enemies.boar, col: 0, row: 0}, // Coluna 0, Linha 0 (Frente Esquerda)
		{data: global.enemies.boar, col: 1, row: 0}, // Coluna 1, Linha 0 (Frente Centro)
		{data: global.enemies.boar, col: 1, row: 1}  // Coluna 1, Linha 1 (Atrás do Centro)
	],
	sBattle1
);