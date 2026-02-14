import { onDocumentCreated, onDocumentUpdated, FirestoreEvent, Change, QueryDocumentSnapshot } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();

/**
 * Enterprise Auditing Logic
 * This function injects audit fields into Firestore documents.
 * It relies on a '_userId' field passed by the client which is confirmed
 * by security rules (client can only pass their own UID).
 */

const handleAudit = async (
    event: FirestoreEvent<QueryDocumentSnapshot | undefined> | FirestoreEvent<Change<QueryDocumentSnapshot> | undefined>,
    operation: 'create' | 'update'
) => {
    const snap = operation === 'create'
        ? (event.data as QueryDocumentSnapshot)
        : (event.data as Change<QueryDocumentSnapshot>).after;

    if (!snap || !snap.exists) return;

    const data = snap.data();
    const userId = data._userId;

    // If no _userId is provided, we can't audit correctly.
    // In a strict enterprise system, you might want to throw or log an error.
    if (!userId) {
        console.warn(`No _userId found in ${event.document} during ${operation}. Audit fields may be incomplete.`);
        return;
    }

    const auditFields: any = {
        updatedBy: userId,
        updatedOn: admin.firestore.FieldValue.serverTimestamp(),
        // Always remove the temporary _userId field
        _userId: admin.firestore.FieldValue.delete(),
    };

    if (operation === 'create') {
        auditFields.createdBy = userId;
        auditFields.createdOn = admin.firestore.FieldValue.serverTimestamp();
        auditFields.isDeleted = false;
    }

    // Handle Soft Delete
    if (operation === 'update' && data.isDeleted === true) {
        const beforeData = (event.data as Change<QueryDocumentSnapshot>).before.data();
        if (beforeData.isDeleted !== true) {
            auditFields.deletedBy = userId;
            auditFields.deletedOn = admin.firestore.FieldValue.serverTimestamp();
        }
    }

    return snap.ref.update(auditFields);
};

// Generic trigger for all collections (or specific ones)
// Note: In production, you'd typically apply this to specific collections
// using a wildcard pattern like "{collection}/{id}"
export const auditTrigger = onDocumentUpdated("{collection}/{docId}", async (event) => {
    return handleAudit(event, 'update');
});

export const auditCreateTrigger = onDocumentCreated("{collection}/{docId}", async (event) => {
    return handleAudit(event, 'create');
});
