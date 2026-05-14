#!/bin/bash
cd ~/firststep/frontend
python3 << 'PYEOF'
with open("src/components/pages/CVBuilder.tsx","r") as f: c = f.read()

# Find the broken pattern and wrap in a fragment
old = """              {step===0&&(
                <div>"""

new = """              {step===0&&(
                <>
                <div>"""

c = c.replace(old, new, 1)

# Find where step 0 ends (before step 1 comment) and close the fragment
old2 = """                  </div>
                </div>
              )}

              {step===1&&("""

new2 = """                  </div>
                </div>
                </>
              )}

              {step===1&&("""

c = c.replace(old2, new2, 1)

with open("src/components/pages/CVBuilder.tsx","w") as f: f.write(c)
print("fixed")
PYEOF
