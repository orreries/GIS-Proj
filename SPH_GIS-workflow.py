arcpy.conversion.ExportTable(
    in_table="fixed_sph.csv",
    out_table=r"C:\Users\hanna\OneDrive\Desktop\SPH_Bach\SPH_Bach.gdb\fixed_sph_ExportTable",
    where_clause="",
    use_field_alias_as_name="NOT_USE_ALIAS",
    field_mapping='GEOID "GEOID" true true false 8000 Text 0 0,First,#,fixed_sph.csv,GEOID,0,7999;NAME "NAME" true true false 8000 Text 0 0,First,#,fixed_sph.csv,NAME,0,7999;bach_deg "bach_deg" true true false 8000 Text 0 0,First,#,fixed_sph.csv,bach_deg,0,7999;single_mom "single_mom" true true false 8000 Text 0 0,First,#,fixed_sph.csv,single_mom,0,7999;total_fam_kids "total_fam_kids" true true false 8000 Text 0 0,First,#,fixed_sph.csv,total_fam_kids,0,7999;single_dad "single_dad" true true false 8000 Text 0 0,First,#,fixed_sph.csv,single_dad,0,7999',
    sort_field=None
)

arcpy.management.CalculateField(
    in_table="county_SPH",
    field="Bachelor_Int",
    expression="convert_to_float(!bach_deg!)",
    expression_type="PYTHON3",
    code_block="""def convert_to_float(value):
    try:
        return float(value)
    except:
        return None""",
    field_type="TEXT",
    enforce_domains="NO_ENFORCE_DOMAINS"
)

arcpy.management.CalculateField(
    in_table="county_SPH",
    field="Mom_Int",
    expression="convert_to_float(!single_mom!)",
    expression_type="PYTHON3",
    code_block="""def convert_to_float(value):
    try:
        return float(value)
    except:
        return None""",
    field_type="TEXT",
    enforce_domains="NO_ENFORCE_DOMAINS"
)

arcpy.management.CalculateField(
    in_table="county_SPH",
    field="Dad_Int",
    expression="convert_to_float(!single_dad!)",
    expression_type="PYTHON3",
    code_block="""def convert_to_float(value):
    try:
        return float(value)
    except:
        return None""",
    field_type="TEXT",
    enforce_domains="NO_ENFORCE_DOMAINS"
)

arcpy.management.CalculateField(
    in_table="county_SPH",
    field="TotFam",
    expression="convert_to_float(!total_fam_kids!)",
    expression_type="PYTHON3",
    code_block="""def convert_to_float(value):
    try:
        return float(value)
    except:
        return None""",
    field_type="TEXT",
    enforce_domains="NO_ENFORCE_DOMAINS"
)

arcpy.analysis.TabulateIntersection(
    in_zone_features="county_SPH",
    zone_fields="Bachelor_Int;Dad_Int;Mom_Int",
    in_class_features="county_SPH",
    out_table=r"C:\Users\hanna\OneDrive\Desktop\SPH_Bach\SPH_Bach.gdb\county_SPH_TabulateIntersect",
    class_fields=None,
    sum_fields=None,
    xy_tolerance=None,
    out_units="UNKNOWN"
)

arcpy.analysis.Clip(
    in_features="county_SPH",
    clip_features="county_SPH",
    out_feature_class=r"C:\Users\hanna\OneDrive\Desktop\SPH_Bach\SPH_Bach.gdb\county_SPH_Clip",
    cluster_tolerance=None
)

arcpy.management.SelectLayerByAttribute(
    in_layer_or_view="county_SPH",
    selection_type="NEW_SELECTION",
    where_clause="STATEFP = '12'",
    invert_where_clause=None
)

arcpy.analysis.Clip(
    in_features="county_SPH",
    clip_features="county_SPH",
    out_feature_class=r"C:\Users\hanna\OneDrive\Desktop\SPH_Bach\SPH_Bach.gdb\county_FLA",
    cluster_tolerance=None
)

arcpy.stats.HotSpots(
    Input_Feature_Class="county_FLA",
    Input_Field="Mom_Int",
    Output_Feature_Class=r"C:\Users\hanna\OneDrive\Desktop\SPH_Bach\SPH_Bach.gdb\FLA_Mom_HS",
    Conceptualization_of_Spatial_Relationships="FIXED_DISTANCE_BAND",
    Distance_Method="EUCLIDEAN_DISTANCE",
    Standardization="ROW",
    Distance_Band_or_Threshold_Distance=None,
    Self_Potential_Field=None,
    Weights_Matrix_File=None,
    Apply_False_Discovery_Rate__FDR__Correction="NO_FDR",
    number_of_neighbors=None
)

arcpy.stats.HotSpots(
    Input_Feature_Class="FLA_Dad_Bach",
    Input_Field="Dad_Int",
    Output_Feature_Class=r"C:\Users\hanna\OneDrive\Desktop\SPH_Bach\SPH_Bach.gdb\FLA_Dad_Bach_HotSpots",
    Conceptualization_of_Spatial_Relationships="FIXED_DISTANCE_BAND",
    Distance_Method="EUCLIDEAN_DISTANCE",
    Standardization="ROW",
    Distance_Band_or_Threshold_Distance=None,
    Self_Potential_Field=None,
    Weights_Matrix_File=None,
    Apply_False_Discovery_Rate__FDR__Correction="NO_FDR",
    number_of_neighbors=None
)

arcpy.stats.HotSpots(
    Input_Feature_Class="county_SPH",
    Input_Field="Mom_Int",
    Output_Feature_Class=r"C:\Users\hanna\OneDrive\Desktop\SPH_Bach\SPH_Bach.gdb\US_mom_hotspots",
    Conceptualization_of_Spatial_Relationships="FIXED_DISTANCE_BAND",
    Distance_Method="EUCLIDEAN_DISTANCE",
    Standardization="ROW",
    Distance_Band_or_Threshold_Distance=None,
    Self_Potential_Field=None,
    Weights_Matrix_File=None,
    Apply_False_Discovery_Rate__FDR__Correction="NO_FDR",
    number_of_neighbors=None
)

arcpy.stats.HotSpots(
    Input_Feature_Class="county_SPH",
    Input_Field="Dad_Int",
    Output_Feature_Class=r"C:\Users\hanna\OneDrive\Desktop\SPH_Bach\SPH_Bach.gdb\US_dad_hotspots",
    Conceptualization_of_Spatial_Relationships="FIXED_DISTANCE_BAND",
    Distance_Method="EUCLIDEAN_DISTANCE",
    Standardization="ROW",
    Distance_Band_or_Threshold_Distance=None,
    Self_Potential_Field=None,
    Weights_Matrix_File=None,
    Apply_False_Discovery_Rate__FDR__Correction="NO_FDR",
    number_of_neighbors=None
)
