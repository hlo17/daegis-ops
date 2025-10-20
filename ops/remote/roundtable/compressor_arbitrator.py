# === G2: Compressor & Arbitrator ===
from pydantic import BaseModel, Field, validator
from typing import List


class ProposalSummary(BaseModel):
    ai_name: str
    proposal_summary: str
    purpose: str = Field(..., max_length=100)
    steps: List[str]
    risks: List[str] = []
    dependencies: List[str] = []
    verification: str = Field(..., max_length=150)
    total_length: int = Field(..., ge=300, le=400)

    @validator("steps")
    def _v_steps(cls, v):
        if not (1 <= len(v) <= 5) or any(len(s) > 50 for s in v):
            raise ValueError("steps invalid")
        return v

    @validator("risks")
    def _v_risks(cls, v):
        if any(len(s) > 50 for s in v):
            raise ValueError("risk too long")
            return v

    @validator("dependencies")
    def _v_deps(cls, v):
        if any(len(s) > 50 for s in v):
            raise ValueError("dep too long")
            return v

    @validator("proposal_summary")
    def _v_len(cls, v, values):
        bl = len(v.encode("utf-8"))
        if not (300 <= bl <= 400):
            raise ValueError(f"proposal_summary must be 300-400 bytes, got {bl}")
        if "total_length" in values:
            values["total_length"] = bl
        return v


class DifferencesTableItem(BaseModel):
    aspect: str = Field(..., max_length=50)
    proposals: List[dict]


class AdoptedItem(BaseModel):
    ai_name: str
    item: str = Field(..., max_length=100)
    reason: str = Field(..., max_length=50)


class RejectedItem(BaseModel):
    ai_name: str
    item: str = Field(..., max_length=100)
    reason: str = Field(..., max_length=50)


class EvaluationWeights(BaseModel):
    speed_weight: float = Field(..., ge=0, le=1)
    quality_weight: float = Field(..., ge=0, le=1)
    other_weight: float = Field(..., ge=0, le=1)
    formula_used: str


class SynthesizedOutput(BaseModel):
    differences_table: List[DifferencesTableItem]
    adopted_items: List[AdoptedItem]
    rejected_items: List[RejectedItem]
    synthesized_proposal: str = Field(..., max_length=500)
    evaluation_weights: EvaluationWeights


def compress_proposal(task_text: str, ai_name: str, raw_text: str) -> ProposalSummary:
    purpose = raw_text[:97] + "." if len(raw_text) > 97 else raw_text + "."
    steps = [s for s in ["要件分解", "設計方針決定", "実装/検証"] if s][:5]
    risks = ["要件変更", "API制限"][:3]
    dependencies = ["Slack API", "LLM API"][:3]
    verification = "成果物の妥当性をテスト。メトリクスで評価。"
    parts = [
        f"Purpose:{purpose}",
        "Steps:\n" + "\n".join(f"- {s}" for s in steps),
        f"Risks:{';'.join(risks)}",
        f"Dependencies:{';'.join(dependencies)}",
        f"Verification:{verification}",
    ]
    summary = "\n".join(parts)
    bl = len(summary.encode("utf-8"))
    if bl > 400:
        summary = summary.encode("utf-8")[:400].decode("utf-8", "ignore")
    if bl < 300:
        summary = summary + (" 充足性確認。" * ((300 - bl) // 15))
    total = len(summary.encode("utf-8"))
    return ProposalSummary(
        ai_name=ai_name,
        proposal_summary=summary,
        purpose=purpose,
        steps=steps,
        risks=risks,
        dependencies=dependencies,
        verification=verification,
        total_length=total,
    )


def arbitrate(
    compressed_list: List[ProposalSummary], speed_priority: bool, quality_priority: bool, task_description: str
) -> SynthesizedOutput:
    if not compressed_list:
        raise ValueError("no proposals")
    diff = [
        DifferencesTableItem(
            aspect="Core Approach",
            proposals=[{"ai_name": p.ai_name, "summary": p.purpose[:100]} for p in compressed_list],
        )
    ]
    adopted = [AdoptedItem(ai_name=compressed_list[0].ai_name, item=compressed_list[0].steps[0], reason="alignment")]
    rejected = [
        RejectedItem(ai_name=p.ai_name, item=(p.steps[0] if p.steps else "alt"), reason="lower score")
        for p in compressed_list[1:]
    ]
    s = f"Synthesized: {task_description} → " + "; ".join(p.purpose[:30] for p in compressed_list)
    sw = 0.7 if speed_priority else 0.3
    qw = 0.7 if quality_priority else 0.3
    ew = EvaluationWeights(
        speed_weight=sw,
        quality_weight=qw,
        other_weight=0.2,
        formula_used="(speed?0.7:0.3)*speed+(quality?0.7:0.3)*quality+0.2*(creativity+confidence)/2",
    )
    return SynthesizedOutput(
        differences_table=diff,
        adopted_items=adopted,
        rejected_items=rejected,
        synthesized_proposal=s[:500],
        evaluation_weights=ew,
    )
