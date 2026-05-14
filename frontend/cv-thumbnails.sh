#!/bin/bash
set -e
cd ~/firststep/frontend
echo "🎨 Fixing CV template thumbnails..."

python3 << 'PYEOF'
with open("src/components/pages/CVBuilder.tsx","r") as f: c = f.read()

# Replace dummy data with generic realistic person
old = "name:'Sipokazi Momoza'"
new = "name:'Thabo Nkosi'"
c = c.replace(old, new)

c = c.replace("title:'Sales Assistant'", "title:'Customer Service Agent'")
c = c.replace("email:'sipokazi@gmail.com'", "email:'thabo.nkosi@email.com'")
c = c.replace("phone:'073 380 8914'", "phone:'071 234 5678'")
c = c.replace("location:'Cape Town, 7784'", "location:'Johannesburg, Gauteng'")
c = c.replace(
    "summary:'A hardworking professional with experience in retail and customer service. I take pride in maintaining high standards and contributing positively to my team.'",
    "summary:'Dedicated professional with strong communication and customer service skills. Quick learner who takes pride in delivering quality work and contributing positively to every team.'"
)
c = c.replace("languages:'English, IsiXhosa, Zulu'", "languages:'English, Zulu, Sotho'")
c = c.replace("school:'Ngangelizwe High School'", "school:'Soweto Secondary School'")
c = c.replace("qualification:'Grade 11 / Matric'", "qualification:'National Senior Certificate'")
c = c.replace("year:'2009'", "year:'2021'")

# Replace skills
c = c.replace(
    "skills:['Customer service','Teamwork','Cash handling','Stock management','Communication','Problem solving']",
    "skills:['Customer service','Communication','MS Office','Teamwork','Problem solving','Cash handling','Data entry','Telephone etiquette']"
)

# Replace experience
old_exp = """  exp:[{
    title:'Shop Assistant', org:'Shoprite', start:'Jan 2020', end:'Present',
    bullets:'Assisted customers with product queries and purchases.\\nMaintained stock levels and product rotation.\\nOperated cash register and POS systems.',
    volunteer:false
  }],"""
new_exp = """  exp:[
    {title:'Customer Service Rep', org:'Vodacom Call Centre', start:'Mar 2022', end:'Present',
    bullets:'Handled 80+ customer calls daily resolving billing and technical queries.\\nConsistently achieved 95% customer satisfaction score monthly.\\nTrained 3 new team members on CRM and call procedures.',
    volunteer:false},
    {title:'Sales Assistant', org:'Edgars Retail', start:'Jan 2021', end:'Feb 2022',
    bullets:'Assisted customers with purchases and product queries.\\nProcessed cash and card payments accurately.\\nMaintained store presentation and stock levels.',
    volunteer:false},
  ],"""
c = c.replace(old_exp, new_exp)

# Replace refs
old_refs = "  refs:[{ name:'Mr Mangena', relation:'Sales Manager', contact:'0213601380' },{ name:'Mrs Dlamini', relation:'HR', contact:'0213601380' }],"
new_refs = "  refs:[{ name:'Ms Lindiwe Dube', relation:'Team Leader, Vodacom', contact:'011 000 1234' },{ name:'Mr Sipho Khumalo', relation:'Store Manager, Edgars', contact:'011 000 5678' }],"
c = c.replace(old_refs, new_refs)

# Make thumbnails taller and better scaled
c = c.replace(
    "style={{ height:200 }}",
    "style={{ height:230 }}"
)
c = c.replace(
    "style={{ transform:'scale(0.285)', transformOrigin:'top left', width:'351%', pointerEvents:'none', userSelect:'none' }}",
    "style={{ transform:'scale(0.28)', transformOrigin:'top left', width:'357%', pointerEvents:'none', userSelect:'none' }}"
)
# In case it still has old scale
c = c.replace(
    "style={{ transform:'scale(0.27)', transformOrigin:'top left', width:'370%', pointerEvents:'none', userSelect:'none' }}",
    "style={{ transform:'scale(0.28)', transformOrigin:'top left', width:'357%', pointerEvents:'none', userSelect:'none' }}"
)

with open("src/components/pages/CVBuilder.tsx","w") as f: f.write(c)
print("done")
PYEOF

echo "✅ Done!"
