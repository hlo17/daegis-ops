from typing import List
from compressor_arbitrator import SynthesizedOutput, DifferencesTableItem, AdoptedItem, RejectedItem, EvaluationWeights

def arbitrate_openai(compressed_list: List, speed_priority: bool, quality_priority: bool, task_description: str):
    diffs = [DifferencesTableItem(aspect="Core", proposals=[{"ai_name":getattr(c,"ai_name","?"), "summary":"ok"} for c in compressed_list])]
    ew = EvaluationWeights(speed_weight=0.7, quality_weight=0.3, other_weight=0.2, formula_used="dummy")
    return SynthesizedOutput(
        differences_table=diffs,
        adopted_items=[AdoptedItem(ai_name=getattr(compressed_list[0],"ai_name","?"), item="demo", reason="dummy")],
        rejected_items=[],
        synthesized_proposal=f"Dummy synth for {task_description}",
        evaluation_weights=ew
    )
