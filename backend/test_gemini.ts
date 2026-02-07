
import dotenv from 'dotenv';
dotenv.config();
import { GeminiService } from './src/services/GeminiService';

async function test() {
    const service = new GeminiService();
    console.log('Testing Gemini Service...');

    const original = "Lost a black iPhone 14 with a clear case near the library.";
    const claim = "I found a black iPhone with a transparent cover.";

    console.log(`Original: "${original}"`);
    console.log(`Claim: "${claim}"`);

    const score = await service.verifyDescription(original, claim);
    console.log('Verification Score:', score);
}

test();
