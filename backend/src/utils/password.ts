import bcrypt from 'bcryptjs';

const SALT_ROUNDS = 12;

// Hash password
export const hashPassword = async (password: string): Promise<string> => {
    return bcrypt.hash(password, SALT_ROUNDS);
};

// Verify password
export const verifyPassword = async (
    password: string,
    hash: string
): Promise<boolean> => {
    return bcrypt.compare(password, hash);
};
