library(sidrar)
library(dplyr)
library(ggplot2)
library(tidyr)

## Selecionar tabela sidra ##
get_sidra(
  x = 7060,
  variable = c(63, 66),  
  period = "202510",     
  geo = "Brazil",              
  classific = "c315",      
) -> ipca_oct25

## Limpar e preparar a base ##
ipca_oct25 %>%
  select(
    data = `Mês (Código)`,
    item = `Geral, grupo, subgrupo, item e subitem`,
    variavel = Variável,
    valor = Valor
  ) %>%
  pivot_wider(names_from = variavel, values_from = valor) %>%
  rename(
    variacao = `IPCA - Variação mensal`,
    peso = `IPCA - Peso mensal`
  ) %>%
  mutate(
    variacao = as.numeric(variacao) / 100,
    peso = as.numeric(peso) / 100
  ) %>%
  filter(!is.na(peso), !is.na(variacao)) -> ipca_oct25_clean

## Núcleo com média aparada para 5% ##
ipca_oct25_clean %>%
  arrange(variacao) %>%
  mutate(cum_peso = cumsum(peso) / sum(peso)) %>%
  filter(cum_peso > 0.05, cum_peso < 0.95) %>%
  summarise(nucleo_trimmed = sum(variacao * peso) / sum(peso)) %>%
  pull(nucleo_trimmed) -> nucleo_trimmed

ipca_oct25_clean %>%
  arrange(variacao) %>%
  mutate(cum_peso = cumsum(peso) / sum(peso)) %>%
  filter(cum_peso >= 0.5) %>%
  slice(1) %>%
  pull(variacao) -> mediana_ponderada

cat("Média aparada (5%):", round(nucleo_trimmed * 100, 2), "%\n")
cat("Mediana ponderada:", round(mediana_ponderada * 100, 2), "%\n")

## Calcular com diferentes níveis ##
calcular_nucleo <- function(df, corte) {
  df %>%
    arrange(variacao) %>%
    mutate(cum_peso = cumsum(peso) / sum(peso)) %>%
    filter(cum_peso > corte, cum_peso < 1 - corte) %>%
    summarise(nucleo = sum(variacao * peso) / sum(peso)) %>%
    mutate(corte = corte)
}

nucleos_multiplos <- bind_rows(
  calcular_nucleo(ipca_oct25_clean, 0.05),
  calcular_nucleo(ipca_oct25_clean, 0.10),
  calcular_nucleo(ipca_oct25_clean, 0.20),
  calcular_nucleo(ipca_oct25_clean, 0.40)
) %>%
  mutate(
    nucleo = nucleo * 100,
    corte_label = paste0("Apara ", corte*100, "%")
  )

ipca_oct25_clean %>%
  arrange(variacao) %>%
  mutate(cum_peso = cumsum(peso) / sum(peso)) %>%
  filter(cum_peso >= 0.5) %>%
  slice(1) %>%
  pull(variacao) * 100 -> mediana_ponderada

cat("Mediana ponderada:", round(mediana_ponderada, 2), "%\n")
dir.create("carrossel_nucleos", showWarnings = FALSE)

for (i in 1:nrow(nucleos_multiplos)) {
  
  corte <- nucleos_multiplos$corte[i]
  label <- nucleos_multiplos$corte_label[i]
  valor <- round(nucleos_multiplos$nucleo[i], 2)
  
  p <- ipca_oct25_clean %>%
    arrange(variacao) %>%
    mutate(cum_peso = cumsum(peso) / sum(peso)) %>%
    ggplot(aes(x = variacao * 100, weight = peso)) +
    geom_histogram(bins = 40, fill = "#005C99", alpha = 0.8, color = "white") +
    geom_vline(
      xintercept = valor,
      color = "#E63946",
      linetype = "dashed",
      linewidth = 1
    ) +
    labs(
      title = paste0("Núcleo de Inflação (", label, ")"),
      subtitle = paste0("Outubro de 2025 — ", valor, "%"),
      x = "Variação mensal dos subitens (%)",
      y = "Peso agregado",
      caption = "Fonte: IBGE (SIDRA 7060) | Cálculo próprio"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", size = 18),
      plot.subtitle = element_text(size = 14),
      panel.grid.minor = element_blank()
    )
  
  ggsave(
    filename = paste0("carrossel_nucleos/nucleo_", gsub(" ", "_", label), "_out2025.png"),
    plot = p,
    width = 7, height = 5, dpi = 300
  )
}
