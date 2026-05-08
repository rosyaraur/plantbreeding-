# tools/tool_registry.py

from .r_wrappers import (
    simulate_field_trial_tool, generate_rcbd_plan_tool, generate_lattice_plan_tool,
    generate_stripplot_plan_tool, generate_inventory_design_tool, generate_prep_design_tool,
    generate_augmented_design_tool, analyze_rcbd_comp_tool, analyze_rcbd_contrast_tool,
    analyze_factorial_anova_tool, analyze_spatial_ancova_tool, adjust_spatial_unreplicated_tool,
    calc_geno_values_tool, analyze_varietal_trial_tool, run_augmented_rcb_tool,
    run_augmented_rowcol_tool, run_stability_analysis_tool, run_ammi_analysis_tool,
    generate_gge_biplot_tool, run_metan_gge_tool, run_comstock_robinson_tool,
    run_fast_analysis_tool, rank_gxe_stability_tool, calculate_prob_superiority_tool,
    calc_prob_from_summary_tool, calculate_on_farm_win_prob_tool, run_safety_first_analysis_tool,
    run_line_tester_tool, run_nc_design_1_tool, run_nc_design_2_tool, run_diallel_1_tool,
    run_genetic_correlation_tool, calculate_selection_index_tool, calculate_mabc_population_tool,
    run_mabc_engine_tool, verify_biparental_progeny_tool, classify_germplasm_tool,
    calculate_genomic_relationship_tool, calculate_population_fst_tool, 
    calculate_genetic_distance_tool, analyze_pedigree_network_tool, trim_pedigree_tool,
    plot_genetic_gain_tool, calculate_audpc_tool
)

def get_all_tools():
    """Returns the complete list of tools available to the PlantbreedAIAgent."""
    return [
        simulate_field_trial_tool, generate_rcbd_plan_tool, generate_lattice_plan_tool,
        generate_stripplot_plan_tool, generate_inventory_design_tool, generate_prep_design_tool,
        generate_augmented_design_tool, analyze_rcbd_comp_tool, analyze_rcbd_contrast_tool, 
        analyze_factorial_anova_tool, analyze_spatial_ancova_tool, adjust_spatial_unreplicated_tool,
        calc_geno_values_tool, analyze_varietal_trial_tool, run_augmented_rcb_tool,
        run_augmented_rowcol_tool, run_stability_analysis_tool, run_ammi_analysis_tool,
        generate_gge_biplot_tool, run_metan_gge_tool, run_comstock_robinson_tool, run_fast_analysis_tool,
        rank_gxe_stability_tool, calculate_prob_superiority_tool, calc_prob_from_summary_tool,
        calculate_on_farm_win_prob_tool, run_safety_first_analysis_tool, run_line_tester_tool, 
        run_nc_design_1_tool, run_nc_design_2_tool, run_diallel_1_tool, run_genetic_correlation_tool, 
        calculate_selection_index_tool, calculate_mabc_population_tool, run_mabc_engine_tool, 
        verify_biparental_progeny_tool, classify_germplasm_tool, calculate_genomic_relationship_tool, 
        calculate_population_fst_tool, calculate_genetic_distance_tool, analyze_pedigree_network_tool, 
        trim_pedigree_tool, plot_genetic_gain_tool, calculate_audpc_tool
    ]