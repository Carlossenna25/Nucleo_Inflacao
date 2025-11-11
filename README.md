# Núcleo de Inflação — IPCA (Outubro/2025)

📊 Cálculo dos núcleos de inflação aparados e mediana ponderada
a partir dos microdados do IPCA (SIDRA 7060 / IBGE).

## 🔍 Objetivo
Identificar a tendência subjacente da inflação, removendo choques voláteis
(por exemplo, alimentos e energia elétrica), através dos núcleos:

- Média aparada 5%  
- Média aparada 10%  
- Média aparada 20%  
- Média aparada 40%  
- Mediana ponderada  

## ⚙️ Código
O script [`Nucelo.R`](Nucelo.R) baixa os dados via pacote **sidrar**, trata os subitens e gera gráficos comparativos com o **ggplot2**.

## 📈 Resultados (Outubro/2025)

| Núcleo              | Corte | Resultado |
|---------------------|:------:|:----------:|
| Média aparada 5%    | ±5%   | 0,13% |
| Média aparada 10%   | ±10%  | 0,13% |
| Média aparada 20%   | ±20%  | 0,13% |
| Média aparada 40%   | ±40%  | 0,09% |
| Mediana ponderada   | —     | 0,09% |

## 🧾 Fonte de dados
- IBGE — SIDRA Tabela 7060  
- Banco Central do Brasil (Atas Copom, séries SGS)

## 🧰 Ferramentas
R, dplyr, tidyr, ggplot2, sidrar

## 🧠 Autor
**Carlos Senna**  
[LinkedIn](https://www.linkedin.com/in/carlossenna25/) | [GitHub](https://github.com/Carlossenna25)
