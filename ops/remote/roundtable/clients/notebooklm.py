import random
def _mock(task_text: str):
    s = {k: random.randint(6,10) for k in ["speed","quality","creativity","confidence"]}
    return {"ai_name":"NotebookLM","scores":s,"why":"mock(no public API)","needed_inputs":[],"constraints":[]}
async def vote(task_text: str): return _mock(task_text)
