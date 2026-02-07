export const CONSTANTS = {
    // Item categories
    ITEM_CATEGORIES: [
        'ELECTRONICS',
        'ACCESSORIES',
        'BOOKS',
        'CLOTHING',
        'DOCUMENTS',
        'KEYS',
        'BAGS',
        'OTHER',
    ] as const,

    // Claim proof types
    PROOF_TYPES: [
        'DESCRIPTION',
        'SERIAL_NUMBER',
        'UNIQUE_FEATURE',
        'PURCHASE_RECEIPT',
        'PHOTO',
        'OTHER',
    ] as const,

    // Pagination defaults
    DEFAULT_PAGE_SIZE: 20,
    MAX_PAGE_SIZE: 100,

    // File upload
    MAX_IMAGES_PER_ITEM: 5,
    ALLOWED_IMAGE_EXTENSIONS: ['.jpg', '.jpeg', '.png', '.webp'] as const,

    // Rate limiting
    AUTH_RATE_LIMIT: {
        windowMs: 15 * 60 * 1000, // 15 minutes
        max: 5, // 5 attempts
    },

    API_RATE_LIMIT: {
        windowMs: 15 * 60 * 1000, // 15 minutes
        max: 100, // 100 requests
    },

    // Audit actions
    AUDIT_ACTIONS: {
        CLAIM_APPROVED: 'CLAIM_APPROVED',
        CLAIM_REJECTED: 'CLAIM_REJECTED',
        ITEM_MODERATED: 'ITEM_MODERATED',
        ITEM_DELETED: 'ITEM_DELETED',
        ITEM_HANDOVER: 'ITEM_HANDOVER',
    } as const,
} as const;

export type ItemCategory = typeof CONSTANTS.ITEM_CATEGORIES[number];
export type ProofType = typeof CONSTANTS.PROOF_TYPES[number];
export type AuditAction = typeof CONSTANTS.AUDIT_ACTIONS[keyof typeof CONSTANTS.AUDIT_ACTIONS];
