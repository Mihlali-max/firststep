.PHONY: dev backend frontend setup

backend:
	cd backend && uvicorn app.main:app --reload --port 8000

frontend:
	cd frontend && npm run dev

dev:
	docker compose up --build

setup:
	cp backend/.env.example backend/.env
	cp frontend/.env.example frontend/.env
	cd frontend && npm install
	cd backend && pip install -r requirements.txt
	@echo "✅ Done. Edit backend/.env with your secrets then run: make backend"
