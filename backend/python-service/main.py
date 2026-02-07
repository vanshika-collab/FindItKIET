from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import torch
import torch.nn as nn
from torchvision import models, transforms
from PIL import Image
import io
import requests

app = FastAPI(title="FindIt Image Verification Service")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load pre-trained model (ResNet50)
# We remove the final classification layer to get feature embeddings
try:
    print("Loading ResNet50 model...")
    weights = models.ResNet50_Weights.DEFAULT
    model = models.resnet50(weights=weights)
    # Remove the last fully connected layer to get features instead of classes
    model = nn.Sequential(*list(model.children())[:-1])
    model.eval()
    print("Model loaded successfully!")
except Exception as e:
    print(f"Error loading model: {e}")
    # Fallback to simple matching if model fails (should not happen in prod)
    model = None

# Image transformation pipeline
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

def get_image_embedding(image_bytes):
    """Extract feature vector from image bytes"""
    if model is None:
        return torch.zeros(2048)
        
    try:
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        tensor = transform(image).unsqueeze(0)  # Add batch dimension
        
        with torch.no_grad():
            features = model(tensor)
            
        return features.squeeze().flatten()
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid image format: {str(e)}")

@app.get("/health")
def health_check():
    return {"status": "ok", "model_loaded": model is not None}

@app.post("/verify-image")
async def verify_image(
    claim_image: UploadFile = File(...),
    original_image_url: str = None
):
    """
    Compare uploaded claim image with original item image URL.
    Returns a similarity score (0-100).
    """
    if not original_image_url:
        raise HTTPException(status_code=400, detail="original_image_url is required")

    try:
        # 1. Process Claim Image
        claim_bytes = await claim_image.read()
        claim_embedding = get_image_embedding(claim_bytes)

        # 2. Fetch and Process Original Image
        try:
            # Handle local file paths if testing locally, otherwise assume HTTP
            if original_image_url.startswith("http"):
                response = requests.get(original_image_url, timeout=10)
                response.raise_for_status()
                original_bytes = response.content
            else:
                # Fallback for local testing if path is provided
                with open(original_image_url, "rb") as f:
                    original_bytes = f.read()
                    
            original_embedding = get_image_embedding(original_bytes)
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Failed to fetch original image: {str(e)}")

        # 3. Compute Cosine Similarity
        cosine_sim = nn.functional.cosine_similarity(
            claim_embedding.unsqueeze(0), 
            original_embedding.unsqueeze(0)
        )
        
        # Convert to percentage (0.0 to 1.0 -> 0% to 100%)
        # ResNet features are usually non-negative, but cosine can be -1 to 1.
        # We clamp to 0-1 range for simplicity in UI.
        similarity_score = max(0.0, cosine_sim.item()) * 100

        return {
            "status": "success",
            "similarity_score": round(similarity_score, 2),
            "match": similarity_score > 70.0 # Threshold for "match"
        }

    except HTTPException as he:
        raise he
    except Exception as e:
        print(f"Verification error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8001, reload=True)
