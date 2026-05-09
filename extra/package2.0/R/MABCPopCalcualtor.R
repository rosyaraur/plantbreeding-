# =====================================================================
# 1. THE FUNCTION DEFINITION (Run this first to load it into memory)
# =====================================================================
MABCPopCalculator <- function(unlinked_qtls = 0, blocks = list(), 
                              target_confidence = 0.95, bg_top_pct = 0.05) {
  
  # 1. Independent Assortment
  p_total <- (0.5)^unlinked_qtls
  
  # 2. Process Each Linkage Block
  for (i in seq_along(blocks)) {
    block <- blocks[[i]]
    distances_cM <- block$distances
    phase <- block$phase
    
    # Haldane mapping: cM to Recombination Fraction (r)
    r_values <- 0.5 * (1 - exp(-2 * (distances_cM / 100)))
    
    if (phase == "coupling") {
      # Need NO crossovers between any of the QTLs
      p_block <- 0.5 * prod(1 - r_values)
    } else if (phase == "repulsion") {
      # Need EXACT crossovers between every QTL to stack them
      p_block <- 0.5 * prod(r_values)
    } else {
      stop("Phase must be 'coupling' or 'repulsion'")
    }
    
    p_total <- p_total * p_block
  }
  
  # 3. Final Population Calculation
  if (p_total == 0) return("Probability is functionally zero. Stacking impossible in one generation.")
  
  base_n <- log(1 - target_confidence) / log(1 - p_total)
  final_n <- ceiling(base_n / bg_top_pct)
  
  return(list(
    Target_Gamete_Probability = p_total,
    Base_Carriers_Needed = ceiling(base_n),
    Final_Pop_Size = final_n
  ))
}


# # =====================================================================
# # 2. EXAMPLE USAGE (Executes using the function defined above)
# # =====================================================================
# 
# # Complex Scenario: 
# # - 1 Unlinked transgenic trait.
# # - Block 1: 3 QTLs in coupling (distances 5cM and 12cM).
# # - Block 2: 2 QTLs in repulsion (distance 8cM).
# my_blocks <- list(
#   list(distances = c(5, 12), phase = "coupling"),
#   list(distances = c(8), phase = "repulsion")
# )
# 
# print("--- Complex Scenario ---")
# MABCPopCalculator(
#   unlinked_qtls = 1, 
#   blocks = my_blocks
# )
# 
# 
# # Scenario 1: The "Easy" Stack (2 unlinked traits)
# print("--- Scenario 1: Easy Stack ---")
# MABCPopCalculator(
#   unlinked_qtls = 2, 
#   blocks = list()
# )
# 
# 
# # Scenario 2: The "Lucky" Introgression (Coupling Phase Linkage)
# my_blocks_scen2 <- list(
#   list(distances = c(5), phase = "coupling")
# )
# 
# print("--- Scenario 2: Coupling ---")
# MABCPopCalculator(
#   unlinked_qtls = 0, 
#   blocks = my_blocks_scen2
# )
# 
# 
# # Scenario 3: The "Tough" Stack (Repulsion Phase Linkage)
# my_blocks_scen3 <- list(
#   list(distances = c(10), phase = "repulsion")
# )
# 
# print("--- Scenario 3: Repulsion ---")
# MABCPopCalculator(
#   unlinked_qtls = 0, 
#   blocks = my_blocks_scen3
# )
# 
# 
# # Scenario 4: The "Nightmare" Multi-Donor Stack (The Wall)
# my_blocks_scen4 <- list(
#   list(distances = c(10, 2), phase = "repulsion")
# )
# 
# print("--- Scenario 4: The Wall ---")
# MABCPopCalculator(
#   unlinked_qtls = 1, 
#   blocks = my_blocks_scen4
# )