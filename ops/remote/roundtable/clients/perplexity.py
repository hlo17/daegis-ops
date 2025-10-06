import random
async def vote(task_text: str):
    s = {k: random.randint(6,10) for k in ["speed","quality","creativity","confidence"]}
    return {"ai_name":"Perplexity","scores":s,"why":"mock(no API)","needed_inputs":[],"constraints":[]}
