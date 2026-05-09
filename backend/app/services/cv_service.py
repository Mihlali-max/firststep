from app.models.user import CV, User

def calculate_completion(cv: CV) -> int:
    score = 0
    if cv.personal_info: score += 25
    if cv.education: score += 20
    if cv.skills: score += 20
    if cv.experience: score += 20
    if cv.references: score += 15
    return score
