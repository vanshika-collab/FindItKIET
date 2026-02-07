import axios from 'axios';
import fs from 'fs';
import FormData from 'form-data';

export class ImageVerificationService {
    private pythonServiceUrl = 'http://localhost:8001';

    async verifyImage(originalImageUrl: string, claimImagePath: string): Promise<number> {
        try {
            const formData = new FormData();

            // Check if claim image exists locally
            if (fs.existsSync(claimImagePath)) {
                formData.append('claim_image', fs.createReadStream(claimImagePath));
            } else {
                console.error(`Claim image not found at path: ${claimImagePath}`);
                return 0;
            }

            // Append original image URL path
            // Note: The Python service expects 'original_image_url' query param or form field
            // My Python implementation used query param for URL, but let's check.
            // Python: verify_image(claim_image: UploadFile, original_image_url: str)

            const response = await axios.post(
                `${this.pythonServiceUrl}/verify-image`,
                formData,
                {
                    headers: {
                        ...formData.getHeaders(),
                    },
                    params: {
                        original_image_url: originalImageUrl
                    }
                }
            );

            if (response.data && response.data.status === 'success') {
                return response.data.similarity_score;
            }

            return 0;
        } catch (error) {
            console.error('Image verification failed:', error);
            // Return 0 if verification fails (fail safe)
            return 0;
        }
    }
}
