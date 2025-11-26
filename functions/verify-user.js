/**
 * Script to manually verify test user emails in Firebase Auth
 * Usage: node verify-user.js <email>
 * Example: node verify-user.js partner2@test.com
 *
 * Note: This script uses Firebase Admin SDK with application default credentials
 * Make sure you're logged in with: firebase login
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin with default credentials
// This works when you're logged in via Firebase CLI
admin.initializeApp({
  projectId: 'deb-shiftsync-7984c'
});

async function verifyUserEmail(email) {
  try {
    // Get user by email
    const user = await admin.auth().getUserByEmail(email);

    console.log(`\nFound user: ${user.email}`);
    console.log(`Current emailVerified status: ${user.emailVerified}`);

    if (user.emailVerified) {
      console.log(`✅ User ${email} is already verified!`);
      process.exit(0);
    }

    // Update user to set emailVerified to true
    await admin.auth().updateUser(user.uid, {
      emailVerified: true
    });

    console.log(`✅ Successfully verified ${email}!`);
    console.log(`User UID: ${user.uid}`);

    // Verify the change
    const updatedUser = await admin.auth().getUserByEmail(email);
    console.log(`New emailVerified status: ${updatedUser.emailVerified}`);

    process.exit(0);
  } catch (error) {
    console.error(`❌ Error verifying user:`, error.message);
    process.exit(1);
  }
}

// Get email from command line argument
const email = process.argv[2];

if (!email) {
  console.error('❌ Please provide an email address');
  console.log('Usage: node verify-user.js <email>');
  console.log('Example: node verify-user.js partner2@test.com');
  process.exit(1);
}

// Run the verification
verifyUserEmail(email);
