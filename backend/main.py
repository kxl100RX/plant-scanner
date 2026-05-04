import os

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

load_dotenv()

app = FastAPI(title="Plant Scanner API")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

PLANTNET_KEY = os.getenv("PLANTNET_API_KEY")


def _care_by_family(family: str) -> dict:
    f = family.lower()
    if any(x in f for x in ["cactaceae", "crassulaceae", "agavaceae", "aizoaceae", "asphodelaceae"]):
        return {
            "water": "Riego escaso. Dejar secar completamente el sustrato entre riegos.",
            "light": "Pleno sol o luz muy brillante.",
            "soil": "Sustrato arenoso y bien drenado.",
            "temperature": "Tolera calor intenso. Sensible a heladas.",
            "humidity": "Ambiente seco, baja humedad.",
            "fertilizer": "Fertilizante para cactus una vez en primavera.",
        }
    if any(x in f for x in ["orchidaceae"]):
        return {
            "water": "Riego moderado. Dejar secar ligeramente entre riegos.",
            "light": "Luz indirecta brillante.",
            "soil": "Sustrato especial para orquídeas con corteza de pino.",
            "temperature": "18–25 °C. Evitar corrientes de aire.",
            "humidity": "Alta humedad (50–70%).",
            "fertilizer": "Fertilizante para orquídeas cada 2 semanas en crecimiento.",
        }
    if any(x in f for x in ["polypodiaceae", "pteridaceae", "aspleniaceae", "dennstaedtiaceae"]):
        return {
            "water": "Riego frecuente; mantener el sustrato húmedo sin encharcar.",
            "light": "Sombra o luz indirecta.",
            "soil": "Sustrato rico en materia orgánica y bien drenado.",
            "temperature": "15–22 °C.",
            "humidity": "Alta. Nebulizar regularmente.",
            "fertilizer": "Fertilizante equilibrado diluido cada mes en primavera-verano.",
        }
    if any(x in f for x in ["arecaceae"]):
        return {
            "water": "Riego regular; dejar secar ligeramente entre riegos.",
            "light": "Sol pleno a media sombra según la especie.",
            "soil": "Sustrato bien drenado y nutritivo.",
            "temperature": "18–30 °C.",
            "humidity": "Moderada a alta.",
            "fertilizer": "Fertilizante para palmeras rico en potasio, 3 veces al año.",
        }
    if any(x in f for x in ["rosaceae", "lamiaceae", "asteraceae"]):
        return {
            "water": "Riego regular, especialmente en floración.",
            "light": "Sol directo al menos 6 horas al día.",
            "soil": "Sustrato fértil y bien drenado.",
            "temperature": "10–25 °C.",
            "humidity": "Moderada.",
            "fertilizer": "Fertilizante rico en fósforo para favorecer la floración.",
        }
    return {
        "water": "Riego moderado; revisar el sustrato antes de regar.",
        "light": "Luz brillante indirecta o sol moderado.",
        "soil": "Sustrato universal bien drenado.",
        "temperature": "15–25 °C.",
        "humidity": "Humedad moderada.",
        "fertilizer": "Fertilizante equilibrado una vez al mes en primavera-verano.",
    }


@app.post("/identify")
async def identify_plant(file: UploadFile = File(...)):
    image_data = await file.read()
    if len(image_data) > 5 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="La imagen no debe superar 5 MB")

    content_type = file.content_type or "image/jpeg"
    if not content_type.startswith("image/"):
        ext = (file.filename or "").split(".")[-1].lower()
        content_type = {"jpg": "image/jpeg", "jpeg": "image/jpeg", "png": "image/png", "webp": "image/webp"}.get(ext, "image/jpeg")

    async with httpx.AsyncClient(timeout=20.0) as c:
        r = await c.post(
            "https://my-api.plantnet.org/v2/identify/all",
            params={"api-key": PLANTNET_KEY, "include-related-images": "false", "lang": "es"},
            files={"images": ("image.jpg", image_data, content_type)},
        )

    if r.status_code == 404:
        return {"error": "No se detectó ninguna planta en la imagen"}
    if r.status_code != 200:
        raise HTTPException(status_code=500, detail=f"Error PlantNet: {r.status_code}")

    results = r.json().get("results", [])
    if not results:
        return {"error": "No se detectó ninguna planta en la imagen"}

    best = results[0]
    score = best.get("score", 0)
    confidence = "high" if score > 0.7 else "medium" if score > 0.4 else "low"

    species = best.get("species", {})
    scientific_name = species.get("scientificNameWithoutAuthor", "Desconocida")
    common_names = species.get("commonNames") or []
    common_name = common_names[0] if common_names else scientific_name
    family = species.get("family", {}).get("scientificNameWithoutAuthor", "")

    wiki = await _wikipedia(scientific_name)
    description = (wiki or {}).get("summary", "") or f"{common_name} es una planta de la familia {family}."
    if len(description) > 600:
        description = description[:597] + "..."

    care = _care_by_family(family)

    return {
        "name": common_name,
        "scientific_name": scientific_name,
        "confidence": confidence,
        "description": description,
        "care": care,
        "toxicity": "Consultá a un especialista para información específica sobre toxicidad de esta especie.",
        "tips": [
            f"Pertenece a la familia {family}." if family else "Identificada con PlantNet.",
            "Revisá las hojas regularmente para detectar plagas o enfermedades.",
            "Investigá los cuidados específicos de esta especie para obtener mejores resultados.",
        ],
        "wikipedia": wiki,
    }


async def _wikipedia(scientific_name: str):
    name = scientific_name.replace(" ", "_")
    async with httpx.AsyncClient(timeout=5.0) as c:
        try:
            r = await c.get(
                f"https://en.wikipedia.org/api/rest_v1/page/summary/{name}",
                headers={"User-Agent": "PlantScannerApp/1.0"},
            )
            if r.status_code == 200:
                d = r.json()
                return {
                    "summary": d.get("extract", ""),
                    "image": d.get("originalimage", {}).get("source", "") if d.get("originalimage") else "",
                    "url": d.get("content_urls", {}).get("mobile", {}).get("page", ""),
                }
        except Exception:
            pass
    return None


@app.get("/health")
async def health():
    return {"status": "ok"}


_here = os.path.dirname(__file__)
web_dir = os.path.join(_here, "static")  # Production (Render.com)
if not os.path.exists(web_dir):
    web_dir = os.path.join(_here, "..", "mobile", "build", "web")  # Local dev
if os.path.exists(web_dir):
    app.mount("/", StaticFiles(directory=web_dir, html=True), name="static")
