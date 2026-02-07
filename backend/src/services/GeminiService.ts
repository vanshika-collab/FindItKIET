import axios from 'axios';

export class GeminiService {
    private apiKey = process.env.GEMINI_API_KEY;
    private baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent';

    async verifyDescription(originalDescription: string, claimDescription: string): Promise<number> {
        if (!this.apiKey) {
            console.warn('GEMINI_API_KEY not configured. Skipping text verification.');
            return 0;
        }

        try {
            const prompt = `
            Compare the following two descriptions of a lost item to determine if they refer to the same item.
            
            Original Item Description: "${originalDescription}"
            Claimant's Description: "${claimDescription}"
            
            Analyze the details (color, brand, distinctive marks, location, etc.).
            Return ONLY a number between 0 and 100 representing the probability that the claimant is describing the actual original item. 
            0 means completely different/wrong, 100 means perfect match with specific details.
            If the claimant's description is vague but not contradictory, give a lower score (e.g., 20-40).
            If it contains specific correct details, give a high score.
            `;

            const response = await axios.post(
                `${this.baseUrl}?key=${this.apiKey}`,
                {
                    contents: [{
                        parts: [{
                            text: prompt
                        }]
                    }]
                },
                {
                    headers: {
                        'Content-Type': 'application/json'
                    }
                }
            );

            if (response.data &&
                response.data.candidates &&
                response.data.candidates.length > 0 &&
                response.data.candidates[0].content &&
                response.data.candidates[0].content.parts &&
                response.data.candidates[0].content.parts.length > 0) {

                const text = response.data.candidates[0].content.parts[0].text;
                const score = parseInt(text.trim());

                return isNaN(score) ? 0 : score;
            }

            return 0;
            return 0;
        } catch (error: any) {
            console.error('Gemini verification failed:', error.response?.data || error.message);
            return 0;
        }
    }
}
